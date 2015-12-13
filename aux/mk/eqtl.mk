ifeq ($(eqtl_method),limix)
step4: $(step1a_dir)/complete $(step2_dir)/complete $(step3_dir)/complete $(eqtl_dir)/step4.complete
# 
#


# foreach chr
#   foreach fold_j in 1...nfolds
#     cis_eqtl.py $(chr) $(fold_j) $(nfolds) $(outname) -> chr/$nfolds_fold_j.hdf5
All_CisQTL_JOBS=$(foreach j,$(shell seq $(n_folds)),$(foreach chr,$(chromosomes), $(eqtl_dir)/$(chr)/$(n_folds)_$(j).hdf5))

# $(1)=chr
define CisQTL_JOBS_chr=
$(foreach j,$(shell seq $(n_folds)), $(eqtl_dir)/$(1)/$(n_folds)_$(j).hdf5)
endef

#$(info $(All_CisQTL_JOBS))
TARGETS7+=$(All_CisQTL_JOBS)



# $(1) = chr
define make-cisqtl-rule-chr=
$(eqtl_dir)/$(1)/$(n_folds)_%.hdf5: $(step1a_dir)/$(1)/chr$(1).hdf5 $(step2_dir)/$(expr_matrix_filename).filtered.hdf5  $(kpop_file) $(step3_dir)/$(corr_method)/$(corr_method).hdf5 $(cov_sorted_hdf5)
	mkdir -p $$(@D) && eqtl_cis.py $(step1a_dir)/$(1)/chr$(1).hdf5   $(step2_dir)/$(expr_matrix_filename).filtered.hdf5  $(corr_method)  $(step3_dir)/$(corr_method)/$(corr_method).hdf5  $(kpop_file) $(cov_sorted_hdf5) $(limix_use_peer_covariates) $(cis_window) $(n_folds) $$* $$@.tmp && mv $$@.tmp $$@

# $(step3_dir)/$(1)/summary.hdf5
$(eqtl_dir)/$(1).hdf5: $(call CisQTL_JOBS_chr,$(1))  $(cov_sorted_hdf5) $(step2_dir)/$(expr_matrix_filename).filtered.hdf5 $(step3_dir)/$(corr_method)/$(corr_method).hdf5
	$$(file >$$@.lst.txt,$(call CisQTL_JOBS_chr,$(1))) \
	sed -i -E "s/^ //;s/ +/\n/g" $$@.lst.txt && \
	eqtl_summary.py $(step1a_dir)/$(1)/chr$(1).hdf5  $(step2_dir)/$(expr_matrix_filename).filtered.hdf5  $(corr_method) $(step3_dir)/$(corr_method)/$(corr_method).hdf5  $(kpop_file) $(cov_sorted_hdf5) $(cis_window)  $(n_folds) $$@.lst.txt  $$@.tmp && \
	rm -f $$@.lst.txt && \
	mv $$@.tmp $$@

endef

$(foreach chr,$(chromosomes),$(eval $(call make-cisqtl-rule-chr,$(chr))))

$(eqtl_dir)/summary.tsv: $(foreach chr,$(chromosomes),$(eqtl_dir)/$(chr).hdf5)
	get_results.py $(fdr_threshold) $@.tmp $^ && mv $@.tmp $@


TARGETS8+=$(foreach chr,$(chromosomes),$(eqtl_dir)/$(chr).hdf5)

else
#######################################################
# matrixEQTL


# 1 - chr
# TODO: generate a pos file
ifeq ($(corr_method),none)
define make-meqtl-rule-chr=
$(eqtl_dir)/$(1).tsv: $(step1a_dir)/$(1)/chr$(1).genotype.tsv $(step2_dir)/$(expr_matrix_filename).filtered.tsv $(cov_sorted_hdf5).tsv $(gtf_eqtl_tsv)
	mkdir -p $$(@D) && run_matrix_eqtl $$< $(step2_dir)/$(expr_matrix_filename).filtered.tsv  $(cov_sorted_hdf5).tsv $(gtf_eqtl_tsv) $(cis_window) $(fdr_threshold) $$@.tmp && rename ".tmp" "" $$@.tmp*
endef

else

define make-meqtl-rule-chr=
$(eqtl_dir)/$(1).tsv: $(step1a_dir)/$(1)/chr$(1).genotype.tsv $(step3_dir)/$(corr_method)/$(corr_method).tsv $(cov_sorted_hdf5).tsv $(gtf_eqtl_tsv)
	mkdir -p $$(@D) && run_matrix_eqtl $$< $(step3_dir)/$(corr_method)/$(corr_method).tsv  $(cov_sorted_hdf5).tsv $(gtf_eqtl_tsv) $(cis_window) $(fdr_threshold) $$@.tmp && rename ".tmp" "" $$@.tmp*
endef
endif

$(foreach chr,$(chromosomes),$(eval $(call make-meqtl-rule-chr,$(chr))))

# merge all files into one
$(eqtl_dir)/summary.tsv: $(foreach chr,$(chromosomes),$(eqtl_dir)/$(chr).tsv)
	head -n 1 $< > $@.tmp && \
	tail -q -n +2 $^ | grep -v "No significant" >> $@.tmp && mv $@.tmp $@


TARGETS7+=$(foreach chr,$(chromosomes),$(eqtl_dir)/$(chr).tsv)
TARGETS8+=$(eqtl_dir)/summary.tsv


endif

step4: $(step1a_dir)/complete $(step2_dir)/complete $(step3_dir)/complete $(eqtl_dir)/step4.complete report

$(eqtl_dir)/step4.complete:  $(eqtl_dir)/summary.tsv
	$(call p_info,"Step 4 complete") touch $@

TARGETS9+=$(step1a_dir)/complete $(step2_dir)/complete $(step3_dir)/complete $(step3_dir)/step4.complete report

phony_targets+= setup setup_files

###################################################