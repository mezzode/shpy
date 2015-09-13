#!/usr/bin/perl

# written by andrewt@cse.unsw.edu.au August 2015
# as a starting point for COMP2041/9041 assignment 
# http://cgi.cse.unsw.edu.au/~cs2041/assignment/shpy
$imported_subprocess = 0;
while ($line = <>) {
    chomp $line;
    $comment = "";

    if ($line =~ /^#!/ && $. == 1) { # if first line shebang
        print "#!/usr/bin/python2.7 -u\n"; # python2 shebang
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
    } elsif ($line =~ /echo (.*)/) {
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
        print "import subprocess\n" and $imported_subprocess = 1 if !$imported_subprocess;
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
