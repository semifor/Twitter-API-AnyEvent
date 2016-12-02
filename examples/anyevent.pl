#!/usr/bin/env perl
use 5.14.1;
use warnings;

use AnyEvent;
use Twitter::API::AnyEvent;

my $client = Twitter::API::AnyEvent->new(
    consumer_key        => $ENV{CONSUMER_KEY},
    consumer_secret     => $ENV{CONSUMER_SECRET},
    access_token        => $ENV{ACCESS_TOKEN},
    access_token_secret => $ENV{ACCESS_TOKEN_SECRET},
);

my $cv = AE::cv;

my $guard = $client->get('account/verify_credentials', sub {
    my ( $client, $error, $r, $c ) = @_;

    $cv->croak($error) if $error;

    say "$$r{screen_name} is authorized";
    say "remaining: ", $c->rate_limit_remaining;
    say "until: ", scalar localtime $c->rate_limit_reset;
    $cv->send;
});

# $client already has 10 second timeout (default); this just demonstrates that
# you can cancel a pending request by undef-ing $r.  We also have to call
# $cv->send, because that's what I request callback would hove done.
# Otherwise, the request continues anyway, until the callback's $cv->send is
# called, or a request timeout results the callback's $cv->croak call.
my $timeout; $timeout = AE::timer 2, 0, sub {
    undef $timeout;
    undef $guard;
    say "aborting...";
    $cv->send;
};

say "waiting...";
$cv->recv;
