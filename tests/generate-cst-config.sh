#!/usr/bin/env bash
# Generates the container-structure-test config sections that vary by
# Dockerfile (CoC extension list) or by host (the /system symlink target).
# The plugin list is shared by every Dockerfile variant since they all read
# nvim/init.vim. Printed to stdout as YAML; merged with tests/cst/base.yaml
# via `container-structure-test --config ... --config ...`.
#
# Usage: tests/generate-cst-config.sh <Dockerfile> <local_uname>

set -euo pipefail
cd "$(dirname "$0")/.."

DOCKERFILE="$1"
LOCAL_UNAME="$2"

echo 'schemaVersion: "2.0.0"'
echo
echo "commandTests:"
cat <<EOF
  - name: "host symlink present (/home/$LOCAL_UNAME -> /system bind mount)"
    command: "bash"
    args: ["-c", "test -L \"/home/$LOCAL_UNAME\""]
    exitCode: 0
  - name: "rustup variables point at the host's toolchains (its shims need them)"
    command: "bash"
    args: ["-c", "test \"\$RUSTUP_HOME\" = \"/home/$LOCAL_UNAME/.rustup\" -a \"\$CARGO_HOME\" = \"/home/$LOCAL_UNAME/.cargo\""]
    exitCode: 0
EOF

echo
echo "fileExistenceTests:"

# vim-plug plugin dirs, parsed from nvim/init.vim (dir name = repo basename;
# none of our Plug lines use {'as': ...} to rename it).
for plugin in $(grep -oP "^Plug '\K[^']+" nvim/init.vim | sed 's#.*/##'); do
    cat <<EOF
  - name: "plugin installed: $plugin"
    path: "/home/docker/.nvim/plugged/$plugin"
    shouldExist: true
EOF
done

# CoC extensions, parsed from this Dockerfile's CocInstall line.
for ext in $(grep -oP "CocInstall -sync \K[^']+" "$DOCKERFILE"); do
    cat <<EOF
  - name: "coc extension installed: $ext"
    path: "/home/docker/.config/coc/extensions/node_modules/$ext"
    shouldExist: true
EOF
done
