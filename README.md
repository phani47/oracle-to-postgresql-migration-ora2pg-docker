# oracle-to-postgresql-migration-ora2pg-docker

# 🚀 Oracle to PostgreSQL Migration using Docker and Ora2Pg

## 📌 Project Overview

This project demonstrates an end-to-end migration of an Oracle database schema to PostgreSQL using Docker and Ora2Pg.

The migration was performed using the Oracle HR sample schema and includes schema assessment, object migration, data migration, and post-migration validation.

## 🏗️ Technology Stack

| Technology       | Version                      |
| ---------------- | ---------------------------- |
| Oracle Database  | Oracle AI Database 26ai Free |
| PostgreSQL       | PostgreSQL 18                |
| Ora2Pg           | 25.0                         |
| Docker           | Docker Containers            |
| Operating System | macOS                        |

---

# 🏛️ Migration Architecture

```text
                    ┌──────────────────────┐
                    │                      │
                    │  Oracle AI Database  │
                    │       26ai Free      │
                    │                      │
                    │      HR Schema       │
                    │                      │
                    └──────────┬───────────┘
                               │
                               │
                               ▼
                    ┌──────────────────────┐
                    │                      │
                    │       Ora2Pg         │
                    │       Version 25     │
                    │                      │
                    └──────────┬───────────┘
                               │
               ┌───────────────┴───────────────┐
               │                               │
               ▼                               ▼
      ┌──────────────────┐          ┌──────────────────┐
      │                  │          │                  │
      │ Schema Export    │          │   Data Export    │
      │                  │          │                  │
      └────────┬─────────┘          └────────┬─────────┘
               │                               │
               └───────────────┬───────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │                      │
                    │    PostgreSQL 18     │
                    │                      │
                    │    HR Migration DB   │
                    │                      │
                    └──────────────────────┘
```

---

# 📂 Oracle Source Database

## Schema

```text
HR
```

## Oracle Version

```text
Oracle AI Database 26ai Free Release
23.26.2.0.0
```

---

# 📊 Source Schema Statistics

| Object Type | Count |
| ----------- | ----: |
| Tables      |     7 |
| Indexes     |    19 |
| Procedures  |     2 |
| Sequences   |     3 |
| Triggers    |     2 |
| Views       |     1 |

---

# 📊 Oracle Table Statistics

| Table       | Rows |
| ----------- | ---: |
| EMPLOYEES   |  107 |
| DEPARTMENTS |   27 |
| COUNTRIES   |   25 |
| LOCATIONS   |   23 |
| JOBS        |   19 |
| JOB_HISTORY |   10 |
| REGIONS     |    4 |

Total Rows:

```text
215
```

---

# 🚀 Migration Steps

## Step 1: Create Docker Network

Create a dedicated Docker network for Oracle, PostgreSQL, and Ora2Pg containers.

```bash
docker network create db-migration-network
```

Verify:

```bash
docker network ls
```

---

# Step 2: Start Oracle Database

Oracle Database runs inside a Docker container.

Verify Oracle container:

```bash
docker ps
```

Oracle service used:

```text
oracle-free
```

Oracle port:

```text
1521
```

Oracle PDB:

```text
FREEPDB1
```

---

# Step 3: Start PostgreSQL 18

Verify PostgreSQL container:

```bash
docker ps
```

Connect to PostgreSQL:

```bash
docker exec -it pg18 psql \
-U postgres
```

Create migration database:

```sql
CREATE DATABASE hr_migration;
```

Connect:

```sql
\c hr_migration
```

---

# Step 4: Create PostgreSQL Schema

Create the target schema.

```sql
CREATE SCHEMA hr;
```

Verify:

```sql
\dn
```

---

# Step 5: Configure Ora2Pg

Create:

```text
config/ora2pg.conf
```

Configuration:

```conf
ORACLE_DSN    dbi:Oracle:host=oracle-free;port=1521;service_name=freepdb1

ORACLE_USER   HR

SCHEMA        HR

PG_VERSION    18

TYPE          SHOW_REPORT

USER_GRANTS   1
```

---

# Step 6: Configure Oracle Password

Avoid storing Oracle passwords in configuration files.

Set the password:

```bash
read -s ORACLE_PWD
```

Press Enter after entering the password.

The password is passed securely using:

```bash
-e ORA2PG_PASSWD="$ORACLE_PWD"
```

---

# Step 7: Test Oracle Connectivity from Ora2Pg

Test the Oracle connection using DBI.

```bash
docker run --rm \
--platform linux/amd64 \
--network db-migration-network \
--entrypoint /bin/bash \
-e ORA2PG_PASSWD="$ORACLE_PWD" \
georgmoser/ora2pg:25.0 \
-c 'perl -MDBI -e '\''
my $dsn = "dbi:Oracle:host=oracle-free;port=1521;service_name=freepdb1";

my $dbh = DBI->connect(
    $dsn,
    "HR",
    $ENV{ORA2PG_PASSWD},
    { RaiseError => 1, PrintError => 0 }
);

print "DBI authentication SUCCESS\n";

$dbh->disconnect;
'\'''
```

Successful output:

```text
DBI authentication SUCCESS
```

---

# Step 8: Verify Oracle Database Version

Run:

```bash
docker run --rm \
--platform linux/amd64 \
--network db-migration-network \
--entrypoint /bin/bash \
-e ORA2PG_PASSWD="$ORACLE_PWD" \
georgmoser/ora2pg:25.0 \
-c 'ora2pg \
-t SHOW_VERSION \
-s "dbi:Oracle:host=oracle-free;port=1521;service_name=freepdb1" \
-u HR'
```

Output:

```text
Oracle AI Database 26ai Free Release
23.26.2.0.0
```

---

# Step 9: Generate Migration Assessment Report

Ora2Pg provides a migration assessment report.

Run:

```bash
docker run --rm \
--platform linux/amd64 \
--network db-migration-network \
--entrypoint /bin/bash \
-e ORA2PG_PASSWD="$ORACLE_PWD" \
-v "$PWD/config:/config:ro" \
-v "$PWD/output/reports:/reports" \
georgmoser/ora2pg:25.0 \
-c 'ora2pg \
-c /config/ora2pg.conf \
-t SHOW_REPORT \
--estimate_cost \
--dump_as_html \
-o /reports/hr_assessment.html'
```

Generated files:

```text
hr_assessment.html
hr_assessment.json
hr_source_baseline.txt
```

---

# Step 10: Export Oracle Tables

Set:

```conf
TYPE TABLE
```

Run Ora2Pg to export tables.

Generated file:

```text
output/schema/hr_tables.sql
```

Verify:

```bash
grep -i "CREATE TABLE" \
output/schema/hr_tables.sql
```

Expected tables:

```text
countries
departments
employees
jobs
job_history
locations
regions
```

---

# Step 11: Export Sequences

Set:

```conf
TYPE SEQUENCE
```

Generated file:

```text
output/schema/hr_sequences.sql
```

Verify:

```bash
grep -i "CREATE SEQUENCE" \
output/schema/hr_sequences.sql
```

Sequences:

```text
departments_seq
employees_seq
locations_seq
```

---

# Step 12: Export Views

Set:

```conf
TYPE VIEW
```

Generated file:

```text
output/schema/hr_views.sql
```

---

# Step 13: Export Procedures

Set:

```conf
TYPE PROCEDURE
```

Generated file:

```text
output/schema/hr_procedures.sql
```

Procedures exported:

```text
add_job_history
secure_dml
```

---

# Step 14: Export Triggers

Set:

```conf
TYPE TRIGGER
```

Generated file:

```text
output/schema/hr_triggers.sql
```

Triggers exported:

```text
secure_employees
update_job_history
```

---

# Step 15: Review Generated Schema Files

Check for migration warnings.

```bash
grep -RniE \
"WARNING|TODO|FIXME|unsupported|not supported" \
output/schema/
```

Review all generated SQL before importing into PostgreSQL.

---

# Step 16: Prepare Table Import Script

Create:

```text
hr_tables_import.sql
```

Command:

```bash
(
echo "SET search_path TO hr;"

cat output/schema/hr_tables.sql

) > output/schema/hr_tables_import.sql
```

Verify:

```bash
head -15 \
output/schema/hr_tables_import.sql
```

---

# Step 17: Copy Files to PostgreSQL Container

Example:

```bash
docker cp \
output/schema/hr_tables_import.sql \
pg18:/tmp/
```

---

# Step 18: Import Tables into PostgreSQL

Run:

```bash
docker exec -it pg18 psql \
-U postgres \
-d hr_migration \
-f /tmp/hr_tables_import.sql
```

Verify:

```sql
SET search_path TO hr;

\dt
```

Expected:

```text
countries
departments
employees
job_history
jobs
locations
regions
```

---

# Step 19: Import Sequences

Prepare sequence import script.

```bash
(
echo "SET search_path TO hr;"

cat output/schema/hr_sequences.sql

) > output/schema/hr_sequences_import.sql
```

Copy:

```bash
docker cp \
output/schema/hr_sequences_import.sql \
pg18:/tmp/
```

Import:

```bash
docker exec -it pg18 psql \
-U postgres \
-d hr_migration \
-f /tmp/hr_sequences_import.sql
```

Verify:

```sql
SET search_path TO hr;

\ds
```

---

# Step 20: Export Oracle Data

Set:

```conf
TYPE COPY
```

Run Ora2Pg.

Generated file:

```text
output/data/hr_data.sql
```

Verify:

```bash
grep -in "COPY" \
output/data/hr_data.sql
```

Tables exported:

```text
countries
departments
employees
jobs
job_history
locations
regions
```

---

# Step 21: Handle Foreign Key Dependencies

During import, foreign key dependency issues can occur.

Example:

```text
insert or update on table "countries"
violates foreign key constraint
"countr_reg_fk"
```

The solution is to import parent tables before child tables.

Example dependency:

```text
regions
   │
   ▼
countries
   │
   ▼
locations
   │
   ▼
departments
   │
   ▼
employees
   │
   ▼
job_history
```

---

# Step 22: Import Data

Create:

```text
hr_data_import.sql
```

Set schema:

```sql
SET search_path TO hr;
```

Copy data file:

```bash
docker cp \
output/data/hr_data_import.sql \
pg18:/tmp/
```

Import:

```bash
docker exec -it pg18 psql \
-U postgres \
-d hr_migration \
-f /tmp/hr_data_import.sql
```

---

# Step 23: Validate Row Counts

Run:

```sql
SELECT 'countries' AS table_name, COUNT(*) AS row_count
FROM hr.countries

UNION ALL

SELECT 'departments', COUNT(*)
FROM hr.departments

UNION ALL

SELECT 'employees', COUNT(*)
FROM hr.employees

UNION ALL

SELECT 'jobs', COUNT(*)
FROM hr.jobs

UNION ALL

SELECT 'job_history', COUNT(*)
FROM hr.job_history

UNION ALL

SELECT 'locations', COUNT(*)
FROM hr.locations

UNION ALL

SELECT 'regions', COUNT(*)
FROM hr.regions

ORDER BY table_name;
```

Migration result:

| Table       | Rows |
| ----------- | ---: |
| countries   |   25 |
| departments |   27 |
| employees   |  107 |
| job_history |   10 |
| jobs        |   19 |
| locations   |   23 |
| regions     |    4 |

Total:

```text
215 Rows
```

---

# Step 24: Validate Foreign Keys

Run:

```sql
SELECT
    conname AS constraint_name,
    conrelid::regclass AS table_name,
    confrelid::regclass AS referenced_table

FROM pg_constraint

WHERE contype = 'f'

AND connamespace = 'hr'::regnamespace

ORDER BY table_name;
```

Foreign Keys:

```text
countr_reg_fk
dept_loc_fk
dept_mgr_fk
emp_dept_fk
emp_job_fk
emp_manager_fk
jhist_dept_fk
jhist_emp_fk
jhist_job_fk
loc_c_id_fk
```

Total:

```text
10 Foreign Keys
```

---

# Step 25: Validate Sequences

Run:

```sql
SELECT
    'departments_seq' AS sequence_name,
    last_value
FROM hr.departments_seq

UNION ALL

SELECT
    'employees_seq',
    last_value
FROM hr.employees_seq

UNION ALL

SELECT
    'locations_seq',
    last_value
FROM hr.locations_seq;
```

Results:

| Sequence        | Last Value |
| --------------- | ---------: |
| departments_seq |        280 |
| employees_seq   |        207 |
| locations_seq   |       3300 |

---

# Step 26: Validate Final Object Count

Run:

```sql
SELECT

    'TABLES' AS object_type,

    COUNT(*) AS object_count

FROM information_schema.tables

WHERE table_schema = 'hr'

AND table_type = 'BASE TABLE'

UNION ALL

SELECT

    'VIEWS',

    COUNT(*)

FROM information_schema.views

WHERE table_schema = 'hr'

UNION ALL

SELECT

    'SEQUENCES',

    COUNT(*)

FROM information_schema.sequences

WHERE sequence_schema = 'hr'

UNION ALL

SELECT

    'PROCEDURES/FUNCTIONS',

    COUNT(*)

FROM information_schema.routines

WHERE routine_schema = 'hr'

UNION ALL

SELECT

    'TRIGGERS',

    COUNT(DISTINCT trigger_name)

FROM information_schema.triggers

WHERE trigger_schema = 'hr';
```

Final Results:

| Object Type            | Count |
| ---------------------- | ----: |
| Tables                 |     7 |
| Views                  |     1 |
| Sequences              |     3 |
| Procedures / Functions |     4 |
| Triggers               |     2 |

---

# 🎯 Migration Result

The Oracle HR schema was successfully migrated to PostgreSQL 18.

## Migrated Objects

```text
Tables              7
Indexes             19
Sequences           3
Views               1
Procedures          2
Functions           2
Triggers            2
Foreign Keys       10
Rows              215
```

---

# 🧪 Validation Status

| Validation              | Status |
| ----------------------- | ------ |
| Oracle Connectivity     | ✅      |
| Database Version        | ✅      |
| Schema Assessment       | ✅      |
| Table Migration         | ✅      |
| Sequence Migration      | ✅      |
| View Migration          | ✅      |
| Procedure Migration     | ✅      |
| Trigger Migration       | ✅      |
| Data Migration          | ✅      |
| Row Count Validation    | ✅      |
| Sequence Validation     | ✅      |
| Foreign Key Validation  | ✅      |
| Object Count Validation | ✅      |

---

# 🔐 Security Best Practice

Oracle passwords were not stored in the Ora2Pg configuration file.

The password was passed using:

```bash
ORA2PG_PASSWD
```

Example:

```bash
read -s ORACLE_PWD
```

Then:

```bash
-e ORA2PG_PASSWD="$ORACLE_PWD"
```

---

# 📈 Key Learning Outcomes

This project provided hands-on experience with:

* Oracle Database migration
* PostgreSQL migration
* Ora2Pg
* Docker networking
* Oracle DBI connectivity
* Schema conversion
* Data migration
* Foreign key dependency management
* PostgreSQL schema management
* Sequence migration
* Trigger migration
* Procedure migration
* Migration validation
* Database object comparison

---

# 🚀 Future Enhancements

Future improvements can include:

* Automated migration pipeline
* Docker Compose deployment
* Pre-migration compatibility scanner
* Automated object comparison
* Automated row count validation
* Data checksum validation
* PostgreSQL performance tuning
* Automated rollback process
* Ansible-based migration automation
* CI/CD pipeline using GitHub Actions
* Migration dashboard using Streamlit
* AI-powered migration validation assistant

---

# 👨‍💻 Author

**Phani Kumar Pinjala**

Oracle DBA | PostgreSQL DBA | Database Migration | AI/ML Enthusiast

---

# ⭐ Project Status

```text
Migration Status: SUCCESSFUL

Oracle → PostgreSQL

Schema Migration      ✅

Data Migration        ✅

Validation            ✅

PostgreSQL Version    18

Ora2Pg Version        25.0
```

