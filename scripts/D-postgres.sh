postgres_pw=$(kubectl get secret --namespace docintel postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
postgres_im=$(grep -Eo 'image: (.*?bitnami/postgresql:\S+)' common/postgresql.yaml | cut -c8-)

kubectl run postgresql-client --rm --tty -i --restart='Never' \
    --namespace docintel --image $postgres_im \
    --env="PGPASSWORD=$postgres_pw" \
    --command -- psql --host postgresql -U postgres -d postgres -p 5432
