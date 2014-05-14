#docker-wordpress

## initial setup

Connect to your server and execute the following commands:

```text
sudo apt-get -q update
sudo apt-get install -y --force-yes --no-install-recommends puppet git
git clone https://github.com/rstiller/docker-wordpress.git
cd docker-wordpress
sudo puppet apply --modulepath=modules setup.pp
docker pull rstiller/wordpress
```

## add a new blog

Each new customer needs to have

* a domain
* a port number

```text
sudo add-blog.sh www.domain.com 5000
```

To start the actual container type the following command:

```text
/containers/www_domain_com/run.sh
```

The new blog is now available.
