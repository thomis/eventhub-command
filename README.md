eventhub-command
================

Event Hub Command Line Tool includes the following features

* Packaging Event Hub Processor's
* Pushing Channel Adapter and Processor configuration files to servers
* Scaffold your Event Hub Processor

## Installation

Install gem and make command provided by this gem available

~~~ sh
$ gem i eventhub-command
$ rbenv rehash
~~~

First time running the command
~~~ sh
$ eh
Config file missing: ~/.eh, will create it now...
Please specify the Eventhub SVN root directory (i.e. the directory which contains the 'src', 'release', ... directories
/Users/username/dev/event_hub
Config file written to /Users/username/.eh. Please try again.
$
~~~

### Stages

Some commands (e.g. deploy commands) will use stages to determine where to deploy. Those stage files are now
stored in the eventhub SVN repository under config/ directory

The file name is the name of the stage, the content describes environments, hosts, ports and users to use.
Content looks like this:

~~~
localhost:
  node_env: development
  hosts:
    - host: localhost
      port: 2222
      user: s_cme
~~~


## Usage

Help and description for the commands can be obtained through:

~~~
eh --help
~~~
and more specific for a single command
~~~
eh <COMMAND> --help
~~~

### Common options

Some common options are:

* --stage (one of the names that are listed from list_stages command)
* --deploy_via (use svn or scp for deployment. If scp, then the local release directory is used, otherwise svn)
* --branch/--tag (specify a branch or tag to use for "deploy_via scp")
* --verbose (enable verbose output)

### Commands

* deploy_ruby: deploy a ruby processor to a stage. You can specify:
  * a processor name
  * multiple processor names spearated via commas
  * a pattern like something.*
  * a combination of above
* deploy_mule: deploy a mule adapter to a stage
  * a adapter name
  * multiple adapter names spearated via commas
  * a pattern like something.*
  * a combination of above
* deploy_config: checkout the latest version of config on target stage and copy to the config folder on stage.
Those config files will be used uppon next deployment.
* list_stages: list stages that are available for deploy_* commands
* package_ruby: package ruby processors to zip files and copy to release directory on local machines. Those packages
will be used upon next "deploy_via scp" or if you commit them to SVN then upon next "deploy_via svn"
* generate_processor: generate a processor from a basic template


