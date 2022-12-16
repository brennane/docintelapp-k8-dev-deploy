kubectl -n docintel rollout restart deploy -l app.kubernetes.io/part-of=docintel

for what in $(kubectl -n docintel get deploy -ojsonpath='{.items[*].metadata.labels.app}'); do
    echo ""
    echo "${what}: ..."
    kubectl -n docintel rollout status deploy "${what}"
done
