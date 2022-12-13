postgres_pw=$(kubectl get secret --namespace docintel postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
postgres_im=$(grep -Eo 'image: (.*?bitnami/postgresql:\S+)' common/postgresql.yaml | cut -c8-)

has_docintel=$( \
    kubectl run postgresql-docintel-check --rm --tty -i --restart='Never' --namespace docintel \
          --image $postgres_im --env="PGPASSWORD=$postgres_pw" \
          --command -- psql --host postgresql -U postgres -d postgres -p 5432 \
          -c 'SELECT datname FROM pg_database' 2> /dev/null | grep docintel \
      )

# echo "X${has_docintel}X"

echo ""
echo "=== POSTGRESQL"

if [ "X${has_docintel}X" = "XX" ]; then
    kubectl run postgresql-init-uuid --rm --tty -i --restart='Never' --namespace docintel \
          --image $postgres_im --env="PGPASSWORD=$postgres_pw" \
          --command -- psql --host postgresql -U postgres -d postgres -p 5432 \
          -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"'

    kubectl run postgresql-init-database --rm --tty -i --restart='Never' --namespace docintel \
          --image $postgres_im --env="PGPASSWORD=$postgres_pw" \
          --command -- psql --host postgresql -U postgres -d postgres -p 5432 \
          -c 'CREATE DATABASE docintel'
    echo ""
    echo "=== READY"
else
    echo ""
    echo "=== SKIPPED (PREVIOUSLY CONFIGURED)"
fi
