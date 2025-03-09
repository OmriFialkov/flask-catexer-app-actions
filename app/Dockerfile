FROM python:3.8

# set a app dir - creating it
WORKDIR /usr/src/app

# copy whole app-dir consisting of app files to image, according to build context in dc ( app/ )
COPY . .

# install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# tell the port number the container should expose
EXPOSE 5000

# run app
CMD ["python", "./app.py"]

# .dockerignore in same hirarchy according to build context! , per one dockerfile.