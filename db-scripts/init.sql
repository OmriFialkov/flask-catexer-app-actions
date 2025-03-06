CREATE DATABASE IF NOT EXISTS flaskdb;

USE flaskdb;

CREATE TABLE IF NOT EXISTS images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    image_url VARCHAR(255) NOT NULL
);

INSERT INTO images (image_url) VALUES
    ("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRcuqUINWHLTIq9D-GWb9gyGG3AWQmO2HiA3w&s"),
    ("https://www.pawlovetreats.com/cdn/shop/articles/pembroke-welsh-corgi-puppy_1000x.jpg?v=1628638716"),
    ("https://hips.hearstapps.com/goodhousekeeping/assets/17/30/pembroke-welsh-corgi.jpg"),
    ("https://img.freepik.com/free-photo/portrait-cute-boxer-dog_181624-47633.jpg"),
    ("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQlO4erNhFuKmV1TNly5fu8RbSFftERnpUCUg&s"),
    ("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS0qDKYT9QCq6VnNu4Rlo-rCzD5CDpwt4JCBvIJ5dhI1NpNjyE0tQl740Kf5lUWwe8T6UA&usqp=CAU");


CREATE TABLE IF NOT EXISTS visitor_counter (
    id INT AUTO_INCREMENT PRIMARY KEY,
    count INT NOT NULL DEFAULT 0
);

-- Initialize the counter with a starting value of 0, for more rows add (0), (value of another row).
INSERT INTO visitor_counter (count) VALUES (0); 