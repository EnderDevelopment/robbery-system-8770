CREATE TABLE IF NOT EXISTS robberies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT NOT NULL,
    location VARCHAR(255) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    success BOOLEAN NOT NULL,
    reward INT NOT NULL
);

CREATE TABLE IF NOT EXISTS robbery_locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    coords VARCHAR(255) NOT NULL,
    difficulty INT NOT NULL
);

INSERT INTO robbery_locations (name, coords, difficulty) VALUES
    ('Bank', '{"x": 255.0, "y": 220.0, "z": 106.0}', 3),
    ('Store', '{"x": 373.0, "y": 326.0, "z": 103.0}', 1),
    ('Jewelry Store', '{"x": -622.0, "y": -238.0, "z": 38.0}', 2);