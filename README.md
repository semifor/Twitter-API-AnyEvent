Twitter-API-AnyEvent
================================
A subclass of Twitter::API for asyncronous Twitter API calls.

Description
----------

Provides all the features of Twitter::API, but expects a callback as the final argument to get/post/request and API methods. Allows easy use of Twitter::API in an AnyEvent based application.

Install
-------
```
dzil install
```

Usage
-----

Basic example:

```perl
use AnyEvent;
use Twitter::API::AnyEvent;

my $cv = AE::cv;
my $api = Twitter::API::AnyEvent->new_with_traits(
    traits => [ qw/ApiMethods/ ],
    %other_new_options,
);

$api->show_user('twitter', sub {
    my ( $error, $r, $c ) = @_;

    $cv->croak($error) if $error;

    say $r->{location};
    say "remaing calls: ", $c->rate_limit_remaining;
    say "until: ", scalar localtime $c->rate_limit_reset;
    $cv->send;
});

$cv->recv;

```

Output:
```
San Francisco, CA
remaining calls: 74
until: Thu Dec  1 20:13:01 2016
```

Authors
-------
* [Marc Mims](https://github.com/semifor)
