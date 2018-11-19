
## My Drupal 8 docker image

This is a custom drupal 8 image that i use as my drupal 8 developpement environment.

Image arguments are available in the Dockerfile .

---
  

## Main Tools

* Apache2

* Php 7.2

* MariaDb

* Drush 8.1.16

* Composer

* Php-My-Admin

* Memcached

* Git

* mailcatcher

* Basic Utilities (curl,wget,ruby,nodejs...)

## Instructions

On the the docker-compose.yml you can bind a volume to the web root directory by using the commented line or by using -v in the running step ..

- Build Image :

docker-compose build

- Run :

docker-compose run --service-ports drupal_server

optional to mount a volume :

docker-compose run --service-ports -v ~/Documents/elsan: /home/www.vactory8.ma/public_html drupal_server

- [Docker commands sheet](https://groupe-sii.github.io/cheat-sheets/docker/index.html)

---

## STATUS

v1.0.0

---

## Links

- Phpmyadmin: http://localhost/phpmyadmin/
- Web site : http://localhost
- Mailcatcher http://localhost:1081

---

## Contributors

- Hasbi Hamza : <hamza.hasbi@gmail.com> or <h.hasbi@void.fr>

---

## LICENSE

Licenced under the [MIT LICENCE](LICENSE)
