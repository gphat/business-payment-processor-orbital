use inc::Module::Install;

name     'Business-Payment-Processor-Orbital';
all_from 'lib/Business/Payment/Processor/Orbital.pm';
author   'Cory G Watson <gphat@cpan.org>';
license  'perl';

build_requires 'Test::More';

requires 'Business::Payment' => '0.01';

WriteAll;

