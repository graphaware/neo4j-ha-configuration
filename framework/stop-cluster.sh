# ===============================================================================================
#  starts the specified cluster, and tails the log files
# ===============================================================================================

if [[ $1 ]]
then
   pushd $HOME/neo4j-ha/$1
   ./stop-cluster.sh
   tail -f neo4j-1/data/log/console.log neo4j-2/data/log/console.log neo4j-3/data/log/console.log
   popd
else
   echo "Please supply the cluster identity, e.g. 2.3.3"
fi
