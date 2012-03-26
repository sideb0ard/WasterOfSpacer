#!/usr/bin/perl -w
use strict;
use Date::Parse;

my $dir = "/Users/thorstensideboard/OUTPUT";
opendir(my $dh, $dir) || die "Deid! couldnae open $dir - $!\n";
my @files = grep { /^node*/ && -f "$dir/$_" } readdir($dh);
my %nodes = map { s/\.(du|last)//; $_ => 1; } @files;

my $today = "2010-12-01";
my $today_unixtime = str2time($today);
my $WEEK = 7 * 24 * 60 * 60; # one week in seconds;

#TASK ONE - WHICH USERS ARE USING DISK SPACE ON MACHINES THEY HAVE NOT LOGGED INTO RECENTLY
foreach my $node (keys %nodes) {
  print "Examining machine $node...\n";

  my %users;
  my %du_per_user;

  # PROCESS LAST LOGIN TIMES
  my $lastfile = $dir . "/" . $node . ".last";
  if (-e $lastfile) {
    open(my $lfh, $lastfile) || die "bleurgh! - $!\n";
    while(<$lfh>) {
      chomp;
      my @userinfo = split(/\s+/);
      my $user = $userinfo[0];
      my $lastlogin = str2time($userinfo[3] . " " . $userinfo[4] . " " . $userinfo[5] . " " . 2010);
      if (!defined $users{$user}) {
        $users{$user} = $lastlogin;
      } elsif ($users{$user} < $lastlogin) {
        $users{$user} = $lastlogin;
      } 
    }
  }

  # PROCESS PER USER DU
  my $dufile = $dir . "/" . $node . ".du";
  if (-e $dufile) {
    open (my $dufh, $dufile) ||die "blah - can't open $dufile - $!\n";
    while (<$dufh>) {
      my @line = split();
      $du_per_user{$line[1]} = $line[0];
      }
    }

  # FIND OUT IF THEY HAVEN'T LOGGED IN FOR OVER A WEEK AND ARE USING MORE THAN 2MB DISK SPACE
  foreach my $u ( keys %users) {
    if ($today_unixtime - $users{$u} > $WEEK && $du_per_user{$u} > 2000 ) {
      print "$u hasn't logged into $node for over a week, and is using up $du_per_user{$u} KB disk space\n";
    } 
  }
  print "\n";
}



