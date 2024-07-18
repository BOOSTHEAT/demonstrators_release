
SCRIPT_FOLDER=$(readlink -f $(dirname $0))
NAME=GimletDemo_$BUILD_BUILDNUMBER
OUTPUT=$PIPELINE_WORKSPACE/$NAME
mkdir -p $OUTPUT

addzip()
{
  unzip "$PIPELINE_WORKSPACE/$1" -d $OUTPUT/$2
}

addmisc()
{
  SRC=$(echo $PIPELINE_WORKSPACE/$1)
  cp -rv "$SRC" $OUTPUT/$2
}

addexe()
{
  addmisc $1 $2
  chmod +x $OUTPUT/$2/$3
}

addzip Gimlet/App_linux_x64/app.zip backend
addzip Gimlet.PlcSim/App_linux_x64/app.zip backend_sim

mkdir -p $OUTPUT/nupkgs
addmisc "Gimlet/App_linux_x64/*.nupkg" nupkgs/Gimlet.nupkg
addmisc "Gimlet.PlcSim/App_linux_x64/*.nupkg" nupkgs/Gimlet.PlcSim.nupkg

addexe Gimlet/GUI_linux_x64 gui ImpliciX.GUI
addexe Gimlet.PlcSim/GUI_linux_x64 gui_sim ImpliciX.GUI
addexe "Monitor/ImpliciX_Monitor_linux_*" monitor ImpliciX.Monitor

cp -rv $SCRIPT_FOLDER/grafana $OUTPUT/grafana
cp -rv $SCRIPT_FOLDER/filebrowser $OUTPUT/filebrowser
cp -v $SCRIPT_FOLDER/docker-compose.yml $SCRIPT_FOLDER/.env $OUTPUT

tar cf $BUILD_ARTIFACTSTAGINGDIRECTORY/$NAME.tar -C $PIPELINE_WORKSPACE $NAME


