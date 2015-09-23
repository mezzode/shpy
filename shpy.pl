#!/usr/bin/perl

# written by andrewt@cse.unsw.edu.au August 2015
# as a starting point for COMP2041/9041 assignment 
# http://cgi.cse.unsw.edu.au/~cs2041/assignment/shpy

%import = ();
@shell = <>;
@python = ("#!/usr/bin/python2.7 -u");

# read
if ($shell[0] =~ /^#!/ and !($shell[0] =~ /^#!\/bin\/sh/)) die; # if not shell, die
foreach $line (@shell) {
    chomp $line;
    $comment = "";

    if ($line =~ /^#!/ && $. == 1) { # if first line shebang
        # print "#!/usr/bin/python2.7 -u\n"; # python2 shebang
        die if not ($line =~ /^#!\/bin\/sh/); # die if not shell script
        next;
    } elsif ($line =~ /^\s*#(.*)/){
        print "#$1\n";
        next;
    } elsif ($line =~ /(.*)#(.*)/){
        $line = $1;
        $comment = $2;        
    }

    if (!$line){
        next;
    } elsif ($line =~ /([A-Za-z_][0-9A-Za-z_]*)=(\S.*)/g){
        $var = $1;
        $assigned = $2;
        if ($assigned =~ /^\d+$/){
            print "$var = $assigned\n";
        } else {
            print "$var = '$assigned'";
        }
    } elsif ($line =~ /^\s*echo (.*)/){
        @words = split(/ /,$1);
        foreach $i (0..$#words){
            if ($words[$i] =~ /\$([A-Za-z_][0-9A-Za-z_]*)/){
                $words[$i] = $1;
            } else {
                $words[$i] = "'$words[$i]'";
            }
        }
        $line = join(",",@words);
        print "print $line";
        # print "print '$1'";
    } elsif (!keyword($line)){
        print "import subprocess\n" and $imported{subprocess} = 1 if !exists $imported{subprocess};
        @words = split(/\s/,$line);
        @new = map {"'$_'"} @words;
        $line = join(",",@new);
        print "subprocess.call([$line])";
    } else {
        # Lines we can't translate are turned into comments
        print "# $line";
    }
    print " #$comment" if $comment;
    print "\n";
}

# print
print "#!/usr/bin/python2.7 -u\n";
print "import $_\n" foreach (sort keys %import);
foreach $line (@python){
    # print/process $line[$i]
    print "$line\n";
}

# original one-step method (print line-by-line)
# %imported = ();
# while ($line = <>) {
#     chomp $line;
#     $comment = "";

#     if ($line =~ /^#!/ && $. == 1) { # if first line shebang
#         print "#!/usr/bin/python2.7 -u\n"; # python2 shebang
#         next;
#     } elsif ($line =~ /^\s*#(.*)/){
#         print "#$1\n";
#         next;
#     } elsif ($line =~ /(.*)#(.*)/){
#         $line = $1;
#         $comment = $2;        
#     }

#     if (!$line){
#         next;
#     } elsif ($line =~ /([A-Za-z_][0-9A-Za-z_]*)=(\S.*)/g){
#         $var = $1;
#         $assigned = $2;
#         if ($assigned =~ /^\d+$/){
#             print "$var = $assigned\n";
#         } else {
#             print "$var = '$assigned'";
#         }
#     } elsif ($line =~ /echo (.*)/) {
#         @words = split(/ /,$1);
#         foreach $i (0..$#words){
#             if ($words[$i] =~ /\$([A-Za-z_][0-9A-Za-z_]*)/){
#                 $words[$i] = $1;
#             } else {
#                 $words[$i] = "'$words[$i]'";
#             }
#         }
#         $line = join(",",@words);
#         print "print $line";
#         # print "print '$1'";
#     } elsif (!keyword($line)){
#         print "import subprocess\n" and $imported{subprocess} = 1 if !exists $imported{subprocess};
#         @words = split(/\s/,$line);
#         @new = map {"'$_'"} @words;
#         $line = join(",",@new);
#         print "subprocess.call([$line])";
#     } else {
#         # Lines we can't translate are turned into comments
#         print "# $line";
#     }
#     print " #$comment" if $comment;
#     print "\n";
# }

# shell keywords which need special handling
# currently not handling "!"
# from https://www.gnu.org/software/bash/manual/html_node/Reserved-Word-Index.html#Reserved-Word-Index
@keywords = ("[[.*]]","{.*}","case","do","done","elif","else","esac",
            "fi","for","function","if","in","select",
            "then","time","until","while");

sub keyword {
    my $is_keyword = 0; # false
    my ($in) = @_; # first argument
    # compare to array of known keywords
    foreach $word (@keywords){
        $is_keyword = 1 if ($in =~ /^$word$/); # need to deal with substrings?
    }
    return $is_keyword;
}

sub listConvert {
    my ($list) = @_;
    my @elems = split(/ /,$list);
    my $elem;
    foreach my $i (0..$#elems){
        if ($elems[$i] =~ /^\$([A-Za-z_][0-9A-Za-z_]*)$/){ # if variable
            $elem = $1;
            if ($elem =~ /^{(.*)}$/) $elem = $1; # remove delimiters
            $elems[$i] = $elem;
        } elsif ($elems[$i] =~ /^[\d]+$/){ # if number
            next;
        } else { # if string
            $elems[$i] = "'$elems[$i]'";
        }
    }
    $list = join(", ",@elems);
    return $list;
}
