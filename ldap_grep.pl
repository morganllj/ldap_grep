#!/usr/bin/perl -w
#

use strict;
use Getopt::Std;
use Data::Dumper;

sub print_usage();

$,=$\="\n";

my $argv_neg2 = $ARGV[-2];
my $argv_neg1 = $ARGV[-1];
my $argv_count = $#ARGV;

my $found=0;

my $in;

#if ($#ARGV > 0) {
#    open ($in, $ARGV[-1]) || die "can't open $ARGV[-1]";
#} else {
#    $in = "STDIN";
#}

my $value;

# if ($#ARGV > 0 && $ARGV[-2] !~ /^-/) {
#     open ($in, $ARGV[-1]) || die "can't open $ARGV[-1]";
#     $value = $ARGV[-2];
# } else {
#     $in = "STDIN";
#     $value = $ARGV[-1];
# }

my %opts;
getopt('is', \%opts);

#if ($#ARGV > 0 && ($argv_neg2 !~ /^-/ || exists $opts{s})) {
if ($argv_count > 0 && ($argv_neg2 !~ /^-/ || exists $opts{s})) {
    print "opening argv_neg1\n";
    open ($in, $argv_neg1) || die "can't open $argv_neg1";
    $value = $argv_neg2 unless (exists $opts{s});
} else {
    $in = "STDIN";
    $value = $argv_neg1;
}

my %conns;
my %matching_conns;
my %summary;
my $conn_from = "none";

while (<$in>) {
    chomp;

    my $conn;
    next unless (($conn) = /conn=(\d+)\s+/);

    if (exists $opts{s}) {
	# if (my ($conn_from) = /connection from (\d+\.\d+\.\d+\.\d+) /) {
	#     print "connect from: /$conn_from/\n";
	# }
	# if (my ($bind) = /BIND dn=\"([^\"]+)\"/) {
	#     print "bind: /$bind/\n";
	# }

	$conn_from = $1
	  if (/connection from (\d+\.\d+\.\d+\.\d+) /);

	my $bind;
	$bind = $1
	  if (/BIND dn=\"([^\"]+)\"/);

	if (defined $bind) {
	    print "in if\n";
	    if (defined $conn_from) {
		print "adding $bind $conn_from\n";
		$summary{$bind . " " . $conn_from} = 1
	    } else {
		print "adding $bind\n";
		$summary{$bind} = 1
	    }
	    $conn_from = undef;
	}


    } else {
	# my $conn;
	# next unless (($conn) = /conn=(\d+)\s+/);

	push @{$conns{$conn}}, $_;

	my $match=0;

	if (exists $opts{i}) {
	    $match = 1
	      if (/$value/i);
	} else {
	    $match = 1
	      if (/$value/);
	}

	#    if (/$value/i) {
	if ($match) {
	    $matching_conns{$conn} = 1;
	    if (exists $conns{$conn}) {
		print @{$conns{$conn}};
		delete $conns{$conn}
	    }
	} elsif (exists $matching_conns{$conn}) {
	    print "$_";
	    pop @{$conns{$conn}};
	}
    }
}

# if (exists $opts{s}) {
#     for my $k (sort keys %summary) {
# 	print $k . "\n";
#     }
# }







sub print_usage() {
    print "\nusage: $0 [-i] PATTERN [file]\n";
    print "or: $0 -s\n";
    print "\n";
    exit;
}
