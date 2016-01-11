#!/bin/tcsh
# version specification
#set VERSION_XML=/group/halld/www/halldweb/html/dist/version_1.10.xml
set VERSION_XML=/home/gxproj4/version_newbcal.xml
#
setenv BUILD_SCRIPTS /group/halld/Software/build_scripts
setenv BMS_OSNAME `$BUILD_SCRIPTS/osrelease.pl`
setenv GLUEX_TOP /group/halld/Software/builds/$BMS_OSNAME
# finish the rest of the gluex environment
source $BUILD_SCRIPTS/gluex_env_version.csh $VERSION_XML
setenv JANA_CALIB_URL $CCDB_CONNECTION
setenv JANA_RESOURCE_DIR /group/halld/www/halldweb/html/resources
# python on the cue
setenv PATH /apps/python/PRO/bin:$PATH
setenv LD_LIBRARY_PATH /apps/python/PRO/lib:$LD_LIBRARY_PATH
# Use January 7, 2016 version of CCDB SQLite
setenv CCDB_CONNECTION sqlite:////group/halld/Software/calib/ccdb_sqlite/ccdb_2016-01-07.sqlite
setenv JANA_CALIB_URL sqlite:////group/halld/www/halldweb/html/dist/ccdb.sqlite
if ( ! $?JANA_CALIB_CONTEXT ) then
    echo "WARNING: JANA_CALIB_CONTEXT not set!  Setting default variation to mc_sim1 ..."
    setenv JANA_CALIB_CONTEXT "variation=mc_sim1"
endif

# check to see if the variation and calibtime fields are set for the CCDB
#if( '$JANA_CALIB_CONTEXT' !~ *calibtime* || '$JANA_CALIB_CONTEXT' !~ *variation* ) then
if( `expr index calibtime "$JANA_CALIB_CONTEXT"` == 0 || `expr index variation "$JANA_CALIB_CONTEXT"` == 0 ) then
    echo "WARNING: The JANA_CALIB_CONTEXT environment variable is not properly set."
    echo "For generating and analyzing simulated data, the variation should be set"
    echo "to one that begins with 'mc', and the 'calibtime' parameter to should"
    echo "be set as well."
    echo 
    echo '    Example:  JANA_CALIB_CONTEXT="variation=mc_sim1 calibtime=2015-10-31"'
else
    # check to make sure that the variation begins with "mc", as it GlueX convention
    set check=`echo $JANA_CALIB_CONTEXT | perl -e '$_=<>; foreach $field (split) { @tokens=split/=/,$field; if( $tokens[0] eq "variation" and scalar(@tokens)>1 and $tokens[1] =~ "^mc") {print "1"; exit; } } print "0";'`
    if( $check == 0 ) then
        echo "WARNING: The JANA_CALIB_CONTEXT environment variable is not properly set."
        echo "For generating and analyzing simulated data, the variation should be set"
        echo "to one that begins with 'mc', and the 'calibtime' parameter to should"
        echo "be set as well."
        echo 
        echo '    Example:  JANA_CALIB_CONTEXT="variation=mc_sim1 calibtime=2015-10-31"'
    endif
endif
