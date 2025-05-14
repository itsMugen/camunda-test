# DockerHub Stats Exporter

This application is a FastAPI-based service that exports DockerHub image pull statistics for one or multplie organizations as Prometheus metrics. It is designed to be deployed in a Kubernetes cluster and integrates with Prometheus for monitoring.

---

## Features

- Fetches DockerHub image pull statistics for a specified organization.
- Exposes metrics at the `/metrics` endpoint in Prometheus format.
- Periodically updates metrics every 5 minutes.

---

## Configuration

In the app you can configure two parameters:
   1. **TTL**
      This will impact how fast the data is updated. (The number is expressed in seconds)
   2. **port**
      This is where the app will listen for calls to it's endpoints. (Be sure to pick a port that is not already used)


### Environment Variables

The application requires the following environment variables to be set:

- **`DOCKERHUB_ORGANIZATION`**: The DockerHub organization whose image pull statistics will be fetched. This is mandatory. It can be either a string or a list.

---

## Deployment

### Steps to Deploy

1. **Set Up the Environment**:
   - Update the `settings.sh` file with your name and app language:
     ```bash
     CLUSTER_NAME="your.name"
     APP_LANGUAGE="python"
     ```
   Allowed characters for the CLUSTER_NAME = [a-z\.]

2. **Create the Kubernetes Cluster**:
   ```bash
   make create

3. **Build**:
   ```bash
   make build

4. **Deploy**
   ```bash
   make deploy

5. **Testing**
   The application can be tested locally with(start the application first):
   ```bash
   make test-local
   ```

   To do a full test use:
   ```bash
   make full-test
   ```
   Which will take care of deployment and testing
