package DBIC::Violator::Util;

use strict;
use warnings;

# ABSTRACT: Misc DBIC::Violator util functions

use DBI;
use Path::Class qw(file dir);

use RapidApp::Util ':all';

#
#   perl -MDBIC::Violator::Util -e 'DBIC::Violator::Util::_test_as_script' 
#
sub _test_as_script {
  $| = 1;
  &_merge_sqlite_files(@ARGV)
}

sub _merge_sqlite_files {
  $_[0] eq __PACKAGE__ and shift;
  my ($db_file, $db_dir) = @_;
  -f $db_file && -d $db_dir or die "must supply valid db_file and db_dir arguments";
  
  my $version = &_get_dbic_violator_version_from_sqlite_db($db_file) or die join('',
    "Failed to detect DBIC::Violator::VERSION in '$db_file'"
  );
  
  scream_color(GREEN.BOLD,"$db_file : ".$version);
  
  my @db_files = &_get_dbs_in_dir_matching_version($db_dir,$version,$db_file);
  
  die "no valid db files found in $db_dir" unless(scalar(@db_files) > 0);
  
  my $dbh = &_dbi_connect_sqlite_file($db_file);
  
  &_left_combine_sqlite_dbs($db_file,$_) for (@db_files);
  
  print "\n\n";
  
  #scream(\@db_files);
  
}


sub _left_combine_sqlite_dbs {
  $_[0] eq __PACKAGE__ and shift;
  my ($l_db, $r_db) = @_;
  -f $l_db && -f $r_db or die "must supply valid left and right db args";
  
  print "\n\n  -> merge $r_db into $l_db";
  
  my $dbh = &_dbi_connect_sqlite_file($l_db);
  
  &__dbh_do($dbh => "ATTACH DATABASE '$r_db' AS r_db");
  
  my $max_qId = &__dbh_max_col_in_table($dbh,'[id]','[query]');
  my $rmax_qId = &__dbh_max_col_in_table($dbh,'[id]','[r_db].[query]');
  $max_qId = $rmax_qId if ($rmax_qId > $max_qId);
  
  my $max_rId = &__dbh_max_col_in_table($dbh,'[id]','[request]');
  my $rmax_rId = &__dbh_max_col_in_table($dbh,'[id]','[r_db].[request]');
  $max_rId = $rmax_rId if ($rmax_rId > $max_rId);
  
  &__dbh_do($dbh => "UPDATE [r_db].[query]   SET [id] = [id] + $max_qId");
  &__dbh_do($dbh => "UPDATE [r_db].[request] SET [id] = [id] + $max_rId");
  &__dbh_do($dbh => "INSERT INTO [request] SELECT * FROM [r_db].[request]");
  &__dbh_do($dbh => "INSERT INTO [query]   SELECT * FROM [r_db].[query]");
  
  $dbh->disconnect;
  
  print "\n  => unlink $r_db";
  unlink $r_db;
  print "\n";

}



sub __dbh_max_col_in_table {
  $_[0] eq __PACKAGE__ and shift;
  my ($dbh, $col, $table) = @_;
  
  my $count = $dbh->selectcol_arrayref("SELECT COUNT(*) FROM $table")->[0];
  die "Failed to COUNT(*) $table" unless (defined $count);

  return 0 unless ($count > 0);
  
  my $max = ($dbh->selectcol_arrayref("SELECT MAX($col) FROM $table")||[])->[0]
    or die "Failed to identify max($col) in $table";
    
  $max
}


sub __dbh_do {
  $_[0] eq __PACKAGE__ and shift;
  my ($dbh, $sql) = @_;
  
  print "\n   > $sql";
  $dbh->do($sql) or die "\nerrored";

}


sub _get_dbs_in_dir_matching_version {
  $_[0] eq __PACKAGE__ and shift;
  my ($db_dir, $version, $ignore_file) = @_;
  $version and -d $db_dir or die "must supply valid db_dir and version arguments";
  
  my $iFile;
  $iFile = file($ignore_file)->absolute if ($ignore_file);
  
  my @db_files = ();
  
  my @Children = 
    map { $_->absolute } 
    sort { $a->basename cmp $b->basename } 
    grep { -f $_ }
    dir($db_dir)->children;
  
  for my $Child (@Children) {
    next if ($iFile and "$Child" eq "$iFile");
    no warnings;
    my $v = &_get_dbic_violator_version_from_sqlite_db($Child) or next;
    next unless ("$v" eq "$version");
    
    push @db_files, "$Child";
  }
  
  return @db_files
}



sub _dbi_connect_sqlite_file {
  $_[0] eq __PACKAGE__ and shift;
  my $db_file = shift or die "_dbi_connect_sqlite_file(): must supply path to SQLite db file";
  die "'$db_file' does not exist or not a regular file" unless (-f $db_file);
  DBI->connect(join(':','dbi','SQLite',$db_file),'','', {
    AutoCommit => 1,
    sqlite_use_immediate_transaction => 0,
  });
}

sub _get_dbic_violator_version_from_sqlite_db {
  $_[0] eq __PACKAGE__ and shift;
  my $db_file = shift;
  
  my $dbh = &_dbi_connect_sqlite_file($db_file) or return undef;
  
  my $arr = $dbh->selectcol_arrayref(
   'SELECT [value] FROM [db_info] WHERE [name] = "DBIC::Violator::VERSION"'
  ) || [];
  
  $dbh->disconnect;

  $arr->[0];
}



1;


__END__

=head1 NAME

DBIC::Violator::Util - Misc DBIC::Violator util functions

=head1 DESCRIPTION

This is currently an internal package used by L<DBIC::Violator> and should not be used directly.

=head1 SEE ALSO

=over

=item * 

L<DBIC::Violator>

=back


=head1 AUTHOR

Henry Van Styn <vanstyn@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2021 by IntelliTree Solutions llc.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut