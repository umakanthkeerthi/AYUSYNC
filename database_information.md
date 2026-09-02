# Ayusync Database Total Information

This file contains a complete snapshot of all the tables and their current data in `ayusync.db`.

## Table: `users`

| id | role | full_name | username | hashed_password | email | phone_number | created_at |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 412f0b26-6b12-4569-862b-eb964c33ab23 | DOCTOR | Dr. Gowrinath S. | gowrinath | password123 | None | 555-DOC-1 | 2026-09-01 09:22:26.835867 |
| b75eccea-7094-40dd-afc9-c5bf58988477 | DOCTOR | Dr. Uma Kanth | umakanth | password123 | None | 555-DOC-2 | 2026-09-01 09:22:26.835870 |
| 0866bf18-3958-400d-bf66-cc72be341a1a | PATIENT | Ramesh Gupta | PT-RAMESH | password123 | None | +91 99512 58552 | 2026-09-01 09:22:26.835871 |
| fadc0102-ca89-4e3f-9b21-c67abf3986f8 | CAREGIVER | Sunita Gupta | CG-SUNITA | password123 | None | +91 98450 12345 | 2026-09-01 09:22:26.835872 |
| 45b4d779-4893-4b8d-906f-41eec58ae129 | PATIENT | Swathi Reddy | PT-SWATHI | password123 | None | +91 70132 50990 | 2026-09-01 09:22:26.835872 |
| 67cee7e8-96a0-4a82-bfd9-03ee339c3b6e | CAREGIVER | Ravi Reddy | CG-RAVI | password123 | None | +91 99887 66554 | 2026-09-01 09:22:26.835873 |
| 2a3d314c-4ee2-490c-bf88-f23377d2eb65 | PATIENT | Varun Verma | PT-VARUN | password123 | None | +91 93902 56747 | 2026-09-01 09:22:26.835873 |
| 903bcb0e-84e2-432c-9c16-84ef415f4e87 | CAREGIVER | Priya Verma | CG-PRIYA | password123 | None | +91 91234 56789 | 2026-09-01 09:22:26.835873 |
| 6253c1ae-ef0b-4f75-a209-cb9e34a0375b | PATIENT | Ananya Sharma | PT-ANANYA | password123 | None | +91 93464 15704 | 2026-09-01 09:22:26.835874 |
| 9105a24d-f5ae-43b8-a491-d06a8d274857 | CAREGIVER | Rahul Sharma | CG-RAHUL | password123 | None | +91 98765 43210 | 2026-09-01 09:22:26.835874 |
| 65981e69-6f0d-4c22-8eb4-986b1aa705cf | PATIENT | Vikram Chawla | PT-VIKRAM | password123 | None | +91 90001 39840 | 2026-09-01 09:22:26.835874 |
| 70a852b6-e797-4646-b4ea-a35758e1c178 | CAREGIVER | Neha Chawla | CG-NEHA | password123 | None | +91 90123 45678 | 2026-09-01 09:22:26.835875 |
| ab95cf7d-da26-4b5e-a5d5-14e3a782100c | DOCTOR | Dr. Smith | dr_smith | password123 | None | +15550000 | 2026-09-01 09:22:27.800124 |
| b0834019-9862-4021-9eea-34d06abbd4ea | DOCTOR | Dr. Patel | dr_patel | password123 | None | +15550001 | 2026-09-01 09:22:27.802661 |
| f68d72ae-ab2c-42c5-8657-c309e3701fae | DOCTOR | Dr. Chen | dr_chen | password123 | None | +15550002 | 2026-09-01 09:22:27.805367 |
| 1557247e-c567-4b3c-b2a8-bf690d067305 | DOCTOR | Dr. Emily Carter | dr_carter | password123 | None | +15550003 | 2026-09-01 09:22:27.806116 |
| 0a529ba7-6c0d-4d31-b3c7-3875e7bf130a | DOCTOR | Dr. Jones | dr_jones | password123 | None | +15550004 | 2026-09-01 09:22:27.806794 |
| 2c36fe47-e370-4e44-86d6-d456f761a6f1 | DOCTOR | Dr. Smith (EHR System) | None | None | None | +1555162042 | 2026-09-01 09:22:31.528737 |


## Table: `organizations`

*Table is empty.*

## Table: `system_audit_logs`

*Table is empty.*

## Table: `ambulance_drivers`

*Table is empty.*

## Table: `hospital_admins`

*Table is empty.*

## Table: `patients`

| id | user_id | caregiver_id | caregiver_relation | date_of_birth | blood_type |
| --- | --- | --- | --- | --- | --- |
| 14268918-9c4b-4fe5-bd12-77851aea8562 | 0866bf18-3958-400d-bf66-cc72be341a1a | None | None | 1981-04-12 00:00:00.000000 | None |
| 77440e31-dc83-4f57-b82b-640f157befd1 | 45b4d779-4893-4b8d-906f-41eec58ae129 | None | None | 1998-11-05 00:00:00.000000 | None |
| c31ffd41-51ae-4625-a405-00d72ad65397 | 2a3d314c-4ee2-490c-bf88-f23377d2eb65 | None | None | 1964-02-18 00:00:00.000000 | None |
| e802435a-081f-40d1-b8fd-0beaf99b522d | 6253c1ae-ef0b-4f75-a209-cb9e34a0375b | None | None | 1991-08-22 00:00:00.000000 | None |
| 42a110ad-e5d2-4ef9-89d0-de764eacad53 | 65981e69-6f0d-4c22-8eb4-986b1aa705cf | None | None | 1976-12-10 00:00:00.000000 | None |


## Table: `practitioners`

| id | user_id | npi_number | specialty |
| --- | --- | --- | --- |
| 0349b106-d961-4189-94b3-d65234e961eb | ab95cf7d-da26-4b5e-a5d5-14e3a782100c | None | Cardiology |
| b12ddc2d-527b-45c7-96bf-fe8fc7a1986e | b0834019-9862-4021-9eea-34d06abbd4ea | None | Neurology |
| ff6c9132-b7a0-49fe-a034-8ee94bc468c1 | f68d72ae-ab2c-42c5-8657-c309e3701fae | None | Internal Medicine |
| 44fc2669-1412-433b-9dca-57975efb1f0b | 1557247e-c567-4b3c-b2a8-bf690d067305 | None | General Practice |
| 50ba1ce4-ae86-41bc-a2fd-4f2a7f8bba0c | 0a529ba7-6c0d-4d31-b3c7-3875e7bf130a | None | Oncology |
| 26e5b040-745f-4cbe-b590-4fd892782c4a | 2c36fe47-e370-4e44-86d6-d456f761a6f1 | None | None |


## Table: `chat_threads`

*Table is empty.*

## Table: `vitals`

*Table is empty.*

## Table: `conditions`

| id | patient_id | condition_name | status | diagnosed_date |
| --- | --- | --- | --- | --- |
| 14ad0677-7205-4e0d-8906-aa710023a47b | 14268918-9c4b-4fe5-bd12-77851aea8562 | Unknown Condition | active | None |
| d74683b1-1686-404a-a6e4-35275eff5a01 | 14268918-9c4b-4fe5-bd12-77851aea8562 | Unknown Condition | active | None |
| 3081ef12-c3d1-482b-b598-16b911f4be64 | 77440e31-dc83-4f57-b82b-640f157befd1 | Unknown Condition | active | None |
| caf060c5-174b-4661-b82d-0183e9b73d71 | 77440e31-dc83-4f57-b82b-640f157befd1 | Unknown Condition | active | None |
| f7af8e9a-8177-4691-ae1b-599719a0f498 | c31ffd41-51ae-4625-a405-00d72ad65397 | Unknown Condition | active | None |
| 04f61d58-9c7e-454b-badf-7062f21c107a | c31ffd41-51ae-4625-a405-00d72ad65397 | Unknown Condition | active | None |
| 43ce1849-7b39-4e8d-b3b5-5834388e269c | e802435a-081f-40d1-b8fd-0beaf99b522d | Unknown Condition | active | None |
| 996d960f-0080-44f9-a7ab-5b2679e82c8e | e802435a-081f-40d1-b8fd-0beaf99b522d | Unknown Condition | active | None |
| 53459585-53ae-4893-adbe-c906fe0c6785 | 42a110ad-e5d2-4ef9-89d0-de764eacad53 | Unknown Condition | active | None |
| cc62ff9f-2ebf-4b9c-974f-c3a3178e8354 | 42a110ad-e5d2-4ef9-89d0-de764eacad53 | Unknown Condition | active | None |


## Table: `clinical_notes`

*Table is empty.*

## Table: `encounters`

| id | patient_id | status | discharge_date |
| --- | --- | --- | --- |
| d73b2be9-25d2-4a51-bbd8-f0b627148009 | 14268918-9c4b-4fe5-bd12-77851aea8562 | finished | None |
| e0110ce8-091e-4677-a53f-0e8ff248635c | 77440e31-dc83-4f57-b82b-640f157befd1 | finished | None |
| 11f7f201-0ddc-4ed7-8d59-ac25b695ee59 | c31ffd41-51ae-4625-a405-00d72ad65397 | finished | None |
| effb7a42-a6eb-42d6-a5dc-4e6d2628aef4 | e802435a-081f-40d1-b8fd-0beaf99b522d | finished | None |
| 25c35c20-840a-494b-b3a7-c1c03cc0499a | 42a110ad-e5d2-4ef9-89d0-de764eacad53 | finished | None |


## Table: `appointments`

*Table is empty.*

## Table: `care_tasks`

*Table is empty.*

## Table: `lab_tests`

*Table is empty.*

## Table: `care_plans`

*Table is empty.*

## Table: `medications`

| id | patient_id | prescribed_by_id | drug_name | dosage | frequency | is_active |
| --- | --- | --- | --- | --- | --- | --- |
| a29f707a-4be8-4dab-91b4-e03d734aaa17 | 14268918-9c4b-4fe5-bd12-77851aea8562 | 26e5b040-745f-4cbe-b590-4fd892782c4a | Unknown Drug | 1 pill | 1 time a day | 1 |
| 3e041ff0-fa54-49eb-9983-fe32cf801352 | 14268918-9c4b-4fe5-bd12-77851aea8562 | 26e5b040-745f-4cbe-b590-4fd892782c4a | Unknown Drug | 1 pill | 3 times a day | 1 |
| ec3cddb7-04db-47fc-8407-0c8661438a79 | 77440e31-dc83-4f57-b82b-640f157befd1 | 26e5b040-745f-4cbe-b590-4fd892782c4a | Unknown Drug | 1 pill | Up to 3 times a day (Every 8 hours) | 1 |
| ec3481b6-dadc-4534-9eab-3034d1a951a9 | 77440e31-dc83-4f57-b82b-640f157befd1 | 26e5b040-745f-4cbe-b590-4fd892782c4a | Unknown Drug | 1 pill | Up to 3 times a day (Every 8 hours) | 1 |
| 6ea9533e-bd26-4fb1-8322-6ef1a60c9b3c | c31ffd41-51ae-4625-a405-00d72ad65397 | 26e5b040-745f-4cbe-b590-4fd892782c4a | Unknown Drug | 1 pill | 2 times a day | 1 |
| 18095130-9426-48bf-a6d4-34fb1ce05449 | c31ffd41-51ae-4625-a405-00d72ad65397 | 26e5b040-745f-4cbe-b590-4fd892782c4a | Unknown Drug | 1 pill | 1 time a day | 1 |
| 9ffd93e0-c905-4fd1-83d7-8c9e8af40dc0 | c31ffd41-51ae-4625-a405-00d72ad65397 | 26e5b040-745f-4cbe-b590-4fd892782c4a | Unknown Drug | 1 pill | 1 time a day | 1 |
| 4d16a467-8f31-472d-9fa2-52f914ef5745 | c31ffd41-51ae-4625-a405-00d72ad65397 | 26e5b040-745f-4cbe-b590-4fd892782c4a | Unknown Drug | 1 pill | 1 time a day | 1 |
| 8308e316-d55a-485f-aab5-a17a9a79288e | e802435a-081f-40d1-b8fd-0beaf99b522d | 26e5b040-745f-4cbe-b590-4fd892782c4a | Unknown Drug | 1 pill | Up to 4 times a day (Every 6 hours) | 1 |
| 6a3d823e-e290-4f2d-ad6e-cfdfc5934457 | e802435a-081f-40d1-b8fd-0beaf99b522d | 26e5b040-745f-4cbe-b590-4fd892782c4a | Unknown Drug | 1 pill | 1 time a day | 1 |
| bbe3d094-3aad-4288-b003-aeac846a667f | 42a110ad-e5d2-4ef9-89d0-de764eacad53 | 26e5b040-745f-4cbe-b590-4fd892782c4a | Unknown Drug | 1 pill | 3 times a day | 1 |
| 72fc1536-342b-48eb-8d1f-6eea0e76fd37 | 42a110ad-e5d2-4ef9-89d0-de764eacad53 | 26e5b040-745f-4cbe-b590-4fd892782c4a | Unknown Drug | 1 pill | 3 times a week | 1 |
| 6a8531e9-1a28-4d22-a847-3eddb155f39e | 42a110ad-e5d2-4ef9-89d0-de764eacad53 | 26e5b040-745f-4cbe-b590-4fd892782c4a | Unknown Drug | 1 pill | 1 time a day | 1 |


## Table: `triage_queues`

*Table is empty.*

## Table: `doctor_escalations`

*Table is empty.*

## Table: `lab_orders`

*Table is empty.*

## Table: `emergency_dispatches`

*Table is empty.*

## Table: `prior_authorizations`

*Table is empty.*

## Table: `chat_messages`

*Table is empty.*

## Table: `adherence_logs`

*Table is empty.*

## Table: `pharmacy_orders`

*Table is empty.*

## Table: `lab_results`

*Table is empty.*

