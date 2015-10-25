
# preliminaries
setenv BUILD_SCRIPTS /group/halld/Software/build_scripts
setenv BMS_OSNAME `$BUILD_SCRIPTS/osrelease.pl`
# gluex software versions
#setenv CCDB_HOME /group/halld/Software/builds/ccdb/$BMS_OSNAME/ccdb_1.04
setenv CCDB_HOME /group/halld/Software/builds/$BMS_OSNAME/ccdb/prod
setenv HALLD_HOME /work/halld/home/sdobbs/Software/sim-recon/prod
setenv HDDS_HOME /work/halld/home/sdobbs/Software/hdds/prod
#setenv JANA_HOME //group/halld/Software/builds/jana/jana_0.7.2/$BMS_OSNAME
setenv JANA_HOME /group/halld/Software/builds/$BMS_OSNAME/jana/jana_0.7.3/$BMS_OSNAME
#setenv JANA_HOME /group/halld/Software/builds/$BMS_OSNAME/jana/jana_0.7.2/$BMS_OSNAME
setenv ROOTSYS /group/halld/Software/builds/$BMS_OSNAME/root/root_5.34.26
#setenv ROOTSYS /group/halld/Software/ExternalPackages/ROOT/v5.34.01/root_$BMS_OSNAME
#
setenv CERN_CUE `$BUILD_SCRIPTS/cue_cernlib.pl`
setenv CERN `$BUILD_SCRIPTS/cue_cernlib.pl`
setenv CERN_LEVEL 2005
setenv EVIOROOT /group/halld/Software/builds/Linux_CentOS6-x86_64-gcc4.4.7/evio/evio-4.3.1/Linux-x86_64
setenv XERCESCROOT /group/halld/Software/ExternalPackages/xerces-c-3.1.1.$BMS_OSNAME
source $BUILD_SCRIPTS/gluex_env.csh
setenv LD_LIBRARY_PATH $EVIOROOT/lib:$LD_LIBRARY_PATH
#
setenv CCDB_CONNECTION mysql://ccdb_user@hallddb.jlab.org/ccdb
setenv JANA_CALIB_URL mysql://ccdb_user@hallddb.jlab.org/ccdb
#setenv CCDB_CONNECTION sqlite:////work/halld/home/sdobbs/detcom_02/conditions/ccdb_2015-04-18.sqlite
setenv JANA_RESOURCE_DIR /group/halld/www/halldweb/html/resources
if ( ! $?JANA_PLUGIN_PATH ) then
	setenv JANA_PLUGIN_PATH 
endif

setenv JANA_CALIB_CONTEXT "variation=mc"
setenv JANA_PLUGIN_PATH /group/halld/Software/builds/online/monitoring/${BMS_OSNAME}/plugins/:${HALLD_HOME}/${JANA_PLUGIN_PATH}/${BMS_OSNAME}/plugins:${JANA_HOME}/plugins/

# for eventstore
setenv PYTHONPATH $HALLD_HOME/$BMS_OSNAME/lib/python:$PYTHONPATH

#unsetenv HALLD_MY
setenv HALLD_MY /work/halld/home/sdobbs/halld_my
