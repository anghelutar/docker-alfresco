FROM hub.xenit.eu/alfresco-enterprise-bundle:4.2.6

ONBUILD COPY ./amps/* /opt/alfresco/amps/
ONBUILD COPY ./amps_share/* /opt/alfresco/amps_share/
ONBUILD RUN /opt/alfresco/bin/apply_amps.sh

