#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Future;
use Event::Distributor;

# subscribe_sync
{
   my $dist = Event::Distributor->new;
   $dist->declare_signal( "alert" );

   my $called;
   $dist->subscribe_sync( alert => sub { $called++ } );

   my $f = $dist->fire_async( alert => );

   ok( $f->is_ready, '$f already ready for only sync subscriber' );
   ok( $called, 'Synchronous subscriber actually called' );
}

# fire_sync
{
   my $dist = Event::Distributor->new;
   $dist->declare_signal( "alert" );

   $dist->subscribe_async( alert => sub { Future->done } );

   $dist->fire_sync( alert => );
   pass( 'Synchronous fire returns immediately' );
}

done_testing;
