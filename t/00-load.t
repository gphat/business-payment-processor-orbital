#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Business::Payment::Processor::Orbital' );
}

diag( "Testing Business::Payment::Processor::Orbital $Business::Payment::Processor::Orbital::VERSION, Perl $], $^X" );
