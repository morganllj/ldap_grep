#!/usr/bin/perl -w
#

use strict;
use Getopt::Std;
use Data::Dumper;

sub print_usage();
sub omit_conn();

my @arg = @ARGV;

my $found=0;
my $in;
my $value;

my %conns;
my %matching_conns;
my %omitted_conns;
my $conn_from;
my $search;
my $saved_conn;

my %opts;
getopt('iv:', \%opts);

my $infile;

if ($#arg == 0) {
    # reading from stdin
    $value = $arg[0];
} else {
    # reading from stdin with 1 or more switches or reading from a file 0 or more switches
  if ($arg[-2] =~  /^-/) {
	$value = $arg[-1];
    } else {
	$value = $arg[-2];
	$infile = $arg[-1];
    }
}

print_usage() if (!defined $value);

if (defined $infile) {
    open ($in, $infile) || die "can't open $infile";
} else {
    $in = "STDIN";
}

while (<$in>) {
    chomp;

    my $conn;
    next unless (($conn) = /conn=(\d+)\s+/);
    push @{$conns{$conn}}, $_;

    # case sensitive or insensitive?
    if (exists $opts{i}) {
	$matching_conns{$conn} = 1
	  if (/$value/i);

	if (exists $opts{v} && /$opts{v}/i) {
	    omit_conns($conn, %omitted_conns);
	    $omitted_conns{$conn} = 1
	}
    } else {
	if (/$value/) {
	    $matching_conns{$conn} = 1;
	}

	if (exists $opts{v} && /$opts{v}/) {
	    omit_conns($conn, %omitted_conns);
	    $omitted_conns{$conn} = 1;
	}
    }

    if (exists $matching_conns{$conn} && !exists $omitted_conns{$conn}) {
	$,=$\="\n";
	print @{$conns{$conn}};
	$,=$\="";
	delete $conns{$conn};
    }
}


sub omit_conns {
    my ($conn, %omitted_conns) = @_;

     # print "***omitting $conn from further output"
     #   if (!exists $omitted_conns{$conn});
    $omitted_conns{$conn} = 1;
}


sub print_usage() {
    print "\nusage: $0 [-i] [-v pattern] PATTERN file\n";
    print "\tor: cat file | $0 [-i] PATTERN\n";
    print "\n";
    exit;
}
