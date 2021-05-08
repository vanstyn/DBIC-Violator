package DBIC::Violator::Plack::Middleware;
use parent 'Plack::Middleware';

use strict;
use warnings;

# ABSTRACT: Plack Middleware hook for DBIC::Violator

sub call {
  my ($self, $env) = @_;

  # Start of request

  my $ret = $self->app->($env);
  
  # End of request
  
  $ret
}


1;