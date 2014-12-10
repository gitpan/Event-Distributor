#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

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

# failure
{
   my $dist = Event::Distributor->new;
   $dist->declare_signal( "waah" );

   $dist->subscribe_sync( waah => sub { die "Failure" } );

   my $called;
   $dist->subscribe_sync( waah => sub { $called++ } );

   like( exception { $dist->fire_sync( "waah" ) },
         qr/^Failure /,
         '->fire_sync raises exception' );
   ok( $called, 'second subscriber still invoked after first failure' );
}

# Multiple failures
{
   my $dist = Event::Distributor->new;
   $dist->declare_signal( "all_broken" );

   $dist->subscribe_sync( all_broken => sub { die "One failed\n" } );
   $dist->subscribe_sync( all_broken => sub { die "Two failed\n" } );

   is( exception { $dist->fire_sync( "all_broken" ) },
      "Multiple subscribers failed:\n" .
      " | One failed\n" .
      " | Two failed\n",
      '->fire_sync raises special multiple failure' );
}

done_testing;
