###################################################################
# Project Configuration: 
# 
# Specify the name of the design (project) and the Quartus II
# Settings File (.qsf)
###################################################################

PROJECT = soc_system
TOP_LEVEL_ENTITY = c5sx_soc
ASSIGNMENT_FILES = $(PROJECT).qpf $(PROJECT).qsf
OUTPUT_DIR = output

#  Get all the verilog files from the qsys settings file
VERILOG_FILES = $(shell awk '/^set_global_assignment -name VERILOG_FILE/ {print $$4}' soc_system.qsf)
#  Get any qsys files too
QSYS_FILES = $(shell awk '/^set_global_assignment -name VERILOG_FILE/ {print $$4}' soc_system.qsf)

#  For any custom qsys modules we have, we find the verilog files out of these
#  and expand them.
QSYS_MODULE_HW_FILES = $(wildcard */*_hw.tcl)
QSYS_MODULE_FILES = $(foreach module, $(QSYS_MODULE_HW_FILES), $(addprefix $(dir $(module)), $(shell awk '/^add_fileset_file .*\.v VERILOG PATH/ {print $$5}' $(module))))
SRCS = $(VERILOG_FILES) $(QSYS_FILES) $(QSYS_MODULE_FILES)

###################################################################
# Main Targets
#
# all: build everything
# clean: remove output files and database
# program: program your device with the compiled design
###################################################################

all: $(OUTPUT_DIR)/soc_system.rbf

.PRECIOUS: %.map.rpt %.fit.rpt

bla:
	@echo $(QSYS_MODULE_HW_FILES)
	@echo $(VERILOG_FILES) $(QSYS_FILES) $(QSYS_MODULE_FILES)

clean:
	rm -rf $(OUTPUT_DIR)/*.rpt $(OUTPUT_DIR)/*.chg $(OUTPUT_DIR)/smart.log $(OUTPUT_DIR)/*.htm $(OUTPUT_DIR)/*.eqn $(OUTPUT_DIR)/*.pin $(OUTPUT_DIR)/*.sof $(OUTPUT_DIR)/*.pof $(OUTPUT_DIR)/db incremental_db $(OUTPUT_DIR)/*.rbf

###################################################################
# Executable Configuration
###################################################################

MAP_ARGS = --read_settings_files=on --write_settings_files=off -c soc_system

FIT_ARGS = --read_settings_files=on --write_settings_files=off -c soc_system
ASM_ARGS = --read_settings_files=off --write_settings_files=off -c soc_system

$(OUTPUT_DIR)/%.map.rpt: %.qsf %.qpf $(SRCS)
	quartus_map $(MAP_ARGS) $* -c $*	

$(OUTPUT_DIR)/%.fit.rpt: $(OUTPUT_DIR)/%.map.rpt
	quartus_fit $(FIT_ARGS) $* -c $*

$(OUTPUT_DIR)/%.sof $(OUTPUT_DIR)/%.asm.rpt: $(OUTPUT_DIR)/%.fit.rpt
	quartus_asm $(ASM_ARGS) $* -c $*

$(OUTPUT_DIR)/%.rbf: $(OUTPUT_DIR)/%.sof
	quartus_cpf -c $< $@

###################################################################
# Target implementations
###################################################################

upload: $(OUTPUT_DIR)/$(PROJECT).rbf
	scp $(OUTPUT_DIR)/$(PROJECT).rbf 198.178.136.63:
