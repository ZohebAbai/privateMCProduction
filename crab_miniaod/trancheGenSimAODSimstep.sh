#!/bin/bash

# Define number of events
export NUMBEREVENTS=1

# Define workdir
export WORKDIR=`pwd`

# Define location of GenSim samples, warning make sure that you run only one time on the same folder since otherwise we will produce two times the events.
# You will get an error message if you try to reuse some of the input files, so please make sure that you start this production only after all GenSim events are produced.
# Furthermore, you have to give an absolute path name
export GENSIMLOC=/privateMCProductionLHEGEN/dekumar-eventLHEGEN-VBF_H_slc6_amd64_gcc630_CMSSW_9_3_0_test_AllInOneVBF_H_NNPDF30_14TeV_M125-2018040316041522766658_LHEoutput-cdf6682d86ac38d50f7592eda6420f49/USER


# Use crab for grid submitting, adjust crabconfig.py accordingly beforehand
# Use of crab is necessary so far
export USECRAB="True"

######### Do not change anything behind this line ###############


#export STARTDIR=`pwd`
#echo "Start dir was:"
#echo $STARTDIR

#echo "Workdir set is:"
#echo $WORKDIR
#mkdir -p $WORKDIR
#echo "Created workdir"
#cd $WORKDIR
#echo "Changed into workdir"

#echo "Install CMSSW in workdir"
#source /cvmfs/cms.cern.ch/cmsset_default.sh
#export SCRAM_ARCH=slc6_amd64_gcc530
#scram project CMSSW_8_0_21
#cd CMSSW_8_0_21/src
#eval `scramv1 runtime -sh`
#echo "Loaded CMSSW_8_0_21"


echo "Make sure that GenSim event files are not used twice by checking if a GenSimAlreadyUsed.txt file exists in repository folder"
echo "If file is found, production will not be started. Please contact Andrej or Marco to clarify if this warning is unexpected, e.g. you did not produce DR event files yet."
export ALREADYUSED=`grep "$GENSIMLOC" $WORKDIR/GenSimAlreadyUsed.txt`
if [ -z "$ALREADYUSED" ]; then
   echo $ALREADYUSED
   echo "Production can go on"
else
    echo "GenSimAlreadyUsed.txt file was found. Since GenSim events were already used, production will not be started. Contact Andrej and Marco if you have questions."
    echo "Check GenSimAlreadyUsed.txt file in this folder. If you want to give another GENSIMLOC than you used before it is safe to delete this file, but please make sure that nobody else used this GENSIMLOC before."
    exit -1
fi

echo "Create file for blocking of second production using same input files"
touch $WORKDIR/GenSimAlreadyUsed.txt
echo $GENSIMLOC >> $WORKDIR/GenSimAlreadyUsed.txt

echo $GENSIMLOC > filelist_crab.txt
head -c -1 -q  $WORKDIR/step2_draft_part1.py filelist_crab.txt $WORKDIR/step2_draft_part2.py > ./step2_filesInserted.py
head -c -1 -q  $WORKDIR/crabconfig_draft_part1.py filelist_crab.txt $WORKDIR/crabconfig_draft_part2.py > $WORKDIR/crabconfig_draft.py

echo "Change number of events in python config to"
echo $NUMBEREVENTS
sed -e "s/#NUMBEREVENTS#/${NUMBEREVENTS}/g" step2_filesInserted.py > ./step2_cfg.py
sed -e "s/#NUMBEREVENTS#/${NUMBEREVENTS}/g" $WORKDIR/step3_cfg_draft.py > ./step3_cfg.py
sed -e "s/#NUMBEREVENTS#/${NUMBEREVENTS}/g" $WORKDIR/step4_cfg_draft.py > ./step4_cfg.py

echo "Copy jobScript.sh file to workdir"
cp $WORKDIR/jobScript.sh ./jobScript.sh

if [ $USECRAB = "True" ]; then
	echo "Will use crab submission, adjust crabconfig.py accordingly if problems arise"

        echo "Scram b and start of GenSim to AODSim to MiniAOD production"
	scram b -j 4

	echo "Load crab environment, grid environment should be loaded manually in advance if necessary"
	source /cvmfs/cms.cern.ch/crab3/crab.sh

	echo "Change number of events in crab config to"
	echo $NUMBEREVENTS
	echo " and copy crabconfig.py to workdir"
	sed -e "s/#NUMBEREVENTS#/${NUMBEREVENTS}/g" $WORKDIR/crabconfig_draft.py > ./crabconfig_eventsInserted.py
	sed -e "s/#REQUESTDATE#/`date  +'%Y%m%d%H%m%s'`/g" ./crabconfig_eventsInserted.py > ./crabconfig_dateInserted.py
	sed -e "s/#WHOAMI#/`whoami`/g" ./crabconfig_dateInserted.py > ./crabconfig_UserInserted.py

	export BASENAMEREPLACEFULL=`echo $GENSIMLOC | grep -o 'eventLHEGEN-[A-Za-z_0-9]*'`
	export BASENAMEREPLACE=${BASENAMEREPLACEFULL:13}
	sed -e "s/#BASENAME#/${BASENAMEREPLACE}/g" ./crabconfig_UserInserted.py > ./crabconfig.py


        echo "Scram b and start of GenSim to AODSim to MiniAOD production"
        scram b -j 4

	echo "Submit crab jobs"
	crab submit crabconfig.py

	echo "Finished with crab submission, check job status manually"
	echo "In the end you should get MiniAOD files."
else
	echo "Local production using cmsRun is not supported."
	exit -1
fi
