#!/bin/tcsh
#
# version specification
set VERSION_XML=/group/halld/www/halldweb/html/dist/version_recon-2017_01-ver01-batch01-mcsmear-ver03.xml
#
# finish the rest of the gluex environment
source /group/halld/Software/build_scripts/gluex_env_jlab.csh $VERSION_XML
# Use September 28, 2017 version of CCDB SQLite file
setenv CCDB_CONNECTION sqlite:////group/halld/Software/calib/ccdb_sqlite/ccdb_2017-09-28.sqlite
setenv JANA_CALIB_URL $CCDB_CONNECTION
setenv JANA_CALIB_CONTEXT "variation=mc calibtime=2017-09-28"
