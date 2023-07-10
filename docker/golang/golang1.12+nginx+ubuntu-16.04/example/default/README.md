Example [Default] :: [golang]
=============================

Description
-----------
This is an example of a go server running `http`, `fcgi_tcp`, and `fcgi_unix_socket`. This is to show the three reverse proxy types that golang supports. There are two docker files used here to test against the local image, used for testing before going to ECR; the ECR Dockerfile is used to run tests against the production image.  

### Working Directory
```commandline
cd docker/golang/golang1.12+nginx+ubuntu-16.04/example/default
```

#### Build Local Example Image 
```commandline
docker build -t packer-local:test-golang1.2-nginx-ubuntu -f Dockerfile .
```

#### Build ECR Example Image 
```commandline
docker build -t packer-ecr:test-golang1.2-nginx-ubuntu -f Dockerfile.ecr .
```

#### Run The Built Example Image (Background)
```commandline
docker run -d --rm --name "example-default" packer-local:test-golang1.2-nginx-ubuntu
docker logs -f example-default
docker stop example-default
```

#### Tests 
```commandline
docker exec -it example-default curl -sI http://127.0.0.1:8000/
docker exec -it example-default curl -sI http://127.0.0.1:8001/
docker exec -it example-default curl -sI http://127.0.0.1:8002/
```
