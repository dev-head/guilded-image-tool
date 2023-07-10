Docker Image for: [PHP]::[7.2]::[apache]::[ubuntu]
====================================================

Description
-----------
Image used for hosting a php web service. 
NOTE: Image uses AWS Memcached module to allow for their cluster discovery client. (https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/Appendix.PHPAutoDiscoverySetup.html)

* [Image](555555555555.dkr.ecr.us-east-1.amazonaws.com/examplecom-php7.2-apache:ubuntu-16.04)


Docker Environment Variables 
----------------------------
| Variable  | Required  | Default       |
| --------- | --------- | ------------- | 

Build :: Local 
--------------
```commandline
packer build -only=local -var-file docker/php/php7.2+apache+ubuntu-16.04/config.json \
    docker/php/php7.2+apache+ubuntu-16.04/docker-build.json 

```

Test :: Local
-------------
```commandline
docker run -d --rm --publish 82:80 examplecom-php7.2-apache:ubuntu-16.04
```

Build :: ECR
------------
```commandline
packer build -only=ecr -var-file docker/php/php7.2+apache+ubuntu-16.04/config.json -var-file config/example.json \
    -var-file config/local.json -var 'provisioned_version=0.0.1' \
    docker/php/php7.2+apache+ubuntu-16.04/docker-build.json
```

Test :: ECR 
-----------
```commandline
cd docker/php/php7.2+apache+ubuntu-16.04
docker build -t packer:test-php7.2-apache-ubuntu -f Dockerfile .
docker run -d --rm packer:test-php7.2-apachew-ubuntu
```