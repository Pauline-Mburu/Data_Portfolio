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
