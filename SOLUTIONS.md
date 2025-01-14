### Challenge 1. The API returns a list instead of an object

> As you can see, the API returns a list in the two exposed endpoints:
> 
> - `/api/v1/restaurant`: Returns a list containing all the restaurants.
> - `/api/v1/restaurant/{id}`: Returns a list with a single restaurant that match the `id` path parameter.
> 
> We want to fix the second endpoint. Return a json object instead of a json array if there is a match or a http 204 status code if no match found.

To fix the second endpoint, the `find_restaurants` function in [mongoflask.py](./src/mongoflask.py) needs to be modified to return a single restaurant object instead of a JSON array when provided with an `_id` parameter.

After this modification, the `restaurant` function in [app.py](./app.py) can be updated to verify if a restaurant object is returned from `find_restaurants`. If a restaurant object is found, it is returned as a JSON response using Flask's `jsonify` function. If no restaurant object is found, a 204 status code (No Content) is returned to indicate that the request was successful, but no data is available.

To handle the edge case where an invalid `ObjectId` is passed to the `/api/v1/restaurant/{id}` endpoint, the `restaurant` function is amended to catch the `InvalidId` exception raised by the `ObjectId` constructor. If an `InvalidId` exception is caught, it returns a 204 status code (No Content) to indicate that the request was successful, but the provided ID is invalid and no data can be retrieved.

### Challenge 2. Test the application in any cicd system

> As a good devops engineer, you know the advantages of running tasks in an automated way. There are some cicd systems that can be used to make it happen.
> Choose one, travis-ci, gitlab-ci, circleci... whatever you want. Give us a successful pipeline.

The GitHub Actions [workflow](./.github/workflows/python-app.yml) builds and tests our Python application on Ubuntu with Python 3.9, 3.10, and 3.11. It runs on a push event to the master branch when any `.py` file is modified. The job checks out the code, sets up Python, installs dependencies, lints with ruff, and tests with tox.

### Challenge 3. Dockerize the APP

> What about containers? As this moment *(2018)*, containers are a standard in order to deploy applications *(cloud or in on-premise systems)*. So the challenge is to build the smaller image you can. Write a good Dockerfile :)

The [Dockerfile-app](./Dockerfile-app) containerizes our Python application, using a multi-stage build process to create a smaller and more secure image.

During the first stage, dependencies are installed and binary wheel files are created for them. The second stage installs these dependencies from the binary wheel files, copies the source files, exposes port 8080, and sets the command to run the app. In order to improve the image security, the app runs using a non-root user.

As a result of this optimization, the image size has been reduced by 92.5%, compared to a single-stage build:

```shell
$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
app          v2        361cd22a8d14   7 minutes ago   69.7MB
app          v1        5a23eb32f952   5 hours ago     930MB
```

### Challenge 4. Dockerize the database

> We need to have a mongodb database to make this application run. So, we need a mongodb container with some data. Please, use the [restaurant](./data/restaurant.json) dataset to load the mongodb collection before running the application.
> 
> The loaded mongodb collection must be named: `restaurant`. Do you have to write code or just write a Docker file?

[Dockerfile-mongo](./Dockerfile-mongo) serves to create a MongoDB Docker image. It copies the dataset file [restaurant.json](./data/restaurant.json) and a script file [import-data.sh](./data/import-data.sh) into the container, and then switches to a non-root user and group (mongodb) to ensure better security and avoid potential security vulnerabilities.

The official [mongo](https://hub.docker.com/_/mongo) container image provides the `/docker-entrypoint-initdb.d` path. When the container is launched for the first time, any files with the `.sh` or `.js` extension in this directory are executed. Therefore, by placing our [import-data.sh](./data/import-data.sh) script in this directory, we can ensure that our dataset is imported at initialization time.

### Challenge 5. Docker Compose it

> Once you've got dockerized all the API components *(python app and database)*, you are ready to make a docker-compose file.
> **KISS**.

The [docker-compose.yml](./docker-compose.yml) file is written in version 3.9 and defines two services:

- `mongo`: Built using the [Dockerfile-mongo](./Dockerfile-mongo) file. It maps the `./data` directory to the `/data/db` directory within the container using volumes. It exposes the port 27017i (MongoDB default port).

- `app`: Built using the [Dockerfile-app](./Dockerfile-app) file. It sets the `MONGO_URI` environment variable, enabling `app` to connect to the `mongo` database. Additionally, it exposes the port 8080, and the `depends_on` parameter is set to `mongo`, indicating that the `app` service depends on the `mongo` service.

### Final Challenge. Deploy it on kubernetes

> If you are a container hero, an excellent devops... We want to see your expertise. Use a kubernetes system to deploy the `API`. We recommend you to use tools like [minikube](https://kubernetes.io/docs/setup/minikube/) or [microk8s](https://microk8s.io/).
> Write the deployment file *(yaml file)* used to deploy your `API` *(python app and mongodb)*.

These files are shell scripts and Kubernetes manifests files that can be used to create a local Kubernetes cluster using `kind`, as well as deploy the Python app and MongoDB instance:

- [init.sh](./k8s/init.sh): This script checks if `kind` is installed and installs it if it isn't. It then creates a local Kubernetes cluster using the [kind-config.yml](./k8s/kind-config.yml) file, retrieves the kubeconfig, and applies the Kubernetes manifests found in the [manifests/](./k8s/manifests/) directory. The Kubernetes manifests define a deployment, service, and ingress for the app, and a deployment and service for the MongoDB instance.
- [clean.sh](./k8s/clean.sh): This script checks if a kind cluster and kind binary exist, and deletes them if they do. It is intended for cleaning your environment after running [init.sh](./k8s/init.sh).

> Note that after applying the manifests, it may take some time for the Ingress to fully deploy and become functional. You can check the status of the Ingress by running the command `kubectl get ingress app`.

You can access the API using the following paths:

- `curl localhost/api/v1/restaurant` to retrieve a list containing all the restaurants.
- `curl localhost/api/v1/restaurant/{id}` to retrieve a specific restaurant that matches its `id`.
