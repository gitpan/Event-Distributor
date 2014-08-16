#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Future;
use Event::Distributor;

# async->async
{
   my $dist = Event::Distributor->new;
   $dist->declare_signal( "alert" );

   my $called_f;
   my $called_dist;
   my @called_args;
   $dist->subscribe_async( alert => sub {
      $called_dist = shift;
      @called_args = @_;
      return $called_f = Future->new
   });

   my $f = $dist->fire_async( alert => "args", "here" );
   ok( $f, '->fire_async yields signal' );
   ok( !$f->is_ready, '$f not yet ready' );

   is( $called_dist, $dist, 'First arg to subscriber is $dist' );
   is_deeply( \@called_args, [ "args", "here" ], 'Args to subscriber' );

   $called_f->done();

   ok( $f->is_ready, '$f is now ready after $called_f->done' );

   is_deeply( [ $f->get ], [], '$f->get yields nothing' );
}

# two subscribers
{
   my $dist = Event::Distributor->new;
   $dist->declare_signal( "alarm" );

   my $f1;
   $dist->subscribe_async( alarm => sub { $f1 = Future->new } );

   my $f2;
   $dist->subscribe_async( alarm => sub { $f2 = Future->new } );

   my $f = $dist->fire_async( alarm => );

   ok( $f1 && $f2, 'Both subscribers invoked' );

   $f1->done;
   ok( !$f->is_ready, 'Result future still waiting after $f1->done' );

   $f2->done;
   ok( $f->is_ready, 'Result future now done after $f2->done' );
}

done_testing;
