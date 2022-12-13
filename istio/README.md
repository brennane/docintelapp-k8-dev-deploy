These are simple ISTIO configurations.

I had trouble with the application using ingress-nginx and spent a week
trying to remember how to install istio.  Only to remember that

Install / Update Profiles:

- istioctl install -f lab.yaml

Notes:

- istioctl profile dump demo > demo.yaml
- istioctl profile dump default > default.yaml
- lab.yaml is similar to demo but istio is running as NodePort

Frustrated?  Remove w/:

- istioctl uninstall -y --purge

Check the ingress for docintel - very helpful!

- istioctl -n docintel analyze

Lab.yaml notes.

IN our lab we have RKE2 five-node cluster for testing things.  This
bare-metal server does not have a load-balancer (metal-lb) due to 
lab mangament, but we have an HAProxy  on a another VM that does 
SSL termination, etc.  

routing the Istio service on that cluster is done by noting
the nodePort for istio-ingressgateway in the proxy configuration.
This should not change once its set up, but you could 

~~~
backend rke2istio
  # 
  # from the cluster:
  # kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort
  # 
  balance roundrobin
  cookie SERVERUSED insert indirect nocache
  server k80s1i lab-rke2-01tst:32554 check port 32554 cookie k80s1i
~~~
