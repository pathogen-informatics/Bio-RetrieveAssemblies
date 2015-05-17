package Bio::RetrieveAssemblies::Exceptions;

# ABSTRACT: Exceptions for input data

=head1 SYNOPSIS

Exceptions for input data 

=cut

use Exception::Class (
    Bio::RetrieveAssemblies::Exceptions::CouldntDownload => { description => 'Couldnt download RefWeak' },
    Bio::RetrieveAssemblies::Exceptions::CSVParser       => { description => 'TSV parser error' },
    Bio::RetrieveAssemblies::Exceptions::GenBankToGFFConverter => { description => 'Couldnt convert GenBank file to GFF file' },
    Bio::RetrieveAssemblies::Exceptions::FileCopyFailed => { description => 'Couldnt copy the file' },

);

1;
