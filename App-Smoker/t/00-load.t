#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'App::Smoker' );
}

diag( "Testing App::Smoker $App::Smoker::VERSION, Perl $], $^X" );
