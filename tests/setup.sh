

implicix()
{
  az $* --org https://dev.azure.com/boostheat --project "ImpliciX"
}

demo()
{
  az $* --org https://dev.azure.com/boostheat --project "ImpliciX Demonstrators"
}

download()
{
  project=$1
  pipeline=$2
  builds=$($project pipelines build definition list | jq ".[] | select( .name | . == \"$pipeline\") | .id")
  for buildid in $builds
  do
    runid=$($project pipelines build list --definition-ids $buildid --top 1 | jq '.[0]|.id')
    runpath=$($project pipelines runs show --id $runid | jq -r '.definition|.path')
    app=${runpath##*\\}
    folder=${app:-$2}
    echo "Processing pipeline $folder $pipeline id $buildid"
    artifacts=$($project pipelines runs artifact list --run-id $runid | jq -r '.[]|.name')
    for artifact in $artifacts
    do
      outpath=$WORKSPACE/$folder/$artifact
      echo "Downloading $artifact from build $runid into $outpath"
      mkdir -p "$outpath"
      $project pipelines runs artifact download --artifact-name "$artifact" --run-id $runid --path $outpath
    done
  done
}

setup()
{
  PREFIX="TestRelease"
  WORKSPACE=$(pwd)
  if [ $(basename ${WORKSPACE%%.*}) = $PREFIX ]
  then
    return
  fi
  echo "Creating Workspace..."
  WORKSPACE=$(mktemp --tmpdir -d $PREFIX.XXXXXXXX)
  cd $WORKSPACE
  download implicix linker
  LINKER_PATH="$WORKSPACE/linker/device_linker/ImpliciX.Linker/src/ImpliciX.Linker"
  chmod +x "$LINKER_PATH"
  download implicix Monitor
  download demo app
  download demo release
}

setup

