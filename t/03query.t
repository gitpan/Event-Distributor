#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Future;
use Event::Distributor;

{
   my $dist = Event::Distributor->new;
   $dist->declare_query( "question" );

   $dist->subscribe_sync( question => sub {
      return "The result", "here";
   });

   my @result = $dist->fire_sync( question => );

   is_deeply( \@result, [ "The result", "here" ], 'result of query event' );
}

# two sync subscribers
{
   my $dist = Event::Distributor->new;
   $dist->declare_query( "asking" );

   my $called;
   $dist->subscribe_sync( asking => sub { $called++; return 123 } );
   $dist->subscribe_sync( asking => sub { $called++; return 456 } );

   my $result = $dist->fire_sync( asking => );

   is( $result, 123, 'query event takes first result' );
   is( $called, 1, 'query event does not invoke later sync subscribers' );
}

done_testing;
