#!/usr/bin/perl

# written by andrewt@cse.unsw.edu.au August 2015
# as a starting point for COMP2041/9041 assignment 
# http://cgi.cse.unsw.edu.au/~cs2041/assignment/shpy

# shell keywords which need special handling
# currently not handling "!"
# from https://www.gnu.org/software/bash/manual/html_node/Reserved-Word-Index.html#Reserved-Word-Index
@keywords = ("[[.*]]","{.*}","case","do","done","elif","else","esac",
            "fi","for","function","if","in","select",
            "then","time","until","while");

%import = ();
@shell = <>;
@python = ();
$loop = 0; # flag to indicate whether currently in loop
$if = 0; # if flag to indicate if in if statement
$var_re = "[A-Za-z_][0-9A-Za-z_]*"; # shell variable regex

# read
if ($shell[0] =~ /^#!/) {
    die if !($shell[0] =~ /^#!\/bin\/sh/); # if not shell, die
    shift @shell; # remove shebang
}
foreach $line (@shell) {
    chomp $line;
    $comment = "";
    $else = 0; # flag to indicate if line should not be indented

    if ($line =~ /^\s*#(.*)/){ # if just a comment
        $line = "";
        $comment = $1;
    } elsif ($line =~ /(.*)#(.*)/){
        $line = $1;
        chomp $line;
        $comment = $2;
    }

    if ($line =~ /($var_re)=(\S.*)/){ # variable assignment
        # $var = $1;
        # $assigned = $2;
        # if ($assigned =~ /^\d+$/){ # number
        #     $line = "$var = $assigned";
        # } else { # string
        #     $line = "$var = '$assigned'";
        # }
        $line = "$1 = ".listConvert($2);
    } elsif ($line =~ /^\s*echo\s+(.*)/){ # echo
        $line = "print ".listConvert($1);
        # $line = "print ".$line;
    } elsif ($line =~ /^\s*cd (.*)/){ # cd
        $import{os} = 1;
        $line = "os.chdir('$1')";
    } elsif ($line =~ /^\s*exit\s+([\d]*)/){ # exit
        $import{sys} = 1;
        $line = "sys.exit($1)";
    } elsif ($line =~ /^\s*read\s+(.*)/){ # read
        $import{sys} = 1;
        $line = "$1 = sys.stdin.readline().rstrip()";
    } elsif ($line =~ /^\s*for\s+($var_re)\s+in\s+(.*)/) { # for
        $list = listConvert($2);
        $line = "for $1 in $list:";
    } elsif ($line =~ /^\s*while\s+(.*)/){ # while
        $line = "while ".translate($1).":";
    } elsif ($line =~ /^\s*do\b/) { # do
        $loop++;
        $line = "";
    } elsif ($line =~ /^\s*done\b/) { # done
        die if $loop == 0; # die if done but not in loop
        $loop--;
        $line = "";
    } elsif ($line =~ /^\s*if\s+(.*)/){ # if
        $line = "if ".translate($1).":";
    } elsif ($line =~ /^\s*then\b/){ # then
        $if++;
        $line = "";
    } elsif ($line =~ /^\s*elif\s+(.*)/){ # elif
        die if $if == 0; # die if elif but not in if statement
        $if--;
        $line = "elif ".translate($1).":";
    } elsif ($line =~ /^\s*else\b/){ # else
        die if $if == 0; # die if else but not in if statement
        $else++;
        $line = "else:";
    } elsif ($line =~ /^\s*fi\b/){ # fi
        die if $if == 0; # die if fi but not in if statement
        $if--;
        $line = "";
    } elsif ($line and not keyword($line)){
        # print "import subprocess\n" and $imported{subprocess} = 1 if !exists $imported{subprocess};
        $import{subprocess} = 1;
        @words = split(/\s/,$line);
        @new = map {"'$_'"} @words;
        $line = join(",",@new);
        $line = "subprocess.call([$line])";
    } elsif ($line) {
        # Lines we can't translate are turned into comments
        $line = "# $line";
    }
    if ($comment and $line){
        $line = "$line #$comment";
    } elsif ($comment and not $line){
        $line = "#$comment";
    }
    next if not $line; # skip blank lines
    $line .= "\n";
    # $line = "    $line" if $loop; # indent if in for loop
    # $line = "    $line" if $if and not $else; # indent if in if statement
    $line = "    "x($loop+$if-$else).$line; # indent by required amount
    push @python,$line;
}

# print
print "#!/usr/bin/python2.7 -u\n";
print "import $_\n" foreach (sort keys %import);
# foreach $line (@python){
#     # print/process $line[$i]
#     print "$line\n";
# }
print @python;

sub keyword {
    my $is_keyword = 0; # false
    my ($in) = @_; # first argument
    # compare to array of known keywords
    foreach $word (@keywords){
        $is_keyword = 1 if ($in =~ /^\s*$word/); # need to deal with substrings?
    }
    return $is_keyword;
}

# Converts a list from Shell to Python. e.g. ($var 90 moo) becomes (var,90,'moo')
sub listConvert {
    my ($list) = @_;
    my @elems = $list =~ /('.*?'|\S+)/g;
    foreach my $i (0..$#elems){
        if ($elems[$i] =~ /^\$($var_re)$/){ # if variable
            $elems[$i] = $1;
        # } elsif ($elems[$i] =~ /\${($var_re)}/){ # if delimited variable
        #     $elems[$i] =~ s/\${/'+/g;
        #     $elems[$i] =~ s/}/+'/g;
        #     $elems[$i] = "'$elems[$i]'";
        } elsif ($elems[$i] =~ /^\$(\d+)$/){ # if special variable
            $import{sys} = 1;
            $elems[$i] = "sys.argv[$1]";
        } elsif ($elems[$i] =~ /^[\d]+$/){ # if number
            next;
        } elsif ($elems[$i] =~ /[?*\[\]]/){ # file expansion
            $import{glob} = 1;
            $elems[$i] = "sorted(glob.glob(\"$elems[$i]\"))";
        } elsif (not $elems[$i] =~ /^'.*'$/) { # if string
            $elems[$i] = "'$elems[$i]'";
        }
    }
    $list = join(", ",@elems);
    return $list;
}

sub translate {
    my ($line) = @_;
    # translate line
    return $line;
}
