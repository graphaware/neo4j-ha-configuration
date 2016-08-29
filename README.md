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


neo4j-install-ubuntu.sh
-----------------------

Script which will install a Neo4j cluster on your local machine for the purpose of testing. You must supply the Neo4j version number, e.g. `./neo4j-install-ubuntu.sh 2.3.6`

The above example will install a Neo4j cluster in `~/neo4j-ha/2.3.6` and create 2 scripts in the install folder, `start-cluster` and `stop-cluster`, which do exactly what they say.

You can install multiple versions of Neo4j Enterprise, but only one cluster can be running at any one time.

The individual instances in the cluster are available on ports 7474, 7484 and 7494, and are open to the entire network, so you can access them remotely.

haproxy-install-ubuntu.sh
-------------------------

Script which will install, configure and start an HAProxy server as a front-end to the Neo4j cluster. You should start the Neo4j Enterprise cluster before running this script, or the HAProxy service will fail to start.

Note: Depending on how out of date your ubuntu distribution is, the install can take some time as it will upgrade your distribution to ensure all the latest packages are installed.

The HAProxy server serves Http requests on port 8088. You can stop/start/restart it using the standard service commands, e.g. `sudo service haproxy restart`. The admin port is 8080.



