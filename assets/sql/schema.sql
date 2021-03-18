CREATE TABLE employee_position (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL UNIQUE
);

CREATE TABLE employee (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    access_group INTEGER NOT NULL,
    position_id INTEGER NOT NULL,
    CONSTRAINT fk_position
        FOREIGN KEY (position_id)
        REFERENCES employee_position(id)
);

CREATE TABLE request_type (
   id  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
   short_name VARCHAR NOT NULL UNIQUE,
   full_name  VARCHAR NOT NULL
);