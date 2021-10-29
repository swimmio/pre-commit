---
id: srUmS
name: Maintaining The Pre-Commit Hooks
file_version: 1.0.2
app_version: 0.6.3-1
file_blobs:
  hooks/swimm-verify.sh: c6446061a0e9c2307a771e456e743536ee45eee4
  hooks/swimm-verify-nonblocking.sh: 66c4fed3ededa1eb1fb20f2b92f067b11775f5c2
---

What are the pre-commit hooks?
------------------------------

The [pre-commit hook repository](https://github.com/swimmio/pre-commit) is how users can take advantage of [pre-commit](https://pre-commit.com/) using Swimm. There are two main use cases for needing the pre-commit hooks:

1\. Developers that want to get Swimm verification out of the way with other lint checks that run before they open a PR. This helps them optimize the review process for discussion about the merits of the actual change, and not things like formatting, extraneous spaces, or broken Swimm docs.

2\. Developers that don't currently use any kind of continuous integration server. This could be developers working on something solo, or instances where teams just don't want to use CI. If everyone that has commit access or sends pull requests uses our commit hook, they can still benefit from continuous documentation.

The hooks themselves are written with [Bash](https://www.gnu.org/software/bash/) ([Zsh](https://www.zsh.org/) will work as well) and run fine on Linux, MacOS and Windows (with [WSL](https://docs.microsoft.com/en-us/windows/wsl/install)).

What hooks are available? How do they work?
-------------------------------------------

We make two hooks available for use:

*   `swimm-verify` : ( `📄 hooks/swimm-verify.sh` ) Checks that all docs are up-to-date, stops the commit if something is out-of-sync. This is the hook that we recommend everyone uses.
    
*   `swimm-verify-nonblocking`: ( `📄 hooks/swimm-verify-nonblocking.sh` ) Like `swimm-verify`, but doesn't block the commit.
    

Both hooks automatically detect if the desktop app is installed, and will use the `swimm` command if present. Otherwise, both hooks will resolve the correct OS (Linux and WSL resolve the same) automatically download the appropriate packed CLI binary from our release server, which is cleaned up once we finish running.

Both hooks can also notify a web hook on failure, with the output of the CLI binary - this is handy for workflows where verification is allowed to fail, but an issue is created with an understood SLA to fix it.

<br/>

Variables like `BIN_WGET`[<sup id="Z1ta2qw">↓</sup>](#f-Z1ta2qw) or `BIN_CURL`[<sup id="oDwtC">↓</sup>](#f-oDwtC) and `BIN_PATH`[<sup id="9IYxs">↓</sup>](#f-9IYxs) are automatically filled when the scripts start. If a needed component like curl or wget is missing, the script will print the problem to stderr and exit.
<!-- NOTE-swimm-snippet: the lines below link your snippet to Swimm -->
### 📄 hooks/swimm-verify.sh
```shell
⬜ 48     }
⬜ 49     
⬜ 50     # H/T to Paxdiablo for the idea of nesting this in a clever little switch
🟩 51     resolve_os() {
🟩 52         local tmp="$(uname -s)" || error_out "Unable to determine machine type. Please contact support."
🟩 53         echo "OS is ${tmp}"
🟩 54         case "${tmp}" in
🟩 55             Linux*)     BIN_DOWNLOAD_SPEC="packed-swimm-linux-cli";;
🟩 56             Darwin*)    BIN_DOWNLOAD_SPEC="packed-swimm-osx-cli";;
🟩 57             *)          error_out "Your machine type ${tmp} isn't supported by this utility."
🟩 58         esac
🟩 59     }
🟩 60     
🟩 61     download_cli() {
🟩 62         $BIN_WGET -O $BIN_PATH/swimm_cli https://releases.swimm.io/ci/latest/${BIN_DOWNLOAD_SPEC}
🟩 63         chmod +x $BIN_PATH/swimm_cli
🟩 64     }
🟩 65     
🟩 66     cleanup() {
🟩 67         echo "Cleaning up..."
🟩 68         rm -f $BIN_PATH/swimm_cli
🟩 69     }
⬜ 70     
⬜ 71     webhook() {
⬜ 72         [ -z "$SWIMM_VERIFY_WEBHOOK" ] && {
```

<br/>

Pre-commit scripts can't really be customized since they're downloaded and run from our pre-commit repository, so we use environmental variables for user-specific configuration.

For instance, `SWIMM_VERIFY_WEBHOOK`[<sup id="2sd7zs">↓</sup>](#f-2sd7zs) needs to contain a valid URL that can accept a `POST` request. If it's present, the hooks will send a request to it with a `context`[<sup id="Z23EFW9">↓</sup>](#f-Z23EFW9) field set that contains the output of `swimm_cli verify`.
<!-- NOTE-swimm-snippet: the lines below link your snippet to Swimm -->
### 📄 hooks/swimm-verify-nonblocking.sh
```shell
⬜ 67         rm -f $BIN_PATH/swimm_cli
⬜ 68     }
⬜ 69     
🟩 70     webhook() {
🟩 71         [ -z "$SWIMM_VERIFY_WEBHOOK" ] && {
🟩 72             warn "Could not read enviormental variable SWIMM_VERIFY_WEBHOOK so I don't know who to call."
🟩 73             warn "swimm_cli returned:"
🟩 74             warn "$@"
🟩 75             return
🟩 76         }
🟩 77         $BIN_CURL --data "context=$@" $SWIMM_VERIFY_WEBHOOK | grep success 2>&1 >/dev/null
🟩 78         if [ $? -eq 0 ]; then
🟩 79             printf "Webhook succeeded!"
🟩 80         else
🟩 81             warn "Webhook failed, sad trombone :("
🟩 82         fi
🟩 83     }
🟩 84     
⬜ 85     # Main program 
⬜ 86     
⬜ 87     # We need curl for the webhook, even if the desktop CLI is available.
```

<br/>

How do users know to install them?
----------------------------------

We [advertise them as available in the docs site](http://localhost:3000/docs/continuous-integration/commit-hooks#pre-commit), and folks from the sales and business teams know they're a possibility for clients that just (for whatever reason) can't or won't use a continuous integration server.

The main `📄 README.md` has instructions on how to get up and running with them quickly, and there's more detail in the `📄 hooks/README.md` file for those that need more detail.

How do we make a new release?
-----------------------------

First, test everything! The `📄 scripts/testmode.sh` script can be used to toggle the repo in and out of a state that causes verification to immediately fail. So you'd do something like this:

```
scripts/testmode.sh
hooks/swimm-verify.sh
(Fails)

scripts/testmode.sh
hooks/swimm-verify.sh
(Succeeds) 
```

Then, you need to make sure the hooks can download the appropriate binaries if the desktop app isn't installed. For most of us, that's going to mean temporarily disabling the desktop commands so that the hooks will pull in the packed CLI binary appropriate for the OS, which is the workflow anyone using the web version exclusively is going to experience:

```
sudo mv /usr/local/bin/swimm /usr/local/bin/swimm-disabled
```

Then, run through the tests above using the `📄 scripts/testmode.sh` script. At some point we'll automate all of that.

After that, make sure you update `📄 README.md` **to point to the version tag you're about to create**. If you're releasing `v1.23`, update the readme to point to that, even though it won't exist until you create it. Make sure to check `📄 hooks/README.md` and ensure it talks about all of the functionality accurately.

Finally, make sure you've pushed _everything_ to the repository, then head to [the release creation page on Github](https://github.com/swimmio/pre-commit/releases/new). Give it a name, indicate what changed, select the new tag that will be created when the release is packed, and release!

The new version should be mentioned in the release notes of the next release, and it's good to mention it in the community slack channel (or to anyone that you know is using them heavily).

<br/>

<!-- THIS IS AN AUTOGENERATED SECTION. DO NOT EDIT THIS SECTION DIRECTLY -->
### Swimm Note

<span id="f-oDwtC">BIN_CURL</span>[^](#oDwtC) - "hooks/swimm-verify-nonblocking.sh" L77
```shell
    $BIN_CURL --data "context=$@" $SWIMM_VERIFY_WEBHOOK | grep success 2>&1 >/dev/null
```

<span id="f-9IYxs">BIN_PATH</span>[^](#9IYxs) - "hooks/swimm-verify.sh" L62
```shell
    $BIN_WGET -O $BIN_PATH/swimm_cli https://releases.swimm.io/ci/latest/${BIN_DOWNLOAD_SPEC}
```

<span id="f-Z1ta2qw">BIN_WGET</span>[^](#Z1ta2qw) - "hooks/swimm-verify.sh" L62
```shell
    $BIN_WGET -O $BIN_PATH/swimm_cli https://releases.swimm.io/ci/latest/${BIN_DOWNLOAD_SPEC}
```

<span id="f-Z23EFW9">context</span>[^](#Z23EFW9) - "hooks/swimm-verify-nonblocking.sh" L77
```shell
    $BIN_CURL --data "context=$@" $SWIMM_VERIFY_WEBHOOK | grep success 2>&1 >/dev/null
```

<span id="f-2sd7zs">SWIMM_VERIFY_WEBHOOK</span>[^](#2sd7zs) - "hooks/swimm-verify-nonblocking.sh" L71
```shell
    [ -z "$SWIMM_VERIFY_WEBHOOK" ] && {
```

<br/>

This file was generated by Swimm. [Click here to view it in the app](https://app.swimm.io/#/repos/Z2l0aHViJTNBJTNBcHJlLWNvbW1pdCUzQSUzQXN3aW1taW8=/docs/srUmS).