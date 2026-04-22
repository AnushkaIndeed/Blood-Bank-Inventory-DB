🩸 Blood Bank Inventory Management System (DBMS Project)

A comprehensive Database Management System project built using MariaDB/MySQL, designed to efficiently manage blood bank operations including donors, inventory, requests, and safety constraints.

🚀 Features
🧑‍⚕️ Donor Management
Registration, eligibility tracking (90-day rule)
Donation history & statistics
🩸 Blood Inventory Management

Blood units tracking with expiry dates
Component-based storage (RBC, Plasma, Platelets)
Auto-expiry handling

🏥 Patient & Request Handling
Blood requests with priority (Emergency, Urgent, Routine)
Request fulfillment tracking

🔬 Safety & Testing
Serology testing (HIV, HCV, etc.)
Automatic discard of unsafe units

📊 Reports & Analytics
Stock summary
Demand vs supply
Monthly donation reports
Camp performance

🔄 Triggers & Automation
Auto-update donor eligibility
Auto-expire blood units
Audit logging for status changes

🔐 Security
Role-based access (Admin, Read-only users)

🏗️ Database Design
The system follows proper DBMS principles:
Normalization (up to 3NF+)
Foreign key constraints
Check constraints
Indexing for performance
Stored procedures & triggers

Main entities:
Donor
Patient
BloodUnit
BloodRequest
Donation
BloodBank
Staff
AuditLog

⚙️ Setup Instructions
1. Clone Repository
git clone https://github.com/your-username/blood-bank-dbms.git
cd blood-bank-dbms
2. Run SQL Script
mariadb -u root -p < blood_bank_dbms.sql
3. Access Database
mariadb -u root -p
USE BloodBankDB;

📂 Project Structure
blood-bank-dbms/
│── blood_bank_dbms.sql
│── README.md

📌 Sample Queries
-- Stock summary
CALL sp_stock_summary(1);
-- Donor eligibility
CALL sp_check_donor_eligibility(1);
-- Pending requests
SELECT * FROM vw_pending_requests;
-- Available inventory
SELECT * FROM vw_available_inventory;

🧠 Concepts Used
Relational Schema Design
Normalization (1NF → 3NF)
Triggers & Stored Procedures
Views & Aggregations
Constraints (CHECK, FOREIGN KEY)
Query Optimization basics

💡 Key Highlights
Real-world healthcare use case
Handles blood expiry & safety constraints
Includes audit logging system
Demonstrates advanced DBMS concepts

🧪 Sample Output
The system generates outputs like:
Donor eligibility status
Blood stock summary
Expired unit tracking
Request fulfillment reports

🎓 Learning Outcomes
Practical implementation of DBMS concepts
Understanding of normalization & constraints
Working with triggers, procedures, and views
Real-world database design experience
👩‍💻 Author

Anushka Kohli
BTech IT | DBMS Project

⭐ Note

This project is built for academic and learning purposes, focusing on applying DBMS concepts to a real-world problem.
