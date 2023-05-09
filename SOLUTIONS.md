### Challenge 1. The API returns a list instead of an object

> As you can see, the API returns a list in the two exposed endpoints:
> 
> - `/api/v1/restaurant`: Returns a list containing all the restaurants.
> - `/api/v1/restaurant/{id}`: Returns a list with a single restaurant that match the `id` path parameter.
> 
> We want to fix the second endpoint. Return a json object instead of a json array if there is a match or a http 204 status code if no match found.

To fix the second endpoint, we need to modify the `find_restaurants` function so that it returns a single restaurant object instead of a JSON array when given an `_id` parameter.

After that, we can modify the `restaurant` function to check if a restaurant object was returned from `find_restaurants`. If a restaurant object is found, we can return it as a JSON response using Flask's `jsonify` function. If no restaurant object is found, we can return a 204 status code (No Content) to indicate that the request was successful, but there is no data to return.

To handle the edge case where an invalid `ObjectId` is passed to the `/api/v1/restaurant/{id}` endpoint, we can modify the `restaurant` function to catch the `InvalidId` exception raised by the `ObjectId` constructor. If an `InvalidId` exception is caught, we can return a 204 No Content status code to indicate that the request was successful, but the provided ID is invalid and no data can be returned.

### Challenge 2. Test the application in any cicd system

> As a good devops engineer, you know the advantages of running tasks in an automated way. There are some cicd systems that can be used to make it happen.
> Choose one, travis-ci, gitlab-ci, circleci... whatever you want. Give us a successful pipeline.

The GitHub Actions workflow builds and tests our Python application on Ubuntu with Python 3.9, 3.10, and 3.11. It runs on a push event to the master branch when any ".py" file is modified. The job checks out the code, sets up Python, installs dependencies, lints with ruff, and tests with tox.

### Challenge 3. Dockerize the APP

> What about containers? As this moment *(2018)*, containers are a standard in order to deploy applications *(cloud or in on-premise systems)*. So the challenge is to build the smaller image you can. Write a good Dockerfile :)

The `Dockerfile-app` containerizes our Python application, using a multi-stage build process to create a smaller and more secure image.

During the first stage, dependencies are installed and binary wheel files are created for them. The second stage installs these dependencies from the binary wheel files, copies the source files, exposes port 8080, and sets the command to run the app. In order to improve the image security, the app runs using a non-root user.

As a result of this optimization, the image size has been reduced by 92.5%, compared to a single-stage build:

```shell
$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
app          v2        361cd22a8d14   7 minutes ago   69.7MB
app          v1        5a23eb32f952   5 hours ago     930MB
```

