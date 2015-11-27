
# TODO: add checks for the variables

step2: $(step2_dir)/complete


$(step2_dir)/$(expr_matrix_filename).limix.hdf5: $(matched_expr_matrix) $(gtf_eqtl_tsv)
	$(LIMIX_BINARY)/limix_converter --outfile=$@.tmp --csv=$< && \
	hdf_annotation.py $(gtf_eqtl_tsv) $@.tmp && \
	mv $@.tmp $@ 


$(step2_dir)/$(expr_matrix_filename).filtered.hdf5: $(step2_dir)/$(expr_matrix_filename).limix.hdf5  $(samples_hdf5) $(cov_hdf5)
	cp $(cov_hdf5) $(cov_sorted_hdf5).tmp && \
	filtering_pheno.py $< $(min_expr) $(min_perc_samples) $(expr_transform) $@.tmp && \
	sort_ids.py $@.tmp $(cov_sorted_hdf5).tmp $(samples_hdf5) &&\
	mv $(cov_sorted_hdf5).tmp $(cov_sorted_hdf5) && \
	mv $@.tmp $@ 

$(cov_sorted_hdf5): $(step2_dir)/$(expr_matrix_filename).filtered.hdf5
	if [ -e $@ ] ; then touch $@; fi

# $(step2_dir)/$(expr_matrix_filename).filtered.hdf5
$(step2_dir)/complete:  $(cov_sorted_hdf5) $(step2_dir)/$(expr_matrix_filename).filtered.clus.png
	$(call p_info,"Step 2 complete") touch $@
