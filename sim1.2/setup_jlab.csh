#!/bin/tcsh
#
# version specification
set VERSION_XML=/group/halld/www/halldweb/html/dist/version_1.30_jlab.xml
#
# finish the rest of the gluex environment
source /group/halld/Software/build_scripts/gluex_env_jlab.csh $VERSION_XML
# Use December 7, 2016 version of CCDB SQLite
setenv CCDB_CONNECTION sqlite:////group/halld/Software/calib/ccdb_sqlite/ccdb_2016-12-07.sqlite
setenv JANA_CALIB_URL $CCDB_CONNECTION
setenv JANA_CALIB_CONTEXT "variation=mc calibtime=2016-12-06"
