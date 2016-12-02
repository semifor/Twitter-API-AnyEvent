package Twitter::API::AnyEvent;
# Abstract: Twitter::API subclass with async support

use 5.14.1;
use Moo;
use Carp;
use AnyEvent::HTTP::Request;
use AnyEvent::HTTP::Response;
use Scalar::Util qw/reftype weaken/;
use Try::Tiny;

use namespace::clean;

extends 'Twitter::API';

around request => sub {
    my $orig = shift;
    my $self = shift;

    # splice in an empty args hashref if we don't have one
    splice @_, 2, 0, {} unless @_ == 4;
    croak 'expected a callback as the final arg'
        unless ref $_[-1] && reftype $_[-1] eq 'CODE';

    my $c = $self->$orig(@_);
};

sub send_request {
    my ( $self, $c ) = @_;
    weaken $self;

    my $cb = pop @{ $$c{extra_args} };
    my $w;
    my $ae_req = AnyEvent::HTTP::Request->new($c->http_request, {
        params => {
            timeout => $self->timeout,
        },
        cb => sub {
            undef $w;
            my $res = AnyEvent::HTTP::Response->new(@_);
            $c->set_http_response($res->to_http_message);
            my $e;
            try {
                $self->inflate_response($c);
            }
            catch {
                $e = $_;
            };
            $cb->($e, $c->result, $c);
        }
    });

    $w = $ae_req->send;

    # return false to exit the request early
    return;
}

1;
