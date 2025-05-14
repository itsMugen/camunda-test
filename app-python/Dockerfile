FROM python:3.13-slim

#prepare the workspace
WORKDIR /app
COPY src/main.py .
COPY requirements.txt .

#install dependencies
RUN pip install --no-cache-dir -r requirements.txt

#run the app 
CMD [ "python", "main.py" ]
