#  You may distribute under the terms of either the GNU General Public License
#  or the Artistic License (the same terms as Perl itself)
#
#  (C) Paul Evans, 2014 -- leonerd@leonerd.org.uk

package Event::Distributor::Signal;

use strict;
use warnings;

our $VERSION = '0.01';

use Future;

sub new
{
   my $class = shift;
   return bless {}, $class;
}

sub fire
{
   my $self = shift;
   my ( $dist, $args, $subscribers ) = @_;

   return Future->wait_all(
      map { $_->( $dist, @$args ) } @$subscribers
   )->then_done( () );
}

0x55AA
