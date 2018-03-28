CREATE TABLE user(
    username TEXT PRIMARY KEY,
    password TEXT NOT NULL,
    authority INT NOT NULL
);

CREATE TABLE device (
    name VARCHAR(20) NOT NULL,
    property TEXT NOT NULL,
    PRIMARY KEY(name, property)
);

CREATE TABLE purchse (
    id INT PRIMARY KEY,
    time_point INT,
    username TEXT REFERENCES user(username) on update cascade on delete cascade,
    device_name TEXT REFERENCES device(name) on update cascade on delete cascade
);

CREATE TABLE component(
    model_id VARCHAR(20) PRIMARY KEY,
    type TEXT NOT NULL REFERENCES device(property) on update cascade on delete cascade,
    price REAL,
    amount INT
);

CREATE TABLE constitute(
    configuration_name TEXT PRIMARY KEY
    device_name TEXT NOT NULL REFERENCES device(name) on update cascade on delete cascade,
    component_type TEXT NOT NULL REFERENCES device(property) on update cascade on delete cascade,
    component_id TEXT NOT NULL REFERENCES component(model_id) on update cascade on delete cascade
);

CREATE TABLE factory(
    name TEXT PRIMARY KEY
);

CREATE TABLE product(
    factory_name TEXT REFERENCES factory(name) on update cascade on delete cascade,
    component_id TEXT REFERENCES component(model_id) on update cascade on delete cascade,
    PRIMARY KEY(factory_name, component_id)
);

CREATE TRIGGER afterReducePurchesId
AFTER DELETE ON purches
BEGIN
    UPDATE purches SET id = id - 1 WHERE id in(SELECT id from purches WHERE id>old.id);
END;