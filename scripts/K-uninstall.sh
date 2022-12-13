#
# silly crazy
# kubectl -n docintel delete "$(kubectl api-resources --namespaced=true --verbs=delete -o name | tr "\n" "," | sed -e 's/,$//')" --all
#
kubectl delete all --all -n docintel
kubectl delete namespace docintel

