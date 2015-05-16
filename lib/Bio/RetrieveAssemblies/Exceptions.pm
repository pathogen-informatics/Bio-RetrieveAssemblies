package Bio::RetrieveAssemblies::Exceptions;

# ABSTRACT: Exceptions for input data

=head1 SYNOPSIS

Exceptions for input data 

=cut

use Exception::Class (
    Bio::RetrieveAssemblies::Exceptions::CouldntDownload => { description => 'Couldnt download RefWeak' },
    Bio::RetrieveAssemblies::Exceptions::CSVParser              => { description => 'CSV parser error' },
);

1;
