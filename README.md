#docker-wordpress

## initial setup

Connect to your server and copy the file `setup.pp` as well as the `modules` folder.

```text
sudo apt-get install -y puppet
sudo puppet apply --modulepath=modules setup.pp
docker pull ubuntu
docker pull rstiller/wordpress
```

## architecture



## add a new customer

## remove a customer

## export a customer's image
