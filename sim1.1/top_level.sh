// manipulate/generate random #'s, file names in scripts here
mv run.ffr.template run.ffr
ln -s run.ffr fort.15
bggen
hdgeant
mcsmear hdgeant.hddm -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1
hd_ana -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 -PPLUGINS=rawevent hdgeant_smeared.hddm
hd_root hdgeant_smeared.hddm -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 -PPLUGINS=danarest,monitoring_hists
// manipulate file names here
