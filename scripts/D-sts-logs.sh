search_target=${1:-ERROR}
context_lines="${NUM_CONTEXT_LINES:-3}"

echo ""
echo "Searching current processes"

for what in $(kubectl -n docintel get pods \
    -o jsonpath='{.items[*].metadata.labels.statefulset\.kubernetes\.io/pod-name}');
do
    echo ""
    echo "${what}: ..."
    kubectl -n docintel logs pods/${what} | grep -C ${context_lines} $search_target 
done

echo ""
echo "Searching previous processes"

for what in $(kubectl -n docintel get pods \
    -o jsonpath='{.items[*].metadata.labels.statefulset\.kubernetes\.io/pod-name}');
do
    echo ""
    echo "${what}: ..."
    kubectl -n docintel logs pods/${what} -p 2> /dev/null | grep -C ${context_lines} $search_target 
done

