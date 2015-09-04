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

%keywords = ("case"); # shell keywords which need special handling
sub keyword {
    my $is_keyword = 0; # false
    my ($in) = @_; # first argument
    # compare to array of known keywords
    foreach $word (%keywords){
        $is_keyword = 1 if ($in eq $word); # true
    }
    return $is_keyword;
}
