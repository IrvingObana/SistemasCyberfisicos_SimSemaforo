-- Schema para el control de semaforos inteligentes, trafico y peatones 
DROP SCHEMA IF EXISTS smart_traffic CASCADE;

CREATE SCHEMA smart_traffic;
SET search_path TO smart_traffic;

CREATE TABLE Intersections (
    intersection_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location_description TEXT,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL
);

CREATE TABLE Traffic_Lights (
    traffic_light_id SERIAL PRIMARY KEY,
    intersection_id INT NOT NULL REFERENCES Intersections(intersection_id) ON DELETE CASCADE,
    direction VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Sensors (
    sensor_id SERIAL PRIMARY KEY,
    intersection_id INT NOT NULL REFERENCES Intersections(intersection_id) ON DELETE CASCADE,
    sensor_type VARCHAR(50) NOT NULL,
    description TEXT,
    installed_on DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE Sensor_Readings (
    reading_id BIGSERIAL PRIMARY KEY,
    sensor_id INT NOT NULL REFERENCES Sensors(sensor_id) ON DELETE CASCADE,
    reading_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    value NUMERIC NOT NULL,
    unit VARCHAR(20)
);

CREATE TABLE Vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    license_plate VARCHAR(20) UNIQUE,
    vehicle_type VARCHAR(30) NOT NULL,
    is_emergency BOOLEAN DEFAULT FALSE
);

CREATE TABLE Vehicle_Movements (
    movement_id BIGSERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES Vehicles(vehicle_id) ON DELETE SET NULL,
    intersection_id INT NOT NULL REFERENCES Intersections(intersection_id) ON DELETE CASCADE,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    direction_from VARCHAR(20),
    direction_to VARCHAR(20),
    detected_by INT REFERENCES Sensors(sensor_id) ON DELETE SET NULL
);

CREATE TABLE Pedestrian_Events (
    event_id BIGSERIAL PRIMARY KEY,
    intersection_id INT NOT NULL REFERENCES Intersections(intersection_id) ON DELETE CASCADE,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    count INT NOT NULL,
    detected_by INT REFERENCES Sensors(sensor_id) ON DELETE SET NULL
);

CREATE TABLE Parking_Spaces (
    parking_id SERIAL PRIMARY KEY,
    location_description TEXT,
    total_capacity INT NOT NULL,
    available_capacity INT NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Incidents (
    incident_id BIGSERIAL PRIMARY KEY,
    intersection_id INT REFERENCES Intersections(intersection_id) ON DELETE SET NULL,
    vehicle_id INT REFERENCES Vehicles(vehicle_id) ON DELETE SET NULL,
    incident_type VARCHAR(50) NOT NULL,
    description TEXT,
    detected_by INT REFERENCES Sensors(sensor_id) ON DELETE SET NULL,
    reported_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Emergency_Prioritization (
    record_id BIGSERIAL PRIMARY KEY,
    traffic_light_id INT NOT NULL REFERENCES Traffic_Lights(traffic_light_id) ON DELETE CASCADE,
    vehicle_id INT REFERENCES Vehicles(vehicle_id) ON DELETE SET NULL,
    activated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deactivated_at TIMESTAMP
);
