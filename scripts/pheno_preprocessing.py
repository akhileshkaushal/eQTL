#!/usr/bin/env python
import getopt, sys, os
import h5py 
import numpy as np
import pandas as pd
import os.path
import warnings
#test
def usage():
	print """
This script generates a matrix of gene expression with samples specified in the map file. It requires 3 mandatory arguments.
		
Usage: pheno_preprocessing.py <map_file.tsv> <pheno.tsv> <outphenoname.tsv>
		"""
#check arguments
if len(sys.argv[1:])!=3:
        usage()
        sys.exit(1)

#arguments
mapfile=sys.argv[1]
phenofile=sys.argv[2]
phenofileout=sys.argv[3]

if os.path.isfile(mapfile)!=True:
        sys.stderr.write("ERROR: mapfile "+mapfile+" not found\n")
        sys.exit(1)

if os.path.isfile(phenofile)!=True:
        sys.stderr.write("ERROR: phenofile "+phenofile+" not found\n")
        sys.exit(1)


##############################################
### reading (Pheno reading should be reviewed)
try:
        with warnings.catch_warnings():
                warnings.simplefilter("ignore")
                mapfile=np.loadtxt(mapfile, delimiter='\t', dtype='S50')
except Exception as e:
        sys.stderr.write("ERROR: unable to load "+mapfile+" - "+str(e)+"\n")
        sys.exit(1)

try:
        GE = pd.read_csv(phenofile, delimiter = "\t")
except Exception as e:
        sys.stderr.write("ERROR: unable to load "+phenofile+" - "+str(e)+"\n")
        sys.exit(1)

header = GE.columns.values
#header = map(lambda x:x.replace('"',''), header)
rnafiles=mapfile[1:,1]
#sanity check
if len(rnafiles) > len(header):
	sys.stderr.write("ERROR: inconsistency between number of samples in mapfile and gene expression matrix\n")
	sys.exit(1)

#take indexes of mapfile RNA samples within gene expression matrix header 
print 'checking consistency between mapfile and gene expression matrix...'

bv=np.in1d(rnafiles,header)

if sum(bv) == len(rnafiles):
	print 'OK'
	####
	header = header.tolist()
	rnafiles = rnafiles.tolist()
	n=map(lambda x:header.index(x),rnafiles)
	#insert index 0 in list to take also first column name
	n.insert(0,0)
	#grep only columns from the GEarray matching the RNA samples with a correspondent VCF analysis IDs.
	GEsliced = GE.take(n, axis=1)
	#susbstitute RNA samples ID with DNA samples ID
	GEsliced.columns = mapfile[:,0]
	#get shape of the matrix of genes
	annot = GEsliced.shape[0]-1
	nsamples = GEsliced.shape[1]-1
	print 'matrix with {0} genes and {1} samples'.format(annot,nsamples)
	#write the new CSV file with Gene expression 
	phenofileout = open(phenofileout, 'w')
	GEsliced.to_csv(phenofileout, sep = '\t', index=None)
	phenofileout.close()
	sys.exit(0)
else:
        print 'The following samples in the mapfile were not found in the gene expression matrix:\n'
        notfound = rnafiles[~bv].tolist()
        s="\n".join(notfound)
        print s
        sys.exit(1)
