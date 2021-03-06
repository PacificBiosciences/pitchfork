RULE?=do-install
default:

override PFHOME:=${CURDIR}
-include settings.mk
include ./mk/config.mk
include ./mk/bootstrap.mk
include ./mk/init.mk # in case we want to re-run init/sanity

UNAME   = uname
ARCH   := $(shell $(UNAME) -m)
OPSYS  := $(shell $(UNAME) -s)
SHELL   = /bin/bash -e
PREFIX ?= deployment

default:
	@echo "'make init' must occur before any other rule."
	@echo "You can do that manually, or let it happen automatically as 'initialized.mk' is generated."
	@echo "CCACHE_DIR=${CCACHE_DIR}"
	@echo "PREFIX=${PREFIX}"

# Please add dependencies after this line
ccache:           initialized.o
openssl:          ccache
zlib:             ccache
boost:            ccache zlib libbzip2
ifeq ($(origin HAVE_PYTHON),undefined)
python:           ccache zlib openssl ncurses readline libbzip2
else ifneq ($(origin HAVE_OPENSSL),undefined)
python:           openssl
else ifneq ($(origin HAVE_LIBSSL),undefined)
python:           openssl
endif
readline:         ccache ncurses
samtools:         ccache zlib ncurses htslib
bamtools:         ccache zlib
cmake:            ccache zlib
ncurses:          ccache
openblas:         ccache
hdf5:             ccache zlib
swig:             ccache python
libpng:           ccache zlib
hmmer:            ccache
gmap:             ccache zlib
sbt:              jre
libbzip2:         ccache
ngmlr:            init
minimap:          zlib

pip:              python
cython:           pip ccache
ifeq ($(OPSYS),Darwin)
numpy:            pip cython
else
numpy:            pip cython openblas
endif
h5py:             pip hdf5 numpy six
jsonschema:       pip functools32
pydot:            pip pyparsing
fabric:           pip paramiko ecdsa pycrypto
rdflib:           pip six isodate html5lib
matplotlib:       pip numpy libpng pytz six pyparsing python-dateutil cycler
rdfextras:        pip rdflib
scipy:            pip numpy
appnope:          pip
avro:             pip
decorator:        pip
docopt:           pip
ecdsa:            pip
functools32:      pip
gnureadline:      pip readline
html5lib:         pip
ipython_genutils: pip
iso8601:          pip
isodate:          pip
jinja2:           pip MarkupSafe
networkx:         pip decorator matplotlib
paramiko:         pip
path.py:          pip
pexpect:          pip
pickleshare:      pip
ptyprocess:       pip
pycrypto:         pip
pyparsing:        pip
pysam:            pip zlib cython htslib
python-dateutil:  pip
pytz:             pip
requests:         pip
simplegeneric:    pip
six:              pip
traitlets:        pip
xmlbuilder:       pip
nose:             pip
cram:             pip
cycler:           pip
MarkupSafe:       pip
tabulate:         pip
CramUnit:         cram nose xmlbuilder

# Not part of pacbio developers' software collection
nim:          ccache zlib
ssw_lib:      ccache pip
fasta2bam:    ccache pbbam htslib zlib boost cmake
scikit-image: pip numpy decorator six networkx matplotlib pillow
pillow:       pip
dask.array:   pip toolz numpy
toolz:        pip
ipython:      pip traitlets pickleshare appnope decorator gnureadline pexpect ipython_genutils path.py ptyprocess simplegeneric
Cogent:       pip numpy scipy networkx scikit-image biopython bx-python PuLP ssw_lib mash matplotlib
biopython:    pip numpy
bx-python:    pip zlib
PuLP:         pip

# software from pacbio
htslib:       ccache zlib
blasr_libcpp: ccache boost hdf5 pbbam
blasr:        ccache blasr_libcpp hdf5 cmake
bax2bam:      ccache blasr_libcpp hdf5 cmake
bam2bax:      ccache blasr_libcpp hdf5 cmake
pbbam:        ccache samtools cmake boost htslib gtest
dazzdb:       ccache
daligner:     ccache dazzdb
damasker:     ccache
dextractor:   ccache
pbdagcon:     ccache dazzdb daligner pbbam blasr_libcpp gtest
bam2fastx:    ccache pbbam htslib zlib boost cmake pbcopper
minorseq:     ccache cmake pbcopper pbbam
#
pbcore:           pysam
pbh5tools:        h5py pbcore
pbbarcode:        pbh5tools pbcore numpy h5py
pbcoretools:      pbcore pbcommand
pbcommand:        xmlbuilder jsonschema avro requests iso8601 numpy tabulate pytz
pbsmrtpipe:       pbcommand jinja2 networkx pbcore pbcommand pyparsing pydot jsonschema xmlbuilder requests nose
falcon_kit:       networkx daligner dazzdb damasker pbdagcon pypeFLOW
FALCON_unzip:     falcon_kit
falcon_polish:    falcon_kit blasr GenomicConsensus pbcoretools dextractor bam2fastx pbalign
falcon:           falcon_polish # an alias
pbfalcon:         falcon_polish pbsmrtpipe #pbreports
pbreports:        matplotlib cython numpy h5py pysam jsonschema pbcore pbcommand
kineticsTools:    scipy pbcore pbcommand h5py
pypeFLOW:         networkx
pbalign:          pbcore samtools blasr pbcommand
ConsensusCore:    numpy boost swig cmake
GenomicConsensus: pbcore pbcommand numpy h5py ConsensusCore unanimity
smrtflow:         sbt
pbtranscript:     scipy networkx pysam pbcore pbcommand pbcoretools pbdagcon hmmer blasr GenomicConsensus gmap
pbtranscript2:    scipy networkx pysam hmmer gmap blasr pbcore GenomicConsensus pbdagcon
pbccs:            unanimity
unanimity:        boost swig cmake htslib pbbam seqan pbcopper numpy
pbcopper:         cmake boost zlib
pbsv:             ngmlr pysam libbzip2 pbcore
pbsvtools:        pbsv pbcommand pbcoretools
pblaa:            htslib pbbam seqan unanimity
#
trim_isoseq_polyA: boost cmake zlib libbzip2
pysiv2:            fabric requests nose xmlbuilder pbsmrtpipe pbcoretools
PacBioTestData:    pip

# end of dependencies

# meta rules
reseq-core: \
       pbsmrtpipe pbalign blasr pbreports GenomicConsensus pbbam pbcoretools unanimity
isoseq-core: \
       reseq-core pbtranscript hmmer gmap biopython cram nose ipython
pbsv-core: \
       pbsv pbsvtoools nose
world: \
       reseq-core  pbfalcon  kineticsTools \
       isoseq-core ssw_lib   mash          \
       ipython     cram      nose          \
       trim_isoseq_polyA
third-party: \
    samtools h5py scipy ipython cram nose pysam networkx ngmlr gmap boost jsonschema swig jinja2 pyparsing pydot xmlbuilder requests fabric matplotlib iso8601 tabulate pytz hmmer avro htslib minimap
hosted-thirdparty: \
    dextractor damasker daligner dazzdb seqan htslib

# rules
ifeq ($(origin USE_CCACHE),undefined)
ccache: ;
else
ccache:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
endif
ifeq ($(OPSYS),Darwin)
HAVE_ZLIB ?=
HAVE_LIBBZIP2 ?=
readline: ;
ncurses: ;
libpng: ;
else
readline:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
ncurses:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
libpng:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
endif
openblas:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
zlib:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
hdf5:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
gtest:
	$(MAKE) -C ports/thirdparty/$@ do-install
gmock:
	$(MAKE) -C ports/thirdparty/$@ do-install
boost:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
samtools:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
bamtools:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
ifeq ($(origin HAVE_CMAKE),undefined)
cmake:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
else
cmake: ;
endif
swig:
	$(MAKE) -j1 -C ports/thirdparty/$@ ${RULE}
hmmer:
	$(MAKE) -j1 -C ports/thirdparty/$@ ${RULE}
gmap:
	$(MAKE) -j1 -C ports/thirdparty/$@ ${RULE}
jre:
	$(MAKE) -j1 -C ports/thirdparty/$@ ${RULE}
sbt:
	$(MAKE) -j1 -C ports/thirdparty/$@ ${RULE}
libbzip2:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
ngmlr:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
minimap:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}

openssl:
	$(MAKE) -C ports/thirdparty/libressl ${RULE}
ifeq ($(origin HAVE_PYTHON),undefined)
python:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
else
python:
	# No do-clean rule here.
	$(MAKE) -j1 -C ports/python/virtualenv do-install
endif
pip:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}

numpy:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
cython:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
xmlbuilder:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
jsonschema:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
avro:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
requests:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
iso8601:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
jinja2:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
networkx:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
pyparsing:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
pydot:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
fabric:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
h5py:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
docopt:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
pysam:
	$(MAKE) --no-print-directory -s -j1 -C ports/python/$@ ${RULE}
six:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
rdflib:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
rdfextras:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
matplotlib:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
scipy:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
traitlets:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
pickleshare:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
appnope:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
decorator:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
gnureadline:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
pexpect:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
ipython_genutils:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
path.py:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
ptyprocess:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
simplegeneric:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
paramiko:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
ecdsa:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
pycrypto:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
isodate:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
html5lib:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
functools32:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
pytz:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
python-dateutil:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
nose:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
cram:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
cycler:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
MarkupSafe:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
tabulate:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
CramUnit:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}

#
blasr_libcpp:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
blasr:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
bax2bam:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
bam2bax:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
htslib:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
seqan:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbbam:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
dazzdb:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
daligner:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
damasker:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
dextractor:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbdagcon:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
bam2fastx:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
#
pbcore:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbcommand:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbsmrtpipe:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
falcon_kit:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
FALCON_unzip:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
falcon_polish:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbfalcon:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pypeFLOW:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
ConsensusCore:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
GenomicConsensus:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbreports:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
kineticsTools:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbalign:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbcoretools:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbtranscript:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbtranscript2:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
unanimity:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbcopper:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbsv:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbsvtools:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
minorseq:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
#
pblaa:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
#
pbh5tools:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
pbbarcode:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
Cogent:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
#
smrtflow:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
trim_isoseq_polyA:
	$(MAKE) -j1 -C ports/pacbio/$@ ${RULE}
#
pysiv2:
	$(MAKE) -C ports/pacbio/$@ ${RULE}

# Not part of pacbio developers' software collection
nim:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
mash:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
ssw_lib:
	$(MAKE) -C ports/thirdparty/$@ ${RULE}
scikit-image:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
pillow:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
dask.array:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
toolz:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
ipython:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
biopython:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
bx-python:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
PuLP:
	$(MAKE) -j1 -C ports/python/$@ ${RULE}
fasta2bam:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
PacBioTestData:
	$(MAKE) -C ports/pacbio/$@ ${RULE}
test: PacBioTestData test-pbtranscript
test-pbtranscript: pbtranscript CramUnit
	$(MAKE) -C ports/pacbio/pbtranscript do-test
test-pbdagcon: pbdagcon
	$(MAKE) -C ports/pacbio/pbdagcon do-test
test-pbfalcon: pbfalcon nose pbreports
	$(MAKE) -C ports/pacbio/pbfalcon do-test
test-bam2bax: bam2bax
	$(MAKE) -C ports/pacbio/bam2bax do-test-bam2bax
test-bax2bam: bax2bam
	$(MAKE) -C ports/pacbio/bax2bam do-test-bax2bam
test-falcon_polish: falcon_polish nose
	$(MAKE) -C ports/pacbio/falcon_polish do-test

clean-%:
	bin/pitchfork clean $*
distclean-%:
	bin/pitchfork distclean $*
clean:
	bin/pitchfork clean --all
distclean:
	bin/pitchfork distclean --all
reinstall-%:
	bin/pitchfork uninstall $* || truue
	bin/pitchfork distclean $*
	$(MAKE) -C ports/pacbio/$* ${RULE}
.PHONY: ConsensusCore GenomicConsensus MarkupSafe appnope avro biopython blasr boost ccache cmake Cogent cram cycler cython dazzdb daligner damasker dextractor decorator default docopt ecdsa fabric gmap gmock gnureadline gtest hmmer htslib ipython isodate jsonschema kineticsTools libpng matplotlib ncurses networkx nim nose numpy openblas openssl paramiko pbalign pbbam unanimity pbchimera pbcommand pbcore pbcoretools pbdagcon pbfalcon pblaa pbreports pexpect pickleshare pip ptyprocess pycrypto pydot pyparsing pypeFLOW pysam python pytz rdfextras rdflib readline requests samtools scipy seqan simplegeneric six swig tcl traitlets world xmlbuilder zlib pbh5tools tabulate pbbarcode
