CREATE DATABASE hospital_hmis;
USE hospital_hmis;

-- LOOKUP TABLES
CREATE TABLE department(
department_id INT AUTO_INCREMENT PRIMARY KEY,
department_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE patient_category(
category_id INT AUTO_INCREMENT PRIMARY KEY,
category_name VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO patient_category(category_name)
VALUES ('Inhouse'),('Credit'),('Cash')
;

DROP TABLE patient_category;

CREATE TABLE patient_category(
patient_category_id INT AUTO_INCREMENT PRIMARY KEY,
patient_category_name VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO patient_category(patient_category_name)
VALUES ('Inhouse'),('Credit'),('Cash')
;

SELECT * FROM patient_category;

CREATE TABLE service_category(
service_category_id INT AUTO_INCREMENT PRIMARY KEY,
service_category_name VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO service_category(service_category_name)
VALUES ('Consultation'),('Lab'),('Pharmacy'),('Theatre'),('Ward')
;


CREATE TABLE physician (
    physician_id INT AUTO_INCREMENT PRIMARY KEY,
    employment_number VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    position VARCHAR(100),
    specialty VARCHAR(100),
    license_issue_date DATE NOT NULL,
    license_expiry_date DATE NOT NULL,
    department_id INT,
    is_department_head BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);

CREATE TABLE nurse (
    nurse_id INT AUTO_INCREMENT PRIMARY KEY,
    employment_number VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);

CREATE TABLE technician (
    technician_id INT AUTO_INCREMENT PRIMARY KEY,
    employment_number VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    role ENUM('Lab', 'Pharmacy') NOT NULL,
    license_issue_date DATE,
    license_expiry_date DATE,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);

SELECT * FROM technician;

CREATE TABLE patient (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    national_id VARCHAR(20) NOT NULL UNIQUE,
    phone_number VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100),
    date_of_birth DATE NOT NULL,
    gender ENUM('Male','Female','Other') NOT NULL,
    residence VARCHAR(150),
    next_of_kin_name VARCHAR(150),
    next_of_kin_phone VARCHAR(15),
    patient_category_id INT NOT NULL,
    insurance_number VARCHAR(100),

    FOREIGN KEY (patient_category_id) 
        REFERENCES patient_category(patient_category_id)
);

CREATE TABLE appointment (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    physician_id INT NOT NULL,
    appointment_start DATETIME NOT NULL,
    appointment_end DATETIME NOT NULL,
    
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (physician_id) REFERENCES physician(physician_id),

    CHECK (appointment_end > appointment_start)
);

CREATE TABLE service (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    service_code VARCHAR(50) NOT NULL UNIQUE,
    service_name VARCHAR(150) NOT NULL,
    service_category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    committee_approval_date DATE,
    
    FOREIGN KEY (service_category_id)
        REFERENCES service_category(service_category_id)
);


CREATE TABLE medication (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    drug_name VARCHAR(150) NOT NULL,
    drug_type ENUM('Brand','Generic') NOT NULL,
    description TEXT NOT NULL,
    batch_number VARCHAR(50) NOT NULL,
    expiry_date DATE NOT NULL,
    alert_date DATE,
    
    UNIQUE (drug_name, batch_number)
);

CREATE TABLE prescription (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    medication_id INT NOT NULL,
    dosage VARCHAR(100),
    quantity INT,
    
    FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id),
    FOREIGN KEY (medication_id) REFERENCES medication(medication_id)
);

CREATE TABLE lab_test (
    lab_test_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    physician_id INT NOT NULL,
    technician_id INT NOT NULL,
    service_id INT NOT NULL,
    test_datetime DATETIME NOT NULL,
    result TEXT,
    
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (physician_id) REFERENCES physician(physician_id),
    FOREIGN KEY (technician_id) REFERENCES technician(technician_id),
    FOREIGN KEY (service_id) REFERENCES service(service_id)
);

CREATE TABLE room (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL UNIQUE,
    ward_type VARCHAR(50),
    bed_charge DECIMAL(10,2) NOT NULL,
    is_occupied BOOLEAN DEFAULT FALSE
);

CREATE TABLE admission (
    admission_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    room_id INT NOT NULL,
    nurse_id INT NOT NULL,
    admission_date DATETIME NOT NULL,
    discharge_date DATETIME,
    
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (room_id) REFERENCES room(room_id),
    FOREIGN KEY (nurse_id) REFERENCES nurse(nurse_id)
);

CREATE TABLE billing (
    billing_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    admission_id INT,
    total_amount DECIMAL(12,2),
    payment_status ENUM('Pending','Paid','Partially Paid') DEFAULT 'Pending',
    billing_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (admission_id) REFERENCES admission(admission_id)
);

CREATE INDEX idx_patient_national_id ON patient(national_id);
CREATE INDEX idx_appointment_datetime ON appointment(appointment_start);
CREATE INDEX idx_service_code ON service(service_code);

DELIMITER $$


CREATE TRIGGER set_alert_date
BEFORE INSERT ON medication
FOR EACH ROW
BEGIN
    SET NEW.alert_date = DATE_SUB(NEW.expiry_date, INTERVAL 100 DAY);
END$$

DELIMITER ;

