package App::Smolder::Report;

use warnings;
use strict;
use LWP::UserAgent;

our $VERSION = '0.01';


###################
# Smolder reporting

sub run {
  my ($self) = @_;
  
  $self->_load_configs;
  
  $self->fatal("Required 'smolder_server' setting is empty or missing")
    unless $self->smolder_server;
  $self->fatal("Required 'project_id' setting is empty or missing")
    unless $self->project_id;
  $self->fatal("You must provide at least one report to upload")
    unless @ARGV;
  
  return $self->_upload_reports(@ARGV);
}

sub _upload_reports {
  my ($self, @reports) = @_;
  
  my $ua = LWP::UserAgent->new;
  my $url
    = $self->smolder_server
    . '/app/developer_projects/process_add_report/'
    . $self->project_id;
  
  foreach my $report_file (@reports) {
    $self->fatal("Could not read report file '$report_file'")
      unless -r $report_file;
    
    my $response = $ua->post(
      $url,
      'Content-Type' => 'form-data',
      'Content'      => [
        username => $self->username,
        password => $self->password,
        tags     => '',
        report_file => [$report_file],
      ],
    );
  }
}


###################################
# Configuration loading and merging

sub _load_configs {}


##################################
# Deal with command line arguments

sub process_args {
  
}


#######
# Utils

sub fatal {
  my ($self, $mesg) = @_;
  
  print STDERR "FATAL: $mesg\n";
  exit(1);
}


###########################
# Constructor and accessors
#   boring stuff

sub new {
  my $class = shift;
  
  return bless {}, $class;
}

sub cfg            { return $_[0]{cfg}            }
sub username       { return $_[0]{username}       }
sub password       { return $_[0]{password}       }
sub project_id     { return $_[0]{project_id}     }
sub smolder_server { return $_[0]{smolder_server} }

__END__

=encoding utf8

=head1 NAME

App::Smolder::Report - The great new App::Smolder::Report!

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

    # You should use the smolder_report frontend really...
    
    use App::Smolder::Report;

    my $app = App::Smolder::Report->new();
    $app->process_args(@ARGV);
    $app->run;

=head1 FUNCTIONS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Pedro Melo, C<< <melo at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-smolder-report at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Smolder-Report>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Smolder::Report


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Smolder-Report>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Smolder-Report>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-Smolder-Report>

=item * Search CPAN

L<http://search.cpan.org/dist/App-Smolder-Report>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Pedro Melo, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of App::Smolder::Report
