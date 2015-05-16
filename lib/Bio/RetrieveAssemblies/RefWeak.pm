package Bio::RetrieveAssemblies::RefWeak;
use Moose;
with('Bio::RetrieveAssemblies::RemoteSpreadsheetRole');

# ABSTRACT: Get the blacklist of accession numbers from refweak

=head1 SYNOPSIS

Get the blacklist of accession numbers from refweak

    use Bio::RetrieveAssemblies::RefWeak;
    my $obj = Bio::RetrieveAssemblies::RefWeak->new();
    my %accessions_hash  = $obj->accessions();

=cut

has 'url' => ( is => 'ro', isa => 'Str', default => 'https://raw.githubusercontent.com/refweak/refweak/master/refweak.tsv' );
has 'accession_column_index'  => ( is => 'ro', isa => 'Int',     default => 0 );
has 'accession_column_header' => ( is => 'ro', isa => 'Str',     default => "accession" );
has 'accessions'              => ( is => 'ro', isa => 'HashRef', lazy    => 1, builder => '_build_accessions' );

__PACKAGE__->meta->make_immutable;
no Moose;
1;
