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

For some deploy commands you'll need a file describing the target servers (stages).
Put them into

~~~
~/.eh-stages
~~~

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
