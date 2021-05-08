package DBIC::Violator::Collector;

use strict;
use warnings;

# ABSTRACT: Collector object for DBIC::Violator

use Moo;
use Types::Standard qw(:all);
use Time::HiRes qw(gettimeofday tv_interval);


require SQL::Abstract::Tree;

use DBI;



use RapidApp::Util ':all';




1;