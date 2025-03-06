FROM python:3.8

# set a directory for the app
WORKDIR /usr/src/app

# copy app dir consisting of app files to container's workdir - first . is all app dir.
COPY . .

# install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# tell the port number the container should expose
EXPOSE 5000

# run the command
CMD ["python", "./app.py"]
