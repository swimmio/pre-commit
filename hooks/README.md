# What hooks are available?

 - `swimm-verify` will run Swimm's verification checks, and exit nonzero if they fail. Recommended.
 - `swimm-verify-nonblocking` Like swimm-verify, but will always return successfully. Webooks are used to open an issue if verification fails.
 - `swimm-export` An example of exporting Swimm docs for third-party documentation hubs like Confluence & Notion

All hooks will currently work with the web or desktop version of swimm. If you
don't have the CLI component, the hook will download it for you and clean up
after it runs. 

If you use the web version, you'll need `curl` and `wget` installed.

## The `swimm-verify` Hook:

This is the simplest (and most ideal) configuration. The verification check will
return nonzero if something requires attention. Documentation failing verification
will be treated just like any other test that fails.

## The `swimm-verify-nonblocking` Hook:

This hook allows documentation verification checks to proceed, and will (optionally)
call a webhook that opens an issue at Github, Bitbucket, Jira, Trello Or anything
else that has an API using [Zapier](http://zapier.com).

We have a template you can use to set this up quickly at:

https://zapier.com/shared/82c84601a5f678127c6cada740e64279c7fdd274

But any webook conveniently accessed with curl will work.


To set it up:

 1. Start with the template linked above. Grab your unique webhook URL.
 2. Change the workflow to open the issue whereever it works for you.
 3. Make sure anyone using the extension has the environmental variable `SWIMM_VERIFY_WEBHOOK` set to the webhook URL.
 4. If the verification fails, the webhook will open an issue with the output letting you know what needs fixed.

## The `swimm-export` Hook:

This hook demonstrates exporting Swimm documentation to other formats for
publishing in other knowledge collections like Docusaurus, Notion, Confluence
and others. This is only currently usable for the Desktop version.