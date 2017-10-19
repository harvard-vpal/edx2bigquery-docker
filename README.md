# edx2bigquery-docker

Test for running edx2bigquery with Docker

## Docker command notes

```
# build image
docker build . -t edx2bigquery


# initial setup: set up container with mounted volumes
# mounts edx_data folder, config file, and a named volume for persisting authentication creds
docker run \
  --mount source="$(pwd)"/edx2bigquery_config.py,destination=/edx2bigquery/edx2bigquery_config.py,type=bind \
  --mount source="$(pwd)"/edx_data,destination=/edx_data,type=bind \
  --name gcloud-config \
  edx2bigquery


# run container with volume mounts configured (interactive shell)
docker run \
  -it \
  --volumes-from gcloud-config \
  edx2bigquery bash


# authenticate and set up project config inside container
gcloud auth activate-service-account --key-file edx_data/edx2bigquery-keyfile.json
gcloud config set project edx2bigquery-keyfile
gcloud config set account edx2bigquery@edx2bigquery-keyfile.iam.gserviceaccount.com

```

