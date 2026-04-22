-- =============================================================================
--         BLOOD BANK INVENTORY MANAGEMENT SYSTEM
--         Full DBMS Project in MariaDB / MySQL SQL
--         Version: 2.0 (Fixed - Compatible with all MariaDB versions)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. DATABASE SETUP
-- -----------------------------------------------------------------------------
DROP DATABASE IF EXISTS BloodBankDB;
CREATE DATABASE BloodBankDB
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE BloodBankDB;

-- =============================================================================
-- 1. TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1.1 Blood Types (lookup)
-- -----------------------------------------------------------------------------
CREATE TABLE BloodType (
    blood_type_id   TINYINT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
    blood_group     CHAR(3)           NOT NULL,
    rh_factor       CHAR(1)           NOT NULL,
    UNIQUE KEY uq_blood_type (blood_group, rh_factor),
    CONSTRAINT chk_blood_group CHECK (blood_group IN ('A','B','AB','O')),
    CONSTRAINT chk_rh          CHECK (rh_factor   IN ('+','-'))
);

-- -----------------------------------------------------------------------------
-- 1.2 Blood Banks / Branches
-- -----------------------------------------------------------------------------
CREATE TABLE BloodBank (
    bank_id         INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
    bank_name       VARCHAR(100)  NOT NULL,
    address         VARCHAR(255)  NOT NULL,
    city            VARCHAR(80)   NOT NULL,
    state           VARCHAR(80)   NOT NULL,
    pin_code        CHAR(10),
    phone           VARCHAR(15)   NOT NULL,
    email           VARCHAR(100),
    license_no      VARCHAR(50)   UNIQUE,
    is_active       TINYINT(1)    NOT NULL DEFAULT 1,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 1.3 Staff
-- -----------------------------------------------------------------------------
CREATE TABLE Staff (
    staff_id        INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    bank_id         INT UNSIGNED   NOT NULL,
    first_name      VARCHAR(60)    NOT NULL,
    last_name       VARCHAR(60)    NOT NULL,
    role            VARCHAR(20)    NOT NULL,
    phone           VARCHAR(15),
    email           VARCHAR(100)   UNIQUE,
    hire_date       DATE           NOT NULL,
    is_active       TINYINT(1)     NOT NULL DEFAULT 1,
    CONSTRAINT fk_staff_bank FOREIGN KEY (bank_id)
        REFERENCES BloodBank(bank_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_staff_role CHECK (role IN ('Doctor','Nurse','Technician','Admin','Manager'))
);

-- -----------------------------------------------------------------------------
-- 1.4 Donors
-- -----------------------------------------------------------------------------
CREATE TABLE Donor (
    donor_id        INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(60)    NOT NULL,
    last_name       VARCHAR(60)    NOT NULL,
    dob             DATE           NOT NULL,
    gender          VARCHAR(10)    NOT NULL,
    blood_type_id   TINYINT UNSIGNED NOT NULL,
    phone           VARCHAR(15)    NOT NULL,
    email           VARCHAR(100),
    address         VARCHAR(255),
    city            VARCHAR(80),
    state           VARCHAR(80),
    national_id     VARCHAR(50)    UNIQUE,
    is_eligible     TINYINT(1)     NOT NULL DEFAULT 1,
    last_donated_on DATE,
    total_donations INT UNSIGNED   NOT NULL DEFAULT 0,
    created_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_donor_bloodtype FOREIGN KEY (blood_type_id)
        REFERENCES BloodType(blood_type_id),
    CONSTRAINT chk_donor_gender CHECK (gender IN ('Male','Female','Other'))
);

-- -----------------------------------------------------------------------------
-- 1.5 Patients / Recipients
-- -----------------------------------------------------------------------------
CREATE TABLE Patient (
    patient_id      INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(60)    NOT NULL,
    last_name       VARCHAR(60)    NOT NULL,
    dob             DATE,
    gender          VARCHAR(10),
    blood_type_id   TINYINT UNSIGNED,
    phone           VARCHAR(15),
    email           VARCHAR(100),
    hospital_name   VARCHAR(150),
    ward            VARCHAR(80),
    doctor_in_charge VARCHAR(120),
    admission_date  DATE,
    national_id     VARCHAR(50),
    created_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_patient_bloodtype FOREIGN KEY (blood_type_id)
        REFERENCES BloodType(blood_type_id)
);

-- -----------------------------------------------------------------------------
-- 1.6 Blood Components
-- -----------------------------------------------------------------------------
CREATE TABLE BloodComponent (
    component_id    TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    component_name  VARCHAR(80)  NOT NULL UNIQUE,
    description     TEXT,
    shelf_life_days SMALLINT UNSIGNED NOT NULL
);

-- -----------------------------------------------------------------------------
-- 1.7 Blood Inventory / Stock Units
-- -----------------------------------------------------------------------------
CREATE TABLE BloodUnit (
    unit_id          INT UNSIGNED      AUTO_INCREMENT PRIMARY KEY,
    bank_id          INT UNSIGNED      NOT NULL,
    blood_type_id    TINYINT UNSIGNED  NOT NULL,
    component_id     TINYINT UNSIGNED  NOT NULL,
    donor_id         INT UNSIGNED,
    bag_number       VARCHAR(50)       NOT NULL UNIQUE,
    volume_ml        SMALLINT UNSIGNED NOT NULL DEFAULT 450,
    collection_date  DATE              NOT NULL,
    expiry_date      DATE              NOT NULL,
    status           VARCHAR(20)       NOT NULL DEFAULT 'Available',
    tested           TINYINT(1)        NOT NULL DEFAULT 0,
    hiv_status       VARCHAR(10)       DEFAULT 'Pending',
    hbsag_status     VARCHAR(10)       DEFAULT 'Pending',
    hcv_status       VARCHAR(10)       DEFAULT 'Pending',
    vdrl_status      VARCHAR(10)       DEFAULT 'Pending',
    malaria_status   VARCHAR(10)       DEFAULT 'Pending',
    storage_location VARCHAR(50),
    collected_by     INT UNSIGNED,
    created_at       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                         ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_unit_bank      FOREIGN KEY (bank_id)       REFERENCES BloodBank(bank_id),
    CONSTRAINT fk_unit_bloodtype FOREIGN KEY (blood_type_id) REFERENCES BloodType(blood_type_id),
    CONSTRAINT fk_unit_component FOREIGN KEY (component_id)  REFERENCES BloodComponent(component_id),
    CONSTRAINT fk_unit_donor     FOREIGN KEY (donor_id)      REFERENCES Donor(donor_id),
    CONSTRAINT fk_unit_staff     FOREIGN KEY (collected_by)  REFERENCES Staff(staff_id),
    CONSTRAINT chk_unit_status   CHECK (status IN ('Available','Reserved','Issued','Expired','Discarded','Quarantine')),
    INDEX idx_unit_status   (status),
    INDEX idx_unit_expiry   (expiry_date),
    INDEX idx_unit_bloodtype(blood_type_id)
);

-- -----------------------------------------------------------------------------
-- 1.8 Donation Camps
-- -----------------------------------------------------------------------------
CREATE TABLE DonationCamp (
    camp_id         INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    bank_id         INT UNSIGNED   NOT NULL,
    camp_name       VARCHAR(120)   NOT NULL,
    venue           VARCHAR(255)   NOT NULL,
    city            VARCHAR(80),
    camp_date       DATE           NOT NULL,
    start_time      TIME,
    end_time        TIME,
    organizer_name  VARCHAR(120),
    target_units    SMALLINT UNSIGNED DEFAULT 0,
    units_collected SMALLINT UNSIGNED DEFAULT 0,
    status          VARCHAR(20)    NOT NULL DEFAULT 'Planned',
    notes           TEXT,
    CONSTRAINT fk_camp_bank   FOREIGN KEY (bank_id) REFERENCES BloodBank(bank_id),
    CONSTRAINT chk_camp_status CHECK (status IN ('Planned','Ongoing','Completed','Cancelled'))
);

-- -----------------------------------------------------------------------------
-- 1.9 Donation Records
-- -----------------------------------------------------------------------------
CREATE TABLE Donation (
    donation_id      INT UNSIGNED   AUTO_INCREMENT PRIMARY KEY,
    donor_id         INT UNSIGNED   NOT NULL,
    bank_id          INT UNSIGNED   NOT NULL,
    camp_id          INT UNSIGNED,
    staff_id         INT UNSIGNED,
    unit_id          INT UNSIGNED,
    donation_date    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    volume_ml        SMALLINT UNSIGNED NOT NULL DEFAULT 450,
    hemoglobin_g     DECIMAL(4,1),
    bp_systolic      SMALLINT,
    bp_diastolic     SMALLINT,
    pulse_bpm        SMALLINT,
    weight_kg        DECIMAL(5,1),
    passed_screening TINYINT(1)     NOT NULL DEFAULT 1,
    rejection_reason VARCHAR(255),
    notes            TEXT,
    CONSTRAINT fk_donation_donor FOREIGN KEY (donor_id) REFERENCES Donor(donor_id),
    CONSTRAINT fk_donation_bank  FOREIGN KEY (bank_id)  REFERENCES BloodBank(bank_id),
    CONSTRAINT fk_donation_camp  FOREIGN KEY (camp_id)  REFERENCES DonationCamp(camp_id),
    CONSTRAINT fk_donation_staff FOREIGN KEY (staff_id) REFERENCES Staff(staff_id),
    CONSTRAINT fk_donation_unit  FOREIGN KEY (unit_id)  REFERENCES BloodUnit(unit_id)
);

-- -----------------------------------------------------------------------------
-- 1.10 Blood Requests
-- -----------------------------------------------------------------------------
CREATE TABLE BloodRequest (
    request_id    INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    patient_id    INT UNSIGNED     NOT NULL,
    bank_id       INT UNSIGNED     NOT NULL,
    blood_type_id TINYINT UNSIGNED NOT NULL,
    component_id  TINYINT UNSIGNED NOT NULL,
    units_needed  TINYINT UNSIGNED NOT NULL DEFAULT 1,
    priority      VARCHAR(15)      NOT NULL DEFAULT 'Routine',
    request_date  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    required_by   DATETIME,
    status        VARCHAR(25)      NOT NULL DEFAULT 'Pending',
    approved_by   INT UNSIGNED,
    notes         TEXT,
    CONSTRAINT fk_req_patient   FOREIGN KEY (patient_id)   REFERENCES Patient(patient_id),
    CONSTRAINT fk_req_bank      FOREIGN KEY (bank_id)      REFERENCES BloodBank(bank_id),
    CONSTRAINT fk_req_bloodtype FOREIGN KEY (blood_type_id)REFERENCES BloodType(blood_type_id),
    CONSTRAINT fk_req_component FOREIGN KEY (component_id) REFERENCES BloodComponent(component_id),
    CONSTRAINT fk_req_staff     FOREIGN KEY (approved_by)  REFERENCES Staff(staff_id),
    CONSTRAINT chk_req_priority CHECK (priority IN ('Routine','Urgent','Emergency')),
    CONSTRAINT chk_req_status   CHECK (status IN ('Pending','Approved','Partially Fulfilled','Fulfilled','Cancelled','Rejected')),
    INDEX idx_req_status  (status),
    INDEX idx_req_priority(priority)
);

-- -----------------------------------------------------------------------------
-- 1.11 Blood Issuance
-- -----------------------------------------------------------------------------
CREATE TABLE BloodIssuance (
    issuance_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    request_id  INT UNSIGNED NOT NULL,
    unit_id     INT UNSIGNED NOT NULL UNIQUE,
    issued_by   INT UNSIGNED NOT NULL,
    issued_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    received_by VARCHAR(120),
    notes       TEXT,
    CONSTRAINT fk_iss_request FOREIGN KEY (request_id) REFERENCES BloodRequest(request_id),
    CONSTRAINT fk_iss_unit    FOREIGN KEY (unit_id)    REFERENCES BloodUnit(unit_id),
    CONSTRAINT fk_iss_staff   FOREIGN KEY (issued_by)  REFERENCES Staff(staff_id)
);

-- -----------------------------------------------------------------------------
-- 1.12 Cross Match Tests
-- -----------------------------------------------------------------------------
CREATE TABLE CrossMatchTest (
    test_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    request_id INT UNSIGNED NOT NULL,
    unit_id    INT UNSIGNED NOT NULL,
    tested_by  INT UNSIGNED,
    test_date  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    result     VARCHAR(15)  NOT NULL DEFAULT 'Pending',
    notes      TEXT,
    CONSTRAINT fk_cm_request FOREIGN KEY (request_id) REFERENCES BloodRequest(request_id),
    CONSTRAINT fk_cm_unit    FOREIGN KEY (unit_id)    REFERENCES BloodUnit(unit_id),
    CONSTRAINT fk_cm_staff   FOREIGN KEY (tested_by)  REFERENCES Staff(staff_id),
    CONSTRAINT chk_cm_result CHECK (result IN ('Compatible','Incompatible','Pending'))
);

-- -----------------------------------------------------------------------------
-- 1.13 Audit Log
-- -----------------------------------------------------------------------------
CREATE TABLE AuditLog (
    log_id     BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(60)     NOT NULL,
    operation  VARCHAR(10)     NOT NULL,
    record_id  INT UNSIGNED,
    changed_by VARCHAR(100)    DEFAULT 'system',
    changed_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    old_status VARCHAR(30),
    new_status VARCHAR(30)
);

-- =============================================================================
-- 2. TRIGGERS
-- =============================================================================

DELIMITER $$

-- 2.1 After donation → update donor stats
CREATE TRIGGER trg_after_donation_insert
AFTER INSERT ON Donation
FOR EACH ROW
BEGIN
    IF NEW.passed_screening = 1 THEN
        UPDATE Donor
        SET
            last_donated_on = DATE(NEW.donation_date),
            total_donations  = total_donations + 1,
            is_eligible      = 0
        WHERE donor_id = NEW.donor_id;
    END IF;
END$$

-- 2.2 Restore eligibility before new donation (90-day rule)
CREATE TRIGGER trg_restore_donor_eligibility
BEFORE INSERT ON Donation
FOR EACH ROW
BEGIN
    UPDATE Donor
    SET is_eligible = 1
    WHERE donor_id = NEW.donor_id
      AND last_donated_on IS NOT NULL
      AND DATEDIFF(CURDATE(), last_donated_on) >= 90;
END$$

-- 2.3 Auto-expire blood units on update
CREATE TRIGGER trg_expire_blood_units
BEFORE UPDATE ON BloodUnit
FOR EACH ROW
BEGIN
    IF NEW.expiry_date < CURDATE() AND NEW.status = 'Available' THEN
        SET NEW.status = 'Expired';
    END IF;
END$$

-- 2.4 Mark unit as Issued when issuance record added
CREATE TRIGGER trg_after_issuance_insert
AFTER INSERT ON BloodIssuance
FOR EACH ROW
BEGIN
    UPDATE BloodUnit
    SET status = 'Issued'
    WHERE unit_id = NEW.unit_id;
END$$

-- 2.5 Update request status when units are fulfilled
CREATE TRIGGER trg_check_request_fulfillment
AFTER INSERT ON BloodIssuance
FOR EACH ROW
BEGIN
    DECLARE issued_count TINYINT;
    DECLARE needed_count TINYINT;

    SELECT COUNT(*) INTO issued_count
    FROM BloodIssuance WHERE request_id = NEW.request_id;

    SELECT units_needed INTO needed_count
    FROM BloodRequest WHERE request_id = NEW.request_id;

    IF issued_count >= needed_count THEN
        UPDATE BloodRequest SET status = 'Fulfilled'
        WHERE request_id = NEW.request_id;
    ELSEIF issued_count > 0 THEN
        UPDATE BloodRequest SET status = 'Partially Fulfilled'
        WHERE request_id = NEW.request_id;
    END IF;
END$$

-- 2.6 Audit log on BloodUnit status change
CREATE TRIGGER trg_audit_blood_unit_update
AFTER UPDATE ON BloodUnit
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO AuditLog (table_name, operation, record_id, old_status, new_status)
        VALUES ('BloodUnit', 'UPDATE', OLD.unit_id, OLD.status, NEW.status);
    END IF;
END$$

DELIMITER ;

-- =============================================================================
-- 3. STORED PROCEDURES
-- =============================================================================

DELIMITER $$

-- 3.1 Register a new donor
CREATE PROCEDURE sp_register_donor (
    IN p_first_name  VARCHAR(60),
    IN p_last_name   VARCHAR(60),
    IN p_dob         DATE,
    IN p_gender      VARCHAR(10),
    IN p_blood_group CHAR(3),
    IN p_rh_factor   CHAR(1),
    IN p_phone       VARCHAR(15),
    IN p_email       VARCHAR(100),
    IN p_address     VARCHAR(255),
    IN p_city        VARCHAR(80),
    IN p_national_id VARCHAR(50)
)
BEGIN
    DECLARE v_blood_type_id TINYINT UNSIGNED;
    DECLARE v_age INT;

    SET v_age = TIMESTAMPDIFF(YEAR, p_dob, CURDATE());

    IF v_age < 18 OR v_age > 65 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Donor age must be between 18 and 65 years.';
    END IF;

    SELECT blood_type_id INTO v_blood_type_id
    FROM BloodType
    WHERE blood_group = p_blood_group AND rh_factor = p_rh_factor;

    IF v_blood_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid blood group or Rh factor.';
    END IF;

    INSERT INTO Donor (
        first_name, last_name, dob, gender, blood_type_id,
        phone, email, address, city, national_id
    ) VALUES (
        p_first_name, p_last_name, p_dob, p_gender, v_blood_type_id,
        p_phone, p_email, p_address, p_city, p_national_id
    );

    SELECT LAST_INSERT_ID() AS new_donor_id,
           'Donor registered successfully.' AS message;
END$$

-- 3.2 Add a blood unit to inventory
CREATE PROCEDURE sp_add_blood_unit (
    IN p_bank_id         INT UNSIGNED,
    IN p_blood_group     CHAR(3),
    IN p_rh_factor       CHAR(1),
    IN p_component_name  VARCHAR(80),
    IN p_donor_id        INT UNSIGNED,
    IN p_bag_number      VARCHAR(50),
    IN p_volume_ml       SMALLINT UNSIGNED,
    IN p_collection_date DATE,
    IN p_storage_loc     VARCHAR(50),
    IN p_staff_id        INT UNSIGNED
)
BEGIN
    DECLARE v_blood_type_id TINYINT UNSIGNED;
    DECLARE v_component_id  TINYINT UNSIGNED;
    DECLARE v_shelf_days    SMALLINT UNSIGNED;
    DECLARE v_expiry        DATE;

    SELECT blood_type_id INTO v_blood_type_id
    FROM BloodType WHERE blood_group = p_blood_group AND rh_factor = p_rh_factor;

    SELECT component_id, shelf_life_days INTO v_component_id, v_shelf_days
    FROM BloodComponent WHERE component_name = p_component_name;

    IF v_blood_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid blood type.';
    END IF;

    IF v_component_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid blood component.';
    END IF;

    SET v_expiry = DATE_ADD(p_collection_date, INTERVAL v_shelf_days DAY);

    INSERT INTO BloodUnit (
        bank_id, blood_type_id, component_id, donor_id,
        bag_number, volume_ml, collection_date, expiry_date,
        storage_location, collected_by, status
    ) VALUES (
        p_bank_id, v_blood_type_id, v_component_id, p_donor_id,
        p_bag_number, IFNULL(p_volume_ml, 450), p_collection_date, v_expiry,
        p_storage_loc, p_staff_id, 'Quarantine'
    );

    SELECT LAST_INSERT_ID() AS new_unit_id,
           v_expiry AS expiry_date,
           'Blood unit added. Status: Quarantine (pending tests).' AS message;
END$$

-- 3.3 Release unit after serology testing
CREATE PROCEDURE sp_release_unit_after_testing (
    IN p_unit_id  INT UNSIGNED,
    IN p_hiv      VARCHAR(10),
    IN p_hbsag    VARCHAR(10),
    IN p_hcv      VARCHAR(10),
    IN p_vdrl     VARCHAR(10),
    IN p_malaria  VARCHAR(10)
)
BEGIN
    DECLARE v_safe TINYINT DEFAULT 0;

    IF p_hiv = 'Negative' AND p_hbsag = 'Negative'
       AND p_hcv = 'Negative' AND p_vdrl = 'Negative'
       AND p_malaria = 'Negative' THEN
        SET v_safe = 1;
    END IF;

    UPDATE BloodUnit
    SET
        hiv_status     = p_hiv,
        hbsag_status   = p_hbsag,
        hcv_status     = p_hcv,
        vdrl_status    = p_vdrl,
        malaria_status = p_malaria,
        tested         = 1,
        status         = IF(v_safe = 1, 'Available', 'Discarded')
    WHERE unit_id = p_unit_id;

    SELECT IF(v_safe = 1,
        'Unit cleared. Now Available in inventory.',
        'Unit DISCARDED - reactive serology detected.') AS result;
END$$

-- 3.4 Issue blood to a patient request
CREATE PROCEDURE sp_issue_blood (
    IN p_request_id  INT UNSIGNED,
    IN p_unit_id     INT UNSIGNED,
    IN p_issued_by   INT UNSIGNED,
    IN p_received_by VARCHAR(120)
)
BEGIN
    DECLARE v_unit_status    VARCHAR(20);
    DECLARE v_unit_type      TINYINT UNSIGNED;
    DECLARE v_req_type       TINYINT UNSIGNED;
    DECLARE v_req_status     VARCHAR(25);

    SELECT status, blood_type_id INTO v_unit_status, v_unit_type
    FROM BloodUnit WHERE unit_id = p_unit_id;

    SELECT blood_type_id, status INTO v_req_type, v_req_status
    FROM BloodRequest WHERE request_id = p_request_id;

    IF v_unit_status != 'Available' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Unit is not available for issuance.';
    END IF;

    IF v_unit_type != v_req_type THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Blood type mismatch between unit and request.';
    END IF;

    IF v_req_status IN ('Fulfilled','Cancelled','Rejected') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Request is already closed.';
    END IF;

    UPDATE BloodUnit SET status = 'Reserved' WHERE unit_id = p_unit_id;

    INSERT INTO BloodIssuance (request_id, unit_id, issued_by, received_by)
    VALUES (p_request_id, p_unit_id, p_issued_by, p_received_by);

    SELECT 'Blood unit issued successfully.' AS message;
END$$

-- 3.5 Stock summary for a bank
CREATE PROCEDURE sp_stock_summary (IN p_bank_id INT UNSIGNED)
BEGIN
    UPDATE BloodUnit
    SET status = 'Expired'
    WHERE bank_id  = p_bank_id
      AND status   = 'Available'
      AND expiry_date < CURDATE();

    SELECT
        CONCAT(bt.blood_group, bt.rh_factor) AS blood_type,
        bc.component_name,
        COUNT(*)              AS total_units,
        SUM(bu.volume_ml)     AS total_volume_ml,
        MIN(bu.expiry_date)   AS earliest_expiry
    FROM   BloodUnit bu
    JOIN   BloodType      bt ON bt.blood_type_id = bu.blood_type_id
    JOIN   BloodComponent bc ON bc.component_id  = bu.component_id
    WHERE  bu.bank_id = p_bank_id
      AND  bu.status  = 'Available'
    GROUP BY CONCAT(bt.blood_group, bt.rh_factor), bc.component_name
    ORDER BY blood_type, bc.component_name;
END$$

-- 3.6 Check donor eligibility
CREATE PROCEDURE sp_check_donor_eligibility (IN p_donor_id INT UNSIGNED)
BEGIN
    SELECT
        d.donor_id,
        CONCAT(d.first_name, ' ', d.last_name)    AS donor_name,
        CONCAT(bt.blood_group, bt.rh_factor)       AS blood_type,
        d.last_donated_on,
        IFNULL(DATEDIFF(CURDATE(), d.last_donated_on), 999) AS days_since_last_donation,
        CASE
            WHEN d.last_donated_on IS NULL THEN 'Eligible - First time donor'
            WHEN DATEDIFF(CURDATE(), d.last_donated_on) >= 90 THEN 'Eligible'
            ELSE CONCAT('Ineligible - ',
                 90 - DATEDIFF(CURDATE(), d.last_donated_on),
                 ' days remaining')
        END AS eligibility_status
    FROM  Donor d
    JOIN  BloodType bt ON bt.blood_type_id = d.blood_type_id
    WHERE d.donor_id = p_donor_id;
END$$

-- 3.7 Expiring units alert
CREATE PROCEDURE sp_expiring_units (IN p_bank_id INT UNSIGNED, IN p_days INT)
BEGIN
    SELECT
        bu.unit_id,
        bu.bag_number,
        CONCAT(bt.blood_group, bt.rh_factor) AS blood_type,
        bc.component_name,
        bu.expiry_date,
        DATEDIFF(bu.expiry_date, CURDATE()) AS days_to_expire,
        bu.storage_location
    FROM   BloodUnit bu
    JOIN   BloodType      bt ON bt.blood_type_id = bu.blood_type_id
    JOIN   BloodComponent bc ON bc.component_id  = bu.component_id
    WHERE  bu.bank_id     = p_bank_id
      AND  bu.status      = 'Available'
      AND  bu.expiry_date BETWEEN CURDATE()
                              AND DATE_ADD(CURDATE(), INTERVAL p_days DAY)
    ORDER BY bu.expiry_date ASC;
END$$

DELIMITER ;

-- =============================================================================
-- 4. VIEWS
-- =============================================================================

-- 4.1 Live available inventory
CREATE VIEW vw_available_inventory AS
SELECT
    bb.bank_name,
    CONCAT(bt.blood_group, bt.rh_factor) AS blood_type,
    bc.component_name,
    COUNT(bu.unit_id)  AS units_available,
    SUM(bu.volume_ml)  AS total_ml
FROM   BloodUnit bu
JOIN   BloodBank      bb ON bb.bank_id       = bu.bank_id
JOIN   BloodType      bt ON bt.blood_type_id = bu.blood_type_id
JOIN   BloodComponent bc ON bc.component_id  = bu.component_id
WHERE  bu.status      = 'Available'
  AND  bu.tested      = 1
  AND  bu.expiry_date >= CURDATE()
GROUP BY bb.bank_name,
         CONCAT(bt.blood_group, bt.rh_factor),
         bc.component_name;

-- 4.2 Pending blood requests
CREATE VIEW vw_pending_requests AS
SELECT
    br.request_id,
    CONCAT(p.first_name, ' ', p.last_name)   AS patient_name,
    p.hospital_name,
    CONCAT(bt.blood_group, bt.rh_factor)      AS blood_type,
    bc.component_name,
    br.units_needed,
    br.priority,
    br.request_date,
    br.required_by,
    br.status
FROM   BloodRequest br
JOIN   Patient        p  ON p.patient_id     = br.patient_id
JOIN   BloodType      bt ON bt.blood_type_id = br.blood_type_id
JOIN   BloodComponent bc ON bc.component_id  = br.component_id
WHERE  br.status IN ('Pending','Partially Fulfilled')
ORDER BY
    FIELD(br.priority, 'Emergency','Urgent','Routine'),
    br.required_by;

-- 4.3 Donor donation history
CREATE VIEW vw_donor_history AS
SELECT
    d.donor_id,
    CONCAT(d.first_name, ' ', d.last_name)  AS donor_name,
    CONCAT(bt.blood_group, bt.rh_factor)     AS blood_type,
    dn.donation_date,
    dn.volume_ml,
    dn.passed_screening,
    bb.bank_name
FROM   Donation dn
JOIN   Donor      d  ON d.donor_id      = dn.donor_id
JOIN   BloodType  bt ON bt.blood_type_id= d.blood_type_id
JOIN   BloodBank  bb ON bb.bank_id      = dn.bank_id
ORDER BY dn.donation_date DESC;

-- 4.4 Expired / wasted units
CREATE VIEW vw_wasted_units AS
SELECT
    bu.unit_id,
    bu.bag_number,
    CONCAT(bt.blood_group, bt.rh_factor) AS blood_type,
    bc.component_name,
    bu.collection_date,
    bu.expiry_date,
    bu.status,
    bb.bank_name
FROM   BloodUnit bu
JOIN   BloodBank      bb ON bb.bank_id       = bu.bank_id
JOIN   BloodType      bt ON bt.blood_type_id = bu.blood_type_id
JOIN   BloodComponent bc ON bc.component_id  = bu.component_id
WHERE  bu.status IN ('Expired','Discarded');

-- 4.5 Camp performance
CREATE VIEW vw_camp_performance AS
SELECT
    dc.camp_id,
    dc.camp_name,
    dc.camp_date,
    dc.venue,
    bb.bank_name,
    dc.target_units,
    dc.units_collected,
    ROUND(dc.units_collected / NULLIF(dc.target_units, 0) * 100, 1) AS achievement_pct,
    dc.status
FROM   DonationCamp dc
JOIN   BloodBank bb ON bb.bank_id = dc.bank_id
ORDER BY dc.camp_date DESC;

-- =============================================================================
-- 5. SEED DATA
-- =============================================================================

-- Blood Types
INSERT INTO BloodType (blood_group, rh_factor) VALUES
('A', '+'), ('A', '-'),
('B', '+'), ('B', '-'),
('AB','+'), ('AB','-'),
('O', '+'), ('O', '-');

-- Blood Components
INSERT INTO BloodComponent (component_name, description, shelf_life_days) VALUES
('Whole Blood',           'Unprocessed donated blood',                        35),
('Packed Red Blood Cells','Concentrated RBC with reduced plasma',              42),
('Fresh Frozen Plasma',   'Plasma rich in clotting factors, stored frozen',  365),
('Platelets',             'Platelet concentrate',                               5),
('Cryoprecipitate',       'Cold-insoluble fraction of plasma',               365),
('Granulocytes',          'White cell concentrate for severe infections',       1);

-- Blood Banks
INSERT INTO BloodBank (bank_name, address, city, state, pin_code, phone, email, license_no) VALUES
('City Central Blood Bank',   '12 MG Road',    'Mumbai',  'Maharashtra', '400001', '022-11112222', 'central@bloodbank.in', 'BB-MH-001'),
('North District Blood Bank', '45 GTK Road',   'Delhi',   'Delhi',       '110009', '011-33334444', 'north@bloodbank.in',   'BB-DL-001'),
('Green Cross Blood Centre',  '78 Anna Salai', 'Chennai', 'Tamil Nadu',  '600002', '044-55556666', 'green@bloodbank.in',   'BB-TN-001');

-- Staff
INSERT INTO Staff (bank_id, first_name, last_name, role, phone, email, hire_date) VALUES
(1, 'Anita',  'Sharma', 'Doctor',     '9876543210', 'anita@bloodbank.in',  '2019-05-01'),
(1, 'Ravi',   'Verma',  'Technician', '9876543211', 'ravi@bloodbank.in',   '2020-03-15'),
(2, 'Priya',  'Nair',   'Nurse',      '9876543212', 'priya@bloodbank.in',  '2021-07-01'),
(3, 'Suresh', 'Kumar',  'Manager',    '9876543213', 'suresh@bloodbank.in', '2018-01-10');

-- Donors
INSERT INTO Donor (first_name, last_name, dob, gender, blood_type_id, phone, email, address, city, national_id) VALUES
('Arjun',   'Mehta',  '1990-04-12', 'Male',   7, '9000000001', 'arjun@mail.com',   '11 Rose Lane',   'Mumbai',  'UID100001'),
('Deepa',   'Reddy',  '1985-08-22', 'Female', 1, '9000000002', 'deepa@mail.com',   '22 Lake View',   'Delhi',   'UID100002'),
('Kiran',   'Singh',  '1995-11-05', 'Male',   3, '9000000003', 'kiran@mail.com',   '33 Park Street', 'Mumbai',  'UID100003'),
('Lalitha', 'Menon',  '1992-02-28', 'Female', 5, '9000000004', 'lalitha@mail.com', '44 River Road',  'Chennai', 'UID100004'),
('Mohit',   'Joshi',  '1988-06-14', 'Male',   8, '9000000005', 'mohit@mail.com',   '55 Hill Top',    'Delhi',   'UID100005');

-- Patients
INSERT INTO Patient (first_name, last_name, dob, gender, blood_type_id, phone, hospital_name, ward, doctor_in_charge, admission_date) VALUES
('Ramesh', 'Iyer',   '1960-03-17', 'Male',   7, '8800000001', 'Apollo Hospital',  'ICU',      'Dr. Sharma', '2025-01-10'),
('Sunita', 'Bose',   '1975-11-02', 'Female', 3, '8800000002', 'Fortis Hospital',  'Oncology', 'Dr. Kapoor', '2025-01-12'),
('Arun',   'Das',    '1990-07-25', 'Male',   5, '8800000003', 'AIIMS Delhi',      'Surgery',  'Dr. Nair',   '2025-01-15'),
('Meena',  'Pillai', '1982-09-09', 'Female', 1, '8800000004', 'Manipal Hospital', 'Maternity','Dr. Gupta',  '2025-01-18');

-- Blood Units
INSERT INTO BloodUnit (bank_id, blood_type_id, component_id, donor_id, bag_number, volume_ml,
    collection_date, expiry_date, storage_location, collected_by, status,
    tested, hiv_status, hbsag_status, hcv_status, vdrl_status, malaria_status) VALUES
(1, 7, 2, 1, 'BAG-2025-0001', 450, '2025-01-01', '2025-02-12', 'Fridge-1-A1',  2, 'Available',  1, 'Negative','Negative','Negative','Negative','Negative'),
(1, 7, 2, 1, 'BAG-2025-0002', 450, '2025-01-02', '2025-02-13', 'Fridge-1-A2',  2, 'Available',  1, 'Negative','Negative','Negative','Negative','Negative'),
(1, 1, 2, 2, 'BAG-2025-0003', 450, '2025-01-03', '2025-02-14', 'Fridge-1-B1',  2, 'Available',  1, 'Negative','Negative','Negative','Negative','Negative'),
(1, 3, 2, 3, 'BAG-2025-0004', 450, '2025-01-04', '2025-02-15', 'Fridge-1-B2',  2, 'Available',  1, 'Negative','Negative','Negative','Negative','Negative'),
(1, 5, 3, 4, 'BAG-2025-0005', 200, '2025-01-05', '2026-01-05', 'Freezer-2-C1', 2, 'Available',  1, 'Negative','Negative','Negative','Negative','Negative'),
(2, 8, 2, 5, 'BAG-2025-0006', 450, '2025-01-06', '2025-02-17', 'Fridge-2-A1',  3, 'Available',  1, 'Negative','Negative','Negative','Negative','Negative'),
(2, 3, 4, 3, 'BAG-2025-0007', 300, '2025-01-07', '2025-01-12', 'Fridge-2-A2',  3, 'Available',  1, 'Negative','Negative','Negative','Negative','Negative'),
(1, 7, 4, 1, 'BAG-2025-0008', 300, '2025-01-08', '2025-01-13', 'Fridge-1-C1',  2, 'Available',  1, 'Negative','Negative','Negative','Negative','Negative'),
(3, 1, 2, 2, 'BAG-2025-0009', 450, '2025-01-08', '2025-02-19', 'Fridge-3-A1',  4, 'Quarantine', 0, 'Pending', 'Pending', 'Pending', 'Pending', 'Pending');

-- Donations
INSERT INTO Donation (donor_id, bank_id, donation_date, volume_ml, hemoglobin_g,
    bp_systolic, bp_diastolic, weight_kg, passed_screening, unit_id) VALUES
(1, 1, '2025-01-01 09:30:00', 450, 14.2, 120, 80, 72.0, 1, 1),
(2, 1, '2025-01-03 10:00:00', 450, 13.5, 115, 75, 58.5, 1, 3),
(3, 1, '2025-01-04 11:00:00', 450, 15.1, 118, 78, 80.0, 1, 4),
(4, 1, '2025-01-05 09:00:00', 200, 13.8, 110, 72, 55.0, 1, 5),
(5, 2, '2025-01-06 10:30:00', 450, 14.8, 125, 82, 78.5, 1, 6);

-- Blood Requests
INSERT INTO BloodRequest (patient_id, bank_id, blood_type_id, component_id,
    units_needed, priority, required_by, status, approved_by) VALUES
(1, 1, 7, 2, 2, 'Emergency', '2025-01-11 08:00:00', 'Pending', 1),
(2, 1, 3, 2, 3, 'Urgent',    '2025-01-14 12:00:00', 'Pending', 1),
(3, 2, 5, 3, 1, 'Routine',   '2025-01-20 18:00:00', 'Pending', NULL),
(4, 1, 1, 2, 1, 'Urgent',    '2025-01-19 10:00:00', 'Pending', 1);

-- Donation Camps
INSERT INTO DonationCamp (bank_id, camp_name, venue, city, camp_date,
    start_time, end_time, organizer_name, target_units, status) VALUES
(1, 'Republic Day Blood Drive',   'Shivaji Park, Mumbai', 'Mumbai', '2025-01-26', '08:00:00', '16:00:00', 'City Central BB',    200, 'Completed'),
(2, 'Corporate Drive - TechCorp', 'TechCorp HQ, Delhi',   'Delhi',  '2025-02-10', '09:00:00', '14:00:00', 'North District BB',   50, 'Planned');

UPDATE DonationCamp SET units_collected = 178 WHERE camp_id = 1;

-- =============================================================================
-- 6. GRANT / REVOKE (Security)
-- =============================================================================

-- Create application user (read + write, no structure changes)
CREATE USER IF NOT EXISTS 'bb_app'@'localhost' IDENTIFIED BY 'App@1234';
GRANT SELECT, INSERT, UPDATE, DELETE ON BloodBankDB.* TO 'bb_app'@'localhost';

-- Create read-only reporting user
CREATE USER IF NOT EXISTS 'bb_report'@'localhost' IDENTIFIED BY 'Report@1234';
GRANT SELECT ON BloodBankDB.* TO 'bb_report'@'localhost';

-- Revoke DELETE from report user (extra safety)
REVOKE DELETE ON BloodBankDB.* FROM 'bb_app'@'localhost';

FLUSH PRIVILEGES;

-- =============================================================================
-- 7. SAMPLE QUERIES
-- =============================================================================

-- Q1: Stock summary at bank 1
CALL sp_stock_summary(1);

-- Q2: Units expiring in next 10 days at bank 1
CALL sp_expiring_units(1, 10);

-- Q3: Donor eligibility check
CALL sp_check_donor_eligibility(1);

-- Q4: All pending requests by priority
SELECT * FROM vw_pending_requests;

-- Q5: Full donor history
SELECT * FROM vw_donor_history;

-- Q6: Wasted / expired units
SELECT * FROM vw_wasted_units;

-- Q7: Available inventory overview
SELECT * FROM vw_available_inventory;

-- Q8: Camp performance report
SELECT * FROM vw_camp_performance;

-- Q9: Blood type demand vs supply
SELECT
    CONCAT(bt.blood_group, bt.rh_factor)   AS blood_type,
    IFNULL(supply.units, 0)                AS units_in_stock,
    IFNULL(demand.pending_units, 0)        AS units_requested
FROM BloodType bt
LEFT JOIN (
    SELECT blood_type_id, COUNT(*) AS units
    FROM   BloodUnit
    WHERE  status = 'Available' AND tested = 1
    GROUP BY blood_type_id
) supply ON supply.blood_type_id = bt.blood_type_id
LEFT JOIN (
    SELECT blood_type_id, SUM(units_needed) AS pending_units
    FROM   BloodRequest
    WHERE  status IN ('Pending','Partially Fulfilled')
    GROUP BY blood_type_id
) demand ON demand.blood_type_id = bt.blood_type_id
ORDER BY blood_type;

-- Q10: Monthly donation stats
SELECT
    YEAR(donation_date)            AS year,
    MONTH(donation_date)           AS month,
    COUNT(*)                       AS total_donations,
    SUM(volume_ml)                 AS total_ml,
    SUM(passed_screening = 1)      AS accepted,
    SUM(passed_screening = 0)      AS rejected
FROM  Donation
GROUP BY YEAR(donation_date), MONTH(donation_date)
ORDER BY year, month;

-- Q11: Top donors
SELECT
    d.donor_id,
    CONCAT(d.first_name, ' ', d.last_name) AS donor_name,
    CONCAT(bt.blood_group, bt.rh_factor)    AS blood_type,
    d.total_donations,
    d.last_donated_on
FROM  Donor d
JOIN  BloodType bt ON bt.blood_type_id = d.blood_type_id
ORDER BY d.total_donations DESC
LIMIT 10;

-- Q12: Audit trail
SELECT * FROM AuditLog ORDER BY changed_at DESC LIMIT 20;

-- =============================================================================
-- END OF SCRIPT
-- =============================================================================