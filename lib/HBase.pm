package HBase;

use warnings;
use strict;

use REST::Client;
use JSON;
use Data::Dumper;
#use Encode;

=head1 NAME

HBase - perl binding for HBase REST/stargate interface

=cut

our $VERSION = '0.0001';

sub new {
    my $class   = shift;
    my $self    = {@_};
    my $client  = REST::Client->new();

    $self->{server} ||= '127.0.0.1:8080';
    $self->{headers} = {Accept => 'application/json'};

    $client->setHost($self->{server});
    $client->GET('/version', $self->{headers});
    if ($client->responseCode() ne '200') {
        warn "error: cannot connect to HBase at $self->{server}";
        return undef;
    }

    my $response = decode_json($client->responseContent());
    if ($response->{REST}) {
        $self->{rest_version} = $response->{REST};
    }
    else {
        warn "warning: cannot determine HBase REST version";
    }

    $self->{client} = $client;

    bless($self, $class);
    $self;
}

sub good_response {
    my $self = shift;
    my $client = $self->{client};
    my $code = $client->responseCode();

    if ((! $code) || ($code ne '200')) {
        warn "error: received response code ", $client->code;
        return 0;
    }

    $code;
}

sub list {
    my $self = shift;
    my $client = $self->{client};

    $client->GET('/', $self->{headers});
    return undef if not $self->good_response;

    my $tables_ref = decode_json($client->responseContent());
    map {$_->{name}} @{$tables_ref->{table}};
}

sub get {
    my $self = shift;
}

1;
