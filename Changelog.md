# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [v0.0.6] - 2018-10-26
### Added
* [DOCKER-126] Image for community 6.0.7-ga

### Removed
* [DOCKER-128] Remove community image 6.0.0, is unstable


## [v0.0.5] - 2018-09-24
### Changed
* [DOCKER-115] Move healthchecks to Dockerfiles

### Fixed
* [DOCKER-91] Redirect port was not parametrized in server.xml, therefore it was not possible to change it

## [v0.0.4] - 2018-09-10
### Added
* [DOCKER-76] Smoke tests

### Fixed
* [DOCKER-107] Property solr.port was not set due to wrong check in the init.sh

### Removed
* [DOCKER-120] Removed ALFRESCO_PORT and ALFRESCO_PORT_SSL referring to ports in server.xml. 
Correct way to change those - via TOMCAT_PORT and TOMCAT_PORT_SSL.


## [v0.0.3] - 2018-08-28
### Added
* [DOCKER-93] Image for Alfresco Enterprise 6.0
* [DOCKER-102] Image for Alfresco Enterprise 5.2.4 (last SP)

### Fixed
* [DOCKER-101] Fix tag on Alfresco Community 5.2.g

## [v0.0.2] - 2018-07-25
### Changed
* [DOCKER-98] Refactorings: simplified and deduplicated build.gradle, addition of "local" resources 

### Security
* [DOCKER-96] Do not echo properties being replaced, they should not appear in the logs (some are confidential)
	
## [v0.0.1] - 2018-07-19
### Changed
* [DOCKER-82] Good defaults for properties
* [DOCKER-12] [DOCKER-80] [DOCKER-79] [DOCKER-61] [DOCKER-55] [DOCKER-28] Refactorings: created global resources (for dockerfiles - with arguments, keystore, init), enterprise + community specific properties, single build.gradle, better namings
* [DOCKER-66] Adapted solr images names
* [DOCKER-31] [DOCKER-38] Tomcat-specific variables implemented as JAVA_OPTS and renamed into TOMCAT_<variable> (e.g. TOMCAT_PORT, TOMCAT_MAX_THREADS).
* [DOCKER-37] Adapt bundle images for new structure

### Added
* [DOCKER-92] Image for Alfresco Enterprise 5.2.3
* [DOCKER-87] Image for Alfresco Enterprise 4.2.8
* [DOCKER-67] Include jod converter amp
* [DOCKER-57] Added alfresco pdf renderer executable to Alfresco images >=5.2
* [DOCKER-94] Declare growing folders as volumes
* [DOCKER-35] Support for JAVA_OPTS_<variable> variables, allowing for overrides in different docker-compose files  
* [DOCKER-43] First version Changelog

### Removed
* [DOCKER-37] Removed bundled images for versions >=5.0
* [DOCKER-26] Removed the PROXY_<variable> parameters from the init
	

