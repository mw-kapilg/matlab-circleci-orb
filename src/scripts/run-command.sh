downloadAndRun() {
    url=$1
    shift
    if [[ -x $(command -v sudo) ]]; then
    curl -sfL $url | sudo -E bash -s -- "$@"
    else
    curl -sfL $url | bash -s -- "$@"
    fi
}

tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'run-command')

# install run-matlab-command
downloadAndRun https://ssd.mathworks.com/supportfiles/ci/run-matlab-command/v1/install.sh "${tmpdir}/bin"

# form OS appropriate paths for MATLAB
os=$(uname)
workdir=$(pwd)
scriptdir=$tmpdir
binext=""
if [[ $os = CYGWIN* || $os = MINGW* || $os = MSYS* ]]; then
    workdir=$(cygpath -w "$workdir")
    scriptdir=$(cygpath -w "$scriptdir")
    binext=".exe"
fi

# create script to execute
script=command_${RANDOM}
scriptpath=${tmpdir}/${script}.m
echo "cd('${workdir//\'/\'\'}');" > "$scriptpath"
cat << EOF >> "$scriptpath"
${PARAM_COMMAND}
EOF

# run MATLAB command
"${tmpdir}/bin/run-matlab-command$binext" "cd('${scriptdir//\'/\'\'}');$script"
