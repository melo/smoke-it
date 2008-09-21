#!perl

use strict;
use warnings;
use Test::Most qw( no_plan );

BEGIN {
  $INC{'LWP/UserAgent.pm'} = '1'; # We provide our own
  use App::Smolder::Report;
}

my $sr = App::Smolder::Report->new;
ok($sr);
ok(!defined($sr->dry_run));
ok(!defined($sr->username));
ok(!defined($sr->password));
ok(!defined($sr->project_id));
ok(!defined($sr->smolder_server));
ok(!defined($sr->run_as_api));
ok(!defined($sr->err_msg));

my @incr_tests = (
  {
    add_to_cfg => {},
    re => qr/Required 'smolder_server' setting is empty or missing/,
  },
  
  {
    add_to_cfg => { smolder_server => 'server.example.com' },
    re => qr/Required 'project_id' setting is empty or missing/,
  },

  {
    add_to_cfg => { project_id => 1 },
    re => qr/Required 'username' setting is empty or missing/,
  },
  
  {
    add_to_cfg => { username => 'user1' },
    re => qr/Required 'password' setting is empty or missing/,
  },
  
  {
    add_to_cfg => { password => 'pass1' },
    re => qr/You must provide at least one report to upload/,
  },
);

foreach my $t (@incr_tests) {
  $sr->_merge_cfg_hash($t->{add_to_cfg});
  throws_ok sub { $sr->report }, $t->{re};
}

lives_ok sub { $sr->report('Makefile.PL') };

cmp_deeply($LWP::UserAgent::last_post, [
  'http://server.example.com/app/developer_projects/process_add_report/1',
  'Content-Type' => 'form-data',
  'Content'      => [
    username => 'user1',
    password => 'pass1',
    tags     => '',
    report_file => ['Makefile.PL'],
  ],
]);


package LWP::UserAgent;

use strict;

our $last_post;

sub new { return bless {}, $_[0] }

sub post {
  my $self = shift;
  $last_post = [@_];
  
  return HTTP::Response->new(
    '302',
    'Okidoky',
    [ Location => '/redirected/to/me' ],
  );
}

1;
