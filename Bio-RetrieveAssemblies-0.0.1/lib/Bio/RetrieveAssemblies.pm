#!/usr/bin/env perl
package Bio::RetreveAssemblies;
use Moose;
use File::Path qw(make_path);
# ABSTRACT: Get assemblies for a project accession
# PODNAME: retrieve_assemblies


has 'project_accessions'     => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'output_directory'       => ( is => 'rw', isa => 'Str', default => 'output' );
has 'file_type'              => ( is => 'rw', isa => 'Str', default => 'annotation' );
has 'organism_type'          => ( is => 'rw', isa => 'Str', default => 'BCT' );



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
	
	# This message 
    retrieve_assemblies -h 
	
USAGE
}

sub download
{
	my($self) = @_;
    $self->download_files_from_centre('embl');
    $self->download_files_from_centre('ddbj');
    $self->download_files_from_centre('genbank');
}


sub download_files_from_centre
{
    my($self, $centre) = @_;
	my $download_url = "http://www.ncbi.nlm.nih.gov/Traces/wgs/?&size=100&term=".$centre."&order=prefix&dir=asc&version=last&state=live&update_date=any&create_date=any&retmode=text&size=all";
	open(my $in_fh, "-|", "curl \"$download_url\" | grep ".$self->organism_type);

    make_path( $self->output_directory);
    while(<$in_fh>)
    {
       my $line = $_;
       my @assembly_details = split(/\t/,$line);	
       
	   for my $project_accession(@{$self->project_accessions})
	   {
		   if($project_accession eq $assembly_details[2])
		   {
	       if($self->file_type eq 'assembly')
	       {
               my $source_url =  'http://www.ncbi.nlm.nih.gov/Traces/wgs/?download='.$assembly_details[0].'.1.fsa_nt.gz';
               system("wget -O ".$self->output_directory."/".$assembly_details[0].'.1.fsa_nt.gz'." $source_url");
           	
	       }
	       else
	       {
	    	   my $source_url =  'http://www.ncbi.nlm.nih.gov/Traces/wgs/?download='.$assembly_details[0].'.1.gbff.gz';
               system("wget -O ".$self->output_directory."/".$assembly_details[0].'.1.gbff.gz'." $source_url");
           	}
		}
	   }
    
    }

}


__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

retrieve_assemblies - Get assemblies for a project accession

=head1 VERSION

version 0.0.1

=head1 SYNOPSIS

Download assemblies for a project accession

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2015 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
