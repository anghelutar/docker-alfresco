# Alfresco in Docker

## Images created (not all available for all versions)

* [`alfresco-skeleton`] = skeleton common for all "core" images per major version; includes java, tomcat, init script, keystore
* [`alfresco-enterprise`] = enterprise Alfresco-only images
* [`alfresco-community`] = community Alfresco-only images
* [`alfresco-enterprise-bundle`] = bundle images, with Alfresco+Solr+Postgres+JodConverter

## Supported Tags

* [`:5.1.3`, `:5.1`, `:5`, `:5.2.g`] = minor, major, revision for enterprise + community
* [`-bundle:4.2.6`,`-bundle:4.2`,`-bundle:4`] = minor, major, revision for bundled images
* [`-bundle:4.2.6-onbuild`] = not build automatically; bundled images including amps

## Overview

This is our repository with _Dockerfile_ s that are the cannonical source for our Alfresco Docker images. 

Images are automatically built by [jenkins-2](https://jenkins-2.xenit.eu) and published to [hub.xenit.eu](https://hub.xenit.eu).

## Image Variants

There are a few image variants, with different use cases in mind.

* Multi-container: `alfresco` to be used together with [`docker-solr`](https://bitbucket.org/xenit/docker-solr), [`postgres`](https://bitbucket.org/xenit/docker-postgres), [`jodconverter-ws`](https://bitbucket.org/xenit/docker-jodconverter-ws)
* Bundle: `alfresco-enterprise-bundle` contains a single image with _Alfresco_, _solr_, _postgresql_, _libreoffice_
* Onbuild bundle: `alfresco-enterprise-bundle:<version>-onbuild` extends from `-bundle` to quickly create a containerized version of Alfresco with your custom .amp

### alfresco-enterprise:<version>

This is the defacto core image for a multi-container deployment, especially in production.

You can use the [`src/main/resources/docker-compose.yml`](https://bitbucket.org/xenit/docker-alfresco/src/master/src/main/resources/docker-compose.yml) or [`src/main/resources/docker-compose-solr4.yml`](https://bitbucket.org/xenit/docker-alfresco/src/master/src/main/resources/docker-compose-solr4.yml) as a template in your project. 

Note that this uses the compose file [version 3](https://docs.docker.com/compose/compose-file/#version-3) syntax, which means you need [Docker Compose 1.10.0+](https://github.com/docker/compose/releases?after=1.10.1).

Images can be customized further by using environment variables - see section Environment Variables.

### alfresco-enterprise-bundle:4.2

If you need a quick disposable vanilla Alfresco image, this will suit you fine.

```
docker run --name my-alfresco -p 8080:8080 hub.xenit.eu/alfresco-enterprise-bundle:4.2
```

If you want your data to be safe, you can use a named volume:

```
docker run --name my-alfresco -p 8080:8080 -v my-alf-data:/data hub.xenit.eu/alfresco-enterprise-bundle:4.2
```

See the [`enterprise-4.2/bundle/docker-compose.yml`](https://bitbucket.org/xenit/docker-alfresco/src/master/4.2/enterprise-4.2.6-bundle/docker-compose.yml) for an example to get up and running.

### alfresco-enterprise-bundle:4.2-onbuild

TODO document onbuild with example

## Environment variables

There are several environment variables available to tweak the behaviour. While none of the variables are required, they may significantly aid you in using these images.
The variables are read by an init script which further replaces them in the relevant files. Such relevant files include - for alfresco:

* alfresco-global.properties
* server.xml (ports)
* context.xml (persistent sessions)
* setenv.sh (JAVA_OPTS parameters)

The alfresco-global.properties can be set via a generic mechanism by setting environment variables of the form GLOBAL_<parameter>, e.g. GLOBAL_alfresco.host. 
They can also be set via environment variables of the form JAVA_OPTS_<ignored_key> where the value should be "-Dkey=value".

A subset of the alfresco-global.properties have also dedicated environment variables e.g. SOLR_SSL. Generic variables take precedence.

A subset of java variables have also dedicated environment variables e.g. JAVA_XMX. Generic variables take precedence.

Environment variables:

| Variable                    | alfresco-global.property variable | java variable                                                | Default                                                      | Comments |
| --------------------------- | --------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | --------------------------- |
| SOLR_SSL                    | solr.secureComms                  |                                                              | https                                                        | disabling only works for Alfresco>=5.1 |
| ALFRESCO_HOST               | alfresco.host                     |                                                              | localhost                                                    |  |
| ALFRESCO_PORT               | alfresco.port                     |                                                              | 8080                                                         |  |
| ALFRESCO_PROTOCOL           | alfresco.protocol                 |                                                              | http                                                         |  |
| SHARE_HOST                  | share.host                        |                                                              | localhost                                                    |  |
| SHARE_PORT                  | share.port                        |                                                              | 8080                                                         |  |
| SHARE_PROTOCOL              | share.protocol                    |                                                              | http                                                         |  |
| DB_DRIVER                   | db.driver                         |                                                              | org.postgresql.Driver                                        |  |
| DB_HOST                     | db.host                           |                                                              | localhost                                                    |  |
| DB_PORT                     | db.port                           |                                                              | 5432                                                         |  |
| DB_NAME                     | db.name                           |                                                              | alfresco                                                     |  |
| DB_USERNAME                 | db.username                       |                                                              | alfresco                                                     |  |
| DB_PASSWORD                 | db.password                       |                                                              | admin                                                        |  |
| DB_URL                      | db.url                            |                                                              | jdbc:postgresql://postgresql:5432/alfresco                   |  |
| DB_QUERY                    | db.pool.validate.query            |                                                              | select 1                                                     |  |
| INDEX                       | index.subsystem.name              |                                                              | solr for alfresco 4 <br>solr4 for alfresco 5<br>solr6 for alfresco >=5.2 |  |
|                             | solr.host                         |                                                              | solr                                                         |  |
| SOLR_PORT                   | solr.port                         |                                                              | 8080                                                         |  |
| SOLR_PORT_SSL               | solr.port.ssl                     |                                                              | 8443                                                         |  |
| DYNAMIC_SHARD_REGISTRATION  | solr.useDynamicShardRegistration  |                                                              | false                                                        |  |
| MAIL_HOST                   | mail.host                         |                                                              | localhost                                                    |  |
| ENABLE_CIFS                 | cifs.enabled                      |                                                              | false                                                        |  |
| ENABLE_FTP                  | ftp.enabled                       |                                                              | false                                                        |  |
| ENABLE_CLUSTERING           | alfresco.cluster.enabled          |                                                              | false                                                        |  |
| TOMCAT_PORT                 |                                   | -DTOMCAT_PORT                                                | 8080                                                         |  |
| TOMCAT_PORT_SSL             |                                   | -DTOMCAT_PORT_SSL                                            | 8443                                                         |  |
| TOMCAT_AJP_PORT             |                                   | -DTOMCAT_AJP_PORT                                            | 8009                                                         |  |
| TOMCAT_SERVER_PORT          |                                   | -DTOMCAT_SERVER_PORT                                         | 8005                                                         |  |
| TOMCAT_MAX_HTTP_HEADER_SIZE |                                   | -DTOMCAT_MAX_HTTP_HEADER_SIZE  or -DMAX_HTTP_HEADER_SIZE                              | 32768                                                        |  |
| TOMCAT_MAX_THREADS          |                                   | -DTOMCAT_MAX_THREADS or -DMAX_THREADS                                              | 200                                                          |  |
| JAVA_XMS                    |                                   | -Xmx                                                         |                                                              |  |
| JAVA_XMX                    |                                   | -Xms                                                         |                                                              |  |
| DEBUG                       |                                   | -Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n |     false                                                         |  |
| JMX_ENABLED                 |                                   | -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.rmi.port=5000 -Dcom.sun.management.jmxremote.port=5000 -Djava.rmi.server.hostname=$JMX_RMI_HOST |     false                                                         |  |
| JMX_RMI_HOST                |                                   |                                                              |  0.0.0.0                                                            |  |
| GLOBAL_\<variable\>           | \<variable\>                        |                                                              |                                                              |  |
| JAVA_OPTS_\<variable\>=\<value\>       |                                   | \<value\>                                                   |                                                              |  |

## Docker-compose files

Besides the docker-compose files used in the tests, there are other example files in [src/main/resources](https://bitbucket.org/xenit/docker-alfresco/src/master/src/main/resources/).

## Support & Collaboration

Issues can be reported on the [JIRA DOCKER](https://xenitsupport.jira.com/projects/DOCKER) project.

These images are updated via pull requests to the [xenit/docker-alfresco/](https://bitbucket.org/xenit/docker-alfresco/) BitBucket-repository.


## FAQ

### How do I access the Tomcat debugport ?

Set the environment variable DEBUG=true. The debug port is 8000.

### How do I enable JMX?

Set the environment variable JMX_ENABLED=true. Jmx port is 5000.


