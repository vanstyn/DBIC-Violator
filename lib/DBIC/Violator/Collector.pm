package DBIC::Violator::Collector;

use strict;
use warnings;

# ABSTRACT: Collector object for DBIC::Violator

use Moo;
use Types::Standard qw(:all);
use Time::HiRes qw(gettimeofday tv_interval);

require SQL::Abstract::Tree;
use DBI;

use Plack::Util;
use Plack::Request;
use Plack::Response;

use RapidApp::Util ':all';


has 'log_db_file', is => 'ro', isa => Str, required => 1;

has 'sqlat', is => 'ro', default => sub {
  SQL::Abstract::Tree->new({
    profile => 'console_monochrome',
    placeholder_surround => ['',''],
    newline => '',
    indent_string => ''
  });
};


sub BUILD {
  my $self = shift;
  $self->logDbh;
}



sub _middleware_call_coderef {
  my $self = shift;
  
  return sub {
    my ($mw, $env) = @_;
    my $start = [gettimeofday];
    
    my $req = Plack::Request->new($env);
  
    my $reqRow = {
      start_ts     => scalar $start->[0],
      remote_addr  => scalar $req->address,
      uri          => scalar $req->uri->as_string,
      username     => scalar $req->user,
      method       => scalar $req->method,
      user_agent   => scalar $req->user_agent,
      referer      => scalar $req->referer
    };
    
    scream($reqRow);
    
    my $id = $self->_do_insert_request_row($reqRow);
    
    local $self->{_current_request_row_id} = $id;

    my $res = $mw->app->($env);
    
    return Plack::Util::response_cb($res, sub {
      my $res = shift;  
      my $Res = Plack::Response->new(@$res);
 
      my $end = [gettimeofday];
    
      $self->_do_update_request_row_by_id( $id => {
        status            => scalar $Res->status,
        res_length        => scalar $Res->content_length,
        res_content_type  => scalar $Res->content_type,
        end_ts            => scalar $end->[0],
        elapsed_ms        => scalar int(1000 * tv_interval($start,$end))
      });
        
    });
  }

}



has 'logDbh', is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  
  my $existed = (-f $self->log_db_file);
  
  my $dbh = DBI->connect(join(':','dbi','SQLite',$self->log_db_file));
  
  # super quick/dirty first time deploy:
  unless($existed) {
    $dbh->do($_) for (split(/;/,$self->_sqlite_ddl));
  }

  $dbh
};





sub _execute_around_coderef {
  my $self = shift;
  
  return sub {
    my ($orig, $pkg, $op, $ident, @args) = @_;
    
    my $meta = { op => $op, ident => $ident };
    
    my $info = $pkg->_resolve_ident_sources($ident) || {};
    
    $meta->{rsrc} = $info->{me} if ($info->{me});

    local $self->{_currently_executing_meta} = $meta;
    
    $pkg->$orig($op, $ident, @args)
    
  };
}



sub _dbh_execute_around_coderef {
  my $self = shift;
  
  return sub {
    my ($orig, $pkg, @args) = @_;
    my $start = [gettimeofday];
    
    my $logRow = {};
    
    $logRow->{unix_ts} = $start->[0];
    
    if(my $id = $self->{_current_request_row_id}) {
      $logRow->{request_id} = $id;
    }
    
    my $storage = $pkg;
    
    if(my $class = try{ref($storage->schema)}) {
      $logRow->{schema_class} = $class
    }
    
    if(my $driver = try{$storage->dbh->{Driver}{Name}}) {
      $logRow->{dbi_driver} = $driver;
    };
    
    if(my $cmeta = $self->{_currently_executing_meta}) {
      if (my $rsrc = $cmeta->{rsrc}) {
        $logRow->{source_name} = $cmeta->{rsrc}->source_name;
      }
      if (my $op = $cmeta->{op}) {
        $logRow->{operation} = $op; #$self->_resolve_op_type($op);
      }
    };
    
    my ($dbh, $sql, $bind, $bind_attrs) = @args;
    
    my @aRet = ();
    my $sRet = undef;
    
    my @fbind = $self->_format_for_trace($bind);
    $logRow->{statement} = $self->sqlat->format($sql,\@fbind);
    
    if(wantarray) {
      @aRet = $pkg->$orig(@args);
    }
    else {
      $sRet = $pkg->$orig(@args);
    }
    
    $logRow->{elapsed_ms} = int(1000 * tv_interval($start));
    
    $self->_do_insert_query_row($logRow);
    
    return wantarray ? @aRet : $sRet;
  };
}



sub _do_insert_query_row {
  my ($self, $row) = @_;
  
  my @colnames = keys %$row;
  
  my $insert = join('',
    'INSERT INTO [query] ',
    '(', join(',',map {"[$_]"} @colnames),') ',
    'VALUES (',join(',',map {'?'} @colnames),') '
  );
  
  my $sth = $self->logDbh->prepare($insert);
  
  $sth->execute(map { $row->{$_} } @colnames);
}



sub _do_insert_request_row {
  my ($self, $row) = @_;
  
  my @colnames = keys %$row;
  
  my $insert = join('',
    'INSERT INTO [request] ',
    '(', join(',',map {"[$_]"} @colnames),') ',
    'VALUES (',join(',',map {'?'} @colnames),') '
  );
  
  my $sth = $self->logDbh->prepare($insert);
  
  $sth->execute(map { $row->{$_} } @colnames);
  
  $self->logDbh->last_insert_id()
}


sub _do_update_request_row_by_id {
  my ($self, $id, $row) = @_;
  
  my @colnames = keys %$row;
  
  my $insert = join('',
    'UPDATE [request] ',
    'SET ', join(', ',map {"[$_] = ?"} @colnames),' ',
    'WHERE [id] = ' . $id
  );
  
  my $sth = $self->logDbh->prepare($insert);
  
  $sth->execute(map { $row->{$_} } @colnames);
}


# Copied from DBIx::Class::Storage::DBI
sub _format_for_trace {
  #my ($self, $bind) = @_;
 
  ### Turn @bind from something like this:
  ###   ( [ "artist", 1 ], [ \%attrs, 3 ] )
  ### to this:
  ###   ( "'1'", "'3'" )
 
  map {
    defined( $_ && $_->[1] )
      ? qq{'$_->[1]'}
      : q{NULL}
  } @{$_[1] || []};
}


sub _sqlite_ddl {q~
DROP TABLE IF EXISTS [request];
CREATE TABLE [request] (
  [id]                INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  [start_ts]          datetime NOT NULL,
  [remote_addr]       varchar(16) NOT NULL,
  [username]          varchar(32) DEFAULT NULL,
  [uri]               varchar(512) NOT NULL,
  [method]            varchar(8) NOT NULL,
  [user_agent]        varchar(1024) DEFAULT NULL,
  [referer]           varchar(512) DEFAULT NULL, 
  [status]            char(3) DEFAULT NULL,
  [res_length]        INTEGER DEFAULT NULL,
  [res_content_type]  varchar(64) DEFAULT NULL,
  [end_ts]            datetime DEFAULT NULL,
  [elapsed_ms]        INTEGER DEFAULT NULL  
);


DROP TABLE IF EXISTS [query];
CREATE TABLE [query] (
  [id] INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  [unix_ts] integer NOT NULL,
  [request_id] INTEGER DEFAULT NULL,
  [dbi_driver] varchar(32) DEFAULT NULL,
  [schema_class] varchar(128) default NULL,
  [source_name] varchar(128) default NULL,
  [operation] varchar(6) DEFAULT NULL,
  [statement] text,
  [elapsed_ms]  INTEGER NOT NULL, 
  FOREIGN KEY ([request_id]) REFERENCES [request] ([id]) ON DELETE CASCADE ON UPDATE CASCADE
);


~}



1;