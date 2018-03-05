+++
author = "Peter Souter"
categories = ["Puppet", "Tech", "vDM30in30"]
date = 2016-11-08T19:25:00Z
description = ""
draft = false
coverImage = "/images/2016/11/marmo.png"
slug = "debugging-puppet-issues"
tags = ["Puppet", "Tech", "vDM30in30"]
title = "Debugging Puppet Issues"

+++

#### Day 8 in the #vDM30in30

When you're beginning with Puppet, it can be difficult to troubleshoot and debug issues with Puppet code.

What many people don't know is that there are a bunch of useful cache files that can be used to help with this debugging.

I've got a box I've classified as a graphite and grafana machine with Puppet, and I want to find out whats going on.

Most of them can be found in the statedir:

```
[root@graphiteagent ~]# tree $(puppet agent --configprint statedir)
/opt/puppetlabs/puppet/cache/state
├── classes.txt
├── graphs
│   ├── expanded_relationships.dot
│   ├── relationships.dot
│   └── resources.dot
├── last_run_report.yaml
├── last_run_summary.yaml
├── resources.txt
├── state.yaml
└── transactionstore.yaml

1 directory, 9 files
```

Lets go through them and explain them a bit...

### classes.txt

This is a simple text file that lists all classes applied during the last run.

```
[root@graphiteagent ~]# cat $(puppet agent --configprint classfile)
cat $(puppet agent --configprint classfile)
profiles::grafana
profiles::graphite
settings
default
profiles::grafana
grafana::params
grafana
grafana::install
grafana::config
grafana::service
profiles::graphite
graphite::params
graphite
graphite::install
graphite::config
graphite::config_apache
```

With a bit of grepping, you can find out if a certain class was present:

```
[root@graphiteagent ~]# grep graphite $(puppet agent --configprint classfile)
profiles::graphite
profiles::graphite
graphite::params
graphite
graphite::install
graphite::config
graphite::config_apache
```

### resources.txt

Similar to `classes.txt`, but this lists all resource titles enforced during the last run:

```
[root@graphiteagent ~]# cat $(puppet agent --configprint resourcefile)
package[fontconfig]
package[grafana]
file[/etc/grafana/grafana.ini]
service[grafana-server]
grafana_datasource[Graphite]
grafana_dashboard[CollectD Stats from Graphite]
file[/usr/bin/pip-python]
package[mysql-python]
package[pyopenssl]
package[python-ldap]
package[python-memcached]
package[python-psycopg2]
...
```

Again, with a bit of grepping, you can look for a specific resource. Remember however: you can only look by resource title, so if someone's given a unique title for say, a file, you won't be able to search for a path.

```
[root@graphiteagent ~]# grep '/opt/graphite/' $(puppet agent --configprint resourcefile)
file[/opt/graphite/storage]
file[/opt/graphite/storage/rrd]
file[/opt/graphite/storage/lists]
file[/opt/graphite/storage/log]
file[/opt/graphite/bin]
file[/opt/graphite/storage/whisper]
file[/opt/graphite/storage/log/carbon-cache]
file[/opt/graphite/storage/graphite.db]
file[/opt/graphite/webapp/graphite/local_settings.py]
file[/opt/graphite/conf/graphite_wsgi.py]
file[/opt/graphite/webapp/graphite/graphite_wsgi.py]
file[/opt/graphite/conf/storage-schemas.conf]
file[/opt/graphite/conf/carbon.conf]
file[/opt/graphite/conf/storage-aggregation.conf]
file[/opt/graphite/conf/whitelist.conf]
file[/opt/graphite/conf/blacklist.conf]
file[/opt/graphite/bin/carbon-logrotate.sh]
```

### Graph folder

Depending on which version of Puppet you have an how it's configured, you may have to enable this first.

```
tree $(puppet agent --configprint statedir)
/opt/puppetlabs/puppet/cache/state
├── classes.txt
├── graphs
├── last_run_report.yaml
├── last_run_summary.yaml
├── resources.txt
├── state.yaml
└── transactionstore.yaml

1 directory, 6 files
```

As you can see, there's no files in the graph folder.

So you just set graph to be true:

```
[root@graphiteagent ~]# puppet config set graph true --section=agent
```

After that you should see graphs next time you have a Puppet run:

```
[root@graphiteagent ~]# cat $(puppet agent --configprint statedir)/graphs/relationships.dot
digraph Relationships {
    label = "Relationships"
    "Stage[main]" [
        fontsize = 8,
        label = "Stage[main]"
    ]

    "Class[Settings]" [
        fontsize = 8,
        label = "Class[Settings]"
    ]

    "Class[Main]" [
        fontsize = 8,
        label = "Class[Main]"
    ]

    "Node[default]" [
        fontsize = 8,
        label = "Node[default]"
    ]

    "Class[Puppet_enterprise::Params]" [
        fontsize = 8,
        label = "Class[Puppet_enterprise::Params]"
    ]

    "Class[Puppet_enterprise]" [
        fontsize = 8,
        label = "Class[Puppet_enterprise]"
    ]

    "Class[Profiles::Grafana]" [
        fontsize = 8,
        label = "Class[Profiles::Grafana]"
    ]

    "Class[Profiles::Graphite]" [
        fontsize = 8,
        label = "Class[Profiles::Graphite]"
    ]
```

You can then put this into a graph that can visualise .dot files such as Graphviz. There's a web version of it that you can use in a pinch:

![Graph Vis Example](/images/2016/11/Screenshot-2016-11-14-20.17.58.png)
###### A Puppet relationship graph made from http://www.webgraphviz.com/

### Cached Agent Catalog

A newish feature of Puppet is the cached catalog. The master sends the compiled catalog to the agent to be applied. In the event the agent cannot reach the master, it will continue to enforce the last catalog it received (the cached catalog).

This is so that when the master is unavailable, there can still be ongoing Puppet management of systems.

However, we can also use it for debugging by reading the data file for it.

This is in a slightly different location than the other files: `$(puppet agent --configprint client_datadir)`

```
[root@graphiteagent ~]# tree $(puppet agent --configprint client_datadir)
/opt/puppetlabs/puppet/cache/client_data
└── catalog
    └── graphiteagent.puppetdebug.vlan.json

1 directory, 1 file
```

Since this is a minified JSON file, grepping it is a little harder as it's all bunched up and harder to read:

```[root@graphiteagent ~]# cat $(puppet agent --configprint client_datadir)/catalog/graphiteagent.puppetdebug.vlan.json
{"tags":["profiles::grafana","profiles","grafana","profiles::graphite","graphite","puppet_enterprise","puppet_enterprise::profile::agent","profile","agent","puppet_enterprise::profile::mcollective::agent","mcollective","settings","default","puppet_enterprise::params","params","grafana::params","grafana::install","install","grafana::config","config","grafana::service","service","graphite::params","graphite::install","graphite::config","graphite::config_apache","config_apache","puppet_enterprise::symlinks","symlinks","puppet_enterprise::pxp_agent","pxp_agent","puppet_enterprise::pxp_agent::service","puppet_enterprise::mcollective::server","server","puppet_enterprise::mcollective::server::plugins","plugins","puppet_enterprise::mcollective::service","puppet_enterprise::mcollective::server::logs","logs","puppet_enterprise::mcollective::server::certs","certs","puppet_enterprise::mcollective::server::facter","facter","puppet_enterprise::mcollective::cleanup","cleanup","node","class"],"name":"pe-201640-agent-1.puppetdebug.vlan","version":1479152216,"code_id":null,"catalog_uuid":"d2f5c1ae-9b01-4be8-8eee-8e756940cae0","catalog_format":1,"environment":"production","resources":[{"type":"Stage","title":"main","tags"
```

But with `jq` or `python` we can read it a little better:

```
[root@graphiteagent catalog]# python -m json.tool $(puppet agent --configprint client_datadir)/catalog/graphiteagent.puppetdebug.vlan.json
{
    "catalog_format": 1,
    "catalog_uuid": "d2f5c1ae-9b01-4be8-8eee-8e756940cae0",
    "classes": [
        "profiles::grafana",
        "profiles::graphite",
        "settings",
        "default",
        "profiles::grafana",
        "grafana::params",
        "grafana",
        "grafana::install",
        "grafana::config",
        "grafana::service",
        "profiles::graphite",
        "graphite::params",
        "graphite",
        "graphite::install",
        "graphite::config",
```

As you can see, this is the complete catalog: so it's all the information, which classes, which resources, tags, parameters, relationships are being created.

There's a powerful `jq` tool which as the website says:

> jq is like sed for JSON data - you can use it to slice and filter and map and transform structured data with the same ease that sed, awk, grep and friends let you play with text.

https://stedolan.github.io/jq/

So for example, if we want to see all the parameters for a certain class from the json:

```
[root@graphiteagent ~]# jq '.resources[] | select(.type == "Class" and .title == "Graphite").parameters' $(puppet agent --configprint client_datadir)/catalog/graphiteagent.puppetdebug.vlan.json
{
  "gr_rendering_hosts_timeout": "1.0",
  "gr_carbonlink_hosts_timeout": "1.0",
  "gr_disable_webapp_cache": false,
  "gr_manage_python_packages": true,
  "gr_pip_install": true,
  "gr_django_provider": "pip",
  "gr_django_ver": "1.5",
  "gr_django_pkg": "Django",
  "gr_aggregator_udp_receiver_port": 2023,
  "gr_aggregator_udp_receiver_interface": "0.0.0.0",
  "gr_aggregator_enable_udp_listener": "False",
  "gr_aggregator_line_port": 2023,
  "gr_aggregator_line_interface": "0.0.0.0",
```

### last\_run\_report.yaml

Lastly, this is a basic yaml file giving the last report run on a machine:

```
[root@graphiteagent ~]# cat $(puppet agent --configprint lastrunreport)
--- !ruby/object:Puppet::Transaction::Report
metrics:
  resources: !ruby/object:Puppet::Util::Metric
    name: resources
    label: Resources
    values:
    - - total
      - Total
      - 235
    - - skipped
      - Skipped
      - 0
    - - failed
      - Failed
      - 0
    - - failed_to_restart
      - Failed to restart
      - 0
    - - restarted
      - Restarted
```

With some simple grepping, you can get simple information from the report. For example, finding changed resources:

```
[root@graphiteagent ~]# grep -c 'changed: true' $(puppet agent --configprint lastrunreport)
7
```

There's a really cool report reading script written by R.I called
[report-print](https://github.com/ripienaar/puppet-reportprint).

### report-print

report-print is a simple Ruby script that parses the last run yaml file script. The output is pretty awesome summary of indicators of what took the longest time in the catalog and other metrics.

```
[root@graphiteagent state] git clone https://github.com/ripienaar/puppet-reportprint /opt/report-print
```

We can actually use the Ruby that comes with the new AIO agent to avoid issues with Ruby incompatibility:

```
[root@graphiteagent state] /opt/puppetlabs/puppet/bin/ruby /opt/report-print/report_print.rb
Report for pe-201640-agent-1.puppetdebug.vlan in environment production at 2016-11-14 20:13:05 +0000

             Report File: /opt/puppetlabs/puppet/cache/state/last_run_report.yaml
             Report Kind: apply
          Puppet Version: 4.7.0
           Report Format: 6
   Configuration Version: 1479154386
                    UUID: dc84cc4b-22c2-4a3a-b793-1cee7ff5bb67
               Log Lines: 8 (show with --log)

Report Metrics:

   Changes:
                   Total: 1

   Events:
                   Total: 1
                 Success: 1
                 Failure: 0

   Resources:
                   Total: 235
             Out of sync: 1
                 Changed: 1
       Corrective change: 1
       Failed to restart: 0
                 Skipped: 0
                  Failed: 0
               Restarted: 0
               Scheduled: 0

   Time:
                   Total: 3.891074847
        Config retrieval: 3.135387682
                    File: 0.318029754
                 Service: 0.17787715599999998
       Grafana dashboard: 0.15070201
      Grafana datasource: 0.09668277
                 Package: 0.009231408999999998
                    Cron: 0.001372621
                    Exec: 0.000852301
                Schedule: 0.000385452
                  Anchor: 0.00031026999999999997
              Filebucket: 0.00015099
               Pe anchor: 9.2432e-05


Resources by resource type:

    187 File
     26 Package
      6 Schedule
      5 Service
      3 Exec
      2 Cron
      2 Anchor
      1 Grafana_dashboard
      1 Grafana_datasource
      1 Filebucket
      1 Pe_anchor

Slowest 20 resources by evaluation time:

      0.15 Grafana_dashboard[CollectD Stats from Graphite]
      0.10 Grafana_datasource[Graphite]
      0.07 File[/tmp/fix-graphite-race-condition.py]
      0.04 Service[mcollective]
      0.04 Service[httpd]
      0.04 Service[grafana-server]
      0.03 Service[carbon-cache]
      0.03 Service[pxp-agent]
      0.02 File[/etc/init.d/carbon-cache]
      0.01 File[/opt/puppetlabs/mcollective/plugins/mcollective/validator]
      0.01 File[/opt/puppetlabs/mcollective/plugins/mcollective/agent/puppet.ddl]
      0.00 File[/etc/puppetlabs/mcollective/ssl/ca.cert.pem]
      0.00 File[/usr/bin/pip-python]
      0.00 File[/opt/graphite/conf/storage-schemas.conf]
      0.00 File[/opt/puppetlabs/mcollective/plugins/mcollective/agent/puppet.rb]
      0.00 File[/etc/puppetlabs/mcollective/ssl/pe-201640-agent-1.puppetdebug.vlan.private_key.pem]
      0.00 File[/opt/puppetlabs/mcollective/plugins/mcollective/validator/puppet_resource_validator.ddl]
      0.00 File[/etc/grafana/grafana.ini]
      0.00 File[/etc/puppetlabs/mcollective/ssl/pe-201640-agent-1.puppetdebug.vlan.cert.pem]
      0.00 File[carbon_hack]

20 largest managed files (only those with full path as resource name that are readable)

    68.00 KB /opt/graphite/storage/graphite.db
    16.77 KB /opt/graphite/conf/carbon.conf
    15.35 KB /opt/puppetlabs/mcollective/plugins/mcollective/util/puppet_agent_mgr.rb
    15.15 KB /opt/puppetlabs/mcollective/plugins/mcollective/security/sshkey.rb
    11.48 KB /opt/puppetlabs/mcollective/plugins/mcollective/application/puppet.rb
    10.53 KB /opt/puppetlabs/mcollective/plugins/mcollective/agent/puppet.rb
     8.97 KB /opt/puppetlabs/mcollective/plugins/mcollective/agent/puppet.ddl
     8.92 KB /opt/graphite/webapp/graphite/local_settings.py
     8.12 KB /opt/puppetlabs/mcollective/plugins/mcollective/util/puppetrunner.rb
     6.06 KB /opt/puppetlabs/mcollective/plugins/mcollective/util/package/base.rb
     5.73 KB /opt/puppetlabs/mcollective/plugins/mcollective/agent/package.ddl
     5.56 KB /opt/puppetlabs/mcollective/plugins/mcollective/util/actionpolicy.rb
     5.25 KB /etc/init.d/carbon-cache
     4.87 KB /opt/puppetlabs/mcollective/plugins/mcollective/util/package/packagehelpers.rb
     4.46 KB /opt/puppetlabs/mcollective/plugins/mcollective/util/package/yumHelper.py
     4.41 KB /opt/puppetlabs/mcollective/plugins/mcollective/agent/package.rb
     3.57 KB /opt/puppetlabs/mcollective/plugins/mcollective/application/package.rb
     3.25 KB /opt/puppetlabs/mcollective/plugins/mcollective/application/service.rb
     3.17 KB /etc/puppetlabs/mcollective/ssl/mcollective-private.pem
     3.17 KB /etc/puppetlabs/mcollective/ssl/pe-201640-agent-1.puppetdebug.vlan.private_key.pem

20 most time consuming containment

      0.76 Stage[main]
      0.25 Profiles::Grafana
      0.15 Grafana_dashboard[CollectD Stats from Graphite]
      0.12 Puppet_enterprise::Mcollective::Server::Plugins
      0.11 Graphite::Config_apache
      0.10 Grafana_datasource[Graphite]
      0.09 Graphite::Config
      0.07 File[/tmp/fix-graphite-race-condition.py]
      0.04 Puppet_enterprise::Mcollective::Service
      0.04 Service[mcollective]
      0.04 Service[httpd]
      0.04 Grafana::Service
      0.04 Service[grafana-server]
      0.03 Service[carbon-cache]
      0.03 Puppet_enterprise::Pxp_agent::Service
      0.03 Service[pxp-agent]
      0.02 File[/etc/init.d/carbon-cache]
      0.02 Puppet_enterprise::Mcollective::Cleanup
      0.02 Puppet_enterprise::Mcollective::Server::Certs
      0.01 Graphite::Install
```

As you can see, we can see what resources took up the most time, the largest resources in the catalog and how long each step of the Puppet run took: compilation, enforcement and reporting.
