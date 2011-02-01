package HBase;

use warnings;
use strict;

use REST::Client;
use JSON;

#use Data::Dumper;
#use Encode;

=head1 NAME

HBase - perl binding for HBase REST/stargate interface

=cut

our $VERSION = '0.0001';

sub new {
    my $class = shift;
    my $self = {@_};
    $self-{server} ||= '127.0.0.1:8080';

    $self->{sock} = IO::Socket::INET->new(
        PeerAddr => $self->{server} Proto => 'tcp'
    ) or die "error: cannot connect to $self->{server}: $!\n";

    bless($self, $class);
    $self;
}

sub version {
    my $sock = $self->{sock} or die "error: no connection";

    my $msg = "
}

1;
