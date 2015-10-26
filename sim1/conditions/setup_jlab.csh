# preliminaries
setenv BUILD_SCRIPTS /group/halld/Software/build_scripts
setenv BMS_OSNAME `$BUILD_SCRIPTS/osrelease.pl`
# gluex software versions
setenv CCDB_HOME /group/halld/Software/builds/$BMS_OSNAME/ccdb/prod
setenv HALLD_HOME /work/halld/home/sdobbs/Software/sim-recon/prod
setenv HDDS_HOME /work/halld/home/sdobbs/Software/hdds/prod
setenv JANA_HOME /group/halld/Software/builds/$BMS_OSNAME/jana/jana_0.7.3/$BMS_OSNAME
setenv ROOTSYS /group/halld/Software/builds/$BMS_OSNAME/root/root_5.34.26
#
setenv CERN_CUE `$BUILD_SCRIPTS/cue_cernlib.pl`
setenv CERN `$BUILD_SCRIPTS/cue_cernlib.pl`
setenv CERN_LEVEL 2005
setenv EVIOROOT /group/halld/Software/builds/Linux_CentOS6-x86_64-gcc4.4.7/evio/evio-4.3.1/Linux-x86_64
setenv XERCESCROOT /group/halld/Software/ExternalPackages/xerces-c-3.1.1.$BMS_OSNAME
source $BUILD_SCRIPTS/gluex_env.csh
#
setenv LD_LIBRARY_PATH $EVIOROOT/lib:$LD_LIBRARY_PATH
if ( ! $?JANA_PLUGIN_PATH ) then
	setenv JANA_PLUGIN_PATH 
endif
setenv JANA_PLUGIN_PATH /group/halld/Software/builds/online/monitoring/${BMS_OSNAME}/plugins/:${HALLD_HOME}/${JANA_PLUGIN_PATH}/${BMS_OSNAME}/plugins:${JANA_HOME}/plugins/
setenv PYTHONPATH $HALLD_HOME/$BMS_OSNAME/lib/python:$PYTHONPATH
#
setenv JANA_RESOURCE_DIR /group/halld/www/halldweb/html/resources
# MySQL CCDB connection
#setenv CCDB_CONNECTION mysql://ccdb_user@hallddb.jlab.org/ccdb
#setenv JANA_CALIB_URL mysql://ccdb_user@hallddb.jlab.org/ccdb
# Default "latest" CCDB SQLite
setenv CCDB_CONNECTION sqlite:////group/halld/www/halldweb/html/dist/ccdb.sqlite 
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
