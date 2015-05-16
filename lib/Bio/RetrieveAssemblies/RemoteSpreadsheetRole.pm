package Bio::RetrieveAssemblies::RemoteSpreadsheetRole;
use Moose::Role;
use LWP::Simple;
use Text::CSV;
use Data::Validate::URI qw(is_uri);
use File::Slurp::Tiny qw(read_file write_file);
use Bio::RetrieveAssemblies::Exceptions;

# ABSTRACT: Role for downloading a spreadsheet

=head1 SYNOPSIS

Role for downloading a spreadsheet

=cut

has 'url'          => ( is => 'ro', isa => 'Str',       required => 1 );
has '_tsv_parser'  => ( is => 'ro', isa => 'Text::CSV', lazy     => 1, builder => '_build__tsv_parser' );
has '_tsv_content' => ( is => 'ro', isa => 'ArrayRef',  lazy     => 1, builder => '_build__tsv_content' );

sub _build__tsv_parser {
    my ($self) = @_;
    my $tsv_parser = Text::CSV->new( { binary => 1, sep_char => "\t" } )
      or Bio::RetrieveAssemblies::Exceptions::CSVParser->throw( error => "Cannot use CSV: " . Text::CSV->error_diag() );

    return $tsv_parser;
}

sub _build__tsv_content {
    my ($self) = @_;

    my $tsv_content = "";
    # If its not a url, then try opening it as a file
    if ( is_uri( $self->url ) ) {
        $tsv_content = get( $self->url )
          or Bio::RetrieveAssemblies::Exceptions::CouldntDownload->throw( error => 'Unable to get remote page' );
    }
    else {
        $tsv_content = read_file( $self->url );
    }

    $tsv_content =~ s/[\r\n]+/\n/;
    my @lines = split( /\n/, $tsv_content );
    return \@lines;
}

1;
