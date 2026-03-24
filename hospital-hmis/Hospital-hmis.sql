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


-- Revenue per patient
SELECT patient_id, SUM(total_amount)
FROM billing
GROUP BY patient_id;

-- Expiring medication
SELECT drug_name, expiry_date, alert_date
FROM medication
WHERE alert_date <= CURDATE();
🖼️ ERD.png

Export your diagram from
dbdiagram.io

🧠 STEP 2: Write a Strong README (MOST IMPORTANT)

Create README.md

Paste this structure:

🏥 Hospital Management Information System (HMIS)
📌 Overview

Designed and implemented a relational database to manage hospital operations including patient records, appointments, billing, pharmacy, and lab systems.

🔴 Problem

Hospitals handle complex data across departments, leading to inefficiencies, duplication, and poor tracking when unmanaged.

🧠 Approach
Designed a normalized (3NF) database
Implemented relational integrity using foreign keys
Automated workflows using triggers
Structured service-based billing
🧩 Key Features
Patient lifecycle tracking
Appointment scheduling
Lab and pharmacy integration
Inpatient admission system
Billing system
⚙️ Automation
Trigger calculates medication alert dates 100 days before expiry
📊 Sample Insights
Track patient distribution by category
Monitor expiring medication
Analyze billing trends
🖼️ ER Diagram

🚀 Business Impact
Improved data consistency
Reduced redundancy
Enabled proactive inventory management
Enhanced operational efficiency
🛠️ Tech Stack
SQL (MySQL)
Database Design (3NF)
🌐 STEP 3: Create a GitHub Repository
Go to GitHub
Click “New Repository”

Name it:

hospital-hmis-database

Add description:

End-to-end hospital database design using SQL
Set to Public
Click Create Repository
⬆️ STEP 4: Upload Your Files
Option A (Easiest – Browser)
Click “Add file” → “Upload files”
Drag your entire Hospital-HMIS files
Scroll down → click Commit changes
Option B (Professional – Git)

If you want to level up:

git init
git add .
git commit -m "Initial commit - Hospital HMIS project"
git branch -M main
git remote add origin https://github.com/yourusername/hospital-hmis-database.git
git push -u origin main
🎯 STEP 5: Make It Recruiter-Friendly
✅ Pin the Repo

On your GitHub profile:

Click “Pin”
👉 Make this project visible immediately
✅ Add Description

Edit repo → add:

SQL | Database Design | Healthcare Analytics Project
✅ Add Topics (VERY IMPORTANT)

Add tags like:

sql
database-design
mysql
data-analytics
healthcare
🧲 STEP 6: Make It Easy to Understand in 30 Seconds

A recruiter should:

Open your repo
See:
Clear title
ER diagram
Business explanation
Think:
👉 “This person understands systems + data”
🔥 STEP 7: Link It Everywhere

Add your repo link to:

CV
LinkedIn Projects section
Portfolio website
⚡ Bonus (What Will Make You Stand Out More)

If you want to go from good → top 10%:

Add sample data (INSERT statements)
Add screenshots of query results
Add a short Loom video explaining your project
💬 If you want next

I can:

Rewrite your README to sound like a top candidate
Help you create impressive SQL queries
Or guide you on your next portfolio project to complement this

Just tell me 👍

share everything is hould add to this file and the format and wording. the readme and the scripts

Perfect—this is where you turn your project into something that feels professional and hire-ready. I’ll give you copy-paste ready content for:

✅ README.md (polished, recruiter-ready)
✅ schema.sql (clean + structured)
✅ triggers.sql
✅ sample_queries.sql

You can literally paste these into your files and adjust names if needed.

📄 1. README.md (Copy-Paste Ready)
# 🏥 Hospital Management Information System (HMIS) Database

## 📌 Overview
This project involves the design and implementation of a relational database system for managing hospital operations. The system models patient records, appointments, billing, pharmacy, laboratory processes, and inpatient admissions.

The goal was to create a scalable, structured, and efficient database that improves data integrity, reduces redundancy, and supports operational decision-making.

---

## 🔴 Problem Statement
Hospitals manage complex data across multiple departments such as outpatient services, laboratory, pharmacy, and inpatient care. Without a structured system, this leads to:
- Data duplication
- Inconsistent pricing of services
- Poor patient tracking
- Inefficient billing processes

---

## 🎯 Objectives
- Automate hospital operations
- Ensure data integrity and consistency
- Enable efficient patient tracking across departments
- Improve billing accuracy
- Support compliance with healthcare data standards

---

## 🧠 Methodology & Approach

### 1. Database Design
- Designed a fully normalized relational database (3NF)
- Eliminated redundancy by separating entities such as services, categories, and billing

### 2. Data Integrity
- Implemented Primary and Foreign Keys
- Applied constraints (UNIQUE, CHECK, ENUM)
- Indexed key fields for performance

### 3. Automation
- Implemented triggers to automate medication expiry alerts

---

## 🧩 System Components

### Core Entities
- Patient
- Physician
- Nurse
- Technician
- Department
- Appointment
- Service & Service Category
- Medication & Prescription
- Lab Test
- Admission & Room
- Billing

---

## 🖼️ Entity Relationship Diagram
![ER Diagram](ERD.png)

---

## ⚙️ Key Features

### Patient Management
- Unique identification using National ID and phone number
- Categorization into Inhouse, Credit, and Cash patients

### Appointment System
- Tracks patient visits with assigned physicians
- Enforces valid appointment durations

### Pharmacy Management
- Tracks medications with batch numbers and expiry dates
- Automatic alert generation before expiry

### Laboratory System
- Records test details, technicians, and results

### Inpatient Management
- Room allocation and admission tracking
- Nurse assignment

### Billing System
- Tracks patient financial data
- Supports multiple payment statuses

---

## 🔁 Automation (Trigger)

Medication expiry alerts are automatically calculated:

```sql
SET NEW.alert_date = DATE_SUB(NEW.expiry_date, INTERVAL 100 DAY);
📊 Sample Business Queries
Revenue per patient
Expiring medications
Patient distribution by category
Appointment trends
Active admissions
💡 Key Insights
Centralized patient tracking improves continuity of care
Standardized service pricing ensures billing consistency
Automated alerts reduce risk of expired medication usage
Structured admissions data improves hospital capacity planning
🚀 Business Impact
Improved data consistency and integrity
Reduced redundancy through normalization
Enhanced operational efficiency
Better decision-making through structured data
Scalable foundation for a full hospital information system
🛠️ Tech Stack
SQL (MySQL)
Database Design (3NF)
📁 Project Structure
Hospital-HMIS/
│
├── README.md
├── schema.sql
├── triggers.sql
├── sample_queries.sql
├── ERD.png
📬 Contact

Feel free to connect or reach out for collaboration opportunities.


---

# 🧱 2. schema.sql (Clean Version)

👉 Remove extra drops + duplicates. Keep it clean like this:

```sql
CREATE DATABASE hospital_hmis;
USE hospital_hmis;

-- ========================
-- LOOKUP TABLES
-- ========================

CREATE TABLE department(
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE patient_category(
    patient_category_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE service_category(
    service_category_id INT AUTO_INCREMENT PRIMARY KEY,
    service_category_name VARCHAR(100) NOT NULL UNIQUE
);

-- ========================
-- STAFF TABLES
-- ========================

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

-- ========================
-- PATIENT TABLES
-- ========================

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

-- ========================
-- OPERATIONS
-- ========================

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

-- ========================
-- SERVICES & BILLING
-- ========================

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

CREATE TABLE billing (
    billing_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    admission_id INT,
    total_amount DECIMAL(12,2),
    payment_status ENUM('Pending','Paid','Partially Paid') DEFAULT 'Pending',
    billing_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
);

-- ========================
-- PHARMACY
-- ========================

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

-- ========================
-- LAB
-- ========================

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

-- ========================
-- ADMISSION
-- ========================

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
⚙️ 3. triggers.sql
DELIMITER $$

CREATE TRIGGER set_alert_date
BEFORE INSERT ON medication
FOR EACH ROW
BEGIN
    SET NEW.alert_date = DATE_SUB(NEW.expiry_date, INTERVAL 100 DAY);
END$$

DELIMITER ;



-- BUSINESS INSIGHTS


-- 1. Total revenue per patient
SELECT patient_id, SUM(total_amount) AS total_revenue
FROM billing
GROUP BY patient_id;

-- 2. Expiring medications
SELECT drug_name, expiry_date, alert_date
FROM medication
WHERE alert_date <= CURDATE();

-- 3. Patient distribution by category
SELECT pc.patient_category_name, COUNT(*) AS total_patients
FROM patient p
JOIN patient_category pc 
ON p.patient_category_id = pc.patient_category_id
GROUP BY pc.patient_category_name;

-- 4. Number of appointments per physician
SELECT physician_id, COUNT(*) AS total_appointments
FROM appointment
GROUP BY physician_id;

-- 5. Active admissions
SELECT * 
FROM admission
WHERE discharge_date IS NULL;


