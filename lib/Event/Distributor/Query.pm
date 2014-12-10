#  You may distribute under the terms of either the GNU General Public License
#  or the Artistic License (the same terms as Perl itself)
#
#  (C) Paul Evans, 2014 -- leonerd@leonerd.org.uk

package Event::Distributor::Query;

use strict;
use warnings;

our $VERSION = '0.02';

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

   my $await = $self->{await};
   my @f;

   foreach my $sub ( @$subscribers ) {
      my $f = $sub->( $dist, @$args );
      push @f, $f;

      last if $f->is_ready and !$f->failure;
   }

   return Future->needs_any( @f )->then( sub {
      my @results = @_;
      # TODO: conversions?
      Future->done( @results );
   });
}
