use utf8;
package DBIC::Violator::LogExplore::DB::Result::Query;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("query");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "unix_ts",
  { data_type => "integer", is_nullable => 0 },
  "request_id",
  {
    data_type      => "integer",
    default_value  => \"null",
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "dbi_driver",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 32,
  },
  "schema_class",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 128,
  },
  "source_name",
  {
    accessor => "column_source_name",
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 128,
  },
  "operation",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 6,
  },
  "statement",
  { data_type => "text", is_nullable => 1 },
  "elapsed_ms",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "request",
  "DBIC::Violator::LogExplore::DB::Result::Request",
  { id => "request_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-05-17 13:40:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:x/iNI+Xln/Oc/9UURQinxQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
