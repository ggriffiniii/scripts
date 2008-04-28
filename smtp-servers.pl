#!/usr/bin/perl
use warnings;
use strict;
use IO::Socket;

my $host = shift @ARGV || 'mail.f5.com';
my %stats;

$SIG{INT} = \&print_summary_and_quit; #Ctrl+C
$SIG{QUIT} = \&print_summary; #Ctrl+\

while(1) {
	my $sock = new IO::Socket::INET ( PeerAddr => $host,
					  PeerPort => 25,
					  Proto => 'tcp',
					  Timeout => 1);
	my $smtp_banner;
	$sock->read($smtp_banner, 32);
	if( $smtp_banner =~ /^220\s+(\S+)\s/ ) {
		$stats{$1}++;
	} else {
		$stats{failures}++;
	}
	$sock->close;
}

sub print_summary {
	my($host,$conns);
print <<EOM;
hostname		connections
----------------------- -----------
EOM
	format STDOUT =
@<<<<<<<<<<<<<<<<<<<<<< @||||||||||
$host, $conns
.

	for $host ( keys %stats ) {
		$conns = $stats{$host};
		write;
	}
	print "\n";
}

sub print_summary_and_quit {
	print_summary();
	exit(0);
}
