#!/usr/bin/env perl
package Bio::RetrieveAssemblies;
use Moose;
use File::Path qw(make_path);

# ABSTRACT: Get assemblies for a project accession
# PODNAME: retrieve_assemblies

=head1 SYNOPSIS

Download assemblies for a project accession

=cut

has 'project_accessions' => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'output_directory'   => ( is => 'rw', isa => 'Str',      default  => 'output' );
has 'file_type'          => ( is => 'rw', isa => 'Str',      default  => 'annotation' );
has 'organism_type'      => ( is => 'rw', isa => 'Str',      default  => 'BCT' );
has 'query'              => ( is => 'rw', isa => 'Bool',     default  => 0 );
has 'gff_file'           => ( is => 'rw', isa => 'Bool',     default  => 0 );

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: retrieve_assemblies [options]
    Download assemblies for a given BioProject accession
	
	# get one project
	retrieve_assemblies PRJEB8877
	
	# multiple projects
	retrieve_assemblies PRJEB8877 PRJEB1111
	
	# update output directory
	retrieve_assemblies -o abc PRJEB8877
	
	# Get assemblies instead of genbank files
	retrieve_assemblies -f assembly PRJEB8877
	
	# Convert the Genbank files to GFF3 files
	retrieve_assemblies -g PRJEB8877
	
	# Search with a specific query instead of an accession number
	retrieve_assemblies -q Salmonella
	
	# Search for multiple queries
	retrieve_assemblies -q Salmonella Staph Strep

	# This message 
    retrieve_assemblies -h 
	
USAGE
}

sub download {
    my ($self) = @_;
    if ( $self->query ) {
        for my $query_value ( @{ $self->project_accessions } ) {
            $self->download_files_with_query($query_value);
        }
    }
    else {
        $self->download_files_from_centre('embl');
        $self->download_files_from_centre('ddbj');
        $self->download_files_from_centre('genbank');
    }
}

sub download_files_with_query {
    my ( $self, $query_value ) = @_;
    my $download_url = $self->_download_url($query_value);
    open( my $in_fh, "-|", "curl \"$download_url\" | grep " . $self->organism_type );

    make_path( $self->output_directory );
    while (<$in_fh>) {
        my $line = $_;
        my @assembly_details = split( /\t/, $line );
        $self->_download_sequence_file( $assembly_details[0] );

    }
	return 1;
}

sub download_files_from_centre {
    my ( $self, $centre ) = @_;
    my $download_url = $self->_download_url($centre);
    open( my $in_fh, "-|", "curl \"$download_url\" | grep " . $self->organism_type );

    make_path( $self->output_directory );
    while (<$in_fh>) {
        my $line = $_;
        my @assembly_details = split( /\t/, $line );

        for my $project_accession ( @{ $self->project_accessions } ) {
            if ( $project_accession eq $assembly_details[2] ) {
                $self->_download_sequence_file( $assembly_details[0] );
            }
        }
    }
	return 1;
}

sub _download_sequence_file {
    my ( $self, $sequence_accession ) = @_;
    if ( $self->file_type eq 'assembly' ) {
        my $source_url = 'http://www.ncbi.nlm.nih.gov/Traces/wgs/?download=' . $sequence_accession . '.1.fsa_nt.gz';
        system( "wget -O " . $self->output_directory . "/" . $sequence_accession . '.1.fsa_nt.gz' . " $source_url" );

    }
    else {
        my $source_url = 'http://www.ncbi.nlm.nih.gov/Traces/wgs/?download=' . $sequence_accession . '.1.gbff.gz';
        system( "wget -O " . $self->output_directory . "/" . $sequence_accession . '.1.gbff.gz' . " $source_url" );
		
		if($self->gff_file)
		{
			system("bp_genbank2gff3.pl -o ".$self->output_directory . " ".$self->output_directory . "/" . $sequence_accession . '.1.gbff.gz');
		}
    }
    return 1;
}

sub _download_url {
    my ( $self, $query ) = @_;
    return "http://www.ncbi.nlm.nih.gov/Traces/wgs/?&size=100&term=" . $query
      . "&order=prefix&dir=asc&version=last&state=live&update_date=any&create_date=any&retmode=text&size=all";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
