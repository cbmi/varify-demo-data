while($line=<>){
    ($md5,$dir,$file)=$line=~m/(\S+)\s+disease_loci\/(\S+)\/(\S+)/;
    open MANIFEST,">disease_loci/$dir/MANIFEST";
print MANIFEST <<LOAD
[general]
load = true

[sample]
project = CEU trio
batch = $dir
version = 0

[vcf]
file = $file
md5 = $md5
LOAD
}
