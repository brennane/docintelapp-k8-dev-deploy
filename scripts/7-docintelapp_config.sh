echo ""
echo "=== CONFIGURE ADMIN"

if ! [ -f ,ADMIN_PW ] ; then
    echo "$(LANG=C < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-9}; echo)-4x" > ,ADMIN_PW
fi

kubectl -n docintel exec -it deploy/webapp -- dotnet /cli/DocIntel.AdminConsole.dll user add --username admin --password "$(cat ,ADMIN_PW)"
kubectl -n docintel exec -it deploy/webapp -- dotnet /cli/DocIntel.AdminConsole.dll user role --username admin --role administrator

echo ""
echo "=== DONE"
