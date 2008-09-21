#! perl

use strict;
use warnings;
use Test::Most 'no_plan';
use Cwd;
use App::Smolder::Report;

my $sr = App::Smolder::Report->new;
ok(!defined($sr->smolder_server));
ok(!defined($sr->project_id));
ok(!defined($sr->username));
ok(!defined($sr->password));

my $cfg;
lives_ok sub {
  $cfg = $sr->_read_cfg_file('t/data/cfg/smolder_1.conf');
};
cmp_deeply($cfg, {
  smolder_server => 'server1',
  project_id     => 1,
  username       => 'user1',
  password       => 'pass1',
});

$sr->_merge_cfg_hash($cfg);
cmp_deeply($cfg, {});
is($sr->smolder_server, 'server1');
is($sr->project_id,     1);
is($sr->username,       'user1');
is($sr->password,       'pass1');

SKIP: {
  my $cwd = getcwd();
  my $base = 't/data/cfg';
  my $dir = "$base/cwd";
  chdir($dir) || skip "Could not chdir to $dir: $!", 4;
  
  $ENV{HOME} = "$cwd/$base/home";
  
  $sr = App::Smolder::Report->new;
  $sr->_load_configs;
  is($sr->smolder_server, 'smolder.example.com');
  is($sr->project_id,     45);
  is($sr->username,       'superme');
  is($sr->password,       'supersecret');
  
  
  $sr = App::Smolder::Report->new;
  $ENV{APP_SMOLDER_REPORT_CONF} = 'tweak.conf';
  $sr->_load_configs;
  
  is($sr->smolder_server, 'smolder.example.com');
  is($sr->project_id,     45);
  is($sr->username,       'superme');
  is($sr->password,       'omfg');
}
