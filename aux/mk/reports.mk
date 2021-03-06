# =========================================================
# Copyright 2015-2016
#
#
# This is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License.
# If not, see <http://www.gnu.org/licenses/>.
#
#
# =========================================================

# get a matrix from a specific .hdf5 file
$(cov_sorted_hdf5).tsv:  $(cov_sorted_hdf5)
	hdf52tsv $< "/covariates" "/row_header/sample_ID" "-"   $@.tmp y && mv $@.tmp $@


%.clus.png: %.tsv $(sample2class_file)
	generate_clustering  $< $(sample2class_file) $@.tmp $(class2colours_file) && mv $@.tmp $@

%.pca.png %.pca_13.png %.pca_23.png: %.tsv $(sample2class_file)
	generate_pca  $< $(sample2class_file) $@ $(class2colours_file)> $@.txt 


#########################################################################
report: plots vcf_stats $(report_dir)/settings.tsv


plots: $(report_dir)/plots

print_report_dir:
	echo $(report_dir)

$(report_dir)/settings.tsv: $(conf) 
	mkdir -p $(@D) &&\
	( $(foreach v,$(settings_vars), echo $v:::$($v);) echo num_vcfs:::$(words $(vcfs)); )  | sed "s/:::/\t/" > $@.tmp && mv $@.tmp $@

# Copy the plots and tsv file to the report folder
PLOTS_TARGETS=$(report_dir)/expr_filtered_clus.png $(report_dir)/expr_filtered_corrected_clus.png $(report_dir)/expr_filtered_pca.png $(report_dir)/expr_filtered_corrected_pca.png $(report_dir)/$(expr_matrix_filename)_pca.png $(report_dir)/vcf_filtering.png  $(report_dir)/$(expr_matrix_filename)_clus.png $(report_dir)/expr_filtered_corrected_$(expr_corr_transform)_clus.png $(report_dir)/expr_filtered_corrected_$(expr_corr_transform)_pca.png copy_qtl_plots

ifeq ($(expr_qn),y)
PLOTS_TARGETS+=$(report_dir)/expr_filtered_qn_clus.png $(report_dir)/expr_filtered_qn_pca.png $(report_dir)/expr_filtered_qn_trans_clus.png $(report_dir)/expr_filtered_qn_trans_pca.png 
else
PLOTS_TARGETS+=$(report_dir)/expr_filtered_trans_clus.png $(report_dir)/expr_filtered_trans_pca.png
endif

$(report_dir)/plots:  $(PLOTS_TARGETS)

copy_qtl_plots: $(foreach p,$(qtl_plots),$(report_dir)/$(notdir $(p)))

phony_targets+=copy_qtl_plots $(report_dir)/plots plots report  

define make-cp-rule=
$(report_dir)/$(notdir $(1)): $(1)
	cp -a $$< $$@
endef

$(foreach p,$(qtl_plots),$(eval $(call make-cp-rule,$(p))))


$(report_dir)/$(expr_matrix_filename)_clus.png: $(matched_expr_matrix_no_ext).clus.png
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@
$(report_dir)/$(expr_matrix_filename)_pca.png: $(matched_expr_matrix_no_ext).pca.png
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@

$(report_dir)/expr_filtered_qn_clus.png:  $(step2_dir)/$(expr_matrix_filename).filtered.qn.clus.png $(step2_dir)/$(expr_matrix_filename).filtered.qn.tsv
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@

$(report_dir)/expr_filtered_qn_trans_clus.png:  $(step2_dir)/$(expr_matrix_filename).filtered.qn.trans.clus.png $(step2_dir)/$(expr_matrix_filename).filtered.qn.trans.tsv
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@

$(report_dir)/expr_filtered_trans_clus.png:  $(step2_dir)/$(expr_matrix_filename).filtered.trans.clus.png $(step2_dir)/$(expr_matrix_filename).filtered.trans.tsv
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@

$(report_dir)/expr_filtered_trans_pca.png:  $(step2_dir)/$(expr_matrix_filename).filtered.trans.pca.png $(step2_dir)/$(expr_matrix_filename).filtered.trans.tsv
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@


$(report_dir)/expr_filtered_clus.png:  $(step2_dir)/$(expr_matrix_filename).filtered.clus.png $(step2_dir)/$(expr_matrix_filename).filtered.tsv
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@

$(report_dir)/expr_filtered_pca.png:  $(step2_dir)/$(expr_matrix_filename).filtered.pca.png $(step2_dir)/$(expr_matrix_filename).filtered.pca_13.png $(step2_dir)/$(expr_matrix_filename).filtered.tsv
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@

$(report_dir)/expr_filtered_qn_pca.png:  $(step2_dir)/$(expr_matrix_filename).filtered.qn.pca.png $(step2_dir)/$(expr_matrix_filename).filtered.qn.pca_13.png $(step2_dir)/$(expr_matrix_filename).filtered.qn.tsv
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@

$(report_dir)/expr_filtered_qn_trans_pca.png:  $(step2_dir)/$(expr_matrix_filename).filtered.qn.trans.pca.png $(step2_dir)/$(expr_matrix_filename).filtered.qn.trans.pca_13.png $(step2_dir)/$(expr_matrix_filename).filtered.qn.trans.tsv
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@

$(report_dir)/expr_filtered_corrected_clus.png: $(step3_dir)/$(corr_method)/$(corr_method).clus.png $(step3_dir)/$(corr_method)/$(corr_method).tsv
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@

$(report_dir)/expr_filtered_corrected_pca.png: $(step3_dir)/$(corr_method)/$(corr_method).pca.png $(step3_dir)/$(corr_method)/$(corr_method).pca_13.png $(step3_dir)/$(corr_method)/$(corr_method).tsv
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@

$(report_dir)/expr_filtered_corrected_$(expr_corr_transform)_clus.png: $(step3_dir)/$(corr_method)/$(corr_method).$(expr_corr_transform).clus.png $(step3_dir)/$(corr_method)/$(corr_method).$(expr_corr_transform).tsv
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@

$(report_dir)/expr_filtered_corrected_$(expr_corr_transform)_pca.png: $(step3_dir)/$(corr_method)/$(corr_method).$(expr_corr_transform).pca.png $(step3_dir)/$(corr_method)/$(corr_method).$(expr_corr_transform).pca_13.png $(step3_dir)/$(corr_method)/$(corr_method).$(expr_corr_transform).tsv
	mkdir -p $(@D) && cp $^ $(@D) && cp $< $@


###################################################
# filtering summary stats

########
# $(1) = chr  e.g, 1, 2, 3, ...
define make-vcf-stats-for-chr=

%.vcf.gz.chr$(1).summary: %.vcf.gz  %.vcf.gz.tbi
	bcftools stats -r "$(1)" $$< > $$@.tmp && mv $$@.tmp $$@

%.vcf.gz.chr$(1).snps: %.vcf.gz.chr$(1).summary
	echo -n "$(1) " | tr " " "\t" > $$@.tmp  && grep "records:" $$< | head -n1 | cut -f 4 >> $$@.tmp && mv $$@.tmp $$@
endef

$(foreach chr,$(geno_chr),$(eval $(call make-vcf-stats-for-chr,$(chr))))

%.vcf.gz.snps: $(foreach chr,$(geno_chr),%.vcf.gz.chr$(chr).snps)
	mkdir -p $(@D) && \
	echo "Chr $(notdir $*)" | sed -E "s/\s+/\t/g" > $@.tmp.col1 &&\
	cat $@.tmp.col1  $^ >$@ && rm -f $@.tmp $@.tmp.col1
# vcf file was already split by chr 
$(step1_dir)/%.vcf.gz.chr.snps: $(foreach chr,$(geno_chr),$(step1_dir)/$(chr)/%.vcf.gz.chr$(chr).snps)
	mkdir -p $(@D) && \
	echo "Chr $(notdir $*)" | sed -E "s/\s+/\t/g" > $@.tmp.col1 &&\
	cat $@.tmp.col1  $^ >$@ && rm -f $@.tmp $@.tmp.col1


ifdef var_matrix
vcf_stats:

$(report_dir)/vcf_filtering.png:

else
# VCFs were provided
VCF_STATS_0=$(foreach vcf,$(vcfs),$(name)/vcf/$(subst .vcf.gz,.fixedheader.vcf.gz,$(vcf)).snps)

$(report_dir)/vcf_snps_0.tsv: $(VCF_STATS_0)
	mkdir -p $(@D) && \
	$(file > $@.tmp,Chr $(vcfs)) $(file > $@.tmp.lst,$^ ) \
	sed -i "s/ /\t/g" $@.tmp && \
	cat $@.tmp.lst | mjoin -stdin | tail -n +2 | tr " " "\t">> $@.tmp  && mv $@.tmp $@

#
VCF_STATS_1=$(foreach vcf,$(vcfs),$(step1_dir)/$(subst .vcf.gz,.filter.vcf.gz,$(vcf)).chr.snps)

$(report_dir)/vcf_snps_1.tsv: $(VCF_STATS_1)
	mkdir -p $(@D) && \
	$(file > $@.tmp,Chr $(vcfs))  	$(file > $@.tmp.lst,$^ ) \
	sed -i "s/ /\t/g" $@.tmp && \
	cat $@.tmp.lst | mjoin -stdin  | tail -n +2 |tr " " "\t">> $@.tmp  && mv $@.tmp $@


vcf_stats_targets=$(report_dir)/vcf_snps_1.tsv $(report_dir)/vcf_snps_0.tsv
TARGETS4+=$(VCF_STATS_0) $(VCF_STATS_1)
###############
## FILTER stats


target_reports_vcfs1=$(VCF_STATS_0) $(VCF_STATS_1)

ifeq ($(collect_filter_summary_stats),y)

VCF_STATS_2=$(foreach c,$(geno_chr),$(step1a_dir)/$(c)/chr$(c)_merged.filt.FILTER.summary)
vcf_stats_targets+=$(report_dir)/vcf_snps_2.tsv
TARGETS4+=$(VCF_STATS_2)
target_reports_vcfs1+=$(VCF_STATS_2)

$(report_dir)/vcf_snps_2.tsv: $(VCF_STATS_2)
	mkdir -p $(@D) && \
	echo Chr $(geno_chr) |tr " " "\t" > $@.tmp &&\
	mjoin $^ | tail -n +2 |sed -E "s/\s+/\t/g;s/\s$$//">> $@.tmp &&\
	mv  $@.tmp $@

endif


vcf_stats: $(vcf_stats_targets)

#$(report_dir)/vcf_snps_0.tsv $(report_dir)/vcf_snps_1.tsv $(report_dir)/vcf_snps_2.tsv  
ifeq ($(words $(vcf_stats_targets)),3)
$(report_dir)/vcf_filtering.png: $(vcf_stats_targets)
	get_barplot.py $^ $@.tmp && mv $@.tmp $@
else
$(report_dir)/vcf_filtering.png: $(vcf_stats_targets)
	echo Skipping the generation of $@ && touch $@
endif

endif

report_targets1:
	echo $(target_reports_vcfs1)
