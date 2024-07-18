
SCRIPT_FOLDER=$(readlink -f $(dirname $0))

init()
{
  PREFIX="TestRelease"
  WORKSPACE=$(pwd)
  if [ $(basename ${WORKSPACE%%.*}) != $PREFIX ]
  then
    echo "Not a workspace..."
    exit 1
  fi
  rm -rf "$WORKSPACE/output"
}

setup()
{
  RUNFOLDER="$WORKSPACE/run"
  sudo rm -rf $RUNFOLDER
  artefacts=$(echo $WORKSPACE/*)
  mkdir -p $RUNFOLDER
  for artefact in $artefacts
  do
    cp -r $artefact $RUNFOLDER
  done
  export PIPELINE_WORKSPACE="$RUNFOLDER"
  echo "PIPELINE_WORKSPACE: $PIPELINE_WORKSPACE"
  export LINKER_PATH="$PIPELINE_WORKSPACE/linker/device_linker/ImpliciX.Linker/src/ImpliciX.Linker"
  export BUILD_BUILDNUMBER="9.9.9.9"
}

defapp()
{
  source $1
  banner "${APPLICATION_ID}"
  setup
  export BUILD_ARTIFACTSTAGINGDIRECTORY="$WORKSPACE/output/${APPLICATION_ID}"
}

allapps()
{
  SUT=$(readlink -f ${SCRIPT_FOLDER}/../Shared/scripts/link.sh)
  for app in ${SCRIPT_FOLDER}/apps/*
  do
    defapp $app
    $SUT backend linux-x64
    $SUT gengui
    $SUT compilegui linux-x64 implicix-qt5
  done
}

demos()
{
  SUT=$(readlink -f ${SCRIPT_FOLDER}/../Demos/Gimlet/pack.sh)
  setup
  export BUILD_ARTIFACTSTAGINGDIRECTORY="$WORKSPACE/DemoGimlet"
  rm -rf $BUILD_ARTIFACTSTAGINGDIRECTORY
  mkdir -p $BUILD_ARTIFACTSTAGINGDIRECTORY
  $SUT
}

init
demos

