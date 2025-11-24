-- database: ../database/starwars.db

-- Lesson 5 Solutions: Database Schema (Multi-table Design)
-- This file contains the complete database schema for the Star Wars database

-- ============================================
-- Setup: Database and Environment
-- ============================================

-- database: /workspaces/Learn_SQL_Basics/database/starwars.db
-- Use the ▷ button in the top right corner to run the entire file.

-- ============================================
-- Part 1: Planets Table
-- ============================================

CREATE TABLE planets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    climate TEXT,
    terrain TEXT,
    population INTEGER
);

-- ============================================
-- Part 2: Vehicles Table
-- ============================================

CREATE TABLE vehicles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    model TEXT,
    vehicle_class TEXT,
    manufacturer TEXT,
    cost_in_credits INTEGER
);

-- ============================================
-- Part 3: Junction Table for Many-to-Many Relationship
-- ============================================

CREATE TABLE character_vehicles (
    character_id INTEGER,
    vehicle_id INTEGER,
    PRIMARY KEY (character_id, vehicle_id),
    FOREIGN KEY (character_id) REFERENCES characters(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
);

-- ============================================
-- Part 4: Modify Characters Table
-- Add foreign key reference to planets
-- ============================================

-- Note: SQLite doesn't support adding foreign keys to existing tables
-- In practice, you'd need to recreate the table or use homeworld_id
-- This demonstrates the concept:

-- Add planet_id column to characters if not already present
ALTER TABLE characters ADD COLUMN planet_id INTEGER;

-- ============================================
-- Verification Queries
-- ============================================

-- View the structure of planets table
PRAGMA table_info(planets);

-- View the structure of vehicles table
PRAGMA table_info(vehicles);

-- View the structure of character_vehicles table
PRAGMA table_info(character_vehicles);

-- View foreign key definitions
PRAGMA foreign_key_list(character_vehicles);

-- ============================================
-- Practice Exercise Solutions
-- ============================================

-- Exercise 1: Create a missions table
CREATE TABLE missions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    mission_date TEXT,
    location TEXT,
    success BOOLEAN
);

-- Exercise 2: Show all tables in the database
SELECT name FROM sqlite_master WHERE type='table';

-- Exercise 3: Display the structure of the characters table
PRAGMA table_info(characters);

-- ============================================
-- CHALLENGE PROBLEM SOLUTION
-- Design a complete schema for tracking lightsabers
-- ============================================

-- Lightsabers table
CREATE TABLE lightsabers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    colour TEXT NOT NULL,
    crystal_type TEXT,
    hilt_material TEXT,
    construction_date TEXT
);

-- Junction table linking characters to their lightsabers
-- (some characters have multiple, some share)
CREATE TABLE character_lightsabers (
    character_id INTEGER,
    lightsaber_id INTEGER,
    relationship TEXT, -- 'owner', 'wielder', 'former owner'
    PRIMARY KEY (character_id, lightsaber_id),
    FOREIGN KEY (character_id) REFERENCES characters(id),
    FOREIGN KEY (lightsaber_id) REFERENCES lightsabers(id)
);

-- View the complete lightsaber schema
PRAGMA table_info(lightsabers);
PRAGMA table_info(character_lightsabers);
PRAGMA foreign_key_list(character_lightsabers);

-- ============================================
-- Additional Schema Examples
-- ============================================

-- Starships table (bonus example)
CREATE TABLE starships (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    model TEXT,
    starship_class TEXT,
    manufacturer TEXT,
    cost_in_credits INTEGER,
    length REAL,
    crew_capacity INTEGER,
    passenger_capacity INTEGER,
    hyperdrive_rating REAL
);

-- Character starships junction table
CREATE TABLE character_starships (
    character_id INTEGER,
    starship_id INTEGER,
    role TEXT, -- 'pilot', 'crew', 'passenger', 'owner'
    PRIMARY KEY (character_id, starship_id),
    FOREIGN KEY (character_id) REFERENCES characters(id),
    FOREIGN KEY (starship_id) REFERENCES starships(id)
);
