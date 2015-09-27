#!/usr/bin/perl

# written by Sean Batongbacal, September 2015
# for COMP2041/9041 assignment 
# http://cgi.cse.unsw.edu.au/~cs2041/assignment/shpy

# shell keywords which need special handling
# currently not handling "!"
# from https://www.gnu.org/software/bash/manual/html_node/Reserved-Word-Index.html#Reserved-Word-Index
@keywords = ("case","do","done","elif","else","esac",
            "fi","for","function","if","in","select",
            "then","time","until","while");

@no_translate = ("&&","||",";",);
$cant_translate = 0;

%int_test = ("-eq"=>"==",
             "-ge"=>">=",
             "-gt"=>">",
             "-le"=>"<=",
             "-lt"=>"<",
             "-ne"=>"!=");

%import = ();
@shell = <>;
@python = ();
$loop = 0; # flag to indicate whether currently in loop
$if = 0; # if flag to indicate if in if statement
$var_re = "[A-Za-z_][0-9A-Za-z_]*"; # shell variable regex

# read
if ($shell[0] =~ /^#!/) {
    # die if !($shell[0] =~ /^#!\/bin\/sh/ or $shell[0] =~ /^#!\/bin\/bash/); # if not shell, die
    die if !($shell[0] =~ /sh/); # if not shell, die
    shift @shell; # remove shebang
}
foreach $line (@shell) {
    chomp $line;
    $comment = "";
    $else = 0; # flag to indicate if line should not be indented
    $cant_translate = 0;

    if ($line =~ /^\s*#(.*)/){ # if just a comment
        $line = "";
        $comment = $1;
    } elsif ($line =~ /(.*?)\s+#(.*)/){
        $line = $1;
        # chomp $line;
        $comment = $2;
    }
    chomp $line;
    if ($line =~ /^\s*for\s+($var_re)\s+in\s+(.*)/) { # for
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
        $line = translate($line);
    } elsif ($line) {
        # Lines we can't translate are turned into comments
        # $line =~ /\s*(.*)\s*/;
        # $line = "# $1";
        $cant_translate = 1;
    }
    if ($cant_translate){
        $line =~ /\s*(.*)\s*/;
        $line = "# $1";
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

sub translate {
    my ($line) = @_;
    chomp $line;
    # $cant_translate = 0;
    # my @words = ();
    # my @new = ();
    if ($line =~ /($var_re)=(\S.*?)\s*$/){ # variable assignment
        $line = "$1 = ".listConvert($2);
    } elsif ($line =~ /^\s*echo\s+(.*?)\s*$/){ # echo
        $line = $1;
        if ($line =~ /^\s*\-n\s+(.*)/){
            # $line = "print ".listConvert($1).",";
            $import{sys} = 1;
            $line = "sys.stdout.write(".echoConvert($1).")";
        } else {
            $line = "print ".echoConvert($line);
        }
        # $line = "print ".$line;
    } elsif ($line =~ /^\s*cd\s+(.*?)\s*$/){ # cd
        $import{os} = 1;
        $line = "os.chdir(".echoConvert($1).")";
    } elsif ($line =~ /^\s*chmod\s+(\d{3})\s+(.*?)\s*$/){ # chmod
        $import{os} = 1;
        $line = "os.chmod(".echoConvert($2).",0$1)";
    } elsif ($line =~ /^\s*ls\s*$/){ # ls
        $import{glob} = 1;
        $line = "print '\\n'.join(sorted(glob.glob('*')))";
    # } elsif ($line =~ /^\s*ls\s+(.*?)\s*$/){ # ls with path
    #     $import{glob} = 1;
    #     # $import{os} = 1;
    #     $line = $1;
    #     if (not $line =~ /^'.*'$/) {
    #         $line = "'$line'";
    #     }
    #     # $line = "print ' '.join(sorted(glob.glob($line)))"; # lists path too
    #     $line = "print ' '.join([os.path.basename(x) for x in sorted(glob.glob($line))])"; # without path
    } elsif ($line =~ /^\s*mv\s+(.*?)\s+(.*?)\s*$/){ # mv
        $import{shutil} = 1;
        # $line = "os.chdir(".echoConvert($1).")";
        $line = "shutil.move(".echoConvert($1).",".echoConvert($2).")";
    } elsif ($line =~ /^\s*rm\s+(.*?)\s*$/){ # rm
        $import{os} = 1;
        $line = "os.remove(".echoConvert($1).")";
    } elsif ($line =~ /^\s*exit\s+(.*?)\s*$/){ # exit
        $import{sys} = 1;
        $line = "sys.exit(".echoConvert($1).")";
    } elsif ($line =~ /^\s*read\s+(.*?)\s*$/){ # read
        $import{sys} = 1;
        $line = "$1 = sys.stdin.readline().rstrip()";
    } elsif ($line =~ /^\s*expr\s+(.*?)\s*$/){ # expr
        $line = "print ".exprConvert($1);
    } elsif ($line =~ /^\s*test\s*$/){ # test
        $line = "False";
    } elsif ($line =~ /^\s*test\s+(.*?)\s*$/){ # test
        $line = testConvert($1);
    } elsif ($line and not keyword($line)){
        # print "import subprocess\n" and $imported{subprocess} = 1 if !exists $imported{subprocess};
        $import{subprocess} = 1;
        # @words = split(/\s+/,$line);
        # @new = map {"'$_'"} @words;
        # $line = join(",",@new);
        if ($line =~ /^([^\']+?)\s+\"?\$@\"?\s+([^\']+?)\s*$/){ # if $@ in middle
            $line = "[".listConvert($1)."] + sys.argv[1:] + [".listConvert($2)."]";
        } elsif ($line =~ /^(.*)\s+"?\$@"?\s*$/){ # if $@ is last
            $line = "[".listConvert($1)."] + sys.argv[1:]";
        } elsif ($line =~ /^\s*"?\$@"?\s+(.*)$/){ # if $@ is first
            $line = "sys.argv[1:] + [".listConvert($1)."]";
        } else {
            $line = "[".listConvert($line)."]";
        }
        $line = "subprocess.call($line)";
    } elsif ($line){
        # Lines we can't translate are turned into comments
        # $line =~ /\s*(.*)\s*/;
        # $line = "# $1";
        $cant_translate = 1;
    } 
    return $line;
}

# determines whether or not $line can be translated
sub keyword {
    my $is_keyword = 0; # false
    my ($line) = @_; # first argument
    my $thing;
    # compare to array of known keywords
    foreach $thing (@keywords){
        # $is_keyword = 1 if ($line =~ /^\s*\Q$thing\E\s+/);
        if ($line =~ /^\s*$thing\s+/){
            $is_keyword = 1;
        }
    }
    foreach $thing (@no_translate){ 
        # $is_keyword = 1 if ($line =~ /^[^#'"]*\Q$thing\E[^'"]*$/);
        if ($line =~ /^[^#'"]*\Q$thing\E[^'"]*$/){
            $is_keyword = 1;
        }
    }
    $is_keyword = 1 if ($line =~ /^[^#'"]*\[\[.*\]\][^'"]*$/); # [[ ]]
    $is_keyword = 1 if ($line =~ /^[^#'"]*{.*}[^'"]*$/); # { }
    # $is_keyword = 1 if ($line =~ /^[^#'"]*\`.*\`[^'"]*$/); # ` `
    # $is_keyword = 1 if ($line =~ /^[^#'"]*\".*\"[^'"]*$/); # " "
    # $is_keyword = 1 if ($line =~ /^[^#'"]*[^\(]*\)[^'"]*$/); # )
    # "[[.*]]","{.*}","`.*`"
    # "\[\[.*\]\]","{.*}","\`.*\`","[^\(]*\)","\".*\""
    if ((not $line =~ /^[^#'"]*expr[^'"]*$/) and (not $line =~ /^[^#'"]*test[^'"]*$/) and ($line =~ /[<>\\]/)){
        $is_keyword = 1;
    }
    # print "$line\n" if $is_keyword;
    return $is_keyword;
}

# Converts a list from Shell to Python. e.g. ($var 90 moo) becomes (var,90,'moo')
sub listConvert {
    my ($list) = @_;
    my @elems = $list =~ /(`.*?`|'.*?'|".*?"|\S+)/g;
    foreach my $i (0..$#elems){
        if ($elems[$i] =~ /^'.*?'$/){ # if string
            next;
        }
        if ($elems[$i] =~ /^`(.*?)`$/){
            $elems[$i] = $1;
            if ($elems[$i] =~ /^\s*test\s+(.*)/){
                $elems[$i] = testConvert($1);
            } elsif ($elems[$i] =~ /^\s*expr\s+(.*)/){
                $elems[$i] = exprConvert($1);
            } else {
                $import{subprocess} = 1;
                # @words = split(/\s+/,$elems[$i]);
                # @new = map {"'$_'"} @words;
                # $elems[$i] = join(",",@new);
                # $elems[$i] = listConvert($elems[$i]);
                # $elems[$i] = "subprocess.check_output([$elems[$i]])";
                if ($elems[$i] =~ /^([^\']+?)\s+\"?\$@\"?\s+([^\']+?)\s*$/){ # if $@ in middle
                    $elems[$i] = "[".listConvert($1)."] + sys.argv[1:] + [".listConvert($2)."]";
                } elsif ($elems[$i] =~ /^(.*)\s+"?\$@"?\s*$/){ # if $@ is last
                    $elems[$i] = "[".listConvert($1)."] + sys.argv[1:]";
                } elsif ($elems[$i] =~ /^\s*"?\$@"?\s+(.*)$/){ # if $@ is first
                    $elems[$i] = "sys.argv[1:] + [".listConvert($1)."]";
                } else {
                    $elems[$i] = "[".listConvert($elems[$i])."]";
                }
                $elems[$i] = "subprocess.check_output($elems[$i]).rstrip()";
            }
        } elsif ($elems[$i] =~ /^"(.*?)"$/){
            $elems[$i] = echoConvert($1);
        } elsif ($elems[$i] =~ /^\$($var_re)$/){ # if variable
            $elems[$i] = $1;
        # } elsif ($elems[$i] =~ /\${($var_re)}/){ # if delimited variable
        #     $elems[$i] =~ s/\${/'+/g;
        #     $elems[$i] =~ s/}/+'/g;
        #     $elems[$i] = "'$elems[$i]'";
        } elsif ($elems[$i] =~ /^\$(\d+)$/){ # if special variable
            $import{sys} = 1;
            $elems[$i] = "sys.argv[$1]";
        } elsif ($elems[$i] =~ /^\$\@$/){ # if $@
            $import{sys} = 1;
            $elems[$i] = "sys.argv[1:]"
        } elsif ($elems[$i] =~ /^\$\*$/){ # if $*
            $import{sys} = 1;
            $elems[$i] = "' '.join(sys.argv[1:])";
        } elsif ($elems[$i] =~ /^\$\#$/){ # if $#
            $import{sys} = 1;
            $elems[$i] = "(len(sys.argv)-1)";
        } elsif ($elems[$i] =~ /^[\d]+$/){ # if number
            next;
        } elsif ($elems[$i] =~ /[?*\[\]]/){ # file expansion
            $import{glob} = 1;
            $elems[$i] = "sorted(glob.glob(\"$elems[$i]\"))";
        } elsif (not $elems[$i] =~ /^'.*'$/) { # else convert to string
            $elems[$i] = "'$elems[$i]'";
        }
    }
    $list = join(", ",@elems);
    return $list;
}

sub echoConvert {
    my ($line) = @_;
    chomp $line;
    # my @elems = $line =~ /('.*?'|\S+)/g;
    my @elems = $line =~ /(`.*?`|'.*?'|".*?"|\$(?:$var_re|[\d\@\#\*]+)|[^\$]+|\s+)/g;
    # print @elems;
    # my @words = ();
    # my @new = ();
    foreach my $i (0..$#elems){
        # print ">>$elems[$i]<<\n";
        if ($elems[$i] =~ /^'.*?'$/){ # if string
            next;
        }
        if ($elems[$i] =~ /^`(.*?)`$/){
            $elems[$i] = $1;
            if ($elems[$i] =~ /^\s*test\s+(.*)/){
                $elems[$i] = testConvert($1);
            } elsif ($elems[$i] =~ /^\s*expr\s+(.*)/){
                $elems[$i] = exprConvert($1);
            } else {
                $import{subprocess} = 1;
                # @words = split(/\s+/,$elems[$i]);
                # @new = map {"'$_'"} @words;
                # $elems[$i] = join(",",@new);
                # $elems[$i] = listConvert($elems[$i]);
                # $elems[$i] = "subprocess.check_output([$elems[$i]])";
                if ($elems[$i] =~ /^([^\']+?)\s+\"?\$@\"?\s+([^\']+?)\s*$/){ # if $@ in middle
                    $elems[$i] = "[".listConvert($1)."] + sys.argv[1:] + [".listConvert($2)."]";
                } elsif ($elems[$i] =~ /^(.*)\s+"?\$@"?\s*$/){ # if $@ is last
                    $elems[$i] = "[".listConvert($1)."] + sys.argv[1:]";
                } elsif ($elems[$i] =~ /^\s*"?\$@"?\s+(.*)$/){ # if $@ is first
                    $elems[$i] = "sys.argv[1:] + [".listConvert($1)."]";
                } else {
                    $elems[$i] = "[".listConvert($elems[$i])."]";
                }
                $elems[$i] = "subprocess.check_output($elems[$i]).rstrip()";
            }
        } elsif ($elems[$i] =~ /^"(.*?)"$/){
            $elems[$i] = echoConvert($1);
        } elsif ($elems[$i] =~ /^\$($var_re)$/){ # if variable
            $elems[$i] = $1;
        # } elsif ($elems[$i] =~ /\${($var_re)}/){ # if delimited variable
        #     $elems[$i] =~ s/\${/'+/g;
        #     $elems[$i] =~ s/}/+'/g;
        #     $elems[$i] = "'$elems[$i]'";
        } elsif ($elems[$i] =~ /^\$(\d+)$/){ # if special variable
            $import{sys} = 1;
            $elems[$i] = "sys.argv[$1]";
        } elsif ($elems[$i] =~ /^\$\@$/){ # if $@
            $import{sys} = 1;
            # $elems[$i] = "sys.argv[1:]"
            $elems[$i] = "' '.join(sys.argv[1:])"; # print in sh format
        } elsif ($elems[$i] =~ /^\$\*$/){ # if $*
            $import{sys} = 1;
            $elems[$i] = "' '.join(sys.argv[1:])";
        } elsif ($elems[$i] =~ /^\$\#$/){ # if $#
            $import{sys} = 1;
            $elems[$i] = "(len(sys.argv) - 1)";
        } elsif ($elems[$i] =~ /^[\d]+$/){ # if number
            next;
        } elsif ($elems[$i] =~ /[?*\[\]]/){ # file expansion
            $import{glob} = 1;
            $elems[$i] = "sorted(glob.glob(\"$elems[$i]\"))";
        } elsif ($elems[$i] =~ /^\$/) {
        } elsif (not $elems[$i] =~ /^'.*'$/) { # else convert to string
            $elems[$i] = "'$elems[$i]'";
        }
    }
    # $line = join(", ",@elems);
    $line = join(" + ",@elems);
    return $line;
}

sub testConvert {
    my ($line) = @_;
    chomp $line;
    my $arg1;
    my $arg2;
    my $op;
    $line =~ s/\\([^\\])/$1/g; # unescape line. does not work for escaped backslash at eol
    if ($line =~ /('.*?'|".*?"|\S+)\s+-nt\s+('.*?'|".*?"|\S+)/){ # newer than
        # $arg1 = $1;
        # $arg2 = $2;
        # if (not $arg1 =~ /'.*'/){
        #     $arg1 = "'$arg1'";
        # }
        # if (not $arg2 =~ /'.*'/){
        #     $arg2 = "'$arg2'";
        # }
        $arg1 = echoConvert($1);
        $arg2 = echoConvert($2);
        $line = "os.path.exists($arg1) and (not os.path.exists($arg2) or os.stat($arg1).st_mtime > os.stat($arg2).st_mtime)";
    } elsif ($line =~ /('.*?'|".*?"|\S+)\s+-ot\s+('.*?'|".*?"|\S+)/){ # older than
        # $arg1 = $1;
        # $arg2 = $2;
        # if (not $arg1 =~ /'.*'/){
        #     $arg1 = "'$arg1'";
        # }
        # if (not $arg2 =~ /'.*'/){
        #     $arg2 = "'$arg2'";
        # }
        $arg1 = echoConvert($1);
        $arg2 = echoConvert($2);
        $line = "os.path.exists($arg2) and (not os.path.exists($arg1) or os.stat($arg2).st_mtime > os.stat($arg1).st_mtime)";
    } elsif ($line =~ /^\s*!\s+(.*?)\s*$/){
        # print "$line\n";
        # $arg1 = "\( $1 \)";
        $arg1 = $1;
        # print "$arg1\n";
        # if ($arg1 =~ /^\s*\(\s+(.*)\s+\)\s*$/){ # problem is here
        # if ($arg1 =~ /^\s*\(\s+(.*)\s+\)\s*$/){ # problem is here
        #     print "$1\n";
        #     $arg1 = testConvert($1);
        # } else {
        #     # print "$arg1\n";
        #     $arg1 = testConvert($arg1);
        # }
        $arg1 = testConvert($arg1);
        # print ">>$arg1<<\n";
        $line = "not ".$arg1;
    } elsif ($line =~ /^\s*\-n\s+('.*?'|\S+)/ or $line =~ /^\s*\(\s+\-n\s+('.*?'|\S+)\s+\)/){ # -n
        # $line = $1;
        $line = echoConvert($1);
        $line = "(len($line) != 0)"; # string is nonzero
    } elsif ($line =~ /^\s*\-z\s+('.*?'|\S+)/ or $line =~ /^\s*\(\s+\-z\s+('.*?'|\S+)\s+\)/){ # -z
        $line = echoConvert($1);
        $line = "(len($line) == 0)"; # string is zero
    } elsif ($line =~ /^\s*-d\s+('.*?'|\S+)/){
        $import{os} = 1;
        $line = "os.path.isdir(".listConvert($1).")";
    } elsif ($line =~ /^\s*-r\s+('.*?'|\S+)/){
        $import{os} = 1;
        $line = "os.access(".listConvert($1).", os.R_OK)";
    } elsif ($line =~ /(\((?:[^\(\)]++|(?1))*\)|\S+)\s+(\-\S+)\s+(\((?:[^\(\)]++|(?1))*\)|\S+)/){
        $arg1 = $1;
        $op = $2;
        $arg2 = $3;
        # $arg1 = testConvert($arg1);
        # $arg2 = testConvert($arg2);
        # print "$line\n";
        # print "$arg1 $op $arg2\n";
        if ($arg1 =~ /\s*\(\s+(.*)\s+\)/){
            $arg1 = testConvert($1);
        } else {
            $arg1 = testConvert($arg1);
        }
        if ($arg2 =~ /\s*\(\s+(.*)\s+\)/){
            $arg2 = testConvert($1);
        } else {
            $arg2 = testConvert($arg2);
        }
        if (not $arg1 =~/^\d+$/ and $arg1 =~ /^\S+$/){ # if not an int or an expression
            $arg1 = "int($arg1)"; # cast to int
        }
        if (not $arg2 =~/^\d+$/ and $arg2 =~ /^\S+$/){ # if not an int or an expression
            $arg2 = "int($arg2)"; # cast to int
        }
        foreach my $key (sort keys %int_test){
            if ($op =~ /$key/){
                # print "$op $key\n";
                $line = "($arg1 $int_test{$key} $arg2)";
            }
        }
        if ($op =~ /-a/){
            $line = "($arg1 and $arg2)"
        } elsif ($op =~ /-o/){
            $line = "($arg1 or $arg2)"
        }
    # } elsif ($line =~ /(.*?)\s+=\s+(.*?)\s*$/){
    } elsif ($line =~ /(\((?:[^\(\)]++|(?1))*\)|\S+)\s+=\s+(\((?:[^\(\)]++|(?1))*\)|\S+)/){
        $arg1 = $1;
        $arg2 = $2;
        # print "$line\n";
        # print "$arg1 = $arg2\n";
        $arg1 = echoConvert($1);
        $arg2 = echoConvert($2);
        # $arg1 = testConvert($1);
        # $arg2 = testConvert($2);
        # if ($arg1 =~ /\(\s+(.*)\s+\)/){
        #     $arg1 = testConvert($1);
        # } else {
        #     $arg1 = testConvert($arg1);
        # }
        # if ($arg2 =~ /\(\s+(.*)\s+\)/){
        #     $arg2 = testConvert($1);
        # } else {
        #     $arg2 = testConvert($arg2);
        # }
        if ($arg1 =~/^\d+$/){ # if number
            $arg1 = "'$arg1'"; # cast to str
        }
        if ($arg2 =~/^\d+$/){ # if number
            $arg2 = "'$arg2'"; # cast to str
        } 
        # if (not $arg1 =~ /'.*'/){
        #     $arg1 = "'$arg1'";
        # }
        # if (not $arg2 =~ /'.*'/){
        #     $arg2 = "'$arg2'";
        # }
        $line = "($arg1 == $arg2)";
    } elsif ($line =~ /('.*?'|\S+)\s+!=\s+('.*?'|\S+)/){
        $arg1 = $1;
        $arg2 = $2;        
        if (not $arg1 =~ /'.*'/){
            $arg1 = "'$arg1'";
        }
        if (not $arg2 =~ /'.*'/){
            $arg2 = "'$arg2'";
        }
        $line = "$arg1 != $arg2";
    } elsif ($line =~ /^\s*(\d+)\s*$/){ # if just number
        # $line = "int($1)";
        $line = $line;
    } elsif ($line =~ /^\$($var_re)$/){ # if variable
        $line = $1;
    } elsif ($line =~ /^\$(\d+)$/){ # if special variable
        $import{sys} = 1;
        $line = "sys.argv[$1]";
    # } elsif (not $line =~ /'.*'/){
    #     $line = "'$line'";
    } elsif ($line){
        if (not $line =~ /'.*'/){
            $line = "(len('$line') != 0";
        } else {
            $line = "(len($line) != 0";
        }
    }
    return $line;
}

sub exprConvert {
    my ($line) = @_;
    chomp $line;
    my $string;
    my $regex;
    my $arg1;
    my $arg2;
    my $op;
    my $token = 0;
    if ($line =~ /^\s*\+/){
        $token = 1; # escape first word;
    }
    $line =~ s/\\([^\\])/$1/g; # unescape line. does not work for escaped backslash at eol
    if ($line =~ /(\((?:[^\(\)]++|(?1))*\)|\S+)\s+([+\-*\/%])\s+(\((?:[^\(\)]++|(?1))*\)|\S+)/){ # numeric operation
        $arg1 = $1;
        $op = $2;
        $arg2 = $3;
        if ($arg1 =~ /\(\s+(.*)\s+\)/){
            $arg1 = exprConvert($1);
        } else {
            $arg1 = exprConvert($arg1);
        }
        if ($arg2 =~ /\(\s+(.*)\s+\)/){
            $arg2 = exprConvert($1);
        } else {
            $arg2 = exprConvert($arg2);
        }
        if (not $arg1 =~/^\d+$/ and $arg1 =~ /^\S+$/){ # if not an int or an expression
            $arg1 = "int($arg1)"; # cast to int
        }
        if (not $arg2 =~/^\d+$/ and $arg2 =~ /^\S+$/){ # if not an int or an expression
            $arg2 = "int($arg2)"; # cast to int
        }
        $line = "($arg1 $op $arg2)"; 
    } elsif ($line =~ /(\((?:[^\(\)]++|(?1))*\)|\S+)\s+([<>=]|[<>!]=)\s+(\((?:[^\(\)]++|(?1))*\)|\S+)/){ # comparison
        $arg1 = exprConvert($1);
        $op = $2;
        $arg2 = exprConvert($3);
        $line = "$arg1 $op $arg2";
    } elsif ($line =~ /(\((?:[^\(\)]++|(?1))*\)|\S+)\s+&\s+(\((?:[^\(\)]++|(?1))*\)|\S+)/){ # |
        $arg1 = exprConvert($1);
        $arg2 = exprConvert($2);
        $line = "$arg1 if $arg1 else $arg2";
    } elsif ($line =~ /(\((?:[^\(\)]++|(?1))*\)|\S+)\s+&\s+(\((?:[^\(\)]++|(?1))*\)|\S+)/){ # &
        $arg1 = exprConvert($1);
        $arg2 = exprConvert($2);
        $line = "$arg1 if $arg1 and $arg2 else 0";
    }elsif ($line =~ /^\s*\(\s+(.*)\s+\)/){
        $line = exprConvert($1);
    } elsif ($line =~ /('.*?'|\S+)\s+:\s+('.*?'|\S+)/){
        $import{re} = 1;
        $string = $1;
        $regex = $2;
        if (not $string =~ /'.*'/){
            $string = "'$string'";
        }
        if ($regex =~ /^'(.*)'$/){
            $regex = $1;
        }
        if ($regex =~ /^\((.*)\)$/){
            $regex = $1;
            $line = "re.search(r'$regex',$string).group()"; # get matching substring
        } else {
            $line = "len(re.search(r'$regex',$string).group())"; # get number of matching chars
        }
    } elsif ($line =~ /^\s*match\s+('.*?'|\S+)\s+('.*'|\S+)/ and not $token){
        $import{re} = 1;
        $string = $1;
        $regex = $2;
        if (not $string =~ /'.*'/){
            $string = "'$string'";
        }
        if ($regex =~ /^'(.*)'$/){
            $regex = $1;
        }
        if ($regex =~ /^\((.*)\)$/){
            $regex = $1;
            $line = "re.search(r'$regex',$string).group()"; # get matching substring
        } else {
            $line = "len(re.search(r'$regex',$string).group())"; # get number of matching chars
        }
    } elsif ($line =~ /^\s*substr\s+('.*?'|\S+)\s+('.*'|\S+)\s+('.*'|\S+)/ and not $token){
        $string = $1;
        if (not $string =~ /'.*'/){
            $string = "'$string'";
        }
        # $line = "$string[".$2."-1:".$2."-1+".$3."]";
        $line = "$string\[$2-1:$2-1+$3\]";
        # $line = join "$string[",$2,"-1:",$2,"-1+",$3,"]";
    } elsif ($line =~ /^\s*index\s+('.*?'|\S+)\s+('.*'|\S+)/ and not $token){
        $import{re} = 1;
        $string = $1;
        if (not $string =~ /'.*'/){
            $string = "'$string'";
        }
        if ($regex =~ /'.*'/){
            $regex = $1;
        }
        $line = "re.search(r'[$regex]',$string).start() + 1";
    } elsif ($line =~ /^\s*length\s+('.*?'|\S+)/ and not $token){
        $line = "len($1)";
    } elsif ($line =~ /^\s*(\d+)\s*$/){ # if just number
        # $line = "int($1)";
        $line = $line;
    } elsif ($line =~ /^\$($var_re)$/){ # if variable
        $line = $1;
    } elsif ($line =~ /^\$(\d+)$/){ # if special variable
        $import{sys} = 1;
        $line = "sys.argv[$1]";
    } elsif (not $line =~ /'.*'/){
        $line = "'$line'";
    }
    # $line =~ /(<(?:[^<>]++|(?1))*>)/g; # for matching top-level angle brackets
    # $line =~ /(\((?:[^\(\)]++|(?1))*\))/g; # for matching top-level brackets
    # (\((?:[^\(\)]++|(?1))*\))

    # my @elems = $line =~ /('.*?'|\S+)/g;
    # foreach my $i (0..$#elems){
    #     if ($elems[$i] =~ /^'.*?'$/){ # if string
    #         next;
        # } elsif ($elems[$i] =~ /^\$($var_re)$/){ # if variable
        #     $elems[$i] = $1;
    #     # } elsif ($elems[$i] =~ /\${($var_re)}/){ # if delimited variable
    #     #     $elems[$i] =~ s/\${/'+/g;
    #     #     $elems[$i] =~ s/}/+'/g;
    #     #     $elems[$i] = "'$elems[$i]'";
        # } elsif ($elems[$i] =~ /^\$(\d+)$/){ # if special variable
        #     $import{sys} = 1;
        #     $elems[$i] = "sys.argv[$1]";
    #     } elsif ($elems[$i] =~ /^[\d]+$/){ # if number
    #         next;
    #     } elsif ($elems[$i] =~ /^([|&<>=+\-*\/%]|[<>!]=)$/){ # if operator
    #         next;
    #     } elsif ($elems[$i] =~ /[?*\[\]]/){ # file expansion
    #         $import{glob} = 1;
    #         $elems[$i] = "sorted(glob.glob(\"$elems[$i]\"))";
    #     } elsif (not $elems[$i] =~ /^'.*'$/) { # else convert to string
    #         $elems[$i] = "'$elems[$i]'";
    #     }
    # }
    # $line = join(" ",@elems);
    # print ">>$line<<\n";
    return $line;
}
