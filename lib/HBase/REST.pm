package HBase;

use warnings;
use strict;

use JSON;
use Data::Dumper;
use MIME::Base64;
use CGI qw(escape);
use LWP::UserAgent;

=head1 NAME

HBase - perl binding for HBase REST/stargate interface

=cut

our $VERSION = '0.0001';

sub new {
    my $class   = shift;
    my $self    = {@_};

    $self->{server} ||= 'http://127.0.0.1:8080';

    my $path = $self->{server} . '/version';
    my $req = HTTP::Request->new(GET => $path);
    $req->header(Accept => 'application/json');

    my $ua = LWP::UserAgent->new;
    my $res = $ua->request($req);

    return undef if not $res->is_success;

    my $response = decode_json($res->decoded_content);
    if ($response->{REST}) {
        $self->{rest_version} = $response->{REST};
    }
    else {
        warn "warning: cannot determine HBase REST version";
    }

    bless($self, $class);
    $self;
}

sub list {
    my $self = shift;
    my $path = $self->{server} . '/';

    my $req = HTTP::Request->new(GET => $path);
    $req->header(Accept => 'application/json');

    my $ua = LWP::UserAgent->new;
    my $res = $ua->request($req);

    return undef if not $res->is_success;

    my $tables_ref = decode_json($res->decoded_content);
    map {$_->{name}} @{$tables_ref->{table}};
}

sub put {
    my $self = shift;
    my ($table, $row, $col, $value, %opts_ref) = @_;
    if (! $value) {
        warn "error: must provide at least a table, row, column, and value";
        return undef;
    }
    my $path = sprintf '/%s/%s/%s', escape($table), escape($row), escape($col);
    my $ts = time;
    $path .= sprintf '/%d', $ts;

    my $xml_data = q|<?xml version='1.0' encoding='UTF-8' standalone='yes'?>|;
    $xml_data .= q|<CellSet>|;
    $xml_data .= sprintf q|<Row key='%s'>|, encode_base64($row); 

    $xml_data .= q|<Cell |;
    $xml_data .= sprintf q|timestamp='%d' |, $ts;
    $xml_data .= sprintf q|column='%s'>|, encode_base64($col);
    $xml_data .= encode_base64($value);
    $xml_data .= q|</Cell>|;

    $xml_data .= q|</Row></CellSet>|;

    $path = $self->{server} . $path;
print $path, "\n";
print $xml_data, "\n";

    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new(POST => $path);
    $req->content_type('text/xml');
    $req->content($xml_data);
    my $res = $ua->request($req);
    print $res->as_string, "\n";
}

sub get {
    my $self = shift;
    my ($table, $row, %opts_ref) = @_;
    if (! $row) {
        warn "error: must provide at least a table and row";
        return undef;
    }
    my $path = sprintf '%s/%s/%s',
        $self->{server}, escape($table), escape($row);
    # does not seem to work via REST interface 0.89
    if (%opts_ref) {
        if ($opts_ref{timestamp}) {
            $path .= sprintf('/%s', escape($opts_ref{timestamp}));
            print $path, "\n";
        }
    }
    
    my $req = HTTP::Request->new(GET => $path);
    $req->header(Accept => 'application/json');

    my $ua = LWP::UserAgent->new;
    my $res = $ua->request($req);

    return undef if not $res->is_success;


    my @rows = ();

    my $resp = decode_json($res->decoded_content);
    foreach my $row (@{$resp->{Row}}) {
        my $key = decode_base64($row->{key});
        my @cols = ();
        #print "ROW: ", Dumper($row) if $self->{debug};
        #print "KEY: ", $key, "\n" if $self->{debug};
        foreach my $c (@{$row->{Cell}}) {
            my $name = decode_base64($c->{column});
            my $value = decode_base64($c->{'$'});
            my $ts = $c->{timestamp};
            push @cols, {name => $name, value => $value, timestamp => $ts};
        }
        push @rows, {row => $key, columns => \@cols};
    }

    @rows;
}

1;
