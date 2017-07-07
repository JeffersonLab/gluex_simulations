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

python_mods = "/cvmfs/singularity.opensciencegrid.org/rjones30/gluex:latest/usr/lib/python2.7/site-packages"
calib_db = "/cvmfs/oasis.opensciencegrid.org/gluex/ccdb/1.06.03/sql/ccdb_2017-06-09.sqlite"
resources = "/cvmfs/oasis.opensciencegrid.org/gluex/resources"
templates = "/cvmfs/oasis.opensciencegrid.org/gluex/templates"
jobname = re.sub(r"\.py$", "", os.path.basename(__file__))

# define the run range and event statistics here

total_events_to_generate = 10000       # aggregate for all slices in this job
number_of_events_per_slice = 250       # how many events generated per job
number_of_slices_per_run = 50          # increment run number after this many slices
initial_run_number = 31001             # starting value for generated run number

gluex_sim_project = "sim-mcsmear07-1.0"
script_to_execute = "sim.csh"

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

   # make a copy of ccdb sqlite file in /tmp to be sure file locking works
   global calib_db
   calib_db_copy = tempfile.NamedTemporaryFile().name
   if os.path.exists(calib_db_copy):
      Print("Warning - ccdb sqlite file", calib_db_copy,
            "already exists in tmp directory, assuming it is ok!")
   elif shellcode("cp -f " + calib_db + " " + calib_db_copy) != 0:
      Print("Error - unable to make a local copy of", calib_db_copy,
            "so cannot start job in this container!")
      sys.exit(77)
   calib_db = calib_db_copy
   

   # get the supporting files for the job
   os.system("wget -nd -r --no-parent https://halldweb.jlab.org/gluex_simulations/%s"%gluex_sim_project)

   # run the script that does the heavy work
   cmd = "./%s %s %d %d %s %s"%(script_to_execute, gluex_sim_project, run_number, slice_index, calib_db, resources)
   print "executing = "+cmd
   os.system(cmd)

   #if err != 0:
   #      return err

   # return success!
   os.remove(calib_db_copy)
   return 0


### This is the end of the section that users normally need to customize ###

execute(sys.argv, do_slice)
