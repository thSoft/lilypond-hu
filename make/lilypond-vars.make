
export PATH:=$(topdir)/lily/out:$(topdir)/buildscripts/out:$(PATH)
export TEXCONFIG:=$(topdir)/mf/out:$(TEXCONFIG)
export TEXPSHEADERS:=$(topdir)/mf/out::$(TEXPSHEADERS)
export MFINPUTS:=$(topdir)/mf/:$(MFINPUTS)::
export TEXINPUTS:=$(topdir)/mf/out/:$(topdir)/tex/:$(topdir)/ps/:$(TEXINPUTS):$(pwd)::
export LILYINCLUDE:=$(topdir)/ps:$(topdir)/scm:$(topdir)/ly:$(topdir)/mf/out::$(TEX_TFMDIR):$(LILYINCLUDE)
export TFMFONTS:=$(topdir)/mf/out:
export extra_mem_top=1000000
export extra_mem_bottom=1000000
export pool_size=250000


ifdef DEB_BUILD
export PKFONTS := $(topdir)/mf/out
export MT_DESTROOT := $(topdir)/mf/out
export DVIPSMAKEPK := mktexpk --destdir $(topdir)/mf/out
endif

# LilyPond is often run from within $(outdir), making a relative
# PREFIX incorrect.
export LILYPONDPREFIX:=$(shell cd $(depth)/ ; pwd)
export PYTHONPATH:=$(buildscript-dir)/$(outdir):$(PYTHONPATH)

# guile load path?
the-script-dir=$(wildcard $(script-dir))

ifneq ($(the-script-dir),)

### some versions apparently choke on $(message)
### $(message running from source tree stepmake)

ABC2LY = $(script-dir)/abc2ly.py
CONVERT_LY = $(script-dir)/convert-ly.py
LILYPOND = $(depth)/$(builddir)/lily/$(outconfbase)/lilypond
LILYPOND_BOOK = $(script-dir)/lilypond-book.py
LILYPOND_BOOK_INCLUDES = -I $(pwd) -I $(outdir) -I$(input-dir) -I $(input-dir)/tricks/ -I $(input-dir)/regression/ -I $(input-dir)/test/ -I $(input-dir)/tutorial/
LY2DVI = $(script-dir)/ly2dvi.py
PS_TO_GIFS = $(buildscript-dir)/ps-to-gifs.sh
PS_TO_PNGS = $(buildscript-dir)/ps-to-pngs.sh

else
### some versions apparently choke on $(message)
### $(message running from installed stepmake)

ABC2LY = $(shell $(SHELL) -c 'type -p abc2ly')
CONVERT_LY = $(shell $(SHELL) -c 'type -p convert-ly')
LILYPOND = $(shell $(SHELL) -c 'type -p lilypond')
LILYPOND_BOOK = $(shell $(SHELL) -c 'type -p lilypond-book')
LILYPOND_BOOK_INCLUDES = -I. -I.. -I$(outdir)
LY2DVI = $(shell $(SHELL) -c 'type -p ly2dvi')
PS_TO_GIFS = $(shell $(SHELL) -c 'type -p ps-to-gifs')
PS_TO_PNGS = $(shell $(SHELL) -c 'type -p ps-to-pngs')

endif

