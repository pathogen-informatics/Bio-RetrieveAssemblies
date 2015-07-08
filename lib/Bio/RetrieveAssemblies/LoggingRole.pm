package Bio::RetrieveAssemblies::LoggingRole;

use Moose::Role;
use Log::Log4perl qw(:easy);

# ABSTRACT: Role for logging

=head1 SYNOPSIS

Role for logging

=cut

has 'logger'                  => ( is => 'rw', lazy => 1, builder => '_build_logger');
has 'verbose'                 => ( is => 'rw', isa => 'Bool',      default  => 0 );

sub _build_logger
{
    my ($self) = @_;
    Log::Log4perl->easy_init(level => $ERROR);
    my $logger = get_logger();
    return $logger;
}

1;
