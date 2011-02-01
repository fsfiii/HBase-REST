#!/usr/bin/env perl

use Modern::Perl;
use HBase::REST;
use Data::Dumper;

my $host = $ARGV[0] || 'http://trpchads01.vm.searshc.com:8080';

my $h = HBase->new(server => $host, debug => 1);

my @tables = $h->list;
foreach my $t (@tables) {
    say "table: $t";
}

#say "************** PUT";
#my $rc = $h->put('rest-test', 'row7', 'c1:h', 'hello');
#say "rc: $rc";
#exit;

say "************** SINGLE ROW";
my @rows = $h->get('rest-test', 'row1');
print Dumper(@rows);

#say "************** SINGLE ROW TIMESTAMP";
#@rows = $h->get('rest-test', 'row1', timestamp => 100);
#print Dumper(@rows);
#
#say "************** MULTI ROW"
#@rows = $h->get('rest-test', 'row*');
#print Dumper(@rows);
