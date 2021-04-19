# pre-commit hooks for Swimm

Utilizing [pre-commit](https://pre-commit.com/), you can enable Swimm checks to run prior to the review cycle. In order to get started, you'll need to [install pre-commit](https://pre-commit.com/#install) (pip, brew and other methods are available). 

Secondly, put the following contents into `.pre-commit-config.yaml` in the root of your repository (create it if needed):

```
repos:
  - repo: https://github.com/swimmio/pre-commit
    rev: <VERSION> # resolve the latest version from the release tags
    hooks:
      - id: swimm-verify
```

If you already have a `.pre-commit-config.yaml` file, add the swimm checks as a new `- repo` section, wherever you'd like them to run. Note that if you have failure mode set to fast, no other checks will run if documentation can't be verified, so we recommend adding Swimm as the last (or close to last) check. 

Please report bugs to Tim Post <tim@swimm.io> 
