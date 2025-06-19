#!/usr/bin/env bash

set +x

if [[ ! -z "${USE_FLUTTER_PUB_RUN}" ]]; then
  runner=(flutter pub run dbus:dart_dbus)
elif [[ ! -z "${DRY_RUN}" ]]; then
  runner=(echo)
else
  runner=(dart-dbus)
fi

srcdir=$(dirname $(dirname $0))

interfaces=()

remoteInterfaces=(
  org.freedesktop.Accounts.xml
)

sources=(
  $(pkg-config accountsservice --variable=datadir)/dbus-1/interfaces
)

function collectPaths {
  for iface in $1; do
    hasIface=0
    for src in ${sources[@]}; do
      if [ -e "${src}/${iface}" ]; then
        echo "${src}/${iface}"
        hasIface=1
        break
      fi
    done

    if [[ -z $hasIface ]]; then
      echo "Missing interface $iface" >&2
      exit 1
    fi
  done
}

function generate {
  local type="$1"
  local path="$2"
  local fname=$(basename "$path")
  local outpath="$srcdir/lib/dbus/${type}s/"$(echo "${fname%.*}" | tr . _ | tr '[:upper:]' '[:lower:]').dart

  mkdir -p $(dirname "$outpath")
  eval "${runner[@]}" "generate-$type" "$path" -o "$outpath"
}

interfacePaths=$(collectPaths "${interfaces[@]}")
remoteInterfacePaths=$(collectPaths "${remoteInterfaces[@]}")

for iface in ${interfacePaths[@]}; do
  generate object "$iface"
done

for iface in ${remoteInterfacePaths[@]}; do
  generate remote-object "$iface"
done
