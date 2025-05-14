import os
import time
import threading
import logging
from typing import Union
import json
import uvicorn
import requests

from fastapi import FastAPI
from prometheus_client import make_asgi_app, Gauge, CollectorRegistry, Info


reg: CollectorRegistry = CollectorRegistry()

DockerhubOrganization_env = os.getenv("DOCKERHUB_ORGANIZATION")
if not DockerhubOrganization_env:
    raise ValueError("DOCKERHUB_ORGANIZATION environment variable is not set")

try:
    DockerhubOrganization: Union[str, list] = json.loads(DockerhubOrganization_env)
except json.JSONDecodeError:
    DockerhubOrganization = DockerhubOrganization_env

if not isinstance(DockerhubOrganization, (str, list)):
    raise ValueError("DOCKERHUB_ORGANIZATION must be a string or a JSON array")

#Params of the app
TTL: int = 299
PORT: int = 2113

info: Info = Info(
    "Organization_status",
    "Is the data up to date",
    registry=reg,
)

gauge: Gauge = Gauge(
    "docker_image_pulls",
    "The total number of Docker image pulls",
    ["image", "organization"],
    registry=reg,
)

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")


def fetch_docker_image_pulls(organization: str):
    retries: int = 3
    delay: list = [10, 30, 100]
    attempt: int = 0
    # I choose to not use HTTPAdapter to handle the retries in order to be able
    # to show right away that the data is not updated if a request happens
    # during the retry period
    while attempt < retries:
        try:
            data_limits = {"page_size": "25", "page": "1"}
            response = requests.get(
                f"https://hub.docker.com/v2/repositories/{organization}/",
                params=data_limits,
                timeout=10,
            )
            response.raise_for_status()

            data = response.json()
            if data["count"] == 0:
                logging.warning(f"No repositories found for organization: {organization}")
                gauge.labels("None", organization).set(0)

            else:
                for result in data["results"]:
                    image_name = result["name"]
                    pull_count = result["pull_count"]
                    gauge.labels(image_name, organization).set(pull_count)
                    logging.info(f"Updated metric for image: {image_name}, pulls: {pull_count}")

            info.info({f"{organization}": "Updated"})
            return

        except requests.exceptions.RequestException as request_error:
            attempt += 1
            logging.error(
                f"HTTP request error while fetching data for organization '{organization}': {request_error}. "
                f"Retrying {attempt}/{retries}..."
            )
            time.sleep(delay[attempt])

        except ValueError as value_error:
            logging.error(f"Value error while processing data for organization '{organization}': {value_error}")
            info.info({f"{organization}": "Not updated"})
            break

    logging.error(f"Failed to fetch data for organization '{organization}' after {retries} attempts.")
    info.info({f"{organization}": "Not updated"})


def fetch_pull_count():
    if isinstance(DockerhubOrganization, list):
        for organization in DockerhubOrganization:
            fetch_docker_image_pulls(organization)
    else:
        fetch_docker_image_pulls(DockerhubOrganization)


def update_loop():
    while True:
        fetch_pull_count()
        time.sleep(TTL)


def lifespan(_app: FastAPI):
    updater_thread = threading.Thread(target=update_loop, daemon=True)
    updater_thread.start()

    yield


app = FastAPI(lifespan=lifespan)
metrics_app = make_asgi_app(reg)
app.mount("/metrics", metrics_app)


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=PORT)
