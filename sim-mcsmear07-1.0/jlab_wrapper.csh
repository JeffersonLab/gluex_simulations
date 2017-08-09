#!/bin/tcsh
#
set script=$1
set project=$2
set run=$3
set file=$4
set number_of_events=$5                                                                                                                     
#
# set up files
cp -pv /group/halld/www/halldweb/html/gluex_simulations/sim-mcsmear07-1.0 .
cp -v /group/halld/www/halldweb/html/dist/ccdb.sqlite .
#
echo -=-JLab environment-=-
source setup_jlab.csh
# 
echo -=run script=-
$script $project $run $file $number_of_events
echo -=copy files to destination=-
#
set smeared_dir=/volatile/halld/gluex_simulations/$project/smeared
mkdir -p $smeared_dir
cp -v hdgeant_smeared_${run}_${file}.hddm $smeared_dir/hdgeant_smeared_${run}_${file}.hddm
#
set rest_dir=/volatile/halld/gluex_simulations/$project/rest
mkdir -p $rest_dir
cp -v dana_rest_${run}_${file}.hddm $rest_dir/dana_rest_${run}_${file}.hddm
#
set hd_root_dir=/volatile/halld/gluex_simulations/$project/hd_root
mkdir -p $hd_root_dir
cp -v hd_root_${run}_${file}.root $hd_root_dir/hd_root_${run}_${file}.root
#
echo -=wrapper done=-
exit
