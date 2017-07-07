#!/bin/tcsh
#
# version specification
set VERSION_XML=/group/halld/www/halldweb/html/dist/version_1.30_jlab.xml
#
# finish the rest of the gluex environment
source /group/halld/Software/build_scripts/gluex_env_jlab.csh $VERSION_XML
# Use February 1, 2017 version of CCDB SQLite file
setenv CCDB_CONNECTION sqlite:////group/halld/Software/calib/ccdb_sqlite/ccdb_2017-02-01.sqlite
setenv JANA_CALIB_URL $CCDB_CONNECTION
setenv JANA_CALIB_CONTEXT "variation=mc calibtime=2017-01-31"
