#!/usr/bin/env perl
use v5.12;
use warnings;
use diagnostics;

my $prog = shift // (usage() and exit);
my $command = "prove t/${prog}.t -v";
system $command;

sub usage {
  say STDERR 'usage:';
  say STDERR '  perl test.pl java';
  say STDERR '  perl test.pl perl';
}
