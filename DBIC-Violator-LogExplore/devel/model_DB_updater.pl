#!/usr/bin/env perl
#
# File bootstrapped by RapidApp 1.3300
#

use strict;
use warnings;

use RapidApp::Util ':all';

use Getopt::Long;
use Pod::Usage;

use DBIx::Class::Schema::Loader;
use Module::Runtime;
use IPC::Cmd qw[can_run run_forked];
use Path::Class qw(file dir);

require Module::Locate;
use RapidApp::Util::RapidDbic::CfgWriter;

my($from_ddl,$schema,$cfg,$all,$Go);

GetOptions(  'schema+' => \$schema,
  'cfg+'    => \$cfg,
  'all+'    => \$all,
  'go+'     => \$Go
);

if($all) {
  $cfg    = 1;
  $schema = 1;}

$schema = 1 if ($from_ddl);


pod2usage(1) unless ($schema || $cfg);



use FindBin;
use lib "$FindBin::Bin/../lib";

my $app_class   = 'DBIC::Violator::LogExplore';
my $model_class = 'DBIC::Violator::LogExplore::Model::DB';

my $approot = "$FindBin::Bin/..";
my $applib = "$approot/lib";

# make an $INC{ $key } style string from the class name
(my $pm = "$app_class.pm") =~ s{::}{/}g;
my $appfile = file($applib,$pm)->absolute->resolve;

# This is purely for Catalyst::Utils::home() which will be invoked when 
# we require the model class in the next statement so it can find the
# home directory w/o having to actually use/load the app class:
$INC{ $pm } = "$appfile";

Module::Runtime::require_module($model_class);

my ($schema_class,$dsn,$user,$pass) = (
  $model_class->config->{schema_class}, 
  $model_class->config->{connect_info}{dsn},
  $model_class->config->{connect_info}{user}, 
  $model_class->config->{connect_info}{password}
);



if($schema) {

  my @connect = ($dsn,$user,$pass);
  print "\nDumping schema \"$schema_class\" to \"" . file($applib)->resolve->relative . "\"\n";
  print "[ " . join(' ',map { $_||"''" } @connect) . " ]\n\n";

  DBIx::Class::Schema::Loader::make_schema_at(
    $schema_class, 
    {
      debug => 1,
      dump_directory => $applib,
      use_moose	=> 1, generate_pod => 0,
      components => ["InflateColumn::DateTime"],
    },
    [ 
      @connect,
      { loader_class => 'RapidApp::Util::MetaKeys::Loader' }
    ]
  );

  print "\n";

}

if($cfg) {
  my $pm_path = file( scalar Module::Locate::locate($model_class) );
  dir($applib)->contains($pm_path) or die "$pm_path is not within the local dir!";
  
  $pm_path = $pm_path->resolve->absolute;
  my $appdir = dir($approot)->resolve->absolute;
  
  print join('',
    "\n==> Updating TableSpecs configs in ",
    $appdir->basename,'/',$pm_path->relative($appdir),
    " ... "
  );
  
  my $CfgW = RapidApp::Util::RapidDbic::CfgWriter->new({ pm_file => "$pm_path" });

  $CfgW->save_to( "$pm_path" );
  
  print "done.\n";
}


1;
__END__

=head1 NAME
model_DB_updater.pl - updater script for RapidDbic model 'DBIC::Violator::LogExplore::Model::DB'

=head1 SYNOPSIS

 perl devel/model_DB_updater.pl [options]

 Options:
   --schema    Regenerate DBIx::Class schema   
   --cfg       Update TableSpec configs for new defaults (nondestructive)

   --all       Shortcut for: --schema --cfg 


 TableSpec Config Update (--cfg):
   When called with the --cfg option, the TableSpec configs within the RapidDbic section of
   the model will be updated to match the schema class. This is a non-destructive operation,
   it will not change any existing configs, just add defaults that do not already exist. This
   adds boilerplate for new tables and columns which were added after the app was bootstrapped.


