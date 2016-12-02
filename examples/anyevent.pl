#!/usr/bin/env perl
use 5.14.1;
use warnings;

use AnyEvent;
use Twitter::API::AnyEvent;

my $api = Twitter::API::AnyEvent->new(
    consumer_key        => $ENV{CONSUMER_KEY},
    consumer_secret     => $ENV{CONSUMER_SECRET},
    access_token        => $ENV{ACCESS_TOKEN},
    access_token_secret => $ENV{ACCESS_TOKEN_SECRET},
);

my $cv = AE::cv;

$api->get('account/verify_credentials', sub {
    my ( $error, $r, $c ) = @_;

    $cv->croak($error) if $error;

    say "$$r{screen_name} is authorized";
    say "remaining: ", $c->rate_limit_remaining;
    say "until: ", scalar localtime $c->rate_limit_reset;
    $cv->send;
});

$cv->recv;
