#!/usr/bin/perl

# written by andrewt@cse.unsw.edu.au August 2015
# as a starting point for COMP2041/9041 assignment 
# http://cgi.cse.unsw.edu.au/~cs2041/assignment/shpy

while ($line = <>) {
    chomp $line;
    if ($line =~ /^#!/ && $. == 1) { # if first line shebang
        print "#!/usr/bin/python2.7\n"; # python2 shebang
    } elsif ($line =~ /echo (.*)/) {
        print "print '$1'\n";
    # } elsif (!keyword($line)){
        # subprocess.call # ?
    } else {
        # Lines we can't translate are turned into comments
        print "#$line\n";
    }
}

# shell keywords which need special handling
# currently not handling !, [[]], {}
# from https://www.gnu.org/software/bash/manual/html_node/Reserved-Word-Index.html#Reserved-Word-Index
%keywords = ("case","do","done","elif","else","esac",
            "fi","for","function","if","in","select",
            "then","time","until","while");

sub keyword {
    my $is_keyword = 0; # false
    my ($in) = @_; # first argument
    # compare to array of known keywords
    foreach $i (%keywords){
        $is_keyword = 1 if ($in eq $keyword[$i]); # true
    }
    return $is_keyword;
}
