#/usr/bin/perl   

use File::Slurp;
no warnings 'experimental::smartmatch';
use Cwd;				#opens current directory and lists all files in an array

print "\n\n\nWelcome to Create_EH_Details.pl \n  
Usage
perl Create_EH_Details.pl INPUT.csvn

A program for converting an xls file to the proper json format for Evolution Highway 2.0 \n
This program takes a csv with the following format:
#taxid,Common name,Species,Taxonomy,Taxonomy Link,Assembly,Assembly Link
9606,human,Homo sapiens,cellular organisms; Eukaryota; Opisthokonta; Metazoa; Eumetazoa; Bilateria; Deuterostomia; Chordata; Craniata; Vertebrata; Gnathostomata; Teleostomi; Euteleostomi; Sarcopterygii; Dipnotetrapodomorpha; Tetrapoda; Amniota; Mammalia; Theria; Eutheria; Boreoeutheria; Euarchontoglires; Primates; Haplorrhini; Simiiformes; Catarrhini; Hominoidea; Hominidae; Homininae; Homo,https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=9606&lvl=3&lin=f&keep=1&srchmode=1&unlock,hg19,https://www.ncbi.nlm.nih.gov/assembly/GCF_000001405.13/
The header must match exatly. 

Output file (Species_Details.json) is in the format:

";
# Input
@Lines = read_file($ARGV[0]);	
chomp @Lines;
# Output
open (OF, ">", "Species_Details.json");

#Print start of Json
print OF 'Species_details = ['."\n";
foreach my $line (@Lines){
	unless ($line =~ /#/){
		my @fields=split(/,/,$line);
		print OF '	{'."\n";
		print OF '		"Taxid": "'.$fields[0].'",'."\n";
		print OF '		"Name": "'.$fields[2].'",'."\n";
		print OF '		"Common_Name": "'.$fields[1].'",'."\n";
		print OF '		"Assembly": "'.$fields[5].'",'."\n";
		print OF '		"Link": "'.$fields[6].'",'."\n";
		print OF '		"Taxonomy": "'.$fields[3].'",'."\n";
		print OF '		"Taxonomy_Link": "'.$fields[4].'",'."\n";
		print OF '		},'."\n";	
	}

}

print OF '	];';
close OF;
