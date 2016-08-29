sudo add-apt-repository ppa:vbernat/haproxy-1.5
sudo apt-get update
sudo apt-get dist-upgrade

sudo apt-get install haproxy

sudo mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.backup

sudo cp ./haproxy.cfg /etc/haproxy/

sudo service haproxy start
