# Repo for updating private Matomo docker images

This repo is for customizing your docker images of Matomo and pushed to your private registry.

Created from examples in the official [matomo-org/docker](https://github.com/matomo-org/docker) repo.

The finished image is roughly about 200-400MB, depending on if you need custom files. So make sure your registry has the capacity to upload and host such large files.
E.g nginx conf:
```
client_max_body_size 400M;
```

## How to use

Clone down repo
```
git clone git@github.com:jorgeuos/matomo-docker.git
cd matomo-docker
```

Copy and edit the `envars-sample.conf` file.

```
cp envars-sample.conf envars.conf
```

The reason why I use `envars.conf` is just because historically Docker ignores `.` files when copied into containers. Read this thread on StackOverflow, [extarnal link](https://stackoverflow.com/a/57837565/2272319).

## Modify to your needs

E.g. if you have a premium license, you need to uncomment:
```
# && ./premium-plugins.sh \
```

Or if you have custom files you want copied into your Matomo,
```
cp custom-script-example.sh custom-script.sh
```

And uncomment and change the `custom-script.sh` file.
```
&& ./custom-script.sh \
```


## Build and tag image


Build to check that everything works.
```
docker build . -t jorgeuos/matomo:4.13.0
```
Or whatever you want to name your image...

Tag and push image to your private registry:
```
docker image tag jorgeuos/matomo:4.13.0 your.registry.com/jorgeuos/matomo:4.13.0
```

Done!

