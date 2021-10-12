#!/bin/bash

# A check to make sure all documentation is up-to-date as a pre-commit hook.
# Written by Tim Post <tim@swimm.io> April 2021
# Permission to use and distribute granted under the MIT license


# Some global variables with initialized states we can test for sanity.
BIN_CURL=""
BIN_WGET=""
BIN_APP=""

# /tmp is hopefully mounted noexec, so we stay in /home. We need to save
# something here and then make it executable.
BIN_PATH="$HOME"

# We customize the download URL based on the OS (Linux/Mac supported)
BIN_DOWNLOAD_SPEC=""

# Swimm is (by default) in /usr/local/bin, so we want to make sure to look there.
export PATH=$PATH:/usr/local/bin

error_out() {
    printf "%s\n" "$*" >&2
    exit 1
}

warn() {
    printf "%s\n" "$*" >&2
}

verify_curl() {
    BIN_CURL=$(which curl) || {
        error_out "You need to install 'curl' to use this hook."
    }
}

verify_wget() {
    BIN_WGET=$(which wget) || {
        error_out "You need to install 'wget' to use this hook."
    }
}

verify_tmp() {
    touch $BIN_PATH || {
        error_out "Could not write to $BIN_PATH"
    }
}

# H/T to Paxdiablo for the idea of nesting this in a clever little switch
resolve_os() {
    local tmp="$(uname -s)" || error_out "Unable to determine machine type. Please contact support."
    echo "OS is ${tmp}"
    case "${tmp}" in
        Linux*)     BIN_DOWNLOAD_SPEC="browser_download_url.*packed-swimm-linux-cli";;
        Darwin*)    BIN_DOWNLOAD_SPEC="browser_download_url.*packed-swimm-osx-cli";;
        *)          error_out "Your machine type ${tmp} isn't supported by this utility."
    esac
}

download_cli() {
    # This currently downloads a compiled script that still requires node, but will soon resolve to a 64 Bit ELF executable.
    src=$(curl -s https://api.github.com/repos/swimmio/SwimmReleases/releases/latest | grep "${BIN_DOWNLOAD_SPEC}" | cut -d '"' -f 4)
    $BIN_WGET -O $BIN_PATH/swimm_cli $src
    chmod +x $BIN_PATH/swimm_cli
}

cleanup() {
    echo "Cleaning up..."
    rm -f $BIN_PATH/swimm_cli
}

webhook() {
    [ -z "$SWIMM_VERIFY_WEBHOOK" ] && {
        warn "Could not read enviormental variable SWIMM_VERIFY_WEBHOOK so I don't know who to call."
        return
    }
    printf "Hi! I'm Webhook!\nContext is:\n%s\nDialing: %s\n" "$@" "$SWIMM_VERIFY_WEBHOOK"
    $BIN_CURL --data "context=$@" $SWIMM_VERIFY_WEBHOOK | grep success 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
        printf "Webhook succeeded!"
    else
        warn "Webhook failed, sad trombone :("
    fi
}

# Main program 

# We need curl for the webhook, even if the desktop CLI is available.
verify_curl

# If the desktop CLI is in the path, use it. Otherwise, grab the CLI executable.
BIN_APP=$(which swimm) || {
    # Should we run?
    resolve_os
    # Can we run?
    verify_wget
    verify_tmp
    # Let's run
    download_cli
    [ -x $BIN_PATH/swimm_cli ] || {
        cleanup
        error_out "Could not successfully stage swimm_cli"
    }
    BIN_APP=$BIN_PATH/swimm_cli
}

# Run the verification. If it fails, pass the output to the webhook function
# that can phone home to Zapier, which can then open an issue (GH, Bitbucket)
# or pipe to a slack channel, or whatever else Zapier can do.
CONTEXT=$($BIN_APP verify 2>&1) || {
	ret=$?
    echo "Swimm Verification Failed. Calling Webhook."
    webhook "$CONTEXT"
    # Since we don't block the commit, we pretend everything is fine.
    # That's cool, because we kicked off an issue.
    exit $ret
}

echo "Swimm Verification Succeeded."
exit 0