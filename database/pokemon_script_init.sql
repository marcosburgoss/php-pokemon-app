DELIMITER $$
USE pokemonPlus$$

CREATE TABLE IF NOT EXISTS pokemon_deleted (
    id INT NOT NULL AUTO_INCREMENT,
    deleted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pokemon_id INT NOT NULL,
    pokemon_name VARCHAR(40) NOT NULL,
    PRIMARY KEY (id)
)$$

DROP TRIGGER IF EXISTS pokemon_deleted_trigger$$
CREATE TRIGGER pokemon_deleted_trigger AFTER DELETE ON pokemon
FOR EACH ROW
BEGIN
    INSERT INTO pokemon_deleted (pokemon_id, pokemon_name)
    VALUES (OLD.pok_id, OLD.pok_name);
END$$

CREATE TABLE IF NOT EXISTS pokemon_created (
    id INT NOT NULL AUTO_INCREMENT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pokemon_id INT NOT NULL,
    pokemon_name VARCHAR(40) NOT NULL,
    PRIMARY KEY (id)
)$$

DROP TRIGGER IF EXISTS pokemon_created_trigger$$
CREATE TRIGGER pokemon_created_trigger AFTER INSERT ON pokemon
FOR EACH ROW
BEGIN
    INSERT INTO pokemon_created (pokemon_id, pokemon_name)
    VALUES (NEW.pok_id, NEW.pok_name);
END$$

ALTER TABLE pokemon ADD COLUMN alias VARCHAR(10)$$

DROP FUNCTION IF EXISTS create_alias$$
CREATE FUNCTION create_alias(pokName VARCHAR(40), pokId INT)
RETURNS VARCHAR(10)
DETERMINISTIC
NO SQL
BEGIN
    RETURN CONCAT(LEFT(pokName, 3), '-', pokId);
END$$

DROP PROCEDURE IF EXISTS insert_alias$$
CREATE PROCEDURE insert_alias()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_pokId INT;
    DECLARE v_pokName VARCHAR(40);
    DECLARE cur CURSOR FOR SELECT pok_id, pok_name FROM pokemon;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_pokId, v_pokName;
        IF done THEN
            LEAVE read_loop;
        END IF;
        UPDATE pokemon AS p
        SET p.alias = create_alias(v_pokName, v_pokId)
        WHERE p.pok_id = v_pokId;
    END LOOP;
    CLOSE cur;
END$$

CALL insert_alias()$$

DROP TRIGGER IF EXISTS alias_created_trigger$$
CREATE TRIGGER alias_created_trigger BEFORE INSERT ON pokemon
FOR EACH ROW
BEGIN
    SET NEW.alias = create_alias(NEW.pok_name, NEW.pok_id);
END$$

ALTER TABLE pokemon ADD COLUMN pok_image VARCHAR(100)$$

DROP PROCEDURE IF EXISTS insert_image$$
CREATE PROCEDURE insert_image()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_pokId INT;
    DECLARE cur CURSOR FOR SELECT pok_id FROM pokemon;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_pokId;
        IF done THEN
            LEAVE read_loop;
        END IF;
        IF v_pokId < 10 THEN
            UPDATE pokemon
            SET pok_image = CONCAT('https://assets.pokemon.com/assets/cms2/img/pokedex/detail/00', v_pokId, '.png')
            WHERE pok_id = v_pokId;
        ELSEIF v_pokId < 100 THEN
            UPDATE pokemon
            SET pok_image = CONCAT('https://assets.pokemon.com/assets/cms2/img/pokedex/detail/0', v_pokId, '.png')
            WHERE pok_id = v_pokId;
        ELSE
            UPDATE pokemon
            SET pok_image = CONCAT('https://assets.pokemon.com/assets/cms2/img/pokedex/detail/', v_pokId, '.png')
            WHERE pok_id = v_pokId;
        END IF;
    END LOOP;
    CLOSE cur;
END$$

CALL insert_image()$$
