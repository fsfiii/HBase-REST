#!/usr/bin/env perl

use Modern::Perl;
use HBase::REST;
use Data::Dumper;

my $host = $ARGV[0] || 'http://trpchads01.vm.searshc.com:8080';

my $h = HBase::REST->new(server => $host, debug => 1);
if (! $h) {
    say STDERR "error: cannot connect to HBase @ $host";
    exit(1);
}

my @tables = $h->list;
foreach my $t (@tables) {
    say "table: $t";
}

say "************** SINGLE ROW";
my @rows = $h->get('rest-test', 'row1');
print Dumper(@rows);

say "************** PUT";
my $rc = $h->put('rest-test', 'api-row', 'cf1:h', 'hello');
say "rc: $rc";


#say "************** SINGLE ROW TIMESTAMP";
#@rows = $h->get('rest-test', 'row1', timestamp => 100);
#print Dumper(@rows);
#
#say "************** MULTI ROW"
#@rows = $h->get('rest-test', 'row*');
#print Dumper(@rows);
