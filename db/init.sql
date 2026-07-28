-- =============================================================
-- Medicine Selling App — Database Initialisation Script
-- Compatible with MySQL 8.0
-- =============================================================

CREATE DATABASE IF NOT EXISTS medicine_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medicine_db;

-- ── User Screen Activity Log ──────────────────────────────────
CREATE TABLE IF NOT EXISTS users_screen_activity_log (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id        BIGINT       NULL COMMENT 'NULL for unauthenticated attempts',
    ip_address     VARCHAR(45)  NOT NULL,
    activity_type  VARCHAR(50)  NOT NULL COMMENT 'LOGIN,LOGIN_FAILED,REGISTER,SCREEN_VIEW,UNAUTHORIZED_ACCESS',
    screen_name    VARCHAR(100) NOT NULL,
    error_message  VARCHAR(500) NULL,
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_usal_user   (user_id),
    INDEX idx_usal_type   (activity_type),
    INDEX idx_usal_ip     (ip_address),
    INDEX idx_usal_time   (created_at)
);

-- ── Audit Log ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS audit_log (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    action_type   VARCHAR(50)  NOT NULL,
    entity_type   VARCHAR(50)  NOT NULL,
    entity_id     BIGINT,
    performed_by  VARCHAR(100) NOT NULL,
    old_value     TEXT,
    new_value     TEXT,
    remarks       VARCHAR(255),
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_al_entity (entity_type, entity_id),
    INDEX idx_al_action (action_type),
    INDEX idx_al_by     (performed_by)
);

-- ── Users ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(20)  NOT NULL DEFAULT 'GUEST',
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ── Medicines ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS medicines (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    description TEXT,
    category    VARCHAR(100),
    image_url   VARCHAR(500),
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ── SKU Master ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sku_master (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    sku_code            VARCHAR(50)    NOT NULL UNIQUE,
    medicine_id         BIGINT         NOT NULL,
    unit_label          VARCHAR(150)   NOT NULL,
    unit_price          DECIMAL(10,2)  NOT NULL,
    quantity_available  INT            NOT NULL DEFAULT 0,
    is_active           BOOLEAN        NOT NULL DEFAULT TRUE,
    created_at          DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sku_med FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE CASCADE,
    INDEX idx_sku_med (medicine_id)
);

-- ── Addresses ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS addresses (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT       NOT NULL,
    recipient_name  VARCHAR(150) NOT NULL,
    phone           VARCHAR(20),
    address_line1   VARCHAR(255) NOT NULL,
    address_line2   VARCHAR(255),
    city            VARCHAR(100) NOT NULL,
    state           VARCHAR(100),
    pincode         VARCHAR(20)  NOT NULL,
    is_default      BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_addr (user_id, address_line1, city, pincode)
);

-- ── Customers ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS customers (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_name       VARCHAR(150) NOT NULL,
    customer_email      VARCHAR(150),
    customer_phone      VARCHAR(20),
    default_address_id  BIGINT,
    created_by_user_id  BIGINT       NOT NULL,
    is_active           BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ── Orders ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id             BIGINT         NOT NULL,
    user_email          VARCHAR(150)   NOT NULL,
    customer_id         BIGINT,
    shipping_address_id BIGINT,
    total_amount        DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
    status              VARCHAR(30)    NOT NULL DEFAULT 'PENDING',
    created_at          DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,      status_updated_at   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,    INDEX idx_order_user   (user_id),
    INDEX idx_order_status (status)
);

-- ── Order Items ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_items (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id        BIGINT         NOT NULL,
    sku_id          BIGINT         NOT NULL,
    medicine_name   VARCHAR(200)   NOT NULL,
    sku_code        VARCHAR(50)    NOT NULL,
    unit_label      VARCHAR(150)   NOT NULL,
    quantity        INT            NOT NULL,
    unit_price      DECIMAL(10,2)  NOT NULL,
    CONSTRAINT fk_oi_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_oi_order (order_id)
);

-- ── Payments ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS payments (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id        BIGINT         NOT NULL UNIQUE,
    amount          DECIMAL(12,2)  NOT NULL,
    payment_method  VARCHAR(50)    NOT NULL DEFAULT 'COD',
    payment_status  VARCHAR(30)    NOT NULL DEFAULT 'PENDING',
    paid_at         DATETIME,
    created_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pay_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- =============================================================
-- SEED DATA
-- =============================================================

-- Admin user  (password = admin123  →  BCrypt hash)
INSERT IGNORE INTO users (name, email, password_hash, role) VALUES
  ('Admin User', 'admin@medicine.com',
   '$2a$12$UZYYqh0M6k1KH8OjhPNaY.OEb7fOW7jcm7VY4lG2GRlAJ.ZVPB4dG',
   'ADMIN');

-- Sample medicines (20 entries across 5 categories)
INSERT IGNORE INTO medicines (name, description, category) VALUES
  -- Antibiotics (4)
  ('Amoxicillin 500mg',    'Broad-spectrum antibiotic for bacterial infections',            'Antibiotics'),
  ('Azithromycin 250mg',   'Macrolide antibiotic for respiratory infections',               'Antibiotics'),
  ('Ciprofloxacin 500mg',  'Fluoroquinolone antibiotic for UTI and skin infections',        'Antibiotics'),
  ('Doxycycline 100mg',    'Tetracycline antibiotic for acne and Lyme disease',             'Antibiotics'),
  -- Pain Relief (4)
  ('Paracetamol 500mg',    'Common analgesic and antipyretic for fever and mild pain',      'Pain Relief'),
  ('Ibuprofen 400mg',      'NSAID for pain, fever and inflammation',                        'Pain Relief'),
  ('Diclofenac 50mg',      'NSAID used for arthritis and muscle pain',                      'Pain Relief'),
  ('Aspirin 325mg',        'Analgesic and antiplatelet for heart health',                   'Pain Relief'),
  -- Vitamins (4)
  ('Vitamin C 500mg',      'Antioxidant vitamin for immune support',                        'Vitamins'),
  ('Vitamin D3 60000 IU',  'Cholecalciferol for bone health and immunity',                  'Vitamins'),
  ('Vitamin B12 1500mcg',  'Methylcobalamin for nerve health and energy',                   'Vitamins'),
  ('Multivitamin Tablets', 'Daily multivitamin with minerals for overall health',           'Vitamins'),
  -- Antacids (4)
  ('Pantoprazole 40mg',    'Proton pump inhibitor for acid reflux and ulcers',              'Antacids'),
  ('Omeprazole 20mg',      'PPI for gastroesophageal reflux disease',                       'Antacids'),
  ('Antacid Syrup 200ml',  'Aluminium hydroxide suspension for instant acidity relief',     'Antacids'),
  ('Ranitidine 150mg',     'H2 blocker for heartburn and stomach ulcers',                   'Antacids'),
  -- Allergy (4)
  ('Cetirizine 10mg',      'Non-drowsy antihistamine for allergic rhinitis',                'Allergy'),
  ('Loratadine 10mg',      'Long-acting antihistamine for seasonal allergies',              'Allergy'),
  ('Fexofenadine 120mg',   'Non-sedating antihistamine for urticaria and hay fever',        'Allergy'),
  ('Montelukast 10mg',     'Leukotriene antagonist for asthma and allergic rhinitis',       'Allergy');

-- SKUs (2-3 per medicine)
INSERT IGNORE INTO sku_master (sku_code, medicine_id, unit_label, unit_price, quantity_available) VALUES
  -- Amoxicillin 500mg (id=1)
  ('AMX-500-10C', 1, 'Strip of 10 Capsules',   45.00, 200),
  ('AMX-500-30C', 1, 'Pack of 30 Capsules',    120.00, 100),
  -- Azithromycin 250mg (id=2)
  ('AZI-250-6T',  2, 'Strip of 6 Tablets',      85.00, 150),
  ('AZI-250-3T',  2, 'Strip of 3 Tablets',       48.00, 200),
  -- Ciprofloxacin 500mg (id=3)
  ('CIP-500-10T', 3, 'Strip of 10 Tablets',     60.00, 180),
  ('CIP-500-20T', 3, 'Pack of 20 Tablets',     115.00,  90),
  -- Doxycycline 100mg (id=4)
  ('DOX-100-10C', 4, 'Strip of 10 Capsules',    55.00, 160),
  -- Paracetamol 500mg (id=5)
  ('PAR-500-10T', 5, 'Strip of 10 Tablets',     15.00, 500),
  ('PAR-500-15T', 5, 'Strip of 15 Tablets',     22.00, 400),
  ('PAR-500-100T',5, 'Bottle of 100 Tablets',  140.00, 120),
  -- Ibuprofen 400mg (id=6)
  ('IBU-400-10T', 6, 'Strip of 10 Tablets',     30.00, 350),
  ('IBU-400-30T', 6, 'Pack of 30 Tablets',      85.00, 150),
  -- Diclofenac 50mg (id=7)
  ('DIC-050-10T', 7, 'Strip of 10 Tablets',     40.00, 250),
  ('DIC-050-GEL', 7, 'Gel Tube 30g',            95.00, 100),
  -- Aspirin 325mg (id=8)
  ('ASP-325-14T', 8, 'Strip of 14 Tablets',     25.00, 300),
  -- Vitamin C 500mg (id=9)
  ('VTC-500-30T', 9, 'Pack of 30 Tablets',      75.00, 200),
  ('VTC-500-60T', 9, 'Pack of 60 Tablets',     140.00, 100),
  -- Vitamin D3 (id=10)
  ('VTD-60K-4C', 10, 'Pack of 4 Capsules',      65.00, 250),
  -- Vitamin B12 (id=11)
  ('VTB-15K-30T',11, 'Strip of 30 Tablets',     110.00, 150),
  -- Multivitamin (id=12)
  ('MVT-001-30T',12, 'Pack of 30 Tablets',       90.00, 200),
  ('MVT-001-60T',12, 'Pack of 60 Tablets',      165.00,  80),
  -- Pantoprazole (id=13)
  ('PAN-040-15T',13, 'Strip of 15 Tablets',      65.00, 300),
  -- Omeprazole (id=14)
  ('OMP-020-10C',14, 'Strip of 10 Capsules',     45.00, 250),
  ('OMP-020-30C',14, 'Pack of 30 Capsules',     120.00, 100),
  -- Antacid Syrup (id=15)
  ('ANT-SYR-200',15, 'Bottle 200ml',             80.00, 150),
  -- Ranitidine (id=16)
  ('RAN-150-10T',16, 'Strip of 10 Tablets',      35.00, 200),
  -- Cetirizine (id=17)
  ('CET-010-10T',17, 'Strip of 10 Tablets',      25.00, 350),
  ('CET-010-30T',17, 'Pack of 30 Tablets',       70.00, 150),
  -- Loratadine (id=18)
  ('LOR-010-10T',18, 'Strip of 10 Tablets',      30.00, 300),
  -- Fexofenadine (id=19)
  ('FEX-120-10T',19, 'Strip of 10 Tablets',      55.00, 200),
  -- Montelukast (id=20)
  ('MON-010-10T',20, 'Strip of 10 Tablets',      85.00, 180);

-- Sample customers
INSERT IGNORE INTO customers (customer_name, customer_email, customer_phone, created_by_user_id) VALUES
  ('Ravi Kumar',  'ravi@example.com',  '9876543210', 1),
  ('Priya Sharma','priya@example.com', '9845678901', 1);

-- ── Schema migrations (idempotent) ───────────────────────────
-- Add status_updated_at if missing (MySQL 8.0 compatible)
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'orders'
      AND COLUMN_NAME  = 'status_updated_at'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE orders ADD COLUMN status_updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
