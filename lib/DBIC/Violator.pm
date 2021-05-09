package DBIC::Violator;

use strict;
use warnings;

# ABSTRACT: Violate DBIC's most private moments

use DBIC::Violator::Collector;
require DBIx::Class::Storage::DBI;
use Class::MOP::Class;


use RapidApp::Util ':all';

sub import {
  my $pkg = shift;
  
  #initialize immediately on use:
  $pkg->collector;
  
  return 1;
}


our $INITIALIZED = 0;
our $COLLECTOR_INSTANCE = undef;


sub collector {
  my $pkg = shift;
  return $COLLECTOR_INSTANCE if ($INITIALIZED);
  $COLLECTOR_INSTANCE //= $pkg->_init_attach_collector
}

sub _init_attach_collector {
  my $pkg = shift;
  return $COLLECTOR_INSTANCE if ($INITIALIZED);
  
  $INITIALIZED = 1; # one and only one shot - we get it here and now or never
  
  # Currently only enable via env var:
  my $dn = $ENV{DBIC_VIOLATOR_DB_DIR} or return;
  
  my $Collector = DBIC::Violator::Collector->new({ log_db_dir => $dn });
  
  my $package = 'DBIx::Class::Storage::DBI';
  $pkg->__attach_around_sub($package, '_execute'     => $Collector->_execute_around_coderef);
  $pkg->__attach_around_sub($package, '_dbh_execute' => $Collector->_dbh_execute_around_coderef);
  
  $COLLECTOR_INSTANCE = $Collector
}



sub __attach_around_sub {
  my ($pkg, $package, $method, $around) = @_;

  #### This is based on RapidApp's 'debug_around' -
  #
  # It's a Moose class or otherwise already has an 'around' class method:
  if($package->can('around')) {
    $package->can('around')->($method => $around);
  }
  else {
    # The class doesn't have an around method, so we'll setup manually with Class::MOP:
    my $meta = Class::MOP::Class->initialize($package);
    $meta->add_around_method_modifier($method => $around);
  }
  #
  ####
}




1;