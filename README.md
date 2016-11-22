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
my $api = Twitter::API::AnyEvent->new(
    traits => [ qw/ApiMethods/ ],
    %other_new_options,
);

$api->show_user('twitter', sub {
    my ( $error, $r ) = @_;

    $cv->croak($error) if $error;

    say $r->{location};
    $cv->send;
});

$cv->recv;

```

Output:
```
San Francisco, CA
```

Authors
-------
* [Marc Mims](https://github.com/semifor)
