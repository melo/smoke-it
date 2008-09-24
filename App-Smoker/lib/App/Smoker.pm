package App::Smoker;

use warnings;
use strict;
use English qw( -no_match_vars );
use 5.008;
use Getopt::Long;

our $VERSION = '0.01';


###################
# Smolder reporting

sub run {
  my ($self, $base_dir) = @_;
  
  if (!$base_dir) {
    $base_dir = (getpwuid($EUID))[7];
    $self->_fatal("You do not exist: user $EUID not found")
      unless $base_dir;
    $base_dir .= '/repositories';
  }
  
  return $self->_smoke_all_repositories_in($base_dir);
}

sub _smoke_all_repositories_in {
  my ($self, $d) = @_;
  
  _foreach_directory($d, sub {
    my ($p) = @_;
    
    $self->_smoke_repository($p);
  });
}

sub _smoke_repository {
  my ($self, $d) = @_;

  return unless $self->update_scm($d);
  
  return if $self->_smoke_dir($d);
   
  _foreach_directory($d, sub {
    my ($p) = @_;
    
    $self->_smoke_dir($p);
  });
}

sub _smoke_dir {
  my ($self, $d) = @_;
  
  return $self->_run_smoker($d) if -e "$d/.smoker";
  return $self->_run_prove_and_report_it($d) if -d "$d/t";
  return;
}

sub _run_smoker {
  my ($self, $d) = @_;
  
  chdir($d) || $self->_fatal("Could not chdir() to '$d': $!");
  
  system('/bin/sh', "./.smoke");
  
  return 1;
}

sub _run_prove_and_report_it {
  my ($self, $d) = @_;
  
  chdir($d) || $self->_fatal("Could not chdir() to '$d': $!");
  
  system('prove', '-l', '-a', 'smoker_report.tgz');
  if (-e 'smoker_report.tgz') {
    system('smolder_report', 'smoker_report.tgz');
    unlink('smoker_report.tgz');
  }
  
  return 1;
}


################
# SCM operations

sub update_scm {
  my ($self, $d) = @_;
  
  chdir($d) || return;

  my @cmd;  
  if    (-d '.git') { @cmd = qw(git pull -f) }
  elsif (-d '.svn') { @cmd = qw(svn update)  }

  $self->_fatal("Directory '$d' uses unknown SCM system") unless @cmd;
  
  my $ok = system(@cmd);  
  return 1 if $ok == 0;
  
  my $cmd = join(' ', @cmd);
  if ($? == -1) {
    $self->_fatal("Could not exec '$cmd': $!");
  }
  elsif (my $signal = $? & 127) {
    $self->_fatal("Command '$cmd' died with signal $signal");
  }
  else {
    $self->_error("Command '$cmd' exited with value ", $? >> 8);
  }
  
  return 0;
}


##################################
# Deal with command line arguments

sub process_args {
  my ($self) = @_;
  
  my ($quiet);
  my $ok = GetOptions(
    "quiet"        => \$quiet,
  );
  exit(2) unless $ok;
  
  $self->{quiet} = $quiet;
  
  return;
}

#######
# Utils

sub _fatal {
  my ($self, $mesg, @more) = @_;
  
  $mesg = "FATAL: $mesg\n";
  foreach my $line (@more) {
    $mesg .= "  $line\n";
  }
  
  print $mesg;
  exit(1);
}

sub _error {
  my ($self, $mesg) = @_;
  return if $self->quiet;

  print "ERROR: $mesg\n";

  return;
}

sub _log {
  my ($self, $mesg) = @_;
  return if $self->quiet;

  print "$mesg\n";

  return;
}

sub _foreach_directory {
  my ($dir, $cb) = @_;
  
  opendir(my $dirh, $dir) || return;
  
  while (my $entry = readdir($dirh)) {
    next if $entry =~ m/^[.]/;
    
    my $path = "$dir/$entry";
    next unless -d $path;
    
    $cb->($path);
  }
  closedir($dirh);
  
  return;
}


###########################
# Constructor and accessors
#   boring stuff

sub new {
  my $class = shift;
  my $self = bless {}, $class;

  my %args;
  if (ref($_[0])) { %args = %{$_[0]} }
  else            { %args = @_       }

  while (my ($k, $v) = each %args) {
    $self->{$k} = $v;
  }
  
  return $self;
}

sub quiet { return $_[0]{quiet} }


__END__

=encoding utf8

=head1 NAME

App::Smoker - The great new App::Smoker!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    # Use the smoker command line for now
    

=head1 DESCRIPTION

The App::Smoker distribution provides a simple system to run smoke tests
on several repositories.


=head1 AUTHOR

Pedro Melo, C<< <melo at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-smoker at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Smoker>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Smoker


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Smoker>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Smoker>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-Smoker>

=item * Search CPAN

L<http://search.cpan.org/dist/App-Smoker>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Pedro Melo

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

42; # End of App::Smoker
