#!/usr/bin/perl 
use strict;
use warnings;
use Data::Dumper qw(Dumper);
use Spreadsheet::Read;#qw(ReadData);
use JSON;
print "xls2Json\n";
#print Dumper \@ARGV;
my %options=();
foreach my $option (@ARGV){
    print "Option is ".$option."\n";
    my ($key, $value) = split /=/, $option;
    $options{$key}=$value;
}
#print "options\n";
#print Dumper \%options;

my $spreadsheet_filepath = $options{'file'};
my $out_json_filepath = $options{'outfile'};
my $first_row_headers = $options{'row-1-header'};


#print "book_keys\n";
#my $book_keys=keys $book;

#my $sheets = $book->sheets;
# Im quite sure this will be a O(n) for searching any sheets
# but also im sure that for any sheet it will be an O(mxn) 
# being m the columns and n the rows
# The purpose to generate a json, or at least my intention is that
# the generated output it does not conform a bunch of data thar requires
# a lot of processing, but that any object in a row could be accessed in O(1)
# and rows explored in max O(n) time.
sub spreadsheet2JSON{
    # $book imust be a Spreadsheet object
    my ($book, $first_row_headers) = @_;
    print "first_row_headers enabled" if ( $first_row_headers );
    my %json_store=();
    for (my $sindex=1; $sindex <= $book->sheets; $sindex++){
        my $sheet = $book->sheet( $sindex );
        print "--- sheet "  . $sheet->label . " ---\n";
        $json_store{ $sheet->label } = { 
            "sheetname" => $sheet->label,
            "keys" => [],
            "data" => [],

        };
        my @sheet_keys = ();
        for ( my $cindex = 1; $cindex <= $sheet->maxcol; $cindex++ ){
            my $label = $sheet->col2label( $cindex );
            if ( $first_row_headers ){
                my $cell = cr2cell ( $cindex, 1 );
                $label =  $sheet->{$cell};
            }
            #print "--- col label " . $label ." ---\n";
            push @sheet_keys, $label;            
            #push @{ $json_store{ $sheet->label }{"keys"} }, $label;
        }
        # O(mxn)
        $json_store{ $sheet->label }{"keys"}=\@sheet_keys;
        foreach my $row (1 .. $sheet->{maxrow}) {
            my %data = ();
            #@{ $json_store{ $sheet->label }{"data"} } = $data;
            foreach my $col (1 .. $sheet->{maxcol}) {
                my $cell = cr2cell ($col, $row);
                $data{ $sheet_keys[$col-1] } = $sheet->{$cell};
                }
                push @{ $json_store{ $sheet->label }{"data"} }, \%data;
            }
            
            #print "sheet_keys\n";
            #print Dumper \@sheet_keys;
            #print Dumper \@$json_store{ $sheet->label }{"keys"};
    }
    #print "json_store\n";
    #print Dumper \%json_store;
    my $JSON = JSON->new->utf8->encode( \%json_store );
    return $JSON;
}
die "no hay archivo a convertir" if (!-e $spreadsheet_filepath);
#my @p = Spreadsheet::Read::parsers ();
print "Opening spreadsheet from $spreadsheet_filepath\n";
my $book = Spreadsheet::Read->new ($spreadsheet_filepath ) or die $@;
open ( OUTFILE, ">> $out_json_filepath" ) or die "Cannot export to $out_json_filepath: ". $@;
foreach my $out( spreadsheet2JSON( $book, $first_row_headers ) ){
    print OUTFILE $out;
}
print "Spreadsheet exported to $out_json_filepath.";
#print "--- JSON ---\n" . $json;