search_target=${1:-ERROR}
context_lines="${NUM_CONTEXT_LINES:-3}"

echo ""
echo "Searching current processes"

for what in $(kubectl -n docintel get deploy -ojsonpath='{.items[*].metadata.labels.app}'); do
    echo ""
    echo "${what}: ..."
    kubectl -n docintel logs deploy/${what} | grep -C ${context_lines} $search_target 
done

echo ""
echo "Searching preveious processes"

for what in $(kubectl -n docintel get deploy -ojsonpath='{.items[*].metadata.labels.app}'); do
    echo ""
    echo "${what}: ..."
    kubectl -n docintel logs deploy/${what} -p | grep -C $search_target
done
