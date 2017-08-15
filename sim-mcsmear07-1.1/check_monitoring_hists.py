from ROOT import TFile,TH1F,TCanvas
import os,sys

###############################################################################
# check_monitoring_hists.py
# Author: Sean Dobbs (s-dobbs@northwestern.edu)
#
# Usage: check_monitoring_hists.py <directory-to-scan>
#
# Script to check the results of the monitoring_hists plugin
# It walks through a directory (defaults to the current directory, or whatever
# is defined below), and looks for histograms of a particular name
# It does two things:
#  1) Plots comparisons of given histograms compared to some reference
#  2) Keeps statistics of the number of counts in each histogram
###############################################################################

### GLOBALS
# name of output files to monitor - assumes that they are all named the same
FILENAME = "hd_root.root"
# reference file to check them all against
# note that this generally works better if the reference file is not in 
# the directory tree you are scanning
REFERENCE_FILE = "../hd_root.root"
# default directory to scan
DIRECTORY = "."
# We don't want to make PDF's for every file
# instead, make them for every PDF_COUNT'th file
PDF_COUNT = 2
# by default, the monitoring hists are made with a ton of bins
# if we want to rebin them, specify the number of bins to combine
# set to 0 for no rebinning
REBIN_LEVEL = 5

# number of generated events per job
EVENTS_PER_JOB = 10000
# name of histogram of the energy of beam photons
# it is filled just once per event (?) so we can use it to cross check if we have
# the number of events we expect
BEAMPHOTON_HIST_NAME = "Independent/Hist_ThrownParticleKinematics/Beam_Photon/Momentum"

# list of histograms to check
histnames = [ "Independent/Hist_DetectedParticleKinematics/Proton/Momentum",
              "Independent/Hist_DetectedParticleKinematics/Pi+/Momentum",
              "Independent/Hist_DetectedParticleKinematics/Pi-/Momentum" ]

###############################################################################

# set the parameters and plot the histograms
def plot_hist_comp(h, href):
    href.SetLineColor(4)
    href.SetLineWidth(2)
    href.SetStats(0)

    #h.Scale(h.Integral()/href.Integral())
    if REBIN_LEVEL>0:
        h.Rebin(REBIN_LEVEL)

    h.Draw()
    href.Draw("SAME")


if __name__ == "__main__":
    ## define data structures
    out_histnames = {}
    out_hists = {}
    reference_hists = {}
    event_counts = {}
    num_files = 0

    ## set up data structures
    for hn in histnames:
        out_histnames[hn] = hn.replace("/", "-")
        event_counts[hn] = []
        #print hn + "  " + out_histnames[hn] 

    ## load reference histograms
    ref_file = TFile(REFERENCE_FILE)    
    for hn in histnames:
        reference_hists[hn] = ref_file.Get(hn)
        if(REBIN_LEVEL>0):
            reference_hists[hn].Rebin(REBIN_LEVEL)

    ## optional command line argument - directory to scan
    if len(sys.argv) > 1:
        DIRECTORY = str(sys.argv[1])

    c1 = TCanvas("c1","",800,600)
    ## process the files - we look for all of the files in a particular
    ## directory structure that match a specific file name
    for root, dirs, files in os.walk(DIRECTORY):
        for f in files:
            if f == FILENAME:
                filenamepath = os.path.join(root, f)
                print "Processing " + filenamepath + "..."
                try:
                    pdf_filename = filenamepath.replace(".root", ".pdf")
                    f = TFile(filenamepath)

                    # check to see if the number of events in the file is correct
                    # as a proxy, look at the number of events in a histogram 
                    # that is filled once per event
                    try:
                        n = f.Get(BEAMPHOTON_HIST_NAME).Integral()
                        if n != EVENTS_PER_JOB:
                            print " %s has too few events!!  (%d out of %d)" % (f, n, EVENTS_PER_JOB)
                    except:
                        print "Could not check number of events for %s" % (f)
                    
                    # only count files that open correctly
                    num_files = num_files + 1
                    for hn in histnames:
                        n = f.Get(hn).Integral()
                        event_counts[hn].append(n)
                        #print hn + "  " + str(n)

                        ## print out PDF comparisons every so often
                        if( (num_files-1)%PDF_COUNT == 0):
                            plot_hist_comp(f.Get(hn), reference_hists[hn])
                            if(hn==histnames[0]):
                                c1.Print(pdf_filename+"(")
                            elif(hn==histnames[-1]):
                                c1.Print(pdf_filename+")")
                            else:
                                c1.Print(pdf_filename)
                    f.Close()
                except:
                    print "Error processing file!"


    ## histogram number of counts
    for hn in histnames:
        out_hists[hn] = TH1F(out_histnames[hn], hn, 100, 0.9*min(event_counts[hn]), 1.1*max(event_counts[hn]))
        for x in event_counts[hn]:
            out_hists[hn].Fill(x)

    ## output the histograms
    outf = TFile("monitor.root", "recreate")
    for h in out_hists.values():
        h.Write()
    outf.Close()
