# pre-commit hooks for Swimm

Utilizing [pre-commit](https://pre-commit.com/), you can enable Swimm checks to run locally with other lints, prior to the PR review cycle. In order to get started, you'll need to [install pre-commit](https://pre-commit.com/#install) (pip, brew and other methods are available).

Then, select which hook you want to run. **Most** users won't need to modify the.

## For Those That Don't Need To Modify The Hooks:

If you don't need to modify any of the hooks, you can simply pull in the hook configurations from this repository.

Put the following contents into `.pre-commit-config.yaml` in the root of your repository (create it if needed):

```yml
repos:
  - repo: https://github.com/swimmio/pre-commit
    rev: v0.5 # (Check release tags for the latest release, current is v0.5)
    hooks:
      - id: swimm-verify # Verifies documentation is in sync
```
That should be all you need if you just want to run the verification checks locally, and treat failure like any other test failing. If you need to open an issue instead of failing, use `swimm-verify-nonblocking` as described in [hooks/](https://github.com/swimmio/pre-commit/tree/main/hooks).

If you already have a `.pre-commit-config.yaml` file, add the swimm checks as a new `- repo` section, wherever you'd like them to run. Note that if you have failure mode set to fast, no other checks will run if documentation can't be verified, so we recommend adding Swimm as the last (or close to last) check. 

Note: The hooks are currently implemented as bash scripts; Windows users need to run WSL in order to use them for now.

## For Those Who Want To Modify The Hooks

Grab the script in [hooks/](https://github.com/swimmio/pre-commit/tree/main/hooks) that you want to use as a base, and just include it in your own pre-commit repository. Your configuration will look something like this:

```yml
repos:
  - repo: https://github.com/your-organization/your-pre-commit-repo
    rev: vX.Y # (Your version nuymbers)
    hooks:
      - id: swimm-verify
```

You can also fork this repository to your own organization, commit whatever changes you wish to make, and then tag in a new release for your teammates to use. 
