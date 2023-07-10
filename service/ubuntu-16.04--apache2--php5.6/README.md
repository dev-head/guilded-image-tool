Ubuntu 16.04::Apache2::PHP5.6
=============================
> ubuntu-16.04--apache2--php5.6

```
aws ec2 describe-images --owners 099720109477 \
  --filters \
    "Name=is-public,Values=true" \
    "Name=architecture,Values=x86_64" \
    "Name=root-device-type,Values=ebs" \
    "Name=name,Values=ubuntu/images/hvm-*/ubuntu-*16.04*" \
    "Name=state,Values=available"
```


Build / Test Locally
--------------------
```commandline
packer build -only=local -var-file service/ubuntu-16.04--apache2--php5.6/v0.0.1/config.example.json \
    -var 'provision_version=0.0.1' ubuntu-16.04--apache2--php5.6/v0.0.1/packer-template.json

docker run \
  -it --rm --privileged=true \
  --entrypoint /bin/bash \
  exco/ubuntu-16.04--apache2--php5.6:16.04-0.0.1
```

 Build AWS [example] 
-------------------
> Ensure you are on VPN or ssh provisioner won't work.
```commandline
packer build -only=prod -var-file service/ubuntu-16.04--apache2--php5.6/v0.0.1/config.example.json \
    -var 'provision_version=0.0.1' service/ubuntu-16.04--apache2--php5.6/v0.0.1/packer-template.json
```
