CREATE TYPE block_type AS ENUM ('fraud','wrong_details','other');

CREATE TABLE payment_block (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id      uuid NOT NULL,
  type           block_type NOT NULL,
  reason         text NOT NULL,
  created_at     timestamptz NOT NULL DEFAULT now(),
  created_by     varchar(100) NOT NULL,
  expires_at     timestamptz NULL,
  released_at    timestamptz NULL,
  released_by    varchar(100),
  release_reason text,
  CONSTRAINT chk_release_fields CHECK (
    (released_at IS NULL AND released_by IS NULL AND release_reason IS NULL) OR
    (released_at IS NOT NULL)
  )
);

CREATE VIEW v_active_payment_block AS
SELECT *
FROM payment_block
WHERE released_at IS NULL
  AND (expires_at IS NULL OR now() < expires_at);

CREATE UNIQUE INDEX uq_active_block_per_client
ON payment_block(client_id)
WHERE released_at IS NULL AND (expires_at IS NULL OR now() < expires_at);

CREATE INDEX idx_block_client ON payment_block(client_id);
CREATE INDEX idx_block_created_at ON payment_block(created_at);