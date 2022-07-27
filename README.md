[![Gem Version](https://badge.fury.io/rb/eventhub-command.svg)](https://badge.fury.io/rb/eventhub-command)
[![Maintainability](https://api.codeclimate.com/v1/badges/e7291af4909ed092fd84/maintainability)](https://codeclimate.com/github/thomis/eventhub-command/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/e7291af4909ed092fd84/test_coverage)](https://codeclimate.com/github/thomis/eventhub-command/test_coverage)
![](https://github.com/thomis/eventhub-command/workflows/ci/badge.svg)

eventhub-command
================

Event Hub Command Line Tool includes the following features

* Dump and Restore database
* Deploy configurations files
* Scaffold, Packaging, and Deploy components
* Manage Repositories
* Manage Statges
* Manage Proxies

## Supported Ruby Versions

Currently supported and tested ruby versions are:

- 3.1
- 3.0
- 2.7
- 2.6

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


