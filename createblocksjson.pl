#/usr/bin/perl   

use File::Slurp;
no warnings 'experimental::smartmatch';

print "\n\n\nWelcome to createblocksjson.pl \n  


This program creates a file Blocks.json or updates it if it exists with a single file of data.
It has two functions. Chromosome sizes may be added to the database or blocks may be added to sizes that are already present.
Deletion of a refrence/alignment is also possible

To add a single refrence chromsome sizes:
perl createblocksjson.pl 0 TAXID INPUT 
	A proper taxid is necessary for the tree compatibility. Should no Taxid exist for a given species use a unique digit higher than 10,000,000. 
	If this is not a finally assembly, strings may be used.
	Input follows the same format produced by the Kent tools 2bitinfo tool:
	chr1	158337067
	It removes all non word characters from the Chromosome label.
	DO NOT USE \" symbols,spaces or terminate the string on miniscule lettering. Recomended structures: CHR1 or SCF2303
	***Will not work is refrence is present already

To delete a single refrence chromsome sizes:
perl createblocksjson.pl 1 TAXID
	****ALL ASOCIATED BLOCKS WILL BE DELETED TOO

To add a single alignment between one refrence and query:
perl createblocksjson.pl 2 RefTAXID QueTAXID RESOLUTION INPUT 
	TAXID of refrence must have sizes present in database
	No entry can have the same Refrence, Query, and Resolution as another alignment
	Input is outputed from the lastz pipeline:
	cattle10k_jp300k,18,232277,2492980,110450,2165283,+1,Reindeer_Chicago10k_300Km,ScFKYPt_10010_HRSCAF=11888,ScFKYPt_10010_HRSCAF=11888
	cattle10k_jp300k,23,49819067,52265085,8885,2525004,-1,Reindeer_Chicago10k_300Km,ScFKYPt_10095_HRSCAF=12005,ScFKYPt_10095_HRSCAF=12005
	REFRENCE,REFCHR,REFSTART,REFEND,QSTART,QEND,DIRECTION,QUERY,QUECHR,QUECHR

To take an already present ref/query and add the blocks to the querys refrence:
perl createblocksjson.pl 3 RefTAXID QueTAXID RESOLUTION
	***Query must have Chromsome sizes loaded. and miniscule letters are not allowed at the end of chromsome names. Ex: chrX=allowed, chrx=Not or Chr24a= Not
	
To Delete an alignment
perl createblocksjson.pl 4 RefTAXID QueTAXID RESOLUTION


**********DO NOT PUT ON EXCESS ALIGNMENTS******
	The speed of loading is directly proportional to the amount of data in this database.
	Each alignment takes up roughly 1/3 mb. 1000 alignments will draw 1 gb of memory.
	So KEEP IT CLEN and use secondary files for temporary assembly alignments

	BLOCKS MUST BE WRITTEN WITH SIZES OR ELSE IT WILL GET UGLY

All output is written to Blocks.json

";

if ($ARGV[0] == 0){
#Add chromsome sizes		FINISHED
# perl createblocksjson.pl 0 TAXID INPUT 
# To get this straight from sql databse do:
#
	print "ADDING CHROMSOME SIZES\n";

	if (@ARGV != 3) {
		print "Unexpected number of arguments\n";
		exit 1;
	}
	my $TAXID=$ARGV[1];
# 	Get the chromsome sizes from the file
 	open(my $handle, "<", $ARGV[2]) or die "Can't open $ARGV[2]\n";
	chomp(my @Chr_Sizes = <$handle>);	
	close $handle;
	
	if (-e 'Blocks.json') {
		print "Appending existing Blocks.json.\nTo revert changes:\nperl createblocksjson.pl 1 $TAXID\n\n";

 		open(my $handle, "<", 'Blocks.json') or die "Can't open Blocks.json\n";
		chomp(my @lines = <$handle>);	
		close $handle;
		
# 		Test to see if the Taxid is already present
		my $taxaline='		"Taxid": "'.$TAXID.'",';
		if ( $taxaline ~~ @lines ) {
  			print "CHROMSOME SIZE ALREADY PRESENT\nDELET IT AND ALL THE BLOCKS WITH: \nperl createblocksjson.pl 1 $TAXID\n\n";
			exit 1;
		}else{
# 		Remove the last bracket
			pop @lines;
			open (OF, ">", "Blocks.json");
			foreach my $x (@lines){print OF $x."\n"};
			print OF '	{
		"Taxid": "'.$TAXID.'",'."\n".'		"Chromosomes": [
';
			foreach my $size (@Chr_Sizes){
				my @fields=split(/\t/,$size);
				chomp @fields;
				$fields[0]=~s/[^\w]/_/g;
				print OF '			{"ChrID":"'."$fields[0]".'"'.",".'"ChrLength":"'."$fields[1]".'"'.",".'},'."\n";
			}
			print OF '		],
	},
];';	
		close OF;
		}
		
	}else{
		print "Creating new Blocks.json\n";
		open (OF, ">", "Blocks.json");
		print OF 'Blocks_DB = [
	{
		"Taxid": "'.$TAXID.'",'."\n".'		"Chromosomes": [
';
		foreach my $size (@Chr_Sizes){
			my @fields=split(/\t/,$size);
			chomp @fields;
			$fields[0]=~s/[^\w]/_/g;
			print OF '			{"ChrID":"'."$fields[0]".'"'.",".'"ChrLength":"'."$fields[1]".'"'.",".'},'."\n";
		}
		print OF '		],
	},
];';
		close OF;
	}

###################################################

###################################################
}elsif ($ARGV[0] == 1){
# Delete refrence	DONE
# perl createblocksjson.pl 1 TAXID
	my $TAXID=$ARGV[1];
	print "Deleating $TAXID chromosome sizes and alinments from Blocks.json\n";

	if (@ARGV != 2) {
		print "Unexpected number of arguments\n";
		exit 1;
	}

	open(my $handle, "<", 'Blocks.json') or die "Can't open Blocks.json\n";
	chomp(my @lines = <$handle>);	
	close $handle;
	my $taxaline='		"Taxid": "'.$TAXID.'",';
	my @out;
	if ( $taxaline ~~ @lines ) {
  		my $counter=0;
  		my $track=0;
  		my $end='	},';
  		while ($counter <= $#lines ){
  			if ($taxaline ~~ $lines[$counter]){
  				pop @out;
  				$track=1;
  			}elsif(($end ~~ $lines[$counter])&&($track==1)){
  				$track=0;
  				$lines[$counter]="";
  			}
  		
  			if ($track==0){
  				push (@out, $lines[$counter]);
  			}
  			  		
  			$counter ++;
  		}
#   		This just gets rid of excess whitespace
  		@out = grep { $_ ne '' } @out;
		open (OF, ">", "Blocks.json");

		foreach my $line (@out){
			print OF $line."\n";
		}
		close OF;

	}else{
		print "$TAXID not found in database\n";
		exit 1;

	}

###################################################

###################################################
}elsif ($ARGV[0] == 2){
# To add a single alignment between one refrence and query:
# perl createblocksjson.pl 2 RefTAXID QueTAXID RESOLUTION INPUT 
	if (@ARGV != 5) {
		print "Unexpected number of arguments\n";
		exit 1;
	}
	
	print $ARGV[4]."\n\n";
	open(my $handle, "<", $ARGV[4]) or die "Can't open $ARGV[4]\n";
	chomp(my @blocks = <$handle>);	
	close $handle;
	
	my $TAXID=$ARGV[1];
	my $QID=$ARGV[2];
	my $RES=$ARGV[3];
	print "Adding blocks at $RES from Refrence $TAXID and Query $QID to Blocks.json\n To delete this do :\nperl createblocksjson.pl 4 $TAXID $QID $RES
";

	open(my $handle, "<", 'Blocks.json') or die "Can't open Blocks.json\n";
	chomp(my @lines = <$handle>);	
	close $handle;
# Test to see if the refrence is present.
	my $taxaline='		"Taxid": "'.$TAXID.'",';
	unless ( $taxaline ~~ @lines ) {
		print "Refrence chromsome sizes not found. Please add them first\n";
		exit 1;
	};
# Determine if the data has been inputed before
	my $reftrack=0;
	my $querytrack=0;
	my @Chrome;
	foreach my $line (@lines){
		if ($line ~~ $taxaline){
# 		Locate Refrence
			$reftrack=1;
		}elsif($reftrack == 1 && index($line, "ChrID") != -1){
# 		Get Chromsome names
			$line =~ /ChrID":"(\w+)"/;
			push (@Chrome,$1);
# 			End if it is on a different taxa
		}elsif($line eq '	},'){
			$reftrack=0;
		}elsif($reftrack == 1 && index($line, "Qid\": \"$QID\"") != -1){
			$querytrack=1;
		}elsif($reftrack == 1 && $querytrack == 1 && index($line, "Resolution\": \"$RES\"") != -1){
			print "Database already contains data at the same resolution for this refrence and query\nExiting\n";
			exit 1;
		}elsif($line eq '			}'){
			$querytrack=0;
		}
			
	}
# 	output data into this array.
	my @out;
	$reftrack=0;
	
	foreach my $line (@lines){
		if ($line ~~ $taxaline){
		# 		Locate Refrence
			$reftrack=1;
			push (@out, $line);

		}elsif($line eq '	},' && $reftrack == 1){
	# 		ADD EVERYTHING HERE including the Alignments array!!!	
			push (@out, '		"Alignments":[');
			push (@out, '			{');
			push (@out, '				"Qid": "'.$QID.'",');
			push (@out, '				"Resolution": "'.$RES.'",');
			push (@out, '				"Blocks":[');
			foreach my $block (@blocks){
				my @fields=split(/,/,$block);
				chomp @fields;
				$fields[1]=~s/[^\w]/_/g;
				if($fields[1] ~~ @Chrome){
					push (@out, '					{"RefChr":"'.$fields[1].'","RefStart":"'.$fields[2].'","RefEnd":"'.$fields[3].'","QueChr":"'.$fields[8].'","QueStart":"'.$fields[4].'","QueEnd":"'.$fields[5].'","Direction":"'.$fields[6].'"},');
				}else{
 					print "$fields[1] not found in chromsome sizes!!!!!!!!!!!\n";
				}
			}			

			push (@out, '				],');		
			push (@out, '			},');
			push (@out, '		],');		
			push (@out, $line);
			$reftrack = 0;

		}elsif($line eq '		"Alignments":[' && $reftrack == 1){
			push (@out, $line);
			push (@out, '			{');
			push (@out, '				"Qid": "'.$QID.'",');
			push (@out, '				"Resolution": "'.$RES.'",');
			push (@out, '				"Blocks":[');
			foreach my $block (@blocks){
				my @fields=split(/,/,$block);
				chomp @fields;
				$fields[1]=~s/[^\w]/_/g;
				if($fields[1] ~~ @Chrome){
					push (@out, '					{"RefChr":"'.$fields[1].'","RefStart":"'.$fields[2].'","RefEnd":"'.$fields[3].'","QueChr":"'.$fields[8].'","QueStart":"'.$fields[4].'","QueEnd":"'.$fields[5].'","Direction":"'.$fields[6].'"},');
				}else{
 					print "$fields[1] not found in chromsome sizes!!!!!!!!!!!\n";
				}
			}			
			push (@out, '				],');		
			push (@out, '			},');			
			$reftrack = 0;
		}else{
			push (@out, $line);
		}
		
# Substitute out non word characters from chromsome
# 				$fields[0]=s/[^\w]//g;
	}
		open (OF, ">", "Blocks.json");
		foreach my $outbit (@out){
			print OF $outbit."\n";
		}
		close OF;

###################################################

###################################################
}elsif ($ARGV[0] == 3){
#Swap ref and query for one set of alignments.
#Must have sizes loaded for query
# perl createblocksjson.pl 3 RefTAXID QueTAXID RESOLUTION
	if (@ARGV != 4) {
		print "Unexpected number of arguments\n";
		exit 1;
	}

	my $TAXID=$ARGV[1];
	my $QID=$ARGV[2];
	my $RES=$ARGV[3];
	print "Adding a reverse set of blocks at $RES from Refrence $TAXID and Query $QID to Blocks.json\n To delete this do :\nperl createblocksjson.pl 4 $QID $TAXID $RES
";

	open(my $handle, "<", 'Blocks.json') or die "Can't open Blocks.json\n";
	chomp(my @lines = <$handle>);	
	close $handle;
	

	
# Test to see if the newref is present.
	my $taxaline='		"Taxid": "'.$QID.'",';
	unless ( $taxaline ~~ @lines ) {
		print "Query chromsome sizes not found. Please add them first\n";
		exit 1;
	};
# Determine if the data has been inputed before
	my $reftrack=0;
	my $querytrack=0;
	my @Chrome;
	foreach my $line (@lines){
		if ($line ~~ $taxaline){
# 		Locate New Refrence
			$reftrack=1;
		}elsif($reftrack == 1 && index($line, "ChrID") != -1){
# 		Get Chromsome names
			$line =~ /ChrID":"(\w+)"/;
			push (@Chrome,$1);
# 			End if it is on a different taxa
		}elsif($line eq '	},'){
			$reftrack=0;
		}elsif($reftrack == 1 && index($line, "Qid\": \"$TAXID\"") != -1){
			$querytrack=1;
		}elsif($reftrack == 1 && $querytrack == 1 && index($line, "Resolution\": \"$RES\"") != -1){
			print "Database already contains data at the same resolution for this refrence and query\nExiting\n";
			exit 1;
		}elsif($line eq '			}'){
			$querytrack=0;
		}
			
	}

# Test to see if the refrence is present.
	my $taxaline='		"Taxid": "'.$TAXID.'",';
	unless ( $taxaline ~~ @lines ) {
		print "Refrence chromsome sizes not found. Please add them first\n";
		exit 1;
	};
	

	
	
#Get the data from the old reference
	$reftrack=0;
	$querytrack=0;
	my $counter=0;
	my @swapdata;
	while ($counter <= $#lines){
		if ($lines[$counter] ~~ $taxaline){
# 		Locate Old Refrence
			$reftrack=1;
		}elsif($lines[$counter] eq '	},'){

			$reftrack=0;
		}elsif($reftrack == 1 && index($lines[$counter], "Qid\": \"$QID\"") != -1){
			$querytrack=1;
		}elsif($reftrack == 1 && $querytrack == 1 && index($lines[$counter], "Resolution\": \"$RES\"") != -1){
 			$counter ++;
 			$counter ++;
			until ($lines[$counter] eq '				],'){
# 	{"RefChr":"chr18","RefStart":"232277","RefEnd":"2492980","QueChr":"ScFKYPt_10010_HRSCAF=11888","QueStart":"110450","QueEnd":"2165283","Direction":"+1"},
				my @splited =split(/\"/,$lines[$counter]);
				my $tempcounter=0;
				$splited[15]=~s/[^\w]/_/g;
				$splited[15]=~s/[a-z]+$//;

				if($splited[15] ~~ @Chrome){
					push (@swapdata, '					{"RefChr":"'.$splited[15].'","RefStart":"'.$splited[19].'","RefEnd":"'.$splited[23].'","QueChr":"'.$splited[3].'","QueStart":"'.$splited[7].'","QueEnd":"'.$splited[11].'","Direction":"'.$splited[27].'"},');
				}else{
					print '					{"RefChr":"'.$splited[15].'","RefStart":"'.$splited[19].'","RefEnd":"'.$splited[23].'","QueChr":"'.$splited[3].'","QueStart":"'.$splited[7].'","QueEnd":"'.$splited[11].'","Direction":"'.$splited[27].'"},';
 					print "$fields[15] not found in chromsome sizes!!!!!!!!!!!\n";
				}
			$counter ++;
			}
		}elsif($lines[$counter] eq '			}'){
			$querytrack=0;
		}	
		$counter ++;
	}
	
	if (@swapdata == 0){
		print "No data found at this resolution for this refrence and query\nExiting\n";
		exit 1;
	}
# Test to see if the newref is present.
	$taxaline='		"Taxid": "'.$QID.'",';
	unless ( $taxaline ~~ @lines ) {
		print "Query chromsome sizes not found. Please add them first\n";
		exit 1;
	};	


#Swap it.
	my @out;
	$reftrack=0;
	
	foreach my $line (@lines){
		if ($line ~~ $taxaline){
		# 		Locate Refrence
			$reftrack=1;
			push (@out, $line);

		}elsif($line eq '	},' && $reftrack == 1){
	# 		ADD EVERYTHING HERE including the Alignments array!!!	
			push (@out, '		"Alignments":[');
			push (@out, '			{');
			push (@out, '				"Qid": "'.$TAXID.'",');
			push (@out, '				"Resolution": "'.$RES.'",');
			push (@out, '				"Blocks":[');
			push (@out,@swapdata);
			push (@out, '				],');		
			push (@out, '			},');
			push (@out, '		],');		
			push (@out, $line);
			$reftrack = 0;

		}elsif($line eq '		"Alignments":[' && $reftrack == 1){
			push (@out, $line);
			push (@out, '			{');
			push (@out, '				"Qid": "'.$TAXID.'",');
			push (@out, '				"Resolution": "'.$RES.'",');
			push (@out, '				"Blocks":[');
			push (@out,@swapdata);
			push (@out, '				],');		
			push (@out, '			},');			
			$reftrack = 0;
		}else{
			push (@out, $line);
		}
		
# Substitute out non word characters from chromsome
# 				$fields[0]=s/[^\w]//g;
	}
		open (OF, ">", "Blocks.json");
		foreach my $outbit (@out){
			print OF $outbit."\n";
		}
		close OF;


###################################################

###################################################
}elsif ($ARGV[0] == 4){
	if (@ARGV == 4) {
		print "Deleting blocks at $RES from Refrence $TAXID and Query $QID in Blocks.json\n";
		my $TAXID=$ARGV[1];
		my $QID=$ARGV[2];
		my $RES=$ARGV[3];
		open(my $handle, "<", 'Blocks.json') or die "Can't open Blocks.json\n";
		chomp(my @lines = <$handle>);	
		close $handle;
	# 	See if it is present

		my $taxaline='		"Taxid": "'.$TAXID.'",';

	# Determine if the data has been inputed before
		my $found=0;
		my $reftrack=0;
		my $querytrack=0;
		my @out;
		foreach my $line (@lines){
			if ($line ~~ $taxaline){
	# 		Locate Refrence
				$reftrack=1;
	# 			End if it is on a different taxa
			}elsif($line eq '	},'){
				$reftrack=0;
			}elsif($reftrack == 1 && index($line, "Qid\": \"$QID\"") != -1){
				$querytrack=1;
			}elsif($reftrack == 1 && $querytrack == 1 && index($line, "Resolution\": \"$RES\"") != -1){
				$found=1;
			}elsif($line eq '			}'){
				$querytrack=0;
			}
			
		}
		if ($found==0){
			print "Data not present in database\n";
			exit 1;
		}else{
		# Delete the chunk of blocks
			my $counter=0;
			$reftrack=0;
			$querytrack=0;
			while ($counter <= $#lines){
				if ($lines[$counter] ~~ $taxaline){
		# 		Locate  Refrence
					$reftrack=1;
					push (@out,$lines[$counter]);					
				}elsif($lines[$counter] eq '	},'){
					push (@out,$lines[$counter]);					
					$reftrack=0;
				}elsif($reftrack == 1 && index($lines[$counter], "Qid\": \"$QID\"") != -1){
					push (@out,$lines[$counter]);					
					$querytrack=1;
				}elsif($reftrack == 1 && $querytrack == 1 && index($lines[$counter], "Resolution\": \"$RES\"") != -1){
# Count until I hit the sweet spot.
					pop @out;
					pop @out;
					
					until ($lines[$counter] eq '			},'){
						$counter ++;					
					}

				}elsif($lines[$counter] eq '			}'){
					$querytrack=0;
					push (@out,$lines[$counter]);					

				}else{
					push (@out,$lines[$counter]);
				}	
				$counter ++;
			}
	
	
		}
			open (OF, ">", "Blocks.json");
		foreach my $outbit (@out){
			print OF $outbit."\n";
		}
		close OF;
	
	}else{
		print "Unexpected number of arguments\n";
		exit 1;
	}
	
	
###################################################

###################################################
}else{

die "Please choose a valid option (0-4) next time."

}



