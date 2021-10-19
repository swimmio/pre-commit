# What hooks are available?

 - `swimm-verify` will run Swimm's verification checks, and exit nonzero if they fail. Recommended.
 - `swimm-verify-nonblocking` (v0.4 only) Like swimm-verify, but will always return successfully. Webooks are used to open an issue if verification fails.

All hooks will currently work with the web or desktop version of swimm. If you
don't have the CLI component, the hook will download it for you and clean up
after it runs. 

If you use the web version, you'll need `curl` and `wget` installed.

If the environmental variable `SWIMM_VERIFY_WEBHOOK` is set, the scripts will
send a POST request to the URL with the field `context` containing the output
of the `swimm_cli verify` command. This is useful for build automation, such 
as automatically opening an issue if the non-blocking hook fails.

An example of how this can be automated is given as a ["Zap" template at Zapier](https://zapier.com),
which consists of a webhook that creates a card on a Trello board. You can switch
the Trello part for Github, Jira, BitBucket and *most* other forges.

## The `swimm-verify` Hook:

This is the simplest (and most ideal) configuration. The verification check will
return nonzero if something requires attention. Documentation failing verification
will be treated just like any other test that fails.

## The `swimm-verify-nonblocking` Hook (v0.4+ only):

This hook is just like `swimm-verify`, but it will always exit successfully, even if
the documentation verification check fails. If used on a conunction with a webhook,
you can let the build proceed and create an issue with a deadline to complete.