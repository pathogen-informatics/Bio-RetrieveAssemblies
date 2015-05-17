#!/usr/bin/env perl
package Bio::RetrieveAssemblies;
use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::RetrieveAssemblies::WGS;
use Bio::RetrieveAssemblies::AccessionFile;

# ABSTRACT: Download assemblies from GenBank

=head1 SYNOPSIS

Download assemblies from GenBank.
All the assemblies are automatically filtered against RefWeak to remove poor quality data.

=cut

has 'search_term'      => ( is => 'rw', isa => 'Str' );
has 'output_directory' => ( is => 'rw', isa => 'Str', default => 'downloaded_files' );
has 'file_type'        => ( is => 'rw', isa => 'Str', default => 'genbank' );
has 'organism_type'    => ( is => 'rw', isa => 'Str', default => 'BCT' );
has 'query'            => ( is => 'rw', isa => 'Str',      default  => '*' );
has 'args'             => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'      => ( is => 'ro', isa => 'Str', required => 1 );

sub _setup_inputs {
    my ($self) = @_;
    my ( $help, $file_type, $output_directory, $organism_type,$query );
    GetOptionsFromArray(
        $self->args,
        'p|organism_type=s'    => \$organism_type,
        'f|file_type=s'        => \$file_type,
        'o|output_directory=s' => \$output_directory,
        'q|query=s'            => \$query,
        'h|help'               => \$help,
    );

    if ( $help || @{ $self->args } == 0 ) {
        print $self->usage_text();
        die;
    }

    $self->output_directory($output_directory) if ($output_directory);
    $self->file_type($file_type)               if ($file_type);
    $self->organism_type($organism_type)       if ($organism_type);
    $self->query($query)                       if ($query);

    $self->search_term( $self->args->[0] );
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: retrieve_assemblies [options]
    Download WGS assemblies or annotation from GenBank. All accessions are screened against RefWeak.
	
	# Download all assemblies in a BioProject
	retrieve_assemblies PRJEB8877
	
	# Download all assemblies for Salmonella 
	retrieve_assemblies Salmonella
    
	# Download all assemblies for Typhi 
	retrieve_assemblies Typhi
	
	# Set the output directory
	retrieve_assemblies -o my_salmonella Salmonella
	
	# Get GFF3 files instead of GenBank files
	retrieve_assemblies -f gff Salmonella
    
	# Get FASTA files instead of GenBank files
	retrieve_assemblies -f fasta Salmonella
    
	# Search for a different category, VRT/INV/PLN/MAM/PRI/ENV (default is BCT)
	retrieve_assemblies -p MAM Canis 

	# This message 
    retrieve_assemblies -h 
	
USAGE
}

sub download {
    my ($self) = @_;
    $self->_setup_inputs;

    my $wgs_assemblies = Bio::RetrieveAssemblies::WGS->new( query => $self->query, organism_type => $self->organism_type, search_term => $self->search_term );

    for my $accession ( sort keys %{ $wgs_assemblies->accessions() } ) {
        my $accession_file = Bio::RetrieveAssemblies::AccessionFile->new(
            accession        => $accession,
            file_type        => $self->file_type,
            output_directory => $self->output_directory
        );
        $accession_file->download_file();
    }
    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
