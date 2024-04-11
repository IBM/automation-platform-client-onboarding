#!/bin/bash
###############################################################################
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2024. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
###############################################################################

# This file is to be used with CP4BA 23.0.2 starter deployment to deploy the Client Onboarding scenario and associated labs using an internal email server/client

# Set all variables according to your environment before executing this file or use the respective command line options

#----------------------------------------------------------------------------------------------------------
# Specify below variables to launch the deployment automation with
#----------------------------------------------------------------------------------------------------------

# 'ocLoginServer' and 'ocLoginToken' need to be specified

# Value of the 'server' parameter as shown on the 'Copy login command' page in the OCP web console
ocLoginServer=REQUIRED
# Value shown under 'Your API token is' or as 'token' parameter as shown on the 'Copy login command' page in the OCP web console
ocLoginToken=REQUIRED

# Uncomment when the OCP cluster contains more than one namespace/project into which CP4BA has been deployed and specify the name of the namespace you want to deploy to. 
# If only one CP4BA namespace exists the deployment tool will determine the namespace automatically
#cp4baNamespace=REQUIRED


# Set to false in case environment the Client Onboarding lab artifacts should not be deployed and only the Client Onboarding scenario is required (if set to false, will reduce deployment time)
configureLabs=true

# Set to true in case environment should be used to perform Workflow labs using business users (user1-user10) instead of admin user (cp4admin)
enableWorkflowLabsForBusinessUsers=false


# User for who the RPA bot is executed (specifying a non-existing user basically skipped the RPA bot execution)
rpaBotExecutionUser=cp4admin2
# URL of the RPA server to be invoked for the RPA bot execution
rpaServer=https://rpa-server.com:1111

# Uncomment below two properties to provide credentials for an external gmail account if emails should be sent to external email addresses otherwise an internal email server/client will be used

# Email address of the gmail account to send emails
# gmailAddress=REQUIRED
# App key for accessing the gmail account to send emails
# gmailAppKey=REQUIRED

# Name of the storage class for the internal mail server (TechZone normally  uses ocs-storagecluster-cephfs, ROKS cp4a-file-delete-gold-gid)
ocpStorageClassForInternalMailServer=ocs-storagecluster-cephfs

# Should one or multiple users be added to the Cloud Pak as part of deploying the solution (The actual users need to be specified in a file called 'AddUsersToPlatform.json' in the directory of this file.)
createUsers=false


# Uncomment following two lines in case you want to use your Docker.io account instead of pulling images for the mail server anonymously (mostly relvant when anonymous pull limit has been reached)
#dockerUserName=REQUIRED
#dockerToken=REQUIRED

# Uncomment in case JVM throws an "Out Of Memory"-exception during the execution
#jvmSettings="-Xms4096M"

# Uncomment in case GitHub is not accessible and all resources are already available locally
#disableAccessToGitHub=true

# Proxy settings in case a proxy server needs to be used to access the GitHub resources
# Uncomment at least the proxScenario, proxyHost, and proxyPort lines and set values accordingly in case a proxy server needs to be used to access GitHub
# Uncomment the lines proxyUser and proxyPwd too, in case the proxy server requires authentication
#proxyScenario=GitHub
#proxyHost=
#proxyPort=
#proxyUser=
#proxyPwd=

# Specific trace string for the boostrapping process (only uncomment if instructed to do so)
#bootstrapDebugString=*=finest

# Specify a value if the log files should be written to a specific path, otherwise will be written to the location from which this file is executed
outputPath=

# Change to true in case detailed output messages and/or trace messages should be printed to the console
printDetailedMessageToConsole=false
printTraceMessageToConsole=false

# ----------------------------------------------------------------------------------------------------------
# Section handling values specified on the command line, requires GNU’s getopt command
# ----------------------------------------------------------------------------------------------------------

VALID_ARGS=$(getopt -o h --long dv:,dc:,ocls:,oclt:,ns:,pscenario:,phost:,pport:,puser:,ppwd:,cl:,cu:,ewflbu:,rpau:,rpas:,gmaila:,gmailk:,sc:,du:,dt:,jvm:,ds:,bd:,op:,pdmtoc:,ptmtoc:,dgithub: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -h)
        echo "HELP"
        echo "Optional command line parameters (overwriting parameters set in sh file):"
        echo "--ocls = ocpLoginServer"
        echo "--oclt = ocpLoginToken"
        echo "--ns = cp4baNamespace"
        echo "--pscenario = proxyScenario (needs to be GitHub if set)"
        echo "--phost = proxyHost"
        echo "--pport = proxyPort"
        echo "--puser = proxyUser"
        echo "--ppwd = proxyPwd"
        echo "--cl = configureLabs (true/false)"
        echo "--cu = createUsers (true/false)"
        echo "--ewflbu = enableWorkflowLabsForBusinessUsers (true/false)"
        echo "--rpau = rpaBotExecutionUser"
        echo "--rpas = rpaServer"
        echo "--gmaila = gmailAddress"
        echo "--gmailk = gmailAppKey"
        echo "--du = dockerUserName"
        echo "--dt = dockerToken"
        echo "--jvm = jvmSettings"
        echo "--bd = bootstrapDebugString"
        echo "--ds = debugString"
        echo "--dgithub = disableAccessToGitHub (true/false)"
        echo "--op = outputPath"
        echo "--pdmtoc = printDetailedMessageToConsole (true/false)"
        echo "--ptmtoc = printTraceMessageToConsole (true/false)"
        shift;
        exit 0;
        ;;
    --dv)
        dumpVariables=true
        shift
        ;;
    --dc)
        dumpCmd=true
        shift
        ;;
    --ocls)
        ocLoginServer=$2
        shift 2
        ;;
    --oclt)
        ocLoginToken=$2
        shift 2
        ;;
    --ns)
        cp4baNamespace=$2
        shift 2
        ;;
    --pscenario)
        proxyScenario=$2
        shift 2
        ;;
    --phost)
        proxyHost=$2
        shift 2
        ;;
    --pport)
        proxyPort=$2
        shift 2
        ;;
    --puser)
        proxyUser=$2
        shift 2
        ;;
    --ppwd)
        proxyPwd=$2
        shift 2
        ;;
    --cl)
        configureLabs=$2
        shift 2
        ;;
    --cu)
        createUsers=$2
        shift 2
        ;;
    --ewflbu)
        enableWorkflowLabsForBusinessUsers=$2
        shift 2
        ;;
    --rpau)
        rpaBotExecutionUser=$2
        shift 2
        ;;
    --rpas)
        rpaServer=$2
        shift 2
        ;;
    --gmaila)
        gmailAddress=$2
        shift 2
        ;;
    --gmailk)
        gmailAppKey=$2
        shift 2
        ;;
    --sc)
        ocpStorageClassForInternalMailServer=$2
        shift 2
        ;;
    --du)
        dockerUserName=$2
        shift 2
        ;;
    --dt)
        dockerToken=$2
        shift 2
        ;;
    --jvm)
        jvmSettings=$2
        shift 2
        ;;
    --bd)
        bootstrapDebugString=$2
        shift 2
        ;;
    --ds)
        debugString=$2
        shift 2
        ;;
    --op)
        outputPath=$2
        shift 2
        ;;
    --pdmtoc)
        printDetailedMessageToConsole=$2
        shift 2
        ;;
    --ptmtoc)
        printTraceMessageToConsole=$2
        shift 2
        ;;
    --dgithub)
        disableAccessToGitHub=$2
        shift 2
        ;;
    --) shift; 
        break 
        ;;
  esac
done

if [ ! -z "${dumpVariables+x}" ]
then
  echo "Config parameter values:"
  echo "ocLoginServer '${ocLoginServer}'"
  echo "ocLoginToken '${ocLoginToken}'"
  echo "cp4baNamespace '${cp4baNamespace}'"
  echo "proxyScenario '${proxyScenario}'"
  echo "proxyHost '${proxyHost}'"
  echo "proxyPort '${proxyPort}'"
  echo "proxyUser '${proxyUser}'"
  echo "proxyPwd '${proxyPwd}'"
  echo "configureLabs '${configureLabs}'"
  echo "createUsers '${createUsers}'"
  echo "enableWorkflowLabsForBusinessUsers '${enableWorkflowLabsForBusinessUsers}'"
  echo "rpaBotExecutionUser '${rpaBotExecutionUser}'"
  echo "rpaServer '${rpaServer}'"
  echo "gmailAddress '${gmailAddress}'"
  echo "gmailAppKey '${gmailAppKey}'"
  echo "ocpStorageClassForInternalMailServer '${ocpStorageClassForInternalMailServer}'"
  echo "dockerUserName '${dockerUserName}'"
  echo "dockerToken '${dockerToken}'"
  echo "jvmSettings '${jvmSettings}'"
  echo "bootstrapDebugString '${bootstrapDebugString}'"
  echo "debugString '${debugString}'"
  echo "disableAccessToGitHub '${disableAccessToGitHub}'"
  echo "outputPath '${outputPath}'"
  echo "printDetailedMessageToConsole '${printDetailedMessageToConsole}'"
  echo "printTraceMessageToConsole '${printTraceMessageToConsole}'"
fi

# ----------------------------------------------------------------------------------------------------------
# Construct the proxy settings for curl and deployment automation tool if proxy is configured
# ----------------------------------------------------------------------------------------------------------

if [ ! -z "${proxyHost+x}" ]
then
  if [ ! -z "${proxyUser+x}" ]
  then
     TOOLPROXYSETTINGS=-"psc=${proxyScenario} -ph=${proxyHost} -pp=${proxyPort} -pu=${proxyUser} -ppwd=${proxyPwd}"

     if [[ "${proxyScenario}" == "GitHub" ]] 
     then
       CURLPROXYSETTINGS="-x ${proxyHost}:${proxyPort} -U ${proxyUser}:${proxyPwd}"
     fi
  else
    TOOLPROXYSETTINGS="-psc=${proxyScenario} -ph=${proxyHost} -pp=${proxyPort}"
    if [[ "${proxyScenario}" == "GitHub" ]] 
    then
       CURLPROXYSETTINGS="-x ${proxyHost}:${proxyPort}"
    fi
  fi
fi

# ----------------------------------------------------------------------------------------------------------
# Global settings for the script (not to be modified by user)
# ----------------------------------------------------------------------------------------------------------

# Source URL where the deployment automation jar can be retrieved from
TOOLSOURCE="https://api.github.com/repos/IBM/cp4ba-client-onboarding-scenario/contents/Deployment_Automation/Current"
# CP4BA version
CP4BAVERSION="23.0.2"
# Deployment pattern of the CP4BA instance
DEPLOYMENTPATTERN="Starter"
# Source URL to bootstrap configuration for the deployment tool
BOOTSTRAPURL="-bootstrapURL=https://api.github.com/repos/IBM/cp4ba-client-onboarding-scenario/contents/${CP4BAVERSION}/Deployment_Automation/${DEPLOYMENTPATTERN}"
# Name of the configuration file to use when running the deployment automation tool
CONFIGNAME="config-deploy"
# Automation script to use when running the deployment automation tool
AUTOMATIONSCRIPT="DeployClientOnboardingEmbeddedGitea.json"

# Name of the source sh file passed to execution environment
SCRIPTNAME=deployClientOnboardingStarterParam.sh
# Name of the actual sh file passed to execution environment
FILENAME=$0
# Version of this script file passed to execution environment
SCRIPTVERSION=1.0.6
# Download URL for this script
SCRIPTDOWNLOADPATH=https://raw.githubusercontent.com/IBM/cp4ba-client-onboarding-scenario/main/${CP4BAVERSION%}/Deployment_Automation/${SCRIPTNAME%}

# ----------------------------------------------------------------------------------------------------------
# Retrieve the deployment automation jar file from GitHub if not already available or use local one when 
# GitHub access is disabled. Validate that the deployment tool jar is available
# ----------------------------------------------------------------------------------------------------------

if [ ! -z "${disableAccessToGitHub+x}" ] && "${disableAccessToGitHub}" == "true"
then
  DISABLEACCESSTOGITHUBINTERNAL="-datgh"
fi

toolValidationSuccess=true
echo "Bootstrapping deployment automation tool:"

# In case access to GitHub is disabled check if the deployment automation jar is available locally
if [ ! -z "${DISABLEACCESSTOGITHUBINTERNAL+x}" ]
then
  # 
  if ls *DeploymentAutomation.jar 1> /dev/null 2>&1; then
    # get the latest version of the file
    TOOLFILENAME=$(ls *DeploymentAutomation.jar | tail -n 1)
    
    echo "  Using local deployment automation jar file '${TOOLFILENAME}' as retrieval from GitHub is disabled"
  # if no file with the name found 
  else
    toolValidationSuccess=false
    echo "  No version of the deployment automation jar could be found while retrieval from GitHub is disabled"
  fi
else
  # Retrieve the download URL of the only deployment automation jar that is available in the GitHub repository
  GITHUBENTRIES=$(curl -s -X GET ${TOOLSOURCE})

  # Extract the download URL and the actual name of the deployment automation jar that is started later on
  DOWNLOADURL="download_url\": \""
  DOWNLOADLINE=${GITHUBENTRIES#*$DOWNLOADURL}
  DOWNLOADURL="${DOWNLOADLINE%%\"*}"
  TOOLFILENAME="${DOWNLOADURL##*/}"
  
  # In case the deployment automation jar does not yet exist locally download it otherwise print a msg that no download is required
  if [[ ! -f ${TOOLFILENAME} ]] 
  then
      echo "  Downloading deployment automation jar ${TOOLFILENAME} from GitHub"
      curl -O ${DOWNLOADURL} ${CURLPROXYSETTINGS}
  else
    echo "  Deployment automation jar file '${TOOLFILENAME}' already exists, no need to download it from Github"
  fi
  
  # In case the tool still does not exist something went wrong during download
  if [[ ! -f ${TOOLFILENAME} ]] 
  then
    toolValidationSuccess=false
    echo "  Failure to download ${TOOLFILENAME} from ${DOWNLOADURL}"  
  fi
fi

echo

# ----------------------------------------------------------------------------------------------------------
# Validation that all required parameters are set
# ----------------------------------------------------------------------------------------------------------

validationSuccess=true

if [ -z "${ocLoginServer+x}" ] || [[ "${ocLoginServer}" == "REQUIRED" ]] || [[ "${ocLoginServer}" == "" ]]
then
	if $validationSuccess
	then
		echo "Validating configuration failed:"
		validationSuccess=false
	fi
	echo "  Variable 'ocLoginServer' has not been defined/set (nor is variable 'pakInstallerPortalURL' defined/set)"
else
	INTERNALOCLOGINSERVER=-ocls=${ocLoginServer}
fi

if [ -z "${ocLoginToken+x}" ] || [[ "${ocLoginToken}" == "REQUIRED" ]] || [[ "${ocLoginToken}" == "" ]]
then
	if $validationSuccess
	then
		echo "Validating configuration failed:"
		validationSuccess=false
	fi
	echo "  Variable 'ocLoginToken' has not been defined/set (nor is variable 'pakInstallerPortalURL' defined/set)"
else
	INTERNALOCLOGINTOKEN=-oclt=${ocLoginToken}
fi

if [ ! -z "${gmailAddress+x}" ]
then
  if [[ "${gmailAddress}" == "REQUIRED" ]] || [[ "${gmailAddress}" == "" ]]
  then
    if $validationSuccess
    then
      echo "Validating configuration failed:"
      validationSuccess=false
    fi
    echo "  Variable 'gmailAddress' has not been set"
  else
    gmailAddressInternal=wf_cp_emailID=${gmailAddress}
  fi
fi

if [ ! -z "${gmailAppKey+x}" ]
then
  if [[ "${gmailAppKey}" == "REQUIRED" ]] || [[ "${gmailAppKey}" == "" ]]
  then
     if $validationSuccess
     then
       echo "Validating configuration failed:"
       validationSuccess=false
     fi
    echo "  Variable 'gmailAppKey' has not been set"
  else
    gmailAppKeyInternal=wf_cp_emailPassword=${gmailAppKey}
  fi
fi

if [[ "${rpaBotExecutionUser}" == "REQUIRED" ]] || [[ "${rpaBotExecutionUser}" == "" ]]
then
  if $validationSuccess
  then
    echo "Validating configuration failed:"
    validationSuccess=false
  fi
  echo "  Variable 'rpaBotExecutionUser' has not been set"
fi

if [[ "${rpaServer}" == "REQUIRED" ]] || [[ "${rpaServer}" == "" ]]
then
   if $validationSuccess
   then
    echo "Validating configuration failed:"
    validationSuccess=false
  fi
  echo "  Variable 'rpaServer' has not been set"
fi

if [ ! -z "${cp4baNamespace+x}" ]
then
  if [[ "${cp4baNamespace}" == "REQUIRED" ]] || [[ "${cp4baNamespace}" == "" ]]
  then
    if $validationSuccess
    then
      echo "Validating configuration failed:"
      validationSuccess=false
    fi
    echo "  Variable 'cp4baNamespace' has not been set"
  else
    INTERNALCP4BANAMESPACE=-cp4bans=${cp4baNamespace}
  fi
fi

if [[ ! -z "${createUsers+x}"  ]] && "${createUsers}" == "true"
then
   createUsersFile=onboardUsersFile=AddUsersToPlatform.json

   if ! ls "AddUsersToPlatform.json" 1> /dev/null 2>&1; 
   then
     if $validationSuccess
     then
	echo "Validating configuration failed:"
        validationSuccess=false
     fi
     echo "  Configured to add users to Cloud Pak environment but file 'AddUsersToPlatform.json' does not exist in current directory"
   fi
fi

# if dockerUserName is defined check if not equal default value required
if [[ ! -z "${dockerUserName+x}" ]]
then
  if [[ "${dockerUserName}" == "REQUIRED" ]]
  then
    if $validationSuccess
    then
      echo "Validating configuration failed:"
      validationSuccess=false
    fi
    echo "  Variable 'dockerUserName' is defined but is not set correctly"

    # check dockerToken variable is set and if so if set to non default value
    if [[ ! -z "${dockerToken+x}" ]]
    then
      if [[ "${dockerToken}" == "REQUIRED" ]]
      then
	echo "  Variable 'dockerToken' is defined but is not set correctly"
      fi
    else
      echo "  Variable 'dockerToken' is not defined but must be defined as variable 'dockerUserName' is defined"
    fi
  else
    if [[ ! -z "${dockerToken+x}" ]]
    then
      if [[ "${dockerToken}" == "REQUIRED" ]]
      then
        if $validationSuccess
        then
          echo "Validating configuration failed:"
          validationSuccess=false
        fi
	echo "  Variable 'dockerToken' is defined but is not set correctly"
      else
        INTERNALDOCKERINFO="dockerUserName=${dockerUserName} dockerToken=${dockerToken}"
      fi
    else
      if $validationSuccess
      then
        echo "Validating configuration failed:"
        validationSuccess=false
      fi
      echo "  Variable 'dockerToken' is not defined but must be defined as variable 'dockerUserName' is defined"
    fi
  fi
# dockerUserName is not defined, check dockerToken variable
else
  if [[ ! -z "${dockerToken+x}" ]]
  then
    if [[ "${dockerToken}" == "REQUIRED" ]]
    then
      if $validationSuccess
      then
	echo "Validating configuration failed:"
	validationSuccess=false
      fi
      echo "  Variable 'dockerUserName' is not defined but must be defined as variable 'dockerToken' is defined"
      echo "  Variable 'dockerToken' is defined but is not set correctly"
    else
      if $validationSuccess
      then
        echo "Validating configuration failed:"
        validationSuccess=false
      fi
      echo "  Variable 'dockerUserName' is not defined but must be defined as variable 'dockerToken' is defined"
    fi
  fi
fi

if ! $validationSuccess
then
  echo
fi

if ! $validationSuccess || ! $toolValidationSuccess
then
  echo "Exiting..."
  exit 1
fi


if [[ ! -z "${printDetailedMessageToConsole+x}" ]]
then
  if [[ "${printDetailedMessageToConsole}" == "true" ]]
  then
    INTERNALPDMTOC=-pdmtc
  fi
fi

if [[ ! -z "${printTraceMessageToConsole+x}" ]]
then
  if [[ "${printTraceMessageToConsole}" == "true" ]]
  then
    INTERALPTCTOC=-ptmtc
  fi
fi

if [[ ! -z "${outputPath+x}" ]]
then
	INTERNALOUTPUTPATH=\"-op=${outputPath}\"
fi

OCPSTORAGECLASSFOREMAILINTERNAL=ocpStorageClassForMail=${ocpStorageClassForInternalMailServer}

if [ ! -z "${enableWorkflowLabsForBusinessUsers+x}" ]
then
	workflowLabsForBusinessUsers=enableWFLabForBusinessUsers=${enableWorkflowLabsForBusinessUsers}
fi

if [ ! -z "${configureLabs+x}" ]
then
	enableConfigureLabsInternal=enableConfigureSWATLabs=${configureLabs}
fi

if [ ! -z "${bootstrapDebugString+x}" ]
then
	BOOTSTRAPDEBUGSTRINGINTERNAL=\"-bds=${bootstrapDebugString}\"
fi

if [ ! -z "${debugString+x}" ]
then
	DEBUGSTRINGINTERNAL=\"debugString=${debugString}\"
fi

if [ ! -z "${dumpCmd+x}" ]
then
  echo java ${jvmSettings} -jar ${TOOLFILENAME} ${BOOTSTRAPDEBUGSTRINGINTERNAL} ${BOOTSTRAPURL} \"-sdp=${SCRIPTDOWNLOADPATH}\" \"-sn=${FILENAME}\" \"-ss=${SCRIPTNAME}\" \"-sv=${SCRIPTVERSION}\" ${INTERNALOCLOGINSERVER} ${INTERNALCP4BANAMESPACE} ${INTERNALPAKINSTALLERPORTALURL} ${TOOLPROXYSETTINGS} ${DEBUGSTRINGINTERNAL} -ibp=${DEPLOYMENTPATTERN} -c=${CONFIGNAME} -as=${AUTOMATIONSCRIPT} ${DISABLEACCESSTOGITHUBINTERNAL} ${INTERNALOUTPUTPATH} ${INTERNALPDMTOC} ${INTERALPTCTOC} ${OCPSTORAGECLASSFOREMAILINTERNAL} ${gmailAddressInternal} ${gmailAppKeyInternal} ${enableConfigureLabsInternal} ${workflowLabsForBusinessUsers} ${createUsersFile} ${INTERNALDOCKERINFO} ACTION_wf_cp_rpaBotExecutionUser=${rpaBotExecutionUser} ACTION_wf_cp_rpaServer=${rpaServer}
fi

java ${jvmSettings} -jar ${TOOLFILENAME} ${BOOTSTRAPDEBUGSTRINGINTERNAL} ${BOOTSTRAPURL} \"-sdp=${SCRIPTDOWNLOADPATH}\" \"-sn=${FILENAME}\" \"-ss=${SCRIPTNAME}\" \"-sv=${SCRIPTVERSION}\" ${INTERNALOCLOGINSERVER} ${INTERNALOCLOGINTOKEN} ${INTERNALCP4BANAMESPACE} ${TOOLPROXYSETTINGS} ${DEBUGSTRINGINTERNAL} -ibp=${DEPLOYMENTPATTERN} -c=${CONFIGNAME} -as=${AUTOMATIONSCRIPT} ${DISABLEACCESSTOGITHUBINTERNAL} ${INTERNALOUTPUTPATH} ${INTERNALPDMTOC} ${INTERALPTCTOC} ${OCPSTORAGECLASSFOREMAILINTERNAL} ${gmailAddressInternal} ${gmailAppKeyInternal} ${enableConfigureLabsInternal} ${workflowLabsForBusinessUsers} ${createUsersFile} ${INTERNALDOCKERINFO} ACTION_wf_cp_rpaBotExecutionUser=${rpaBotExecutionUser} ACTION_wf_cp_rpaServer=${rpaServer}