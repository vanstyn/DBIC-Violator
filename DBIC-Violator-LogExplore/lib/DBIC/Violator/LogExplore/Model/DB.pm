package DBIC::Violator::LogExplore::Model::DB;
use Moo;
extends 'Catalyst::Model::DBIC::Schema';
with 'RapidApp::Util::Role::ModelDBIC';

use strict;
use warnings;

use RapidApp::Util ':all';
use Path::Class qw(file dir);

my $db_path = file( 
  RapidApp::Util::find_app_home('DBIC::Violator::LogExplore'), 
  'dbic-violator-log.db' 
);

__PACKAGE__->config(
  schema_class => 'DBIC::Violator::LogExplore::DB',

  connect_info => {
    dsn             => "dbi:SQLite:$db_path",
    user            => '',
    password        => '',
    quote_names     => q{1},
    sqlite_unicode  => q{1},
    on_connect_call => q{use_foreign_keys},
  },

  # Configs for the RapidApp::RapidDbic Catalyst Plugin:
  RapidDbic => {

    # use only the relationship column of a foreign-key and hide the
    # redundant literal column when the names are different:
    hide_fk_columns => 1,

    # The grid_class is used to automatically setup a module for each source in the
    # navtree with the grid_params for each source supplied as its options.
    grid_class  => 'DBIC::Violator::LogExplore::Module::GridBase',
    grid_params => {
      # The special '*defaults' key applies to all sources at once
      '*defaults' => {
        include_colspec => ['*'],    #<-- default already ['*']
        ## uncomment these lines to turn on editing in all grids
        #updatable_colspec   => ['*'],
        #creatable_colspec   => ['*'],
        #destroyable_relspec => ['*'],
        extra_extconfig => {
          store_button_cnf => {
            save => { showtext => 1 },
            undo => { showtext => 1 }
          }
        }
      }
    },

    # TableSpecs define extra RapidApp-specific metadata for each source
    # and is used/available to all modules which interact with them
    TableSpecs => {
      'DbInfo' => {
        display_column => 'name',
        title          => 'DbInfo',
        title_multi    => 'DbInfo Rows',
        iconCls        => 'ra-icon-pg',
        multiIconCls   => 'ra-icon-pg-multi',
        columns        => {
          name => {
            header => 'name',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          value => {
            header => 'value',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
        },
      },
      'Query' => {
        display_column => 'id',
        title          => 'Query',
        title_multi    => 'Query Rows',
        iconCls        => 'ra-icon-pg',
        multiIconCls   => 'ra-icon-pg-multi',
        columns        => {
          id => {
            allow_add => 0,
            header    => 'id',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          unix_ts => {
            header => 'unix_ts',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          request_id => {
            header => 'request_id',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            profiles => ['hidden'],
          },
          dbi_driver => {
            header => 'dbi_driver',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          schema_class => {
            header => 'schema_class',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          source_name => {
            header => 'source_name',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          operation => {
            header => 'operation',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          statement => {
            header => 'statement',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          elapsed_ms => {
            header => 'elapsed_ms',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          request => {
            header => 'request',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
        },
      },
      'Request' => {
        display_column => 'id',
        title          => 'Request',
        title_multi    => 'Request Rows',
        iconCls        => 'ra-icon-pg',
        multiIconCls   => 'ra-icon-pg-multi',
        columns        => {
          id => {
            allow_add => 0,
            header    => 'id',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          start_ts => {
            header => 'start_ts',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          remote_addr => {
            header => 'remote_addr',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          username => {
            header => 'username',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          uri => {
            header => 'uri',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          method => {
            header => 'method',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          user_agent => {
            header => 'user_agent',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          referer => {
            header => 'referer',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          status => {
            header => 'status',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          res_length => {
            header => 'res_length',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          res_content_type => {
            header => 'res_content_type',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          end_ts => {
            header => 'end_ts',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          elapsed_ms => {
            header => 'elapsed_ms',
            #width => 100,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
          queries => {
            header => 'queries',
            #width => 100,
            #sortable => 1,
            #renderer => 'RA.ux.App.someJsFunc',
            #profiles => [],
          },
        },
      },
    },
  },

);

=head1 NAME

DBIC::Violator::LogExplore::Model::DB - Catalyst/RapidApp DBIC Schema Model

=head1 SYNOPSIS

See L<DBIC::Violator::LogExplore>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<DBIC::Violator::LogExplore::DB>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema::ForRapidDbic - 0.65

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
