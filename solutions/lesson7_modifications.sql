-- database: ../database/starwars.db

-- Lesson 7 Solutions: Updating and Deleting Data
-- This file contains complete solutions for UPDATE and DELETE operations

-- ============================================
-- Setup: Database and Environment
-- ============================================

-- database: /workspaces/Learn_SQL_Basics/database/starwars.db
-- Use the ▷ button in the top right corner to run the entire file.

-- ============================================
-- Basic UPDATE Operations
-- ============================================

-- Query 1: Update a single character's affiliation
UPDATE characters
SET affiliation = 'Rebel Alliance'
WHERE name = 'R2-D2';

-- Verify the change
SELECT name, affiliation FROM characters WHERE name = 'R2-D2';

-- Query 2: Update multiple records at once
UPDATE characters
SET species = 'Human'
WHERE species = 'human';

-- Query 3: Update using calculations
UPDATE characters
SET height = height + 2
WHERE species = 'Human';

-- Verify the changes
SELECT name, species, height FROM characters WHERE species = 'Human';

-- Query 4: Update with multiple columns
UPDATE characters
SET height = 167,
    affiliation = 'Galactic Senate'
WHERE name = 'Padmé Amidala';

-- Query 5: Update based on another column's value
UPDATE vehicles
SET cost_in_credits = cost_in_credits * 1.1
WHERE vehicle_class = 'starfighter';

-- ============================================
-- Conditional UPDATE with CASE
-- ============================================

-- Query 6: Adjust heights based on species
UPDATE characters
SET height = CASE
    WHEN species = 'Droid' THEN height * 0.95
    WHEN species = 'Wookiee' THEN height * 1.02
    ELSE height
END
WHERE species IN ('Droid', 'Wookiee');

-- Query 7: Categorise characters by height
-- (This adds a new column first, then updates it)
ALTER TABLE characters ADD COLUMN height_category TEXT;

UPDATE characters
SET height_category = CASE
    WHEN height IS NULL THEN 'Unknown'
    WHEN height < 100 THEN 'Small'
    WHEN height BETWEEN 100 AND 180 THEN 'Average'
    WHEN height > 180 THEN 'Tall'
END;

-- Verify the categories
SELECT name, height, height_category FROM characters ORDER BY height;

-- Query 8: Update affiliations for an entire species
UPDATE characters
SET affiliation = 'Independent'
WHERE species = 'Droid' AND affiliation IS NULL;

-- ============================================
-- Safe DELETE Operations
-- ============================================

-- IMPORTANT: Always use WHERE with DELETE!

-- Query 9: Delete a single character
DELETE FROM characters
WHERE name = 'Test Character';
-- This won't delete anything if 'Test Character' doesn't exist

-- Query 10: Delete characters based on condition
DELETE FROM characters
WHERE affiliation IS NULL;
-- WARNING: This would delete characters with no affiliation!

-- Query 11: Delete with multiple conditions
DELETE FROM vehicles
WHERE cost_in_credits > 1000000 
AND vehicle_class = 'yacht';

-- Query 12: Delete related records (junction table cleanup)
DELETE FROM character_vehicles
WHERE character_id = (SELECT id FROM characters WHERE name = 'Luke Skywalker')
AND vehicle_id = (SELECT id FROM vehicles WHERE name = 'X-wing');

-- ============================================
-- Safe Deletion Pattern
-- ============================================

-- ALWAYS check what you're about to delete first!

-- Step 1: SELECT to preview what will be deleted
SELECT * FROM characters
WHERE species = 'Test Species';

-- Step 2: If the results look correct, then DELETE
DELETE FROM characters
WHERE species = 'Test Species';

-- Step 3: Verify the deletion
SELECT * FROM characters
WHERE species = 'Test Species';
-- Should return no results

-- ============================================
-- Transactions (for safe multi-step operations)
-- ============================================

-- Start a transaction
BEGIN TRANSACTION;

-- Make changes
UPDATE characters SET affiliation = 'New Republic' WHERE affiliation = 'Rebel Alliance';

-- Check if it looks correct
SELECT name, affiliation FROM characters WHERE affiliation = 'New Republic';

-- If correct, commit the changes
COMMIT;

-- If incorrect, rollback (undo) the changes
-- ROLLBACK;

-- Example of ROLLBACK:
BEGIN TRANSACTION;

DELETE FROM vehicles WHERE vehicle_class = 'starfighter';

-- Oh no! That would delete too much!
ROLLBACK;

-- Verify nothing was deleted
SELECT * FROM vehicles WHERE vehicle_class = 'starfighter';

-- ============================================
-- Practice Exercises
-- ============================================

-- Exercise 1: Change Chewbacca's homeworld from 'Kashyyyk' to match the planet_id
UPDATE characters
SET homeworld = 'Kashyyyk'
WHERE name = 'Chewbacca';

-- Exercise 2: Increase all vehicle costs by 5%
UPDATE vehicles
SET cost_in_credits = ROUND(cost_in_credits * 1.05);

-- Verify changes
SELECT name, cost_in_credits FROM vehicles ORDER BY cost_in_credits DESC;

-- Exercise 3: Delete all vehicles that cost less than 10,000 credits
-- First, check what would be deleted
SELECT * FROM vehicles WHERE cost_in_credits < 10000;

-- Then delete
DELETE FROM vehicles WHERE cost_in_credits < 10000;

-- Exercise 4: Create and then safely delete a test record using transactions
BEGIN TRANSACTION;

-- Create test character
INSERT INTO characters (name, species, homeworld, affiliation)
VALUES ('Test Pilot', 'Human', 'Tatooine', 'Test Squadron');

-- Verify it was created
SELECT * FROM characters WHERE name = 'Test Pilot';

-- Delete it
DELETE FROM characters WHERE name = 'Test Pilot';

-- Verify deletion
SELECT * FROM characters WHERE name = 'Test Pilot';

COMMIT;

-- ============================================
-- CHALLENGE PROBLEM SOLUTION
-- Update all 'Jedi Order' characters to 'New Jedi Order'
-- if they are still alive in the sequel era
-- ============================================

-- Since we don't have a 'status' or 'era' column, we'll demonstrate
-- the safe transaction pattern:

BEGIN TRANSACTION;

-- Check current state
SELECT name, affiliation FROM characters 
WHERE affiliation = 'Jedi Order';

-- Make the update
UPDATE characters
SET affiliation = 'New Jedi Order'
WHERE affiliation = 'Jedi Order'
AND name IN ('Luke Skywalker', 'Ahsoka Tano'); -- Only characters alive in sequel era

-- Verify the changes
SELECT name, affiliation FROM characters 
WHERE affiliation LIKE '%Jedi Order%';

-- Commit if correct
COMMIT;

-- ============================================
-- Advanced Examples
-- ============================================

-- Update characters' planet_id based on homeworld text
UPDATE characters
SET planet_id = (SELECT id FROM planets WHERE planets.name = characters.homeworld)
WHERE homeworld IN (SELECT name FROM planets);

-- Delete orphaned relationships (cleanup junction table)
DELETE FROM character_vehicles
WHERE character_id NOT IN (SELECT id FROM characters)
OR vehicle_id NOT IN (SELECT id FROM vehicles);

-- Bulk update with subquery
UPDATE characters
SET affiliation = 'Resistance'
WHERE id IN (
    SELECT c.id 
    FROM characters c
    INNER JOIN planets p ON c.planet_id = p.id
    WHERE p.name = 'Tatooine'
    AND c.affiliation = 'Independent'
);

-- Update with aggregate function
UPDATE planets
SET population = (
    SELECT COUNT(*) 
    FROM characters 
    WHERE characters.planet_id = planets.id
) * 1000000
WHERE population IS NULL;

-- Safe cascading delete pattern
BEGIN TRANSACTION;

-- Delete character's vehicle relationships first
DELETE FROM character_vehicles
WHERE character_id = (SELECT id FROM characters WHERE name = 'Obsolete Character');

-- Then delete the character
DELETE FROM characters
WHERE name = 'Obsolete Character';

COMMIT;

-- ============================================
-- Common Mistakes to Avoid
-- ============================================

-- MISTAKE 1: Forgetting WHERE clause (DON'T DO THIS!)
-- UPDATE characters SET affiliation = 'Empire';
-- This would change EVERYONE's affiliation!

-- MISTAKE 2: Not using transactions for important changes
-- Always use BEGIN TRANSACTION...COMMIT for critical updates

-- MISTAKE 3: Not checking before deleting
-- Always SELECT before DELETE to see what you're removing

-- CORRECT PATTERN:
BEGIN TRANSACTION;
SELECT * FROM characters WHERE height < 50;  -- Check first
DELETE FROM characters WHERE height < 50;     -- Then delete
COMMIT;
