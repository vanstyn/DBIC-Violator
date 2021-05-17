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
  
  my $dbFile = file($db_file)->absolute;
  
  for my $Child (map { $_->absolute } dir($db_dir)->children) {
    -f $Child or next;
    next if ("$Child" eq "$dbFile");
    
    my $v = &_get_dbic_violator_version_from_sqlite_db($Child);
    
    scream("$Child",$v);
    
    
  
  }
  
  

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