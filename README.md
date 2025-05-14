# Infrastructure Coding Challenge (DockerHub stats exporter)

This challenge includes a test framework that:

- allows the candidates to spend less time on setting up the environment for the app
- allows both the candidates and the evaluators to check if the submitted solution works as expected

# File Structure

## settings.sh

A candidate needs to place the language of their choice as well as their name, for the test
framework to work.

## Makefile

The main entry point to invoke different commands from the test framework:

- **make build**: Builds the app and pushes the docker image to local _kind_ registry
- **make check**: Checks all required tools are installed
- **make create**: Creates local kind cluster
- **make deploy**: Deploys the app
- **make full-test**: Runs the full testing suite
- **make help**: This help
- **make lint**: Runs linters, check missing TODOs
- **make teardown**: Destroys local kind cluster and registry
- **make test**: Runs basic tests to check that the app works (in the kind cluster)
- **make test-local**: Runs basic tests to check that the app works (non-dockerized)
- **make run**: Runs the app locally (non-dockerized)

A candidate does not need to touch this file.

## Feedback.md

A document for the candidates to leave us feedback.

## app-*

These are the directories where a candidate needs to place the code for their app 
(based on the language of their choice.)

## k8s-resources

Includes Kubernetes manifests for the app.

A candidate needs to place the manifests for deploying their app in the `app.yml` file.

## Scripts

Auxiliary scripts used by the `make` targets.

A candidate does not need to touch those.
A candidate normally does not need to run these directly.

- **_library.sh**: Library of the most-used reusable functions of the test framework
- **build-push-app.sh**: Builds the app Docker image and pushes it to the registry of the test cluster
- **check-installed-tools.sh**: Checks that the required utilities for the challenge are installed (e.g. Docker)
- **check-todos.sh**: Checks that the TODOs are fixed by the candidate
- **codestyle.sh**: Runs a linter for the app code
- **create-kind-cluster.sh**: Creates a test kind cluster with the name from `settings.sh`
- **delete-kind-cluster.sh**: Deletes a test kind cluster and its registry
- **deploy-app.sh**: Deploys the app app in the test cluster
- **parselog.sh**: Parses test log and outputs various stats on it
- **test-app.sh**: Tests the app behavior for different process creation rates.
