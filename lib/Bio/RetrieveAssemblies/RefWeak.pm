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
has 'accession_column_index' => ( is => 'ro', isa => 'Int', default => 0 );
has 'accessions' => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_accessions' );

sub _build_accessions {
    my ($self) = @_;

    my %accessions;
    for my $line ( @{ $self->_tsv_content } ) {
        $self->_tsv_parser->parse($line);
        my @columns = $self->_tsv_parser->fields();
        next if($columns[$self->accession_column_index] eq "accession");
        next if($columns[0] eq '' || $columns[0] =~ /^#/);
        
        $accessions{$columns[$self->accession_column_index]} = 1;
    }
    return \%accessions;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
