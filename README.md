[![Gem Version](https://badge.fury.io/rb/eventhub-command.svg)](https://badge.fury.io/rb/eventhub-command)
[![Dependency Status](https://gemnasium.com/badges/github.com/thomis/eventhub-command.svg)](https://gemnasium.com/github.com/thomis/eventhub-command)
[![Build Status](https://travis-ci.org/thomis/eventhub-command.svg?branch=master)](https://travis-ci.org/thomis/eventhub-command)

eventhub-command
================

Event Hub Command Line Tool includes the following features

* Dump and Restore database
* Deploy configurations files
* Scaffold, Packaging, and Deploy components
* Manage Repositories
* Manage Statges
* Manage Proxies

## Installation

Install gem and make command provided by this gem available

~~~ sh
$ gem i eventhub-command
$ rbenv rehash
~~~

First time running the command
~~~ sh
$ eh
Created empty config file. Please run 'eh repository add'
$
~~~

Run again:
~~~ sh
$ eh repository add http://something.com/project/svn /Users/foo/eventhub/branches/master username password
$
~~~

NOTE: username and password you specify here are from the deploy user.

### Stages

Some commands (e.g. deploy commands) will use stages to determine where to deploy. Those stage files are now
stored in the eventhub SVN repository under config/ directory

The file name is the name of the stage, the content describes environments, hosts, ports and users to use.

## Usage

Help and description for the commands can be obtained through:

~~~
eh help
~~~
and more specific for a single command
~~~
eh help <COMMAND> [<SUBCOMMAND>]
~~~


