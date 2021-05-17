use utf8;
package DBIC::Violator::LogExplore::DB::Result::Request;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("request");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "start_ts",
  { data_type => "integer", is_nullable => 0 },
  "remote_addr",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "username",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 32,
  },
  "uri",
  { data_type => "varchar", is_nullable => 0, size => 512 },
  "method",
  { data_type => "varchar", is_nullable => 0, size => 8 },
  "user_agent",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 1024,
  },
  "referer",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 512,
  },
  "status",
  { data_type => "char", default_value => \"null", is_nullable => 1, size => 3 },
  "res_length",
  { data_type => "integer", default_value => \"null", is_nullable => 1 },
  "res_content_type",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 64,
  },
  "end_ts",
  { data_type => "integer", default_value => \"null", is_nullable => 1 },
  "elapsed_ms",
  { data_type => "integer", default_value => \"null", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "queries",
  "DBIC::Violator::LogExplore::DB::Result::Query",
  { "foreign.request_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-05-17 13:40:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SSy6xCcvzphACidC9so3PA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
