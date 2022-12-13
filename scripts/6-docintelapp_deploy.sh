docker_tag=$(cat static/DOCINTEL_DOCKER_TAG)

echo ""
echo "=== CREATE docintel_pvc"

DOCINTEL_PVC_ACCESS_MODE="$(cat ,PVC_MODE)" \
    envsubst < static/docintel-pvc.yaml.template > deploy/docintel_pvc.yaml

echo ""
echo "=== COPY webapp service"

cp static/docintel_service.yaml deploy/docintel_service.yaml

echo ""
echo "=== CREATE docintel deployment"

# note APP_PORT=80 is only meaningful for webapp, I was being lazy
template1=static/docintel_apps.yaml.template
template2=static/docintel_webapp.yaml.template
target=deploy/docintel_apps.yaml
repo=$(cat ,REPO)

cat $template1 | REPOSITORY=$repo APP=document-analyzer APP_NAME=doc-analyzer TAG=${docker_tag} envsubst > $target
cat $template1 | REPOSITORY=$repo APP=document-indexer APP_NAME=doc-indexer TAG=${docker_tag} envsubst >> $target
cat $template1 | REPOSITORY=$repo APP=importer APP_NAME=importer TAG=${docker_tag} envsubst >> $target
cat $template1 | REPOSITORY=$repo APP=newsletter APP_NAME=newsletter TAG=${docker_tag} envsubst >> $target
cat $template1 | REPOSITORY=$repo APP=scraper APP_NAME=scraper TAG=${docker_tag} envsubst >> $target
cat $template1 | REPOSITORY=$repo APP=source-indexer APP_NAME=src-indexer TAG=${docker_tag} envsubst >> $target
cat $template1 | REPOSITORY=$repo APP=tag-indexer APP_NAME=tag-indexer TAG=${docker_tag} envsubst >> $target
cat $template1 | REPOSITORY=$repo APP=thumbnailer APP_NAME=thumbnailer TAG=${docker_tag} envsubst >> $target
cat $template2 | REPOSITORY=$repo APP=webapp APP_NAME=webapp APP_PORT=80 TAG=${docker_tag} envsubst >> $target

echo ""
echo "=== DEPLOY APPLICATIONS"


kubectl apply -f deploy/docintel_pvc.yaml
kubectl apply -f deploy/docintel_apps.yaml
kubectl apply -f deploy/docintel_service.yaml

echo ""
echo "=== WAIT FOR ROLLOUT"

kubectl -n docintel rollout status deploy doc-analyzer
kubectl -n docintel rollout status deploy doc-indexer
kubectl -n docintel rollout status deploy importer
kubectl -n docintel rollout status deploy newsletter
kubectl -n docintel rollout status deploy scraper
kubectl -n docintel rollout status deploy src-indexer
kubectl -n docintel rollout status deploy tag-indexer
kubectl -n docintel rollout status deploy thumbnailer
kubectl -n docintel rollout status deploy webapp

echo ""
echo "=== CONFIGURE ADMIN"

kubectl -n docintel exec -it deploy/webapp -- dotnet /cli/DocIntel.AdminConsole.dll user add --username admin --password Docintel-4me
kubectl -n docintel exec -it deploy/webapp -- dotnet /cli/DocIntel.AdminConsole.dll user role --username admin --role administrator


echo ""
echo "=== DONE"
