#!/usr/local/bin/python

import yaml

with open("../docker-images.yml", 'r') as stream:
    try:
        print(yaml.load(stream))
    except yaml.YAMLError as exc:
        print(exc)