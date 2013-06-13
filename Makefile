# Copyright (c) Citrix Systems Inc. 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, 
# with or without modification, are permitted provided 
# that the following conditions are met: 
# 
# *   Redistributions of source code must retain the above 
#     copyright notice, this list of conditions and the 
#     following disclaimer. 
# *   Redistributions in binary form must reproduce the above 
#     copyright notice, this list of conditions and the 
#     following disclaimer in the documentation and/or other 
#     materials provided with the distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
# SUCH DAMAGE.

USE_BRANDING := yes
USE_BUILD_NUMBER := yes
IMPORT_BRANDING := yes
include $(B_BASE)/common.mk

REPONAME := xencenter-ovf
REPO := $(call hg_loc,$(REPONAME))
REPOSTAMP := $(call hg_req,$(REPONAME))

LENNY_DISTFILES := $(CARBON_DISTFILES)/chroot-lenny

SOURCE_TAR := $(MY_OBJ_DIR)/src.tar.gz
SOURCE_DIR := $(MY_OBJ_DIR)/src

ZIP_DIR := $(MY_OBJ_DIR)/xencenter-ovf-zip

REFERENCE_VHD := $(REPO)/bootablereference.vhd.bz2

MAKE_FIXUP_ISO := $(REPO)/fixup-iso/make-fixup-iso.sh
MAKE_FIXUP_SOURCES := $(REPO)/fixup-iso/make-fixup-sources.sh
FIXUP_ISO := $(MY_OBJ_DIR)/xenserver-linuxfixup-disk.iso
FIXUP_SRC := $(MY_OBJ_DIR)/xenserver-linuxfixup-disk-sources.tar.gz
FIXUP_SOURCES := $(MY_SOURCES)/fixup-sources.tar.bz2

VHDTOOLS_ZIP := $(CARBON_DISTFILES)/vhdtools/vhdtools-148647.tar.bz2
VHDTOOLS_DIR := $(MY_OBJ_DIR)/vhdtools

REGMOD := $(MY_OBJ_DIR)/regmod

MANIFEST := $(MY_SOURCES)/MANIFEST
ZIP := XenCenterOVF.zip
OUTPUT := $(MY_OUTPUT_DIR)/$(ZIP) $(FIXUP_SOURCES) $(MANIFEST)

PLUGIN_VERSION := $(shell echo $(PRODUCT_VERSION) | sed -e 's/[a-z]//g')
PLUGIN_BUILD_NUMBER := $(shell echo $(BUILD_NUMBER) | sed -e 's/[a-z]//g')

.PHONY: build
build: $(OUTPUT)
	@:

-include $(MY_OBJ_DIR)/version.inc
$(MY_OBJ_DIR)/version.inc: $(REPOSTAMP)
	rm -f $@
	$(call hg_cset_number,$(REPONAME)) > $@

$(MY_OUTPUT_DIR)/$(ZIP): $(FIXUP_ISO)
	$(call mkdir_clean, $(ZIP_DIR))
	mkdir "$(ZIP_DIR)/External Tools"
	cp $(FIXUP_ISO) "$(ZIP_DIR)/External Tools"
	cp $(REFERENCE_VHD) "$(ZIP_DIR)/External Tools"
	mkdir -p $(dir $@)
	cd $(ZIP_DIR) && zip -r $@ .

$(MY_OUTPUT_DIR)/%: $(MY_OBJ_DIR)/%
	mkdir -p $(dir $@)
	cp $< $@

$(SOURCE_TAR): $(FIXUP_ISO)
	$(call mkdir_clean, $(SOURCE_DIR))
	mkdir "$(SOURCE_DIR)/XenOvfApi/External Tools"
	cp $(FIXUP_ISO) "$(SOURCE_DIR)/XenOvfApi/External Tools"
	tar -C $(SOURCE_DIR) -czf $@ .

$(FIXUP_ISO) $(FIXUP_SRC): $(REGMOD)
	sh -x $(MAKE_FIXUP_ISO) $(MY_OBJ_DIR) $< "file://$(CARBON_DISTROS_DIR)/Debian/Lenny/i386" $(LENNY_DISTFILES) "file://$(MY_DISTFILES)" $(REPO)/fixup-iso/Sources

$(REGMOD):
	$(call mkdir_clean, $(VHDTOOLS_DIR))
	tar -xjf $(VHDTOOLS_ZIP) -C $(VHDTOOLS_DIR)
	patch -d $(VHDTOOLS_DIR) -p1 < xlocale.patch
	$(call mkdir_clean, $(VHDTOOLS_DIR)/exe)
	$(call mkdir_clean, $(VHDTOOLS_DIR)/lib)
	make -C $(VHDTOOLS_DIR)/ClusterTools
	make -C $(VHDTOOLS_DIR)/OzReg
	make -C $(VHDTOOLS_DIR)/RegMod
	cp $(VHDTOOLS_DIR)/exe/regmod $@

$(FIXUP_SOURCES): $(FIXUP_SRC)
	sh -x $(MAKE_FIXUP_SOURCES) $@ $<

$(MANIFEST):
	mkdir -p $(dir $@)
	echo "xencenter-ovf gpl local $(notdir $(FIXUP_SOURCES))" >$@

clean:
	rm -rf --one-file-system $(MY_OBJ_DIR)/*
	rm -rf $(OUTPUT)
