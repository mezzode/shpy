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
    } else {
        # Lines we can't translate are turned into comments
        print "#$line\n";
    }
}
