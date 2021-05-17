use strict;
use warnings;

use DBIC::Violator::LogExplore;

my $app = DBIC::Violator::LogExplore->apply_default_middlewares(DBIC::Violator::LogExplore->psgi_app);
$app;

