use inc::Module::Install;

name     'App-Smoker';
all_from 'lib/App/Smoker.pm';
author   'Pedro Melo <melo@cpan.org>';

build_requires 'Test::More';

auto_install;

WriteAll;

