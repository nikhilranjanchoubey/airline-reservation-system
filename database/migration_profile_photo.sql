-- ==============================================================================
-- Migration: Add profile_photo to users table
-- Target Database: MySQL 8.x
-- ==============================================================================

USE skytech_db;

-- 1. Safely add profile_photo column if not present
SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'skytech_db' 
      AND TABLE_NAME = 'users' 
      AND COLUMN_NAME = 'profile_photo'
);

SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE users ADD COLUMN profile_photo VARCHAR(255) NULL AFTER date_of_birth', 
    'SELECT "profile_photo column already exists" AS status'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
