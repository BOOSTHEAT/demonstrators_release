#!/bin/bash
set -eEuo pipefail
set -x
trap '[ $? -eq 0 ] && exit 0 || onError $?' EXIT

onError () {
  echo "operation FAILED. Error $1."
  exit "$1"
}

usage() {
  cat <<EOF
Usage: $0 <operation> [<operation args>...]
Operations:
  backend <architecture>
  gengui
  compilegui <architecture> <docker qt5 image>
EOF
  exit 42
}

if [ $# -lt 1 ]
then
  usage
fi


backend()
{
  architecture=$1
  $LINKER_PATH build \
    -s https://pkgs.dev.azure.com/boostheat/_packaging/ImpliciX/nuget/v3/index.json \
    -s ${APPLICATION_FEED} \
    -n ImpliciX.Runtime \
    -n ${APPLICATION_NAME} \
    -e ${APPLICATION_MAIN} \
    -v ${BUILD_BUILDNUMBER} \
    -o "${BUILD_ARTIFACTSTAGINGDIRECTORY}/app.zip" \
    -t $architecture
}

gengui()
{
  $LINKER_PATH qml \
    -s https://pkgs.dev.azure.com/boostheat/_packaging/ImpliciX/nuget/v3/index.json \
    -s ${APPLICATION_FEED} \
    -n ${APPLICATION_NAME} \
    -e ${APPLICATION_MAIN} \
    -v ${BUILD_BUILDNUMBER} \
    -o "${PIPELINE_WORKSPACE}/QML/${BUILD_BUILDNUMBER}"
}

compilegui()
{
  architecture=$1
  image=$2
  buildfolder=build_$architecture
  QML_FOLDER="${PIPELINE_WORKSPACE}/QML/${BUILD_BUILDNUMBER}"
  docker pull implicixpublic.azurecr.io/$image:latest
  docker run -v ${QML_FOLDER}:/app --entrypoint "/bin/sh" implicixpublic.azurecr.io/$image:latest -c "cd /app && qmake -o $buildfolder/Makefile && make -C $buildfolder"
  cd ${QML_FOLDER}
  GUI_EXE_NAME=$(cat "./main.pro" | grep "TARGET = " | cut -d' ' -f3)
  mkdir -p ${BUILD_ARTIFACTSTAGINGDIRECTORY}/gui_output
  cp ${QML_FOLDER}/$buildfolder/$GUI_EXE_NAME ${BUILD_ARTIFACTSTAGINGDIRECTORY}/gui_output
  cp -r ${QML_FOLDER} ${BUILD_ARTIFACTSTAGINGDIRECTORY}/gui_src
}

operation=$1
shift
${operation} $*

