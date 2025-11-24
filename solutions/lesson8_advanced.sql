-- database: ../database/starwars.db

-- Lesson 8 Solutions: Subqueries and Advanced Queries
-- This file contains complete solutions for subquery activities

-- ============================================
-- Setup: Database and Environment
-- ============================================

-- database: /workspaces/Learn_SQL_Basics/database/starwars.db
-- Use the ▷ button in the top right corner to run the entire file.

-- ============================================
-- Basic Subqueries in WHERE Clause
-- ============================================

-- Query 1: Find characters taller than average
SELECT name, species, height
FROM characters
WHERE height > (SELECT AVG(height) FROM characters WHERE height IS NOT NULL)
ORDER BY height DESC;

-- Query 2: Find characters from the most populated planet
SELECT name, species, homeworld
FROM characters
WHERE planet_id = (
    SELECT id 
    FROM planets 
    ORDER BY population DESC 
    LIMIT 1
);

-- Query 3: Characters with the same affiliation as Luke Skywalker
SELECT name, affiliation
FROM characters
WHERE affiliation = (
    SELECT affiliation 
    FROM characters 
    WHERE name = 'Luke Skywalker'
)
AND name != 'Luke Skywalker';

-- Query 4: Find the tallest character of the most common species
SELECT name, species, height
FROM characters
WHERE species = (
    SELECT species
    FROM characters
    GROUP BY species
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
ORDER BY height DESC
LIMIT 1;

-- ============================================
-- Subqueries with IN and NOT IN
-- ============================================

-- Query 5: Characters who pilot vehicles
SELECT name, species, affiliation
FROM characters
WHERE id IN (
    SELECT DISTINCT character_id 
    FROM character_vehicles
)
ORDER BY name;

-- Query 6: Characters who DON'T pilot any vehicles
SELECT name, species, affiliation
FROM characters
WHERE id NOT IN (
    SELECT character_id 
    FROM character_vehicles
)
ORDER BY name;

-- Query 7: Vehicles piloted by Jedi Order members
SELECT name, model, vehicle_class
FROM vehicles
WHERE id IN (
    SELECT vehicle_id
    FROM character_vehicles
    WHERE character_id IN (
        SELECT id 
        FROM characters 
        WHERE affiliation = 'Jedi Order'
    )
)
ORDER BY name;

-- Query 8: Planets with no characters
SELECT name, climate, terrain
FROM planets
WHERE id NOT IN (
    SELECT DISTINCT planet_id
    FROM characters
    WHERE planet_id IS NOT NULL
);

-- ============================================
-- Subqueries with EXISTS and NOT EXISTS
-- ============================================

-- Query 9: Characters who have vehicles (using EXISTS)
SELECT c.name, c.species
FROM characters c
WHERE EXISTS (
    SELECT 1
    FROM character_vehicles cv
    WHERE cv.character_id = c.id
)
ORDER BY c.name;

-- Query 10: Characters without vehicles (using NOT EXISTS)
SELECT c.name, c.species
FROM characters c
WHERE NOT EXISTS (
    SELECT 1
    FROM character_vehicles cv
    WHERE cv.character_id = c.id
)
ORDER BY c.name;

-- Query 11: Vehicles that are piloted (using EXISTS)
SELECT v.name, v.vehicle_class
FROM vehicles v
WHERE EXISTS (
    SELECT 1
    FROM character_vehicles cv
    WHERE cv.vehicle_id = v.id
);

-- Query 12: Find planets that have Rebel Alliance members
SELECT p.name, p.climate
FROM planets p
WHERE EXISTS (
    SELECT 1
    FROM characters c
    WHERE c.planet_id = p.id
    AND c.affiliation = 'Rebel Alliance'
);

-- ============================================
-- Subqueries in SELECT Clause
-- ============================================

-- Query 13: Show each character with vehicle count
SELECT 
    name,
    species,
    (SELECT COUNT(*) 
     FROM character_vehicles cv 
     WHERE cv.character_id = characters.id) AS vehicle_count
FROM characters
ORDER BY vehicle_count DESC, name;

-- Query 14: Show characters with their homeworld population
SELECT 
    c.name,
    c.homeworld,
    (SELECT p.population 
     FROM planets p 
     WHERE p.id = c.planet_id) AS population
FROM characters c
ORDER BY population DESC;

-- Query 15: Compare each character's height to species average
SELECT 
    name,
    species,
    height,
    (SELECT ROUND(AVG(height), 1)
     FROM characters c2
     WHERE c2.species = characters.species
     AND height IS NOT NULL) AS species_avg_height
FROM characters
WHERE height IS NOT NULL
ORDER BY species, height DESC;

-- ============================================
-- Subqueries in FROM Clause (Derived Tables)
-- ============================================

-- Query 16: Find characters taller than their species average
SELECT 
    c.name,
    c.species,
    c.height,
    avg_heights.avg_height
FROM characters c
INNER JOIN (
    SELECT species, AVG(height) AS avg_height
    FROM characters
    WHERE height IS NOT NULL
    GROUP BY species
) AS avg_heights ON c.species = avg_heights.species
WHERE c.height > avg_heights.avg_height
ORDER BY c.species, c.height DESC;

-- Query 17: Species statistics
SELECT 
    species_stats.*,
    species_stats.tallest - species_stats.shortest AS height_range
FROM (
    SELECT 
        species,
        COUNT(*) AS count,
        ROUND(AVG(height), 1) AS avg_height,
        MAX(height) AS tallest,
        MIN(height) AS shortest
    FROM characters
    WHERE height IS NOT NULL
    GROUP BY species
) AS species_stats
ORDER BY count DESC;

-- ============================================
-- Correlated Subqueries
-- ============================================

-- Query 18: Find the tallest character from each planet
SELECT c.name, c.homeworld, c.height
FROM characters c
WHERE c.height = (
    SELECT MAX(height)
    FROM characters c2
    WHERE c2.planet_id = c.planet_id
    AND height IS NOT NULL
)
ORDER BY c.height DESC;

-- Query 19: Characters with above-average height for their affiliation
SELECT 
    c.name,
    c.affiliation,
    c.height,
    (SELECT ROUND(AVG(height), 1)
     FROM characters c2
     WHERE c2.affiliation = c.affiliation
     AND height IS NOT NULL) AS affiliation_avg
FROM characters c
WHERE c.height > (
    SELECT AVG(height)
    FROM characters c2
    WHERE c2.affiliation = c.affiliation
    AND height IS NOT NULL
)
AND c.affiliation IS NOT NULL
ORDER BY c.affiliation, c.height DESC;

-- ============================================
-- Practice Exercises
-- ============================================

-- Exercise 1: Find vehicles more expensive than average
SELECT name, model, cost_in_credits
FROM vehicles
WHERE cost_in_credits > (SELECT AVG(cost_in_credits) FROM vehicles)
ORDER BY cost_in_credits DESC;

-- Exercise 2: List characters from temperate climate planets
SELECT name, species, homeworld
FROM characters
WHERE planet_id IN (
    SELECT id
    FROM planets
    WHERE climate = 'temperate'
)
ORDER BY name;

-- Exercise 3: Find species with more than 2 members
SELECT species, COUNT(*) AS member_count
FROM characters
WHERE species IN (
    SELECT species
    FROM characters
    GROUP BY species
    HAVING COUNT(*) > 2
)
GROUP BY species
ORDER BY member_count DESC;

-- Exercise 4: Characters piloting Incom Corporation vehicles
SELECT c.name, c.species, c.affiliation
FROM characters c
WHERE EXISTS (
    SELECT 1
    FROM character_vehicles cv
    JOIN vehicles v ON cv.vehicle_id = v.id
    WHERE cv.character_id = c.id
    AND v.manufacturer = 'Incom Corporation'
)
ORDER BY c.name;

-- ============================================
-- CHALLENGE PROBLEM SOLUTION
-- Find characters who pilot vehicles from at least 2 different manufacturers
-- WITHOUT using JOIN (subqueries only!)
-- ============================================

SELECT 
    c.name,
    c.affiliation,
    (SELECT COUNT(DISTINCT v.manufacturer)
     FROM character_vehicles cv
     JOIN vehicles v ON cv.vehicle_id = v.id
     WHERE cv.character_id = c.id) AS manufacturer_count
FROM characters c
WHERE (
    SELECT COUNT(DISTINCT v.manufacturer)
    FROM character_vehicles cv
    JOIN vehicles v ON cv.vehicle_id = v.id
    WHERE cv.character_id = c.id
) >= 2
ORDER BY manufacturer_count DESC, c.name;

-- Alternative solution using only subqueries in WHERE clause:
SELECT name, affiliation
FROM characters
WHERE id IN (
    SELECT character_id
    FROM (
        SELECT cv.character_id, COUNT(DISTINCT v.manufacturer) AS mfr_count
        FROM character_vehicles cv
        JOIN vehicles v ON cv.vehicle_id = v.id
        GROUP BY cv.character_id
        HAVING COUNT(DISTINCT v.manufacturer) >= 2
    )
);

-- ============================================
-- Advanced Subquery Examples
-- ============================================

-- Find characters taller than ALL Jedi
SELECT name, species, height
FROM characters
WHERE height > ALL (
    SELECT height
    FROM characters
    WHERE affiliation = 'Jedi Order'
    AND height IS NOT NULL
)
AND height IS NOT NULL;

-- Find characters as tall as ANY Wookiee
SELECT name, species, height
FROM characters
WHERE height >= ANY (
    SELECT height
    FROM characters
    WHERE species = 'Wookiee'
    AND height IS NOT NULL
)
AND species != 'Wookiee'
AND height IS NOT NULL;

-- Rank characters by height within their species
SELECT 
    name,
    species,
    height,
    (SELECT COUNT(*) 
     FROM characters c2 
     WHERE c2.species = c1.species 
     AND c2.height > c1.height
     AND c2.height IS NOT NULL) + 1 AS species_rank
FROM characters c1
WHERE height IS NOT NULL
ORDER BY species, species_rank;

-- Find planets with more characters than average
SELECT 
    p.name,
    (SELECT COUNT(*) 
     FROM characters c 
     WHERE c.planet_id = p.id) AS char_count
FROM planets p
WHERE (
    SELECT COUNT(*) 
    FROM characters c 
    WHERE c.planet_id = p.id
) > (
    SELECT AVG(planet_char_count)
    FROM (
        SELECT COUNT(*) AS planet_char_count
        FROM characters
        GROUP BY planet_id
    )
)
ORDER BY char_count DESC;

-- Most expensive vehicle per class
SELECT v.name, v.vehicle_class, v.cost_in_credits
FROM vehicles v
WHERE v.cost_in_credits = (
    SELECT MAX(cost_in_credits)
    FROM vehicles v2
    WHERE v2.vehicle_class = v.vehicle_class
)
ORDER BY v.cost_in_credits DESC;

-- Characters with the most vehicles in their affiliation
SELECT 
    c.name,
    c.affiliation,
    (SELECT COUNT(*) 
     FROM character_vehicles cv 
     WHERE cv.character_id = c.id) AS vehicle_count
FROM characters c
WHERE (
    SELECT COUNT(*) 
    FROM character_vehicles cv 
    WHERE cv.character_id = c.id
) = (
    SELECT MAX(vcount)
    FROM (
        SELECT COUNT(*) AS vcount
        FROM character_vehicles cv2
        JOIN characters c2 ON cv2.character_id = c2.id
        WHERE c2.affiliation = c.affiliation
        GROUP BY cv2.character_id
    )
)
AND c.affiliation IS NOT NULL
ORDER BY vehicle_count DESC;
