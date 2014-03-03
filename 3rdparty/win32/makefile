# Makefile for the Windows API project
# Uses GNU Make-specific extensions

DC := dmd.exe

DFLAGS := -inline -O -release -w
#DFLAGS := -debug -gc -unittest -w

DFLAGS += -version=Unicode -version=WindowsVista

########################################

SUBDIRS := directx

EXCLUSIONS := winsock.d

########################################

SOURCES := $(wildcard *.d $(addsuffix /*.d, $(SUBDIRS)))
SOURCES := $(filter-out $(EXCLUSIONS), $(SOURCES))

########################################

win32.lib : $(SOURCES)
	$(DC) $^ -lib -of$@ $(DFLAGS)

win64.lib : $(SOURCES)
	$(DC) $^ -lib -m64 -of$@ $(DFLAGS)

clean :
	-del win32.lib
	-del win64.lib

.PHONY : clean
