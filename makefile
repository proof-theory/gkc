# A simple makefile for gkc under linux: 
# an alternative to compilation with the compile.sh script or autotools.
#
# Builds the gkc executable in the top folder.
#
# Run as: 
# make
# make clean
#
# If bison and flex are not available, set below 
# USEBISON = false
# before running make: pre-built parser sources will be used in this case.
#
# gprof-enabled compilation: 
# - enable -pg flag 
# - run ./gkc ... creating gmon.out
# - run gprof gkc gmon.out > res.txt
# - look at the result: less res.txt

CC = gcc # clang # gcc
#CFLAGS = -O2 -Wall -g # -Wmissing-field-initializers 
#CFLAGS = -O2 -Wall -static # -Wmissing-field-initializers 
CFLAGS = -O3 -Wall -static # -Wmissing-field-initializers 
#CFLAGS = -O2 -Wall -pg # -Wmissing-field-initializers 
LIBS = -lm

TESTING = true
USEBISON = true
BISON = bison
LEX = flex

# sources are all c files except the parser files

sources = Main/gkc.c \
  Db/dbmem.c Db/dballoc.c Db/dbdata.c Db/dblock.c Db/dbindex.c Db/dbdump.c  \
  Db/dblog.c Db/dbhash.c Db/dbcompare.c Db/dbquery.c Db/dbutil.c Db/dbmpool.c \
  Db/dbjson.c Db/dbschema.c \
  json/yajl_all.c \
  cjson/cjson.c \
  Reasoner/build.c  Reasoner/clstore.c  Reasoner/clterm.c  Reasoner/derive.c  Reasoner/glb.c  Reasoner/mem.c  \
  Reasoner/printerrutils.c  Reasoner/rgenloop.c  Reasoner/rmain.c  Reasoner/subsume.c  Reasoner/unify.c \
  Reasoner/resolve.c Reasoner/simp.c Reasoner/strat.c Reasoner/rewrite.c Reasoner/history.c Reasoner/prob.c Reasoner/hash.c \
  Reasoner/clmeta.c Reasoner/guide.c  Reasoner/propagate.c Reasoner/init.c\
  Reasoner/analyze.c Reasoner/chains.c Reasoner/prop.c\
  Printer/dbotterprint.c Test/dbtest.c

# some common headers used by many sources

commonheaders = config.h \
  Db/dballoc.h Db/dbdata.h Db/dbhash.h Db/dblog.h Db/dbindex.h Db/dbcompare.h \
  Db/dblock.h Db/dbutil.h Db/dbapi.h Db/dbmpool.h Db/dbquery.h \
  Reasoner/rincludes.h

# prebuilt parser sources are used if flex and bison are not available

prebuiltparsersources = Builtparser/dbparse.c Builtparser/dbclausify.c \
  Builtparser/dbotter.tab.c  Builtparser/dbotter.yy.c   \
  Builtparser/dbprolog.tab.c  Builtparser/dbprolog.yy.c 
  
prebuiltparserheaders = Builtparser/dbparse.h Builtparser/dbclausify.h Builtparser/dbgenparse.h  \
  Builtparser/dbotter.tab.h  Builtparser/dbotterparse.h \
  Builtparser/dbprolog.tab.h Builtparser/dbprologparse.h  

# some parser sources are generated by flex and bison

parsergensources = Parser/dbotter.tab.c Parser/dbotter.yy.c \
  Parser/dbprolog.tab.c Parser/dbprolog.yy.c \
  
parsergenheaders = Parser/dbotter.tab.h Parser/dbprolog.tab.h

# select whether to use flex and bison or use pre-built parser sources

ifeq ($(USEBISON),true)
  parsersources =  Parser/dbparse.c Parser/dbclausify.c $(parsergensources)
  parserheaders = Parser/dbparse.h Parser/dbclausify.h Parser/dbgenparse.h  \
      Parser/dbotterparse.h Parser/dbprologparse.h \
      $(parsergenheaders)
else
  parsersources =  $(prebuiltparsersources)
  parserheaders = $(prebuiltparserheaders)
endif

# build lists of .o files and .h files 

objects = $(subst .c,.o,$(sources))

dependencies =  $(commonheaders) $(subst .c,.h,$(sources))

parserobjects = $(subst .c,.o,$(parsersources))

# main compilation rules

gkc: $(objects) $(parserobjects)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

%.o: %.c $(dependencies) $(parserheaders)
	$(CC) -c -o $@ $< $(CFLAGS)   

# here flex and bison are invoked to generate some parser sources

Parser/dbotter.tab.c Parser/dbotter.tab.h: Parser/dbotter.y Parser/dbotterparse.h Parser/dbgenparse.h
	$(BISON)  -pwg_yyotter -d -v Parser/dbotter.y -o Parser/dbotter.tab.c

Parser/dbotter.yy.c: Parser/dbotter.l Parser/dbotter.tab.h Parser/dbotterparse.h Parser/dbgenparse.h
	$(LEX) -Pwg_yyotter -oParser/dbotter.yy.c Parser/dbotter.l

Parser/dbprolog.tab.c Parser/dbprolog.tab.h: Parser/dbprolog.y Parser/dbprologparse.h Parser/dbgenparse.h
	$(BISON) -pwg_yyprolog -d -v Parser/dbprolog.y -o Parser/dbprolog.tab.c

Parser/dbprolog.yy.c: Parser/dbprolog.l Parser/dbprolog.tab.h Parser/dbprologparse.h Parser/dbgenparse.h
	$(LEX) -Pwg_yyprolog -oParser/dbprolog.yy.c Parser/dbprolog.l  

# cleanup deletes also generated parser sources

.PHONY: clean

clean:
	rm $(objects) $(parserobjects) $(parsergensources) $(parsergenheaders)



