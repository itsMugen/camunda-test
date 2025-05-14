# Do you have any feedback for us? (Any mistakes you've found in the challenge, something was not working with your setup, you've lost a lot of time with something avoidable etc.)
I've changed the urls for the calls made inside test-app.sh by adding a "/" at the end.
Due to me using FastAPI to try it out I've ended up discovering that it enforces strict
route matching, it seems that one the proposed solutions is still not yet approved 
https://github.com/fastapi/fastapi/discussions/7298, so to not write again the code I made
the small fix, thank you for your understanding.
E.g.
URL="http://camunda-app:${APP_PORT}/metrics/"
URL="http://camunda-app:${APP_PORT}/metrics"

Time to complete task = ~4/5 hours
