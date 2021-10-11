# pre-commit hooks for Swimm

Utilizing [pre-commit](https://pre-commit.com/), you can enable Swimm checks to run prior to the review cycle. In order to get started, you'll need to [install pre-commit](https://pre-commit.com/#install) (pip, brew and other methods are available). 

After that, there are two ways you can make use of the hooks hosted here:

## For Those That Don't Need To Modify The Hooks:

If you don't need to modify any of the hooks, you can simply pull in the hook configurations from this repository.

Put the following contents into `.pre-commit-config.yaml` in the root of your repository (create it if needed):

```
repos:
  - repo: https://github.com/swimmio/pre-commit
    rev: v0.3 # (Check release tags for the latest release, current preview release is v0.4)
    hooks:
      - id: swimm-verify # Verifies documentation is in sync
```
That should be all you need if you just want to run the verification checks locally, and treat failure like any other test failing.

There are two more hooks explained in [hooks/](https://github.com/swimmio/pre-commit/tree/main/hooks) which you can optionally enable:

```
      - id: swimm-verify-nonblocking # Verifies documentation but doesn't block, opens an issue instead.
      - id: swimm-export # (Illustrative only) Shows how you could set up your existing hooks to export your documentation to Docusaurus, Notion, Etc.
```

If you already have a `.pre-commit-config.yaml` file, add the swimm checks as a new `- repo` section, wherever you'd like them to run. Note that if you have failure mode set to fast, no other checks will run if documentation can't be verified, so we recommend adding Swimm as the last (or close to last) check. 

Note: The hooks are currently implemented as bash scripts; Windows users need to run WSL in order to use them for now. I'm planning to do it agnostically just with Python in the near future.

## For Those Who Want To Modify The Hooks

Fork this repository to your orgainzation, make the changes you want, and tag in a release for your team to use. Then, your team will need to 
point their configuration files to the forked repo (and specify your version) rather than pointing them here.


If you create any new hooks that you think others might find useful, feel free to send over a PR. 
