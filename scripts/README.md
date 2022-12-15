# Script manifest

## Installation and Configuration

`1-prep.sh (lab.com/docker-io-cache/ | docker.io)`

This makes sure the helm charts for bitnami are installed 
and sets the `,REPO` file.

`2-make-common-deployments.sh ( lab | rancher-desktop )`

This sets some configurations for a lab (remote RKE2 with NFS storageClass)
or a local developement environment (e.g. rancher-desktop).  

It writes the profile to `,PROFILE` a truth value to `,SOLR` (solrCloud
mode) and for lab sets `ReadWriteMany` and for local `ReadWriteOnce`  
into `,PVC_MODE` (used for the `/files` and `/lock`) shares.

`3-install_common.sh`

This installs the following:  `rabbitmq`, `postgresql`, `solr`, and
`synapse-cortex`.  In theory these could be external or in a separate
namespace.

`4-configure_common.sh`

This adds the `docintel` database to postgres and writes the solr
configuraiton files and starts up the collections.

`5-docintelapp_prepare.sh`

This writes the `appsettings.json` used by docintel applications and
saves this into a kubernetes config-map.

_If_ `,BASE_URL` exists (e.g. "https://docintel.lab.example.com") then
this will be patched into `appsettings.json`

`6-docintelapp_deploy.sh`

This writes the docintel deployment into `deploy/docintel_apps.yaml` 
and install them, along with the PVCs for `/files`, `/lock` and the webapp
service running on port 8080.

`7-docintelapp_config.sh`

This adds an admin user.

## Uninstall

`K-uninstall.sh`

(todo: make sure some PVCs can be saved as an option for uninstall)

## Access to system

`R-docintelapp.sh`i

This proxies localhost 8080 to the docintel app.

`R-solr-admin.sh`

This proxies localhost 8983 to the solr curl / admin interface.

## Debugging 

`D-docintel-pause.sh`

`D-docintel-resume.sh`

These scripts will scale up or down the docintel applications to 0 or 1

`D-postgres.sh`

Opens a psql prompt connected to the database.


`D-run-with-pvc.sh`

Helper script.  Attach a emphemeral script to a PVC.  Useful for inspecting
files if pod is not running.  

`D-solr-logs.sh`

Peek at the pods/solr-0 logs.

`D-wireshark-solr.sh`

Open up a local wireshark terminal that is attached to the solr interface.
This is able to inspect the HTTP POSTs from the docintel app indexers to the
solr installtion.  I used this to debug my solr configuration files.

