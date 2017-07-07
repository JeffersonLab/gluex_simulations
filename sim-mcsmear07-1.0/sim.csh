#!/bin/tcsh
limit stacksize unlimited
set project=$1
set run=$2
set file=$3
set number_of_events=$4
set ccdb_location=$5
set jana_resources=$6
echo -=-start job-=-
date
echo project $project run $run file $file num_events $number_of_events
echo ccdb_location $ccdb_location jana_resources $jana_resources
#
#cp -pv /group/halld/www/halldweb/html/gluex_simulations/sim1.2/* .
setenv PATH `pwd`:$PATH # put current directory into the path
echo -=-environment-=-
#source setup_jlab.csh
setenv JANA_RESOURCE_DIR $jana_resources
setenv CCDB_CONNECTION $ccdb_location
setenv JANA_CALIB_URL $ccdb_location
#setenv JANA_CALIB_CONTEXT "variation=mc calibtime=2017-01-31"
setenv JANA_CALIB_CONTEXT "variation=mc"
printenv | sort
#
# set flags based on run number
#
#set collimator = `rcnd $run collimator_diameter | awk '{print $1}'`
#echo collimator = $collimator
echo collimator = "5.0mm"
if ($collimator == "") then
    echo "no value returned for collimator"
    exit 1
endif
#
echo -=-run bggen-=-
cp -v run.ffr.${collimator}_coll.template run.ffr
set seed = $run$file
gsr.pl '<random_number_seed>' $seed run.ffr
gsr.pl '<run_number>' $run run.ffr
gsr.pl '<number_of_events>' $number_of_events run.ffr
rm -f fort.15
ln -s run.ffr fort.15
echo -=-fort.15-=-
cat fort.15
echo -=-=-=-=-=-=-
set command = bggen
echo command = $command
$command
echo -=-clean up bggen-=-
rm -v run.ffr*
rm -v fort.15
rm -v particle.dat
rm -v pythia*
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
echo -=-clean up hdgeant-=-
rm -v bggen.hddm
rm -v control.in*
echo -=-ls -lt after hdgeant-=-
ls -lt
echo -=-run mcsmear-=-
set command = "mcsmear -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1"
set command = "$command hdgeant.hddm"
echo command = $command
$command
echo -=-clean up mcsmear-=-
rm -v hdgeant.hddm
rm -v smear.root
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
mv -v hdgeant_smeared.hddm hdgeant_smeared_${run}_${file}.hddm
mv -v dana_rest.hddm dana_rest_${run}_${file}.hddm
mv -v hd_root.root hd_root_${run}_${file}.root
#
#cp -v tree_bcal_hadronic_eff.root $tree_bcal_hadronic_eff_dir/tree_bcal_hadronic_eff_${run}_${file}.root
#cp -v tree_fcal_hadronic_eff.root $tree_fcal_hadronic_eff_dir/tree_fcal_hadronic_eff_${run}_${file}.root
#cp -v tree_sc_eff.root $tree_sc_eff_dir/tree_sc_eff_${run}_${file}.root
#cp -v tree_tof_eff.root $tree_tof_eff_dir/tree_tof_eff_${run}_${file}.root
#
echo -=-final clean up-=-
rm -v check_monitoring_hists.py
rm -v gsr.pl
rm -v index.html
rm -v setup_jlab.csh
rm -v top_level.sh
rm -v index*
rm -v *.py
echo -=-end run-=-
date
echo -=-exit-=-
exit
