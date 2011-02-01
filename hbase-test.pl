#!/usr/bin/env perl

use Modern::Perl;
use HBase;

my $host = $ARGV[0] || 'http://trpchads01.vm.searshc.com:8080';

my $h = HBase->new(server => $host, debug => 1);

my @tables = $h->list;
foreach my $t (@tables) {
    say "table: $t";
}

print "after module\n";
