#!/bin/sh

# alternative to compilation with automake/make: just run 

[ -z "$CC" ] && CC="cc"

if [ -z "$(which $CC 2>/dev/null)" ]; then
    echo "Error: No compiler found"
    exit 1
fi

[ -f config.h ] || cp config-gcc.h config.h
if [ config-gcc.h -nt config.h ]; then
  echo "Warning: config.h is older than config-gcc.h, consider updating it"
fi

# add -pg switch for profiling):

${CC} -O2 -Wall -Wmissing-field-initializers -static -o gkc \
  Main/gkc.c \
  Db/dbmem.c \
  Db/dballoc.c Db/dbdata.c Db/dblock.c Db/dbindex.c Db/dbdump.c  \
  Db/dblog.c Db/dbhash.c Db/dbcompare.c Db/dbquery.c Db/dbutil.c Db/dbmpool.c \
  Db/dbjson.c Db/dbschema.c \
  json/yajl_all.c \
  cjson/cjson.c \
  Reasoner/build.c  Reasoner/clstore.c  Reasoner/clterm.c  Reasoner/derive.c  \
  Reasoner/glb.c  Reasoner/mem.c  \
  Reasoner/printerrutils.c  Reasoner/rgenloop.c  Reasoner/rmain.c  Reasoner/subsume.c  Reasoner/unify.c \
  Reasoner/resolve.c Reasoner/simp.c Reasoner/strat.c Reasoner/rewrite.c Reasoner/history.c Reasoner/prob.c Reasoner/hash.c \
  Reasoner/clmeta.c Reasoner/guide.c  Reasoner/propagate.c Reasoner/init.c \
  Reasoner/analyze.c Reasoner/chains.c Reasoner/prop.c\
  Printer/dbotterprint.c \
  Builtparser/dbotter.tab.c  Builtparser/dbotter.yy.c  Builtparser/dbparse.c  Builtparser/dbprolog.tab.c \
  Builtparser/dbprolog.yy.c Builtparser/dbclausify.c \
  -lm  

# see https://fastcompression.blogspot.com/2019/01/compiler-warnings.html
# -Wall -Wextra -Wcast-qual -Wcast-align -Wstrict-aliasing -Wpointer-arith -Winit-self 
# -Wshadow -Wswitch-enum -Wstrict-prototypes -Wmissing-prototypes -Wredundant-decls
# -Wfloat-equal -Wundef -Wvla -Wdeclaration-after-statement -Wc++-compat
