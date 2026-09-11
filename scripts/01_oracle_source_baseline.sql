-- ============================================================
-- Oracle -> PostgreSQL Migration
-- Source Baseline: Oracle HR Schema
-- Oracle Database: 26ai
-- ============================================================

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 5000
SET LINESIZE 250
SET LONG 100000
SET LONGCHUNKSIZE 100000
SET TRIMSPOOL ON

COLUMN run_timestamp FORMAT A30

SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') AS run_timestamp
FROM DUAL;

PROMPT ============================================================
PROMPT 1. DATABASE / SCHEMA INFORMATION
PROMPT ============================================================

SELECT
    SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
    SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS service_name,
    SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema,
    SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name
FROM DUAL;

PROMPT ============================================================
PROMPT 2. OBJECT INVENTORY
PROMPT ============================================================

SELECT
    OWNER,
    OBJECT_TYPE,
    COUNT(*) AS OBJECT_COUNT
FROM ALL_OBJECTS
WHERE OWNER = 'HR'
  AND OBJECT_TYPE IN (
      'TABLE',
      'INDEX',
      'SEQUENCE',
      'VIEW',
      'PROCEDURE',
      'TRIGGER'
  )
GROUP BY OWNER, OBJECT_TYPE
ORDER BY OBJECT_TYPE;

PROMPT ============================================================
PROMPT 3. TABLE ROW COUNTS
PROMPT ============================================================

SELECT
    OWNER AS SCHEMA_NAME,
    TABLE_NAME,
    NUM_ROWS AS ROW_COUNT,
    LAST_ANALYZED
FROM ALL_TABLES
WHERE OWNER = 'HR'
ORDER BY NUM_ROWS DESC;

PROMPT ============================================================
PROMPT 4. TABLE STORAGE
PROMPT ============================================================

SELECT
    OWNER AS SCHEMA_NAME,
    SEGMENT_NAME AS TABLE_NAME,
    ROUND(SUM(BYTES) / 1024 / 1024, 2) AS SIZE_MB
FROM DBA_SEGMENTS
WHERE OWNER = 'HR'
  AND SEGMENT_TYPE = 'TABLE'
GROUP BY OWNER, SEGMENT_NAME
ORDER BY SIZE_MB DESC;

PROMPT ============================================================
PROMPT 5. COLUMN DEFINITIONS
PROMPT ============================================================

SELECT
    OWNER,
    TABLE_NAME,
    COLUMN_ID,
    COLUMN_NAME,
    DATA_TYPE,
    DATA_LENGTH,
    DATA_PRECISION,
    DATA_SCALE,
    NULLABLE,
    DEFAULT_LENGTH,
    CHAR_LENGTH
FROM ALL_TAB_COLUMNS
WHERE OWNER = 'HR'
ORDER BY TABLE_NAME, COLUMN_ID;

PROMPT ============================================================
PROMPT 6. PRIMARY KEY / UNIQUE CONSTRAINTS
PROMPT ============================================================

SELECT
    OWNER,
    TABLE_NAME,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    STATUS
FROM ALL_CONSTRAINTS
WHERE OWNER = 'HR'
  AND CONSTRAINT_TYPE IN ('P', 'U')
ORDER BY TABLE_NAME, CONSTRAINT_TYPE, CONSTRAINT_NAME;

PROMPT ============================================================
PROMPT 7. FOREIGN KEY CONSTRAINTS
PROMPT ============================================================

SELECT
    AC.OWNER,
    AC.TABLE_NAME,
    AC.CONSTRAINT_NAME,
    AC.STATUS,
    AC.R_CONSTRAINT_NAME,
    AC.R_OWNER
FROM ALL_CONSTRAINTS AC
WHERE AC.OWNER = 'HR'
  AND AC.CONSTRAINT_TYPE = 'R'
ORDER BY AC.TABLE_NAME, AC.CONSTRAINT_NAME;

PROMPT ============================================================
PROMPT 8. CHECK CONSTRAINTS
PROMPT ============================================================

SELECT
    OWNER,
    TABLE_NAME,
    CONSTRAINT_NAME,
    STATUS,
    SEARCH_CONDITION
FROM ALL_CONSTRAINTS
WHERE OWNER = 'HR'
  AND CONSTRAINT_TYPE = 'C'
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

PROMPT ============================================================
PROMPT 9. INDEX INVENTORY
PROMPT ============================================================

SELECT
    OWNER,
    TABLE_NAME,
    INDEX_NAME,
    INDEX_TYPE,
    UNIQUENESS,
    STATUS,
    NUM_ROWS,
    DISTINCT_KEYS
FROM ALL_INDEXES
WHERE OWNER = 'HR'
ORDER BY TABLE_NAME, INDEX_NAME;

PROMPT ============================================================
PROMPT 10. INDEX COLUMNS
PROMPT ============================================================

SELECT
    INDEX_OWNER,
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_POSITION,
    COLUMN_NAME,
    DESCEND
FROM ALL_IND_COLUMNS
WHERE INDEX_OWNER = 'HR'
ORDER BY TABLE_NAME, INDEX_NAME, COLUMN_POSITION;

PROMPT ============================================================
PROMPT 11. SEQUENCES
PROMPT ============================================================

SELECT
    SEQUENCE_OWNER,
    SEQUENCE_NAME,
    MIN_VALUE,
    MAX_VALUE,
    INCREMENT_BY,
    CYCLE_FLAG,
    ORDER_FLAG,
    CACHE_SIZE,
    LAST_NUMBER
FROM ALL_SEQUENCES
WHERE SEQUENCE_OWNER = 'HR'
ORDER BY SEQUENCE_NAME;

PROMPT ============================================================
PROMPT 12. VIEWS
PROMPT ============================================================

SELECT
    OWNER,
    VIEW_NAME,
    TEXT_LENGTH
FROM ALL_VIEWS
WHERE OWNER = 'HR'
ORDER BY VIEW_NAME;

PROMPT ============================================================
PROMPT 13. PROCEDURES
PROMPT ============================================================

SELECT
    OWNER,
    OBJECT_NAME,
    STATUS
FROM ALL_OBJECTS
WHERE OWNER = 'HR'
  AND OBJECT_TYPE = 'PROCEDURE'
ORDER BY OBJECT_NAME;

PROMPT ============================================================
PROMPT 14. TRIGGERS
PROMPT ============================================================

SELECT
    OWNER,
    TRIGGER_NAME,
    TABLE_NAME,
    TRIGGERING_EVENT,
    TRIGGER_TYPE,
    STATUS
FROM ALL_TRIGGERS
WHERE OWNER = 'HR'
ORDER BY TABLE_NAME, TRIGGER_NAME;

PROMPT ============================================================
PROMPT 15. DATA VALIDATION TOTAL
PROMPT ============================================================

SELECT
    SUM(NUM_ROWS) AS TOTAL_STATISTICS_ROWS
FROM ALL_TABLES
WHERE OWNER = 'HR';

PROMPT ============================================================
PROMPT END OF ORACLE SOURCE BASELINE
PROMPT ============================================================
