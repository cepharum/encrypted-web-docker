# Docker Web Service Template

This template helps with setting up web application supporting encrypted requests via HTTPS. It is inspired by a [similar tutorial](https://devsidestory.com/lets-encrypt-with-docker/) but tries to incorporate additional features.

Consider this template a starting point for running your application's container on a production server. It isn't meant for use while developing the application except in preparing deployment e.g. using staging environment.

## Structure

This template consists of three containers to be run:

* First there is the container with your **app**. It is exposing service on port 80 for processing unencrypted HTTP requests. This container isn't publicly accessible. Instead there is a different container passing along incoming requests.

* This second container is called **proxy**. By default it is exposing ports 80 and 443 forwarding incoming requests on either port to the port 80 exposed by **app** container. In addition it is handling particular requests itself. Those requests are involved in validating your domain for issuing the certificate. The actual process of fetching certificate is put in a separate container, though.

* The third container isn't exposing any port for processing incoming requests but contains the code for interacting with LetsEncrypt service triggering the validation of your domain and fetching the issued certificate on success.

The first two containers are essential for running the service. The third one gets run once on setting up the service and later again to renew the certificate from time to time. It is meant to run on demand, only. 

The latter two containers share volumes for commonly accessing files involved in validating domain and in issuing or renewing the certificate as well as using it for handling encrypted requests via HTTPS.

## Usage

### Configuration

Copy file **.env.dist** to **.env** and open the latter in text editor for configuration. Adjust the variables as desired.

#### DOMAIN

This variable is naming sole domain the certificate for running HTTPS will be issued for. Make sure the selected domain is actually addressing the host running this service.

#### APPLICATION

This is the name of a docker image describing the web application exposing access on port 80. Put the name of your desired application's image here.

### Initialize

> **Note:** All commands using docker-compose are assumed to be called from root folder of this project. This way it's running in scope of provided docker-compose.yml file. You might choose different file using option `-f <filename>` of docker-compose.

On initially setting up the service you need to fetch a certificate so requests via HTTPS become available. This requires to start the proxy for it is involved in answering requests from LetsEncrypt service on validating the selected domain. The proxy basically supports handling encrypted requests but requires valid certificate for doing that. This circular dependency isn't solved by injecting self-signed certificate. Instead you can disable proxy's support for encrypted requests on demand:

```
NOSSL=1 docker-compose up -d proxy
```

Setting environment variable `NOSSL` to a non-empty string results in container **proxy** starting with support for unencrypted requests on port 80, only. The option `-d` puts the running container in to background so you can manually start the certbot client in **letsencrypt** container triggering issue of certificate:

```
docker-compose run --rm letsencrypt initialize
```

Make sure this command exits on success.

Now stop the proxy for currently running without HTTPS support:

```
docker-compose down
```

Due to having a certificate now the whole service can be started eventually:

```
docker-compose up -d
```

Try accessing your web service using non-encrypted request addressing the selected domain, e.g. http://my.example.com/some/path. This will redirect to encrypted request using URL https://my.example.com/some/path without showing warning regarding invalid certificate in modern browsers.

### Renew Certificate

Any issued certificate is valid for a term of 90 days, only. You therefore need to renew it more frequently than commercially available certificates. This requirement is improving security of web for keeping certificates fresh. It is no paing due to supporting automatic renewal by running the following command once a day using **cron** or similar:

```
cd /path/to/the/project && docker-compose run --rm letsencrypt renew && docker-compose kill -s SIGHUP proxy
```

Make sure the command is switching to the root folder of this project or inject explicit selection of docker-compose.yml file using option `-f` of docker-compose.

## License

MIT
