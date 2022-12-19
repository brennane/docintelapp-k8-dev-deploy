
#  Kubernetes deployment scripts for "Docintelapp/DocIntel"

Please see <https://github.com/Docintelapp/DocIntel> for official
documentation.  I have no association with the project but wished to share
these files to help boostrap a local or remote k8 environment for running
the system.

# Profile

We have two profiles for testing kubernets.

## Profile "rancher-desktop"

We use the default local-path storageClass - which required ReadWriteOnce
which is okay since we are using just one node.

- rancher-desktop local development (intel macos)

Note I have CPUs (6) and Memory (24 Kb) dedicated to the rancher-desktop VM.


## Profile "lab"

(not quite baked, working on rancher-desktop right now)

RKE2 HA (5 node) cluster.  The default storageClass is "nfs" where we 
have whole bunch of space for doing experiments.  We also have longhorn.

Here we use ReadWriteMany modes for the docintel /files and /lock shared
dirs.  Helm repos for longhorn (mounted on nodes, shared) or nfs (netapp)
can be found "nfs-subdir-external-provisioner" or "longhorn" 

~~~
   [ HA PROXY ]           | lab-rke2-01tst .
(SSL termination)  -----> | lab-rke2-02tst . <-> lab-rke2-04tst
                          | lab-rke2-03tst .     lab-rke2-05tst
~~~

## Configuring

`Rancher Desktop -> Troubleshooting -> Reset Kubernetes` is a good thing to
find if things are truly wedged.  the "K-uninstall" script has a commented
out version that recursively kills things that might weed out a stale PVC.

- `1-prep.sh docker.io`  does some basic helm checks and sets a file called,
  REPO (in my environment that is a Harbor caching proxy for docker.io)
- `2-make-common-deployments.sh rancher-desktop` this is going to create
  configuraitons for postgres, rabbitmq, solr, and synapse-cortex; things
  that are not properly the docintellapp
- `3-install_common.sh` is going to execute helm install or a kubectl
  apply (synpase) for the common applications and let them come up.
- `4-configure_common.sh` in particular we need postgres with the docintel
   database and extension and the docintel solr configs applied (note)
- `5-docintelapp_prepare.sh` docintell app-configs need a few passwords
   and other settings and this is building the config-map for docintel
- `6-docintelapp_deploy.sh` will deploy the docintell applications 
- `7-docintelapp_config.sh` set an admin account.

(note) solr is not happy in this configuration, and
`static/DOCINTEL_DOCKER_TAG` may need to be updated at this point.


## Running

I don't have the script to expose the docintel webapp to ingress but
will do so once we have verification.  But for localhost testing we have:

- `sh scripts/R-docintelapp.sh &` which exposes localhost:8080 to the docintell webap
- `sh scripts/R-solr-admin.sh &` which exposes localhost:8983 to solr

## Debugging

- `scripts/D-wireshark-solr.sh` is something I found that is useful for
  intra-cluster debugging, it taps wireshark on a node.  This is set for my
  rancher-desktop configuration.

## Shutdown

Killing everything off in the `docintel` namespace is _usually_ enough,
but I have reset the k8s cluster a few times.

- `scripts/K-uninstall.sh`

## Development removing / adding docintel deployments

Once the initial setup has been run we can remove / add the docintel deployments
again w/out removing _everything_ assuming our configs don't change.

- `kubectl delete -f deploy/docintel_apps.yaml`

(update docker images)

- `kubectl apply -f deploy/docintel_apps.yaml`

# TODO

- (definitely) script to build and publish docintel images to a local
  registry within kubernetes
- (possibly) convert docintel files into a Helm manifest.
