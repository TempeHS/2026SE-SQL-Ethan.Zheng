-- database: ../database/starwars.db

-- Lesson 6 Solutions: JOIN Operations
-- This file contains complete solutions for all JOIN activities

-- ============================================
-- Setup: Database and Environment
-- ============================================

-- database: /workspaces/Learn_SQL_Basics/database/starwars.db
-- Use the ▷ button in the top right corner to run the entire file.

-- ============================================
-- INNER JOIN Examples
-- ============================================

-- Query 1: Show characters with their planet information
SELECT 
    characters.name AS character_name,
    characters.species,
    planets.name AS planet_name,
    planets.climate,
    planets.terrain
FROM characters
INNER JOIN planets ON characters.planet_id = planets.id
ORDER BY character_name;

-- Query 2: Show characters and their vehicles
SELECT 
    c.name AS character_name,
    v.name AS vehicle_name,
    v.vehicle_class
FROM characters c
INNER JOIN character_vehicles cv ON c.id = cv.character_id
INNER JOIN vehicles v ON cv.vehicle_id = v.id
ORDER BY c.name, v.name;

-- Query 3: Find all humans and their planets
SELECT 
    c.name,
    c.species,
    p.name AS homeworld,
    p.climate
FROM characters c
INNER JOIN planets p ON c.planet_id = p.id
WHERE c.species = 'Human';

-- Query 4: Show vehicles owned by Rebel Alliance members
SELECT DISTINCT
    v.name AS vehicle_name,
    v.model,
    v.vehicle_class,
    c.name AS owner_name
FROM vehicles v
INNER JOIN character_vehicles cv ON v.id = cv.vehicle_id
INNER JOIN characters c ON cv.character_id = c.id
WHERE c.affiliation = 'Rebel Alliance'
ORDER BY v.name;

-- Query 5: Characters from temperate climate planets
SELECT 
    c.name AS character_name,
    c.species,
    p.name AS planet_name,
    p.climate
FROM characters c
INNER JOIN planets p ON c.planet_id = p.id
WHERE p.climate = 'temperate';

-- ============================================
-- LEFT JOIN Examples
-- ============================================

-- Query 6: All characters and their vehicles (including those without vehicles)
SELECT 
    c.name AS character_name,
    v.name AS vehicle_name
FROM characters c
LEFT JOIN character_vehicles cv ON c.id = cv.character_id
LEFT JOIN vehicles v ON cv.vehicle_id = v.id
ORDER BY c.name;

-- Query 7: Find characters without any vehicles
SELECT 
    c.name AS character_name,
    c.species,
    c.homeworld
FROM characters c
LEFT JOIN character_vehicles cv ON c.id = cv.character_id
WHERE cv.vehicle_id IS NULL;

-- Query 8: All planets with character count (including planets with no characters)
SELECT 
    p.name AS planet_name,
    p.climate,
    COUNT(c.id) AS character_count
FROM planets p
LEFT JOIN characters c ON p.id = c.planet_id
GROUP BY p.id, p.name, p.climate
ORDER BY character_count DESC, p.name;

-- Query 9: All vehicles with their pilots (including unused vehicles)
SELECT 
    v.name AS vehicle_name,
    v.vehicle_class,
    c.name AS pilot_name
FROM vehicles v
LEFT JOIN character_vehicles cv ON v.id = cv.vehicle_id
LEFT JOIN characters c ON cv.character_id = c.id
ORDER BY v.name;

-- Query 10: Find vehicles that no one uses
SELECT 
    v.name AS unused_vehicle,
    v.model,
    v.vehicle_class
FROM vehicles v
LEFT JOIN character_vehicles cv ON v.id = cv.vehicle_id
WHERE cv.character_id IS NULL;

-- ============================================
-- Multiple JOINs
-- ============================================

-- Query 11: Complete character profile (character, planet, vehicles)
SELECT 
    c.name AS character_name,
    c.species,
    c.height,
    c.affiliation,
    p.name AS homeworld,
    p.climate,
    v.name AS vehicle_name
FROM characters c
INNER JOIN planets p ON c.planet_id = p.id
LEFT JOIN character_vehicles cv ON c.id = cv.character_id
LEFT JOIN vehicles v ON cv.vehicle_id = v.id
ORDER BY c.name, v.name;

-- Query 12: Count vehicles by manufacturer for Rebel Alliance
SELECT 
    v.manufacturer,
    COUNT(DISTINCT v.id) AS vehicle_count
FROM vehicles v
INNER JOIN character_vehicles cv ON v.id = cv.vehicle_id
INNER JOIN characters c ON cv.character_id = c.id
WHERE c.affiliation = 'Rebel Alliance'
GROUP BY v.manufacturer
ORDER BY vehicle_count DESC;

-- ============================================
-- Practice Exercises
-- ============================================

-- Exercise 1: List all Jedi Order members with their homeworlds and climates
SELECT 
    c.name AS jedi_name,
    p.name AS homeworld,
    p.climate
FROM characters c
INNER JOIN planets p ON c.planet_id = p.id
WHERE c.affiliation = 'Jedi Order'
ORDER BY c.name;

-- Exercise 2: Find which planet has the most characters
SELECT 
    p.name AS planet_name,
    COUNT(c.id) AS character_count
FROM planets p
INNER JOIN characters c ON p.id = c.planet_id
GROUP BY p.id, p.name
ORDER BY character_count DESC
LIMIT 1;

-- Exercise 3: Show all characters taller than 180cm with their vehicles
SELECT 
    c.name AS character_name,
    c.height,
    v.name AS vehicle_name
FROM characters c
LEFT JOIN character_vehicles cv ON c.id = cv.character_id
LEFT JOIN vehicles v ON cv.vehicle_id = v.id
WHERE c.height > 180
ORDER BY c.height DESC, c.name;

-- Exercise 4: List vehicles from 'Incom Corporation' with their pilots
SELECT 
    v.name AS vehicle_name,
    v.model,
    c.name AS pilot_name
FROM vehicles v
LEFT JOIN character_vehicles cv ON v.id = cv.vehicle_id
LEFT JOIN characters c ON cv.character_id = c.id
WHERE v.manufacturer = 'Incom Corporation'
ORDER BY v.name, c.name;

-- ============================================
-- CHALLENGE PROBLEM SOLUTION
-- Find characters who pilot vehicles costing more than 200,000 credits
-- Show: character name, affiliation, vehicle name, cost
-- Sorted by cost (highest first)
-- ============================================

SELECT 
    c.name AS character_name,
    c.affiliation,
    v.name AS vehicle_name,
    v.cost_in_credits
FROM characters c
INNER JOIN character_vehicles cv ON c.id = cv.character_id
INNER JOIN vehicles v ON cv.vehicle_id = v.id
WHERE v.cost_in_credits > 200000
ORDER BY v.cost_in_credits DESC, c.name;

-- Expected result: Shows characters like Padmé Amidala (Naboo Royal Starship - 2M credits),
-- Obi-Wan/Ahsoka (Jedi Starfighter - 320K credits)

-- ============================================
-- Advanced JOIN Examples
-- ============================================

-- Find characters who share the same homeworld
SELECT 
    c1.name AS character1,
    c2.name AS character2,
    p.name AS shared_homeworld
FROM characters c1
INNER JOIN characters c2 ON c1.planet_id = c2.planet_id AND c1.id < c2.id
INNER JOIN planets p ON c1.planet_id = p.id
ORDER BY p.name, c1.name;

-- Characters and their "fleet" (all vehicles they use)
SELECT 
    c.name AS character_name,
    COUNT(v.id) AS vehicle_count,
    GROUP_CONCAT(v.name, ', ') AS vehicles
FROM characters c
LEFT JOIN character_vehicles cv ON c.id = cv.character_id
LEFT JOIN vehicles v ON cv.vehicle_id = v.id
GROUP BY c.id, c.name
ORDER BY vehicle_count DESC, c.name;

-- Most popular vehicle class by affiliation
SELECT 
    c.affiliation,
    v.vehicle_class,
    COUNT(*) AS usage_count
FROM characters c
INNER JOIN character_vehicles cv ON c.id = cv.character_id
INNER JOIN vehicles v ON cv.vehicle_id = v.id
WHERE c.affiliation IS NOT NULL
GROUP BY c.affiliation, v.vehicle_class
ORDER BY c.affiliation, usage_count DESC;

-- Average vehicle cost by character affiliation
SELECT 
    c.affiliation,
    COUNT(DISTINCT v.id) AS vehicle_count,
    ROUND(AVG(v.cost_in_credits), 2) AS avg_cost
FROM characters c
INNER JOIN character_vehicles cv ON c.id = cv.character_id
INNER JOIN vehicles v ON cv.vehicle_id = v.id
WHERE c.affiliation IS NOT NULL
GROUP BY c.affiliation
ORDER BY avg_cost DESC;

-- Find characters who pilot the same vehicles
SELECT 
    v.name AS vehicle_name,
    GROUP_CONCAT(c.name, ', ') AS pilots
FROM vehicles v
INNER JOIN character_vehicles cv ON v.id = cv.vehicle_id
INNER JOIN characters c ON cv.character_id = c.id
GROUP BY v.id, v.name
HAVING COUNT(c.id) > 1;
