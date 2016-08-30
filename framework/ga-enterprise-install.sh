# ==========================================================================================================
# Install GraphAware Enterprise Framework and all modules
#  
# This script will install all the GA framework modules into the specified Neo4j cluster
#
# usage: ga_enterprise_install 2.3.3
#
#     where 2.3.3 represents a cluster installed at ~/neo4j-ha/2.3.3
#
# ==========================================================================================================

NEO4J_RELEASE=$1
GA_RELEASE=${NEO4J_RELEASE:0:1}

PACKAGE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$PACKAGE/modules"
source "$PACKAGE/versions"

# ==========================================================================================================
# Installs node.js if not already installed. Node.js is required to build the enterprise security module
# ==========================================================================================================
function install_node() {
  msg "Installing node.js"
  
  if command -v node >/dev/null 2>&1
  then
      echo "Node is already installed. Skipping..."
  else
      sudo apt-get install build-essential curl git m4 ruby texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev
      # native packages for node and npm are way out of date. Use linux port of homebrew to get up to date versions   
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
      export PATH=$HOME/.linuxbrew/bin:$PATH
      brew update
      brew install node
  fi
}

# ==========================================================================================================
# just some pretty printing
# ==========================================================================================================
function header() {
   echo "=================================================================================================="
}

# ==========================================================================================================
# Downloads the required module from the graphaware downloads page
# ==========================================================================================================
function build_module_from_release() {

   echo "Downloading module $MODULE from release $ARTIFACT"
   wget -q "http://products.graphaware.com/download/$PROJECT/$ARTIFACT.jar"

   mv $ARTIFACT.jar artifacts
   
}

# ==========================================================================================================
# Enterprise modules must be built from source, they are not available to download 
# ==========================================================================================================
function build_module_from_source() {

   echo "Building module $MODULE from project $PROJECT branch $BRANCH"
   if [ ! -d ./$PROJECT ]
   then	
      git clone "git@github.com:graphaware/$PROJECT.git"
   fi
   pushd $PROJECT >/dev/null 2>&1
   git checkout $BRANCH
   git pull
   mvn -q clean package -DskipTests
   popd >/dev/null 2>&1

   mv $PROJECT/target/$ARTIFACT*SNAPSHOT$JARFILE artifacts
	
}

# ==========================================================================================================
# Copies the framework modules to the specified cluster and reinstalls the server configs
# ==========================================================================================================
function deploy() {
  
   msg "Deploying Enterprise framework to cluster..."
   
   INSTALL_DIR="$HOME/neo4j-ha/$NEO4J_RELEASE"
 
   for i in {1..3}
   do
      SERVER=$i
      
      # remove all currently installed plugins
      rm -f $INSTALL_DIR/neo4j-$SERVER/plugins/* 
  
      # copy the new plugins
      cp artifacts/* $INSTALL_DIR/neo4j-$SERVER/plugins

      # module release index (MRI) will be 0 for 2.x, 1 for 3.x
      if (($MRI))
      then
         # installation is 3.x (TODO parent module doesn't support neo4j3 yet)
         cp neo4j-$SERVER.conf $INSTALL_DIR/neo4j-$SERVER/conf/neo4j.conf
      else
         # installation is 2.x
         cp neo4j-server-$SERVER.properties $INSTALL_DIR/neo4j-$SERVER/conf/neo4j-server.properties
      fi
   done

   echo "Deployed. Please restart the cluster"	
}

# ==========================================================================================================
# output this module's config template to server config files (2.x only at the moment)
# ==========================================================================================================
function write_module_config() {
   CONFIG=$MODULE.conf
   for i in {1..3}
   do
     SERVER=$i
     cat ../$CONFIG >> neo4j-server-$SERVER.properties
   done
}

# ==========================================================================================================
# copy the server configs from the parent project and append GA framework header
# ==========================================================================================================
function initialise_config() {

  # only works with 2.x at the moment...
  for i in {1..3}
  do
    SERVER=$i
    cp ../../neo4j-$SERVER/neo4j-server.properties neo4j-server-$SERVER.properties

    echo " " >> neo4j-server-$SERVER.properties
    echo "#=============================================================================" >> neo4j-server-$SERVER.properties
    echo "# GraphAware Enterprise Framework" >> neo4j-server-$SERVER.properties
    echo "#=============================================================================" >> neo4j-server-$SERVER.properties
  done

}

function title() {

   clear
   header
   echo "Installing GraphAware Enterprise framework and GA Modules into cluster $NEO4j_RELEASE"

}

function msg() {
    echo " "
    echo $1
    header
}

# ==========================================================================================================
# The main script starts here
# ==========================================================================================================

function main() {
   
   install_node

   mkdir -p build/artifacts

   pushd build >/dev/null 2>&1

   initialise_config

   rm -f artifacts/*.jar

   for i in "${!MODULES[@]}"
   do
      
      INDEX=$i
      
      if [ ${INCLUDE[$INDEX]} ]
      then

         MODULE="${MODULES[$i]}"
         PROJECT="${PROJECTS[$INDEX]}"
         msg "Include module: $MODULE"
         if [ ${RELEASED[$INDEX]} ]
         then
            ARTIFACT="${RELEASED[$INDEX]}"
            build_module_from_release 
         else
            ARTIFACT="${ARTIFACTS[$INDEX]}"   
            BRANCH="${BRANCHES[$INDEX]}"
            JARFILE="${JARFILES[$INDEX]}"
            build_module_from_source 
         fi
         write_module_config
      fi
   done

   deploy

   popd >/dev/null 2>&1
}

title

if [ $NEO4J_RELEASE ]
then
  main
else
  echo " "
  echo "ERROR: Missing parameter: <neo4j_version>"
  echo " "
  echo "   usage: ga_enterprise_install <neo4j_version>, e.g. 2.3.3"
  echo " "
fi
