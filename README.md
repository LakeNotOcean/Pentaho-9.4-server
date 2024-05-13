# Pentaho 9.4 Docker Image

## BUILD Image

```
docker build -t docker-pentaho:9.4.0.0-343 .
```

## Run Pentaho Server

```
docker-compose up -d
```

## Possible problems

- The libraries for the image could not be loaded. In this case, you need to update the links in the Dockerfile.
- Sometimes the service may start with an error. In this case, you should delete all containers and **volumes**.
