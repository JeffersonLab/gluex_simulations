#!/usr/bin/env python2.7
#
# jobname: sdobbs
# author: Sean Dobbs, sdobbs@jlab.org
# created: July 7, 2017
#

import sys
import os
import re
import tempfile
import subprocess
import glob

python_mods = "/cvmfs/singularity.opensciencegrid.org/rjones30/gluex:latest/usr/lib/python2.7/site-packages"
calib_db = "/cvmfs/oasis.opensciencegrid.org/gluex/ccdb/1.06.04/sql/ccdb.sqlite"
resources = "/cvmfs/oasis.opensciencegrid.org/gluex/resources"
templates = "/cvmfs/oasis.opensciencegrid.org/gluex/templates"
jobname = re.sub(r"\.py$", "", os.path.basename(__file__))

# define the run range and event statistics here

total_events_to_generate = 10000       # aggregate for all slices in this job
number_of_events_per_slice = 500       # how many events generated per job
#
#total_events_to_generate = 10000000       # aggregate for all slices in this job
#total_events_to_generate = 2000000       # aggregate for all slices in this job
#total_events_to_generate = 250000       # aggregate for all slices in this job
#number_of_events_per_slice = 10000       # how many events generated per job
#number_of_events_per_slice = 5000       # how many events generated per job
#number_of_events_per_slice = 25000       # how many events generated per job
number_of_slices_per_run = 5000          # increment run number after this many slices
initial_run_number = 31001             # starting value for generated run number
#initial_run_number = 31002             # starting value for generated run number

# define the source of random triggers, if you want these
random_triggers_server = "nod29.phys.uconn.edu"
random_triggers_folder = "/Gluex/rawdata/random_triggers/RunPeriod-2017-01"
random_triggers_multiplicity = "1.0"

# job parameters
gluex_sim_project = "sim-mcsmear07-1.0"
script_to_execute = "sim.csh"
#script_to_execute = "sim.omega.csh"
#script_to_execute = "sim.4pi.csh"
script_source_url = "https://halldweb.jlab.org/download/gluex_simulations/%s/"%gluex_sim_project

try:
   sys.path.append(python_mods)
   from osg_job_helper import *
except:
   print "Error - this job script expects to find the cernvm filesystem mounted at /cvmfs"
   print "with /cvmfs/singularity.opensciencegrid.org and /cvmfs/oasis.opensciencegrid.org"
   print "reachable by automount."
   sys.exit(1)
helper_set_slicing(total_events_to_generate, number_of_events_per_slice)

### All processing occurs in these functions -- users should customize these as needed ###

def do_slice(arglist):
   """
   Actually execute this slice here and now. Normally this action takes place
   on the worker node out on the osg, but it can also be executed from an
   interactive shell. The results should be the same in either case.
   Arguments are:
     1) <start> - base slice number to be executed by this request
     2) <offset> - slice number (only 1) to execute is <start> + <offset>
   """
   if len(arglist) != 2:
      usage()

   global run_number
   global slice_index
   slice_index = int(arglist[0]) + int(arglist[1])
   run_number = initial_run_number + int(slice_index / number_of_slices_per_run)
   suffix = "_" + jobname + "_" + str(slice_index)

   # diagnostics
   os.system("printenv")
   
   # get the supporting files for the job
   os.system("wget -nd -r --no-parent %s"%script_source_url)
   # set needed executable bits for scripts
   os.system("chmod +x sim.csh")
   os.system("chmod +x sim.omega.csh")
   os.system("chmod +x sim.4pi.csh")
   os.system("chmod +x gsr.pl")
   os.system("chmod +x Gen4Pi.exe")

   # get latest CCDB SQLite file
   os.system("wget -O ccdb.sqlite https://halldweb.jlab.org/dist/ccdb.sqlite")

   # load random triggers
   if len(random_triggers_server) > 0:
      shellcode("uberftp " + random_triggers_server +
                " \"ls " + random_triggers_folder + "\"" +
                " | awk '{if(NF>8){print $9}}' > randoms_directory")
      randoms_files = open("randoms_directory").readlines()
      randoms_file = randoms_files[slice_index % len(randoms_files)].rstrip()
      shellcode("uberftp " + random_triggers_server +
                " \"get " + random_triggers_folder + "/" +
                randoms_file + " " + randoms_file + "\"")
      os.rename(randoms_file, "random.hddm")

   # run the script that does the heavy work
   cmd = "./%s %s %d %d %d"%(script_to_execute, gluex_sim_project, run_number, slice_index, number_of_events_per_slice)
   retcode = shellcode("source $GLUEX_TOP/.hdpm/env/recon-2017_01-ver01-batch01-mcsmear.sh", 
                       "export JANA_RESOURCE_DIR=" + resources,
                       "export RCDB_CONNECTION=mysql://rcdb@hallddb.jlab.org/rcdb",
                       cmd)

   # temporary fix to ignore segfault at program exit (to be removed)
   if retcode == 139:
      retcode = 0

   # cleanup files
   files_to_clean = [ "check_monitoring_hists.py", "gridjob-classic.py", "gridjob-template.py", "gsr.pl", 
                      "control.in_3.4mm_coll", "control.in_5.0mm_coll", "index.html", "osg-container.sh", "particle.dat", 
                      "pythia.dat", "pythia-geant.map", "run.ffr.3.4mm_coll.template", "run.ffr.5.0mm_coll.template", 
                      "setup_jlab.csh", "sim.csh", "top_level.sh", "sim-mcsmear07-1.0" ]
   files_to_clean += [ "fort.15", "run.ffr", "bggen.his", "bggen.hddm", "smear.root", 
                       "hdgeant.rz", "geant.hbook", "hdgeant.hddm", "randoms_directory", "random.hddm",
                       "gridjob-gluex_sim.py", "Gen4Pi.exe", "cobrems.root" ]

   print "cleaning up = " + str(files_to_clean)
   for fname in files_to_clean:
      if os.path.isfile(fname):
         os.remove(fname)
   for fname in glob.glob("index*"):
      os.remove(fname)
   #os.remove(calib_db_copy)

   return retcode


### This is the end of the section that users normally need to customize ###

execute(sys.argv, do_slice)
