CREATE TABLE IF NOT EXISTS payment_methods (
    payment_method_id  SERIAL       PRIMARY KEY,
    name               VARCHAR(30)  NOT NULL UNIQUE
);
