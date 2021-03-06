# edx2bigquery-docker

## About

Installing and using [edx2bigquery](https://github.com/mitodl/edx2bigquery) with Docker. 

### edx2bigquery
edx2bigquery is a tool for importing edX SQL and log data into Google BigQuery for research and analysis. Learn more about edx2bigquery at:
* GitHub repo: https://github.com/mitodl/edx2bigquery
* [Writeup](https://vpal.harvard.edu/blog/demystifying-educational-mooc-data-using-google-bigquery-person-course-dataset-part-1) by Harvard VPAL
* "[Google BigQuery for Education: Framework for Parsing and Analyzing edX MOOC Data](http://dl.acm.org/citation.cfm?doid=3051457.3053980)", by Glenn Lopez, Daniel Seaton, Andrew Ang, Dustin Tingley, and Isaac Chuang.


### Why docker?
edx2bigquery has many dependencies, and installing them doesn't always go smoothly depending on the machine settings, python environment, etc. Docker makes this process quicker, and more reproducible.

### Contents
The `Dockerfile` in this repo specifies the edx2bigquery image build instructions, which uses [google/cloud-sdk image](https://hub.docker.com/r/google/cloud-sdk/) is used as a base image. Users can build the edx2bigquery image from the provided Dockerfile, or download the pre-built image from DockerHub at [harvardvpal/edx2bigquery](https://hub.docker.com/r/harvardvpal/edx2bigquery). The `edx_data` directory is intended for keeping edx2bigquery settings and data files, that can be used in the container after mounting the folder to the `/edx_data` container directory. (A different host directory mapping can be used, just change the run commands provided in the Getting Started guide accordingly.)

## Getting Started

The following steps walk the user through building the edx2bigquery image, mounting the `edx_data` directory as a container volume, and config/use of edx2bigquery via Docker.

### System requirements
Install the following if not already on your system:
* Docker: https://www.docker.com/community-edition
* git: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

### Get edx2bigquery Docker image

Download this repository, and change directories into the created folder.
```
git clone https://github.com/harvard-vpal/edx2bigquery-docker
cd edx2bigquery-docker
```

Build the image from the Dockerfile:
```
docker build . -t edx2bigquery
```

#### Create Docker container with data volumes
We'll need to designate a folder on our computer that will contain files that we want the Docker container to have access to (e.g. credential files, raw data).

Use the following command to mount the `edx_data/` folder in the current directory to the `/edx_data` directory in the container, and to create a named container for persisting authentication credentials.

```
docker run \
  --mount source="$(pwd)"/edx_data,destination=/edx_data,type=bind \
  --name gcloud-config \
  edx2bigquery
```

### edx2bigquery Configuration:
As with a normal edx2bigquery installation, set up the Google Cloud resources and credentials, edX data packages, and update the edx2bigquery configuration file.

#### Google Cloud resources
In the [google cloud console](https://console.cloud.google.com):
* Create new Google Cloud project
* Create service account
    - Save keyfile in mounted folder (i.e. `edx_data/`)
* Enable youtube API
* Create new gcloud bucket

#### Set up folder with edX data:
Example folder structure:
* `edx_data/`
    - `RAW_SQL/` - (contains raw sql data)
    - `LOGS/` - (contains raw log data)
    - `SQL/` - (empty, processed data will be placed here)
    - `edx2bigquery_config.py` - settings file

#### Update edx2bigquery config file
In the `edx_data/` folder, copy and rename the `edx2bigquery_config.py.template` file to `edx2bigquery_config.py`, and populate the required edx2bigquery settings.

### Authenticate container with google cloud
Run container with volume mounts configured:
```
docker run -it --volumes-from gcloud-config edx2bigquery
```

This gives you an interactive shell inside the container. 

Authenticate and set up project config with the following commands, replacing $KEYFILE, $PROJECT_ID, and $SERVICE_ACCOUNT_ID with appropriate values
```
gcloud auth activate-service-account --key-file $KEYFILE
gcloud config set project $PROJECT_ID
gcloud config set account $SERVICE_ACCOUNT_ID
```

For example:
```
gcloud auth activate-service-account --key-file edx2bigquery-1f07bcd33b85.json
gcloud config set project edx2bigquery-183418
gcloud config set account service-account@edx2bigquery-183418.iam.gserviceaccount.com
```

Once you authenticate successfully, credentials and project settings are preserved in the volume of
the gcloud-config container.

### Run edx2bigquery
If you are not already inside the configured container, use:
```
docker run -it --volumes-from gcloud-config edx2bigquery
```

Now you can run edx2bigquery commands like:
```
edx2bigquery --clist all_courses waldofy RAW_SQL/folder
edx2bigquery --clist all_courses setup_sql
```
