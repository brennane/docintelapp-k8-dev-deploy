targets=$(kubectl --namespace docintel get deployment -l app.kubernetes.io/part-of=docintel | awk '{print $1}' | grep -v NAME)
test -z "${targets}" || kubectl --namespace docintel scale deployment $targets --replicas 1

# everything?
# kubectl --namespace docintel scale statefulset --replicas 1 $(kubectl --namespace docintel get statefulset  | awk '{print $1}' | grep -v NAME)
# kubectl --namespace docintel scale deployment $(kubectl --namespace docintel get deployment | awk '{print $1}' | grep -v NAME) --replicas 1
