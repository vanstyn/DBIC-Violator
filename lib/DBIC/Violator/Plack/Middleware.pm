package DBIC::Violator::Plack::Middleware;
use parent 'Plack::Middleware';

use strict;
use warnings;

# ABSTRACT: Plack Middleware hook for DBIC::Violator

use Plack::Util;
use DBIC::Violator;

use RapidApp::Util ':all';

sub call {
  my ($self, $env) = @_;
  
  my $Collector = DBIC::Violator->collector;
  
  return $Collector 
    ? $Collector->_middleware_call_coderef->($self,$env)
    : $self->app->($env)
  
}


1;