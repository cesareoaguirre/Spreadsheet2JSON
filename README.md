# Spreadsheet2JSON
Converts spreadsheets ton a json format.

./Spreadsheet2JSON.pl file=./data-source-example/timeline-world.xlsx outfile=./data-source-example/timeline-world.json row-1-header=1 


options:

- row-1-header
Tell the script that the first row in your spreadsheet have the headers that will  work as keys for the data, otherwise it will use the column labels as keys. Those keys will be used to store the data in hashes every row, with the purpose to obtain those values in O(1). 

In any case will be an array with all keys generated ordered from first to last column found.

- file
The spreadsheet file path to convert.

- outfile
The json out file path.


# some perl dependencies are avalable with this commands.
sudo cpan install JSON::XS

sudo cpan install Spreadsheet::ParseExcel

sudo cpan install Spreadsheet::XLSX

sudo cpan install Spreadsheet::ParseXLSX
