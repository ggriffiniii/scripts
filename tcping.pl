#!/usr/bin/perl
use IO::Socket;
use Time::HiRes qw( time sleep );

my $max_pings_per_sec = 1;
my $min = 2^32;
my $max = -1;
my $total = 0;
my $attempts = 0;
my $sattempts = 0;

$SIG{INT} = \&print_summary_and_quit;

while(1) {
	my $stime = time;
	my $sock = new IO::Socket::INET (
			PeerAddr => $ARGV[0],
			PeerPort => $ARGV[1],
			Proto => 'tcp',
			Timeout => 2 );
	my $etime = time;
	$attempts++;

	if($sock) {
		close($sock);
		my $delta = $etime - $stime;
		#convert to milliseconds rounded to a one tenth of a millisecond
		$delta *= 1000;
		$delta = sprintf("%.1f", $delta);
		print "Host $ARGV[0] responded: $delta ms\n";
		$total += $delta;
		$max = $delta if $delta > $max;
		$min = $delta if $delta < $min;
		$sattempts++;
		if( $etime - $stime < 1 / $max_pings_per_sec ) {
			sleep( ( 1 / $max_pings_per_sec ) - ( $etime - $stime) );
		}
	} else {
		print "Host $ARGV[0] didn't respond\n";
	}
}

sub print_summary_and_quit {
	my $avg = $total/$attempts;
	$avg = sprintf("%.1f", $avg);

	print<<EOM;
--- $ARGV[0] tcping statistics ---
$attempts flows attempted, $sattempts successfully established,
rtt min/max/avg = $min/$max/$avg
EOM
	exit 2;
}
