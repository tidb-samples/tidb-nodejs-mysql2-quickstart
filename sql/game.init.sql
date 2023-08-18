-- Create `players` table.
DROP TABLE IF EXISTS players;
CREATE TABLE players (
    `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'The unique ID of the player.',
    `coins` INT(11) COMMENT 'The number of coins that the player had.',
    `goods` INT(11) COMMENT 'The number of goods that the player had.',
    PRIMARY KEY (`id`)
);

-- Seed `players` table.
INSERT INTO
    players (`id`, `coins`, `goods`)
VALUES
    (1, 1, 1024),
    (2, 2, 512),
    (3, 3, 256),
    (4, 4, 128),
    (5, 5, 64),
    (6, 6, 32),
    (7, 7, 16),
    (8, 8, 8),
    (9, 9, 4),
    (10, 10, 2),
    (11, 11, 1);



