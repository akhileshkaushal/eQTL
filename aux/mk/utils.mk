
#Version and license info
pname=eqtlXXXXX
version=0.0.1
contact="Add contact"
license=This pipeline is distributed  under the terms of the GNU General Public License 3

$(info *****************************************************)
$(info * $(pname) $(version))
$(info * $(contact))
$(info * $(license))
$(info *)
$(info * Initializing...)

################################################################################
# Auxiliary functions
################################################################################

# Information messages
define p_info=
$(info $(shell date "+%H:%M:%S %d/%m/%Y * ") $(1))
endef

# Error messages
define p_error=
$(info $(shell date "+%H:%M:%S %d/%m/%Y") * ERROR: $(1)) && $(error Fatal error)
endef

maf=0.02
define get_mac=
$(shell bash -c "echo \($(words $(vcfs)) \* $(maf) \* 2 +1\)/1 | bc")
endef

# complain if a file does not exist and exit
file_exists=$(if  $(realpath $(1)),,$(call p_error,$(1) not found))

#  check if a variable  $(1) is defined - return the variable name if it is defined or empty otherwise
is_defined=$(if $(subst undefined,,$(origin $(1))),$(1),)

##################################################################################
################################################################################
# Generic file extension rules

# 
%.vcf.gz.tbi: %.vcf.gz
	tabix -p vcf $< || ( rm -f $@ && exit 1)

%.vcf.tbi: %.vcf
	tabix -p vcf $<  || ( rm -f $@ && exit 1)

%.gtf: %.gtf.gz
	gunzip -c $< > $@.tmp && mv $@.tmp $@
# 
%.gtf.eqtl.tsv: %.gtf
	get_annotation.sh $<  $@.tmp && mv $@.tmp $@

%.tsv: %.tsv.gz
	gunzip -c $< > $@.tmp && mv $@.tmp $@

#
###############################################
# Load configuration (mandatory)
# use a configuration file?
ifdef conf
 $(call file_exists,$(conf))
 $(info * Trying to load configuration file $(conf)...)
 include $(conf)
 $(info * Configuration loaded.)
else
 $(call p_error,Configuration file missing)
endif