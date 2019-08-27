ODIR=${HOME}
CWD=$(pwd)
DOT_FILES = .profile .bash_profile .zprofile .zshrc

ifeq ($(OS),Windows_NT)
	# Generic Windows settings
	CMD_RM=del
	CMD_LS=
	# Architecture-specific settings
    # CCFLAGS += -D WIN32
    ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
        # CCFLAGS += -D AMD64
    else
        ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
            # CCFLAGS += -D AMD64
        endif
        ifeq ($(PROCESSOR_ARCHITECTURE),x86)
            # CCFLAGS += -D IA32
        endif
    endif
else
	# Generic *NIX settings
	CMD_RM=rm
	CMD_LN=ln -s
	# Architecture-specific settings
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        # CCFLAGS += -D LINUX
    endif
    ifeq ($(UNAME_S),Darwin)
        # CCFLAGS += -D OSX
    endif
    UNAME_P := $(shell uname -p)
    ifeq ($(UNAME_P),x86_64)
        # CCFLAGS += -D AMD64
    endif
    ifneq ($(filter %86,$(UNAME_P)),)
        # CCFLAGS += -D IA32
    endif
    ifneq ($(filter arm%,$(UNAME_P)),)
        # CCFLAGS += -D ARM
    endif
endif


all: install

.PHONY: uninstall
uninstall:
	-@$(foreach f, $(DOT_FILES), $(call rm,"$(ODIR)/$(f)"))

install:
	-@$(foreach f, $(DOT_FILES), $(call symlink,"$(PWD)/$(f)","$(ODIR)/$(f)"))

link-dot-file-%: %
	@echo "Create Symlink $< => $(HOME)/$<"
	@ln -snf $(CURDIR)/$< $(HOME)/$<

unlink-dot-file-%: %
	echo "Remove Symlink $(HOME)/$<"
	@$(RM) $(HOME)/$<

define rm
	echo "Deleting file $(1)" && $(CMD_RM) $(1);
endef

define symlink
	echo "Creating Symlink $(1) => $(2)" && $(CMD_LN) $(1) $(2);
endef
