#docker-wordpress

## initial setup

Connect to your server and execute the following commands:

```text
sudo apt-get update
sudo apt-get install -y puppet git
git clone https://github.com/rstiller/docker-wordpress.git
cd docker-wordpress
sudo puppet apply --modulepath=modules setup.pp
docker pull ubuntu
docker pull rstiller/wordpress
```

## add a new customer

Each new customer needs to have

* a domain
* a unique name
* a ssh port number
* a http port number

To start the actual container type the following command:

```text
docker run -p 127.0.0.1:<http_port>:80 -p <ssh_port>:22 -name="<customer_name>" -i -d -t rstiller/wordpress /start.sh
```

Now that the container is launched, the haproxy config (`/etc/haproxy/haproxy.cfg`) needs to be updated:

```text
frontend http_proxy
    bind :80,:443
    log global
    acl <customer_name> hdr_dom(host) -i <customer_domain>
    use_backend <customer_name>_cluster if <customer_name>
    acl customer2 hdr_dom(host) -i www.my-blog.com
    use_backend customer2_cluster if customer2

backend <customer_name>_cluster
    server server1 127.0.0.1:<customer_port> check

backend customer2_cluster
    server server1 127.0.0.1:54321 check
```

After the config was updated, restart haproxy with the following command:

```text
sudo service haproxy restart
```

The customer's website should now be available.
The CName of the domain-owner need to point to your server's IP address.
Usually the domain provider offers a web-interface where you can set the
IP address your domain is pointing to.

## remove a customer

To disable a customer you need to execute the following command:

```text
docker stop <customer_name>
```

## export a customer's data

To export the wordpress instance with all data (including MySQL dump) execute the following command:

```text
docker export <customer_name> > <customer_name>.tar
```

The resulting tar file includes MySQL and all data, PHP5, Apache2, Wordpress + Themes and all customizations.

## import an image

To import an image from an existing customer execute the following command:

```text
cat <customer_name>.tar | docker import - <customer_name>
```

Imported images need to be started with the following command:

```text
docker run -p 127.0.0.1:<http_port>:80 -p <ssh_port>:22 -name="<customer_name>" -i -d -t <customer_name> /start.sh
```
