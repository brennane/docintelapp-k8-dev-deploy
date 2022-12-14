echo ""
echo "=== CONFIGURE ADMIN"

kubectl -n docintel exec -it deploy/webapp -- dotnet /cli/DocIntel.AdminConsole.dll user add --username admin --password Docintel-4me
kubectl -n docintel exec -it deploy/webapp -- dotnet /cli/DocIntel.AdminConsole.dll user role --username admin --role administrator

echo ""
echo "=== DONE"
