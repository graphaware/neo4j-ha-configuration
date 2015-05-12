Neo4j HA cluster configuration (example)
====================

HA cluster
---------------------

3x neo4j server  
1x neo4j arbiter  
1x HAproxy  

###Neo4j configuration
- online backups disabled
- auth to access disabled

###HAproxy configuration

Configuration is optimized for reads and writes. All HTTP state-changing operation (POST, PUT, DELETE) are redirected to master and read (GET) operation to slaves.

####Transactional Cypher HTTP endpoint

Redirection of read and writes will not work for Cypher HTTP endpoint, because it's using POST method for all Cypher statements (reads and writes).


create.sh
---------------------

Script which will install Neo4j cluster on your local machine for the purpose of testing.