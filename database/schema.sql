CREATE TABLE IF NOT EXISTS readings (
    id        SERIAL PRIMARY KEY,
    temp      REAL,
    setpoint  REAL,
    humidity  REAL,
    timestamp TIMESTAMP DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS relay_logs (
    id           SERIAL PRIMARY KEY,
    state        VARCHAR(10),
    triggered_by VARCHAR(50),
    timestamp    TIMESTAMP DEFAULT NOW()
);
