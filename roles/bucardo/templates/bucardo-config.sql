CREATE TABLE bucardo.bucardo_config (
  name     TEXT        NOT NULL, -- short unique name, maps to %config inside Bucardo
  setting  TEXT        NOT NULL,
  about    TEXT            NULL, -- long description
  type     TEXT            NULL, -- sync or goat
  item     TEXT            NULL, -- which specific sync or goat
  cdate    TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE bucardo.bucardo_config IS $$Contains configuration variables for a specific Bucardo instance$$;

CREATE UNIQUE INDEX bucardo_config_unique ON bucardo.bucardo_config(LOWER(name)) WHERE item IS NULL;
CREATE UNIQUE INDEX bucardo_config_unique_name ON bucardo.bucardo_config(name,item,type) WHERE item IS NOT NULL;
ALTER TABLE bucardo.bucardo_config ADD CONSTRAINT valid_config_type CHECK (type IN ('sync','goat'));

ALTER TABLE bucardo.bucardo_config ADD CONSTRAINT valid_config_isolation_level
CHECK (name <> 'isolation_level' OR (setting IN ('serializable','repeatable read')));

