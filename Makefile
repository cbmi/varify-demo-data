default: bedfilesdone

#gene cards list of known disease loci
diseaseloci.html:
	curl http://www.genecards.org/cgi-bin/listdiseasecards.pl?type=full > diseaseloci.html
#scrape loci
toploci.txt : diseaseloci.html
	perl -ne 'm/([0-9XY]+[pq][0-9.]+)/g and print $1."\n";' < diseaseloci.html | sort | uniq -c | sort -nr | perl -ne 'm/(\S+)$/ and print $1."\n"' > toploci.txt 

#get locus coordinates
cytoBand.txt : 
	wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/cytoBand.txt.gz
	gunzip cytoBand.txt.gz

#put coordinates in useful format
cytoBand.grc.txt : cytoBand.txt
	perl -ne 'm/chr(\S+)\t(\d+)\t(\d+)\t(\S+)/;print "$1\t$2\t$3\t$1$4\n"' cytoBand.txt > cytoBand.grc.txt



#extract top loci as bed file
toploci.bed : toploci.txt cytoBand.grc.txt
	grep -f toploci.txt cytoBand.grc.txt | cut -f1,2,3 > toploci.bed

CEU.trio.2010_03.genotypes.annotated.vcf : CEU.trio.2010_03.genotypes.annotated.vcf.gz
	gunzip $<

#split vcf files
bedfilesdone : toploci.bed CEU.trio.2010_03.genotypes.annotated.vcf 
	COUNTER=0
	cat toploci.bed | while read line; do COUNTER=$((COUNTER+1)); echo "$line" | bedtools intersect -a CEU.trio.2010_03.genotypes.annotated.vcf -b - -header -wa > "disease_loci/locus_"$COUNTER".vcf"; done;
	touch bedfilesdone