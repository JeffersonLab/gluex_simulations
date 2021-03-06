#!/bin/tcsh
limit stacksize unlimited
set project=$1
set run=$2
set file=$3
set number_of_events=$4
echo -=-start job-=-
echo project $project run $run file $file num_events $number_of_events
date
#
#cp -v /cvmfs/oasis.opensciencegrid.org/gluex/resources/sqlite/ccdb.sqlite .
#cp -pv /group/halld/www/halldweb/html/gluex_simulations/sim1.2/* .
setenv PATH `pwd`:$PATH # put current directory into the path
echo -=-environment-=-
#source setup_jlab.csh
#source $GLUEX_TOP/.hdpm/env/recon-2017_01-ver01-batch01-mcsmear.sh
#setenv CCDB_CONNECTION sqlite:///`pwd`/ccdb.sqlite
#setenv CCDB_CONNECTION sqlite:////cvmfs/oasis.opensciencegrid.org/gluex/resources/sqlite/ccdb.sqlite
#setenv JANA_CALIB_URL $CCDB_CONNECTION
#setenv JANA_CALIB_URL mysql://ccdb_user@hallddb.jlab.org/ccdb
#setenv JANA_CALIB_CONTEXT "variation=mc calibtime=2017-01-31"
#setenv JANA_CALIB_CONTEXT "variation=mc"
setenv CCDB_CONNECTION sqlite:///`pwd`/ccdb.sqlite
setenv JANA_CALIB_URL $CCDB_CONNECTION
setenv JANA_CALIB_CONTEXT "variation=mc calibtime=2017-08-15-07-00-00"
#
echo HALLD_HOME = $HALLD_HOME
printenv | sort
#
# set flags based on run number
#
set collimator = `rcnd $run collimator_diameter | awk '{print $1}'`
#set collimator = "5.0mm"
echo collimator = $collimator
if ($collimator == "") then
    echo "no value returned for collimator"
    exit 1
endif
#
echo -=-run Gen4pi-=-
set command = "./Gen4Pi.exe -N$run"
echo command = $command
$command
mv -v genOut.hddm bggen.hddm
echo -=-ls -lt after bggen-=-
ls -lt
echo -=-run hdgeant-=-
rm -f control.in
cp -v control.in_${collimator}_coll control.in
echo -=-control.in-=- 
perl -n -e 'chomp; if (! /^c/ && $_) {print "$_\n";}' < control.in
echo -=-=-=-=-=-=-=-=
set command = hdgeant
echo command = $command
$command
echo -=-ls -lt after hdgeant-=-
ls -lt
echo -=-run mcsmear-=-
set command = "mcsmear -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1"
if ($collimator == "31001") then
    set command = "$command hdgeant.hddm random.hddm:1"
else
    set command = "$command hdgeant.hddm"
endif
echo command = $command
$command
echo -=-ls -lt after mcsmear-=-
ls -lt
echo -=-run hd_root-=-
set command = "hd_root -PJANA:BATCH_MODE=1 -PNTHREADS=1"
set command = "$command -PPLUGINS=danarest,monitoring_hists"
#set command = "$command -PPLUGINS=danarest,monitoring_hists,TRIG_online,"
#set command = "${command}BCAL_inv_mass,FCAL_invmass,BCAL_Hadronic_Eff,"
#set command = "${command}CDC_Efficiency,FCAL_Hadronic_Eff,FDC_Efficiency,"
#set command = "${command}SC_Eff,TOF_Eff,p2pi_hists,p3pi_hists"
#set command = "$command -PTRKFIT:HYPOTHESES=2,3,8,9,11,12,14"
set command = "$command hdgeant_smeared.hddm"
echo command = $command
$command
echo -=-ls -lt after hd_root-=-
ls -lt
#
echo -=-rename output files for staging-=-
#
mv -v hdgeant_smeared.hddm hdgeant_smeared_${run}_${file}.4pi.hddm
mv -v dana_rest.hddm dana_rest_${run}_${file}.4pi.hddm
mv -v hd_root.root hd_root_${run}_${file}.4pi.root
mv -v tree_bcal_hadronic_eff.root  tree_bcal_hadronic_eff_${run}_${file}.4pi.root  
mv -v tree_fcal_hadronic_eff.root  tree_fcal_hadronic_eff_${run}_${file}.4pi.root  
mv -v tree_sc_eff.root  tree_sc_eff_${run}_${file}.4pi.root  
mv -v tree_tof_eff.root  tree_tof_eff_${run}_${file}.4pi.root
#
#cp -v tree_bcal_hadronic_eff.root $tree_bcal_hadronic_eff_dir/tree_bcal_hadronic_eff_${run}_${file}.root
#cp -v tree_fcal_hadronic_eff.root $tree_fcal_hadronic_eff_dir/tree_fcal_hadronic_eff_${run}_${file}.root
#cp -v tree_sc_eff.root $tree_sc_eff_dir/tree_sc_eff_${run}_${file}.root
#cp -v tree_tof_eff.root $tree_tof_eff_dir/tree_tof_eff_${run}_${file}.root
#
echo -=-end run-=-
date
echo -=-exit-=-
exit
