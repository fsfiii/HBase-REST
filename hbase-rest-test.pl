#!/usr/bin/env perl

use Modern::Perl;
use HBase::REST;
use Data::Dumper;

my $server = $ARGV[0] || 'http://localhost:8080';

my $h = HBase::REST->new(server => $server, debug => 1)
    or die "error: cannot connect to HBase @ $server";

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
