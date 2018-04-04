from WMCore.Configuration import Configuration
from CRABClient.UserUtilities import getUsernameFromSiteDB
config = Configuration()


name= 'VBFHbb'
config.section_("General")
config.General.requestName = "privateMCProduction#REQUESTDATE##WHOAMI#"
config.General.workArea = 'crab_privateMCProduction'
config.General.transferLogs = True

config.section_("JobType")
config.JobType.pluginName = 'PrivateMC'
config.JobType.psetName = 'pythonLHEGEN_cfg.py'
config.JobType.inputFiles = ['GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh', 'gridpack.tgz']
config.JobType.disableAutomaticOutputCollection = False

config.section_("Data")
config.Data.outputPrimaryDataset = 'privateMCProductionLHEGEN'
config.Data.splitting = 'EventBased'
config.Data.unitsPerJob = 100
config.Data.totalUnits = #NUMBEREVENTS#
config.Data.publication = True
config.Data.outputDatasetTag = 'eventLHEGEN-#BASENAME#-#REQUESTDATE#'
config.Data.outLFNDirBase = '/store/user/%s/t3store2/VBFHbb' % (getUsernameFromSiteDB())

config.section_("Site")
#config.Site.storageSite = 'T2_DE_DESY'
config.Site.storageSite = 'T2_IN_TIFR'
config.Site.whitelist = ['T2_*']

#config.section_("User")
## only german users
#config.User.voGroup = "dcms"
