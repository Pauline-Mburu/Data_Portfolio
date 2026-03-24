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


