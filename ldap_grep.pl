#!/usr/bin/perl -w
#

use strict;
use Getopt::Std;
use Data::Dumper;

sub print_usage();

$,=$\="\n";

my @arg = @ARGV;

my $found=0;
my $in;
my $value;

my %opts;
getopt('i', \%opts);

my $infile;
for my $a (@arg) {
    if ($a !~ /^-/) {
	if (defined $value) {
	    $infile = $a;
	} else {
	    $value = $a;
	}
    }
}

if (defined $infile) {
    open ($in, $infile) || die "can't open $infile";
} else {
    $in = "STDIN";
}

my %conns;
my %matching_conns;
my $conn_from;
my $search;
my $saved_conn;

while (<$in>) {
    chomp;

    my $conn;
    next unless (($conn) = /conn=(\d+)\s+/);
    push @{$conns{$conn}}, $_;

    if (!defined $value) {
	# if no value was passed from the command line all connections match
	$matching_conns{$conn} = 1;
    } elsif (exists $opts{i}) {
	# case insensitive
	$matching_conns{$conn} = 1
	  if (/$value/i);
    } else {
	# case sensitive
	$matching_conns{$conn} = 1
	  if (/$value/);
    }

    if (exists $matching_conns{$conn}) {
	print @{$conns{$conn}};
	delete $conns{$conn}
    }
}



sub print_usage() {
    print "\nusage: $0 [-i] PATTERN file\n";
    print "\tor: cat file | $0 [-i] PATTERN\n";
    print "\n";
    exit;
}
