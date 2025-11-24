-- database: ../database/starwars.db

-- Lesson 5 Solutions: Sample Data
-- This file contains sample data for planets, vehicles, and relationships

-- ============================================
-- Setup: Database and Environment
-- ============================================

-- database: /workspaces/Learn_SQL_Basics/database/starwars.db
-- Use the ▷ button in the top right corner to run the entire file.

-- ============================================
-- Planets Data
-- ============================================

INSERT INTO planets (name, climate, terrain, population) VALUES
('Tatooine', 'arid', 'desert', 200000),
('Alderaan', 'temperate', 'grasslands, mountains', 2000000000),
('Naboo', 'temperate', 'grassy hills, swamps, forests', 4500000000),
('Coruscant', 'temperate', 'cityscape, mountains', 1000000000000),
('Dagobah', 'murky', 'swamp, jungles', NULL),
('Kashyyyk', 'tropical', 'jungle, forests', 45000000),
('Shili', 'temperate', 'scrublands, forests', 100000000);

-- ============================================
-- Vehicles Data
-- ============================================

INSERT INTO vehicles (name, model, vehicle_class, manufacturer, cost_in_credits) VALUES
('Snowspeeder', 't-47 airspeeder', 'airspeeder', 'Incom Corporation', 100000),
('X-wing', 'T-65 X-wing', 'starfighter', 'Incom Corporation', 149999),
('Imperial Speeder Bike', '74-Z speeder bike', 'speeder', 'Aratech Repulsor Company', 8000),
('Millennium Falcon', 'YT-1300 light freighter', 'light freighter', 'Corellian Engineering Corporation', 100000),
('TIE Fighter', 'Twin Ion Engine Fighter', 'starfighter', 'Sienar Fleet Systems', 60000),
('AT-AT', 'All Terrain Armoured Transport', 'assault walker', 'Kuat Drive Yards', 500000),
('Naboo Royal Starship', 'J-type 327 Nubian', 'yacht', 'Theed Palace Space Vessel Engineering Corps', 2000000),
('Jedi Starfighter', 'Eta-2 Actis-class interceptor', 'starfighter', 'Kuat Systems Engineering', 320000);

-- ============================================
-- Update Characters with Planet References
-- ============================================

-- Update planet_id for existing characters
UPDATE characters SET planet_id = (SELECT id FROM planets WHERE name = 'Tatooine') 
WHERE homeworld = 'Tatooine';

UPDATE characters SET planet_id = (SELECT id FROM planets WHERE name = 'Alderaan') 
WHERE homeworld = 'Alderaan';

UPDATE characters SET planet_id = (SELECT id FROM planets WHERE name = 'Naboo') 
WHERE homeworld = 'Naboo';

UPDATE characters SET planet_id = (SELECT id FROM planets WHERE name = 'Coruscant') 
WHERE homeworld = 'Coruscant';

UPDATE characters SET planet_id = (SELECT id FROM planets WHERE name = 'Dagobah') 
WHERE homeworld = 'Dagobah';

UPDATE characters SET planet_id = (SELECT id FROM planets WHERE name = 'Kashyyyk') 
WHERE homeworld = 'Kashyyyk';

UPDATE characters SET planet_id = (SELECT id FROM planets WHERE name = 'Shili') 
WHERE homeworld = 'Shili';

-- ============================================
-- Character-Vehicle Relationships
-- ============================================

-- Luke Skywalker's vehicles
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES
((SELECT id FROM characters WHERE name = 'Luke Skywalker'), 
 (SELECT id FROM vehicles WHERE name = 'X-wing')),
((SELECT id FROM characters WHERE name = 'Luke Skywalker'), 
 (SELECT id FROM vehicles WHERE name = 'Snowspeeder'));

-- Han Solo's vehicles
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES
((SELECT id FROM characters WHERE name = 'Han Solo'), 
 (SELECT id FROM vehicles WHERE name = 'Millennium Falcon'));

-- Chewbacca's vehicles (co-pilot of Millennium Falcon)
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES
((SELECT id FROM characters WHERE name = 'Chewbacca'), 
 (SELECT id FROM vehicles WHERE name = 'Millennium Falcon'));

-- Leia Organa's vehicles
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES
((SELECT id FROM characters WHERE name = 'Leia Organa'), 
 (SELECT id FROM vehicles WHERE name = 'Imperial Speeder Bike'));

-- Darth Vader's vehicles
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES
((SELECT id FROM characters WHERE name = 'Darth Vader'), 
 (SELECT id FROM vehicles WHERE name = 'TIE Fighter'));

-- Obi-Wan Kenobi's vehicles
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES
((SELECT id FROM characters WHERE name = 'Obi-Wan Kenobi'), 
 (SELECT id FROM vehicles WHERE name = 'Jedi Starfighter'));

-- Padmé Amidala's vehicles
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES
((SELECT id FROM characters WHERE name = 'Padmé Amidala'), 
 (SELECT id FROM vehicles WHERE name = 'Naboo Royal Starship'));

-- Ahsoka Tano's vehicles
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES
((SELECT id FROM characters WHERE name = 'Ahsoka Tano'), 
 (SELECT id FROM vehicles WHERE name = 'Jedi Starfighter'));

-- ============================================
-- Verification Queries
-- ============================================

-- View all planets
SELECT * FROM planets;

-- View all vehicles
SELECT * FROM vehicles;

-- View all character-vehicle relationships
SELECT 
    c.name AS character_name,
    v.name AS vehicle_name
FROM character_vehicles cv
JOIN characters c ON cv.character_id = c.id
JOIN vehicles v ON cv.vehicle_id = v.id
ORDER BY c.name;

-- Count vehicles per character
SELECT 
    c.name,
    COUNT(cv.vehicle_id) AS vehicle_count
FROM characters c
LEFT JOIN character_vehicles cv ON c.id = cv.character_id
GROUP BY c.id, c.name
ORDER BY vehicle_count DESC;

-- ============================================
-- Practice Exercise Solutions
-- ============================================

-- Exercise 1: Add 2 more planets
INSERT INTO planets (name, climate, terrain, population) VALUES
('Hoth', 'frozen', 'tundra, ice caves', NULL),
('Mustafar', 'hot', 'volcanoes, lava rivers', 20000);

-- Exercise 2: Add 2 more vehicles
INSERT INTO vehicles (name, model, vehicle_class, manufacturer, cost_in_credits) VALUES
('A-wing', 'RZ-1 A-wing interceptor', 'starfighter', 'Alliance Underground Engineering', 175000),
('Lambda-class Shuttle', 'Lambda-class T-4a', 'transport', 'Sienar Fleet Systems', 240000);

-- Exercise 3: Link at least 1 new vehicle to a character
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES
((SELECT id FROM characters WHERE name = 'Leia Organa'), 
 (SELECT id FROM vehicles WHERE name = 'A-wing'));

-- ============================================
-- CHALLENGE PROBLEM SOLUTION
-- Sample data for lightsaber schema
-- ============================================

-- Insert lightsaber data
INSERT INTO lightsabers (colour, crystal_type, hilt_material, construction_date) VALUES
('blue', 'Kyber', 'durasteel', '32 BBY'),
('green', 'Kyber', 'durasteel', '22 BBY'),
('red', 'synthetic', 'durasteel', '19 BBY'),
('purple', 'Kyber', 'electrum', '58 BBY'),
('green', 'Kyber', 'bronzium', '896 BBY'),
('green', 'Kyber', 'durasteel', '36 BBY'),
('blue', 'Kyber', 'durasteel', '22 BBY');

-- Link lightsabers to characters
INSERT INTO character_lightsabers (character_id, lightsaber_id, relationship) VALUES
((SELECT id FROM characters WHERE name = 'Luke Skywalker'), 1, 'owner'),
((SELECT id FROM characters WHERE name = 'Luke Skywalker'), 2, 'owner'),
((SELECT id FROM characters WHERE name = 'Obi-Wan Kenobi'), 1, 'former owner'),
((SELECT id FROM characters WHERE name = 'Darth Vader'), 3, 'owner'),
((SELECT id FROM characters WHERE name = 'Mace Windu'), 4, 'owner'),
((SELECT id FROM characters WHERE name = 'Yoda'), 5, 'owner'),
((SELECT id FROM characters WHERE name = 'Obi-Wan Kenobi'), 6, 'owner'),
((SELECT id FROM characters WHERE name = 'Ahsoka Tano'), 7, 'owner');

-- Verify lightsaber data
SELECT 
    c.name AS character_name,
    l.colour AS lightsaber_colour,
    cl.relationship
FROM character_lightsabers cl
JOIN characters c ON cl.character_id = c.id
JOIN lightsabers l ON cl.lightsaber_id = l.id
ORDER BY c.name;
