#!/usr/bin/env python


import h5py
import sys,os
import scipy as sp


def usage():
	print ''' 
\nThis script aggregates different chromosome matrices into the same hdf5 

Usage:
aggregate_chromosomes.py <chr_list.lst> <outfile.hdf5>
'''

def add_column(m,n):
	''' add column to a numpy array'''
	m = sp.hstack((m,n))
	return m

def add_row(m,n):
	''' add row to a numpy array '''
	m = sp.vstack((m,n))
	return m


if __name__ == '__main__':
	if len(sys.argv[1:])<2:
		sys.stderr.write('ERROR: missing parameters\n')
		usage()
		sys.exit(1)

	#read arguments
	chr_list,outfile = sys.argv[1:]
	#open list
	chr_list = sp.loadtxt(chr_list,dtype = 'S1000')
	#initialise some empty arrays
	matrix = ''
	chromosome = ''
	pos = ''
	samples = ''
	alleles = ''

	#check is some arguments are missed
	for chr in chr_list:
		if os.path.isfile(chr) != True:
			sys.stderr.write('ERROR: file '+chr+' not found\n')
			sys.exit(1)
		else:
			chr = h5py.File(chr,'r')
			if matrix == '' and chromosome == '' and pos == '' and samples == '' and alleles == '' :
				matrix,chromosome,pos,samples,alleles = chr['genotype/matrix'][:],chr['genotype/col_header/chrom'][:],chr['genotype/col_header/pos'][:],chr['genotype/row_header/sample_ID'][:],chr['genotype/col_header/alleles'][:]
			else:
				matrix = add_column(matrix,chr['genotype/matrix'][:])
				chromosome = add_column(chromosome,chr['genotype/col_header/chrom'][:])
				pos = add_column(pos,chr['genotype/col_header/pos'][:])
				alleles = add_row(alleles,chr['genotype/col_header/alleles'][:])


	outfile = h5py.File(outfile,'w')
	dset = outfile.create_dataset('genotype/matrix',data = matrix[:])
	dset = outfile.create_dataset('genotype/row_header/sample_ID',data = samples[:])
	dset = outfile.create_dataset('genotype/col_header/pos',data = pos[:])
	dset = outfile.create_dataset('genotype/col_header/chrom',data = chromosome[:])
	dset = outfile.create_dataset('genotype/col_header/alleles',data = alleles[:])

	outfile.close()
	sys.exit(0)
