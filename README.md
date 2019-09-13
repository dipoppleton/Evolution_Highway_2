# Evolution_Highway_2
A tool for comparing chromosomes across multiple species

Readme

EH2 must be run on a server or with localhost.

To set up localhost on mac:

	The default the location is: /Library/WebServer/Documents, but most users use /Users/USERNAME/Sites/. 
	Place all EH2 files in this folder
	To set this as the location, edit /etc/apache2/httpd.conf by replacing both instances of /Library/WebServer/Documents with your desired path. ex: /users/home/Sites
	In the terminal: $ sudo apachectl start 
	Test by typing localhost in your webbrowser.
	***Has only been tested on High Sierra
	
To set up localhost on windows:
	Easier, probably is already functional, or just needs to be activated.
	Follow the documentation at https://docs.microsoft.com/en-us/previous-versions/ms181052(v=vs.80)?redirectedfrom=MSDN for enabling Enable Internet Information Services
	
The files included are:
	index.html: The base webpage
	BLOCK_VIEW.html: The block webpage
	Blocks.json: Database containing all of the alignment data and chromosme sizes (Not a true json file at the moment)
	Species_Details.json :Database containing optional details for species (Not a true json file at the moment)
	Create_EH_Details.pl : Script which adds species from a csv file to Species_Details.json
	createblocksjson.pl : Script which adds/removes blocks and sizes of chromosomes from Species_Details.json
	
To use Create_EH_Details.pl:
	Create a CSV file with the following fields and include the following line as a header:
	taxid,Common name,Species,Taxonomy,Taxonomy Link,Assembly,Assembly Link
	example data line is:
	9606,human,Homo sapiens,cellular organisms; Eukaryota; Opisthokonta; Metazoa; Eumetazoa; Bilateria; Deuterostomia; Chordata; Craniata; Vertebrata; Gnathostomata; Teleostomi; Euteleostomi; Sarcopterygii; Dipnotetrapodomorpha; Tetrapoda; Amniota; Mammalia; Theria; Eutheria; Boreoeutheria; Euarchontoglires; Primates; Haplorrhini; Simiiformes; Catarrhini; Hominoidea; Hominidae; Homininae; Homo,https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=9606&lvl=3&lin=f&keep=1&srchmode=1&unlock,hg19,https://www.ncbi.nlm.nih.gov/assembly/GCF_000001405.13/
	run with $perl Create_EH_Details.pl INPUT.csvn

To use createblocksjson.pl:

	To add a single refrence chromsome sizes:
		$perl createblocksjson.pl 0 TAXID INPUT 
	To delete a single refrence chromsome sizes:
		$perl createblocksjson.pl 1 TAXID
	To add a single alignment between one refrence and query:
		$perl createblocksjson.pl 2 RefTAXID QueTAXID RESOLUTION INPUT 
	To take an already present ref/query and add the blocks to the querys refrence:
		$perl createblocksjson.pl 3 RefTAXID QueTAXID RESOLUTION
	To Delete an alignment
		$perl createblocksjson.pl 4 RefTAXID QueTAXID RESOLUTION
	*More details can be found in file header


To run evolution highway:
Go into your browser and type localhost. 
Detailed instructions on usage will be included in a later version
