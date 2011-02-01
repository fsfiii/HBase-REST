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
    my $headers = {Accept => 'application/json'};
    my $client  = REST::Client->new();

    $self->{server} ||= '127.0.0.1:8080';

    $client->setHost($self->{server});
    $client->GET('/version', $headers);
    if ($client->responseCode() ne '200') {
        warn "error: cannot connect to HBase at $self->{server}";
        return undef;
    }

    my $response = decode_json($client->responseContent());
    print Dumper($response) if $self->{debug};
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

1;
