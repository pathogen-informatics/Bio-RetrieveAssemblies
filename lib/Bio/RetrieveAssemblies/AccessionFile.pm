package Bio::RetrieveAssemblies::AccessionFile;

use Moose;
use Bio::RetrieveAssemblies::Exceptions;
use File::Path qw(make_path);
use File::Basename;
use File::Copy;
use Data::Validate::URI qw(is_uri);
use Bio::SeqIO;    # force dependancy on Bio::Perl so that you get bp_genbank2gff3.pl
use Moose::Util::TypeConstraints;

# ABSTRACT: For a given accession get the file of annotation or sequence

=head1 SYNOPSIS

For a given accession get the file of annotation or sequence

    use Bio::RetrieveAssemblies::AccessionFile;
    my $obj = Bio::RetrieveAssemblies::AccessionFile->new(accession => 'abc');
    my %accessions_hash  = $obj->download_file();

=cut

enum 'FileType', [qw(genbank fasta gff)];

has 'accession'        => ( is => 'ro', isa => 'Str',      required => 1 );
has 'output_directory' => ( is => 'ro', isa => 'Str',      default  => 'downloaded_files' );
has 'file_type'        => ( is => 'rw', isa => 'FileType', default  => 'genbank' );
has '_base_url'        => ( is => 'ro', isa => 'Str',      default  => 'http://www.ncbi.nlm.nih.gov/Traces/wgs/?download=' );
has '_converter_exec'  => ( is => 'ro', isa => 'Str',      default  => 'bp_genbank2gff3.pl' );
has 'url_to_file'      => ( is => 'ro', isa => 'ArrayRef', lazy     => 1, builder => '_build_url_to_file' );
has 'output_filename'  => ( is => 'ro', isa => 'Str',      lazy     => 1, builder => '_build_output_filename' );

sub _build_url_to_file {
    my ($self) = @_;

    my @url_to_file;
    if ( $self->file_type eq 'fasta' ) {
        push( @url_to_file, $self->_base_url . $self->accession . '.1.fsa_nt.gz' );
        push( @url_to_file, $self->output_directory . '/' . $self->accession . '.1.fsa_nt.gz' );
    }
    else {
        push( @url_to_file, $self->_base_url . $self->accession . '.1.gbff.gz' );
        push( @url_to_file, $self->output_directory . '/' . $self->accession . '.1.gbff.gz' );
    }
    return \@url_to_file;
}

sub _build_output_filename {
    my ($self) = @_;
    my $output_filename = $self->url_to_file->[1];
    if ( $self->file_type eq "gff" ) {
        $output_filename .= '.gff';
    }
    return $output_filename;
}

sub download_file {
    my ($self) = @_;
    make_path( $self->output_directory );

    if ( is_uri( $self->url_to_file->[0] ) ) {
		system("wget -q -O ".$self->url_to_file->[1]." '".$self->url_to_file->[0] ."'") ;
		#or Bio::RetrieveAssemblies::Exceptions::CouldntDownload->throw( error => "Unable to get remote page ".$self->url_to_file->[0] )
    }
    else {
        copy( $self->url_to_file->[0], $self->url_to_file->[1] )
          or Bio::RetrieveAssemblies::Exceptions::FileCopyFailed->throw( error => "Copy failed: $!" );
    }

    if ( $self->file_type eq "gff" ) {
        $self->_convert_gb_to_gff();
    }
    return 1;
}

sub _convert_gb_to_gff_cmd {
    my ($self) = @_;
    return join( ' ', ( $self->_converter_exec, "--quiet", "-o", $self->output_directory, $self->url_to_file->[1] ) );
}

sub _convert_gb_to_gff {
    my ($self) = @_;
    ( system( $self->_convert_gb_to_gff_cmd ) == 0 )
      or Bio::RetrieveAssemblies::Exceptions::GenBankToGFFConverter->throw(
        error => "Couldnt convert " . $self->accession . " GenBank file to GFF3" );
    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
