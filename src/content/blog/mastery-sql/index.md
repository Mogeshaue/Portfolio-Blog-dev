---
title: Mastery sql
date: "2025-11-18"
draft: false
summary: Master guid for sql
tags: []
---

# 🎓 SQL Mastery Guide - From Beginner to Expert
## Using Your Campus Plus Project

---

## 📚 Table of Contents
1. [SQL Basics - Foundation](#level-1-sql-basics)
2. [Intermediate SQL - Joins & Relationships](#level-2-intermediate-sql)
3. [Advanced SQL - Aggregations & Subqueries](#level-3-advanced-sql)
4. [Expert SQL - Performance & Optimization](#level-4-expert-sql)
5. [Django ORM to SQL Translation](#django-orm-to-sql-mapping)
6. [Real Project Examples](#real-project-examples)
7. [Practice Exercises](#practice-exercises)

---

## 🎯 LEVEL 1: SQL BASICS

### 1.1 Understanding Tables

**Your Database Tables:**
```
hostel_hostelapproval         (Outpass requests - 20,000+ records)
base_app_userrecord           (Students/Staff data)
hostel_hotelaprovaltag        (Approval workflow)
hostel_avenue                 (Hostels/Areas)
hostel_avenuecheckin          (Check-in/out logs)
hostel_calllog                (Parent call logs)
```

**See Table Structure:**
```sql
-- PostgreSQL
\d hostel_hostelapproval

-- Or in SQL
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'hostel_hostelapproval';
```

### 1.2 SELECT - Reading Data

#### **Django ORM:**
```python
# Get all outpass records
HostelApproval.objects.all()
```

#### **Equivalent SQL:**
```sql
SELECT * 
FROM hostel_hostelapproval;
```

#### **Select Specific Columns:**
```python
# Django
HostelApproval.objects.values('id', 'status', 'start_date')
```

```sql
-- SQL
SELECT id, status, start_date 
FROM hostel_hostelapproval;
```

**💡 Pro Tip:** Always select only needed columns in production!

---

### 1.3 WHERE - Filtering Data

#### **Single Condition:**
```python
# Django: Get pending outpasses
HostelApproval.objects.filter(status='PENDING')
```

```sql
-- SQL
SELECT * 
FROM hostel_hostelapproval 
WHERE status = 'PENDING';
```

#### **Multiple Conditions (AND):**
```python
# Django
HostelApproval.objects.filter(
    status='APPROVED',
    type='WEEKEND'
)
```

```sql
-- SQL
SELECT * 
FROM hostel_hostelapproval 
WHERE status = 'APPROVED' 
  AND type = 'WEEKEND';
```

#### **OR Conditions:**
```python
# Django: Using Q objects
from django.db.models import Q

HostelApproval.objects.filter(
    Q(status='PENDING') | Q(status='REJECTED')
)
```

```sql
-- SQL
SELECT * 
FROM hostel_hostelapproval 
WHERE status = 'PENDING' 
   OR status = 'REJECTED';

-- Or using IN
SELECT * 
FROM hostel_hostelapproval 
WHERE status IN ('PENDING', 'REJECTED');
```

---

### 1.4 Comparison Operators

| Operator | Django | SQL | Example |
|----------|--------|-----|---------|
| Equals | `field=value` | `=` | `status = 'APPROVED'` |
| Not equals | `field__ne=value` | `!=` or `<>` | `status != 'PENDING'` |
| Greater than | `field__gt=value` | `>` | `id > 1000` |
| Less than | `field__lt=value` | `<` | `id < 500` |
| Greater or equal | `field__gte=value` | `>=` | `id >= 100` |
| Less or equal | `field__lte=value` | `<=` | `id <= 200` |
| In list | `field__in=[...]` | `IN (...)` | `status IN ('APPROVED', 'PENDING')` |
| Contains | `field__contains='text'` | `LIKE '%text%'` | `reason LIKE '%medical%'` |
| Starts with | `field__startswith='text'` | `LIKE 'text%'` | `reason LIKE 'Emergency%'` |
| Is NULL | `field__isnull=True` | `IS NULL` | `reject_reason IS NULL` |

**Examples from Your Project:**

```python
# Django: Get outpasses applied in last 7 days
from datetime import datetime, timedelta
week_ago = datetime.now() - timedelta(days=7)

HostelApproval.objects.filter(applied_at__gte=week_ago)
```

```sql
-- SQL
SELECT * 
FROM hostel_hostelapproval 
WHERE applied_at >= NOW() - INTERVAL '7 days';
```

---

### 1.5 ORDER BY - Sorting

```python
# Django: Latest outpasses first
HostelApproval.objects.order_by('-applied_at')

# Multiple columns
HostelApproval.objects.order_by('status', '-applied_at')
```

```sql
-- SQL
SELECT * 
FROM hostel_hostelapproval 
ORDER BY applied_at DESC;

-- Multiple columns
SELECT * 
FROM hostel_hostelapproval 
ORDER BY status ASC, applied_at DESC;
```

---

### 1.6 LIMIT - Pagination

```python
# Django: First 50 records
HostelApproval.objects.all()[:50]

# Records 51-100 (offset)
HostelApproval.objects.all()[50:100]
```

```sql
-- SQL (PostgreSQL)
SELECT * 
FROM hostel_hostelapproval 
LIMIT 50;

-- With offset
SELECT * 
FROM hostel_hostelapproval 
LIMIT 50 OFFSET 50;
```

---

## 🔗 LEVEL 2: INTERMEDIATE SQL - Joins & Relationships

### 2.1 Understanding Relationships in Your Project

```
UserRecord (Student)
    ├─── HostelApproval (One student has MANY outpasses)
    ├─── AvenueCheckIn (One student has MANY check-ins)
    └─── CallLog (Through HostelApproval)

HostelApproval
    ├─── UserRecord (BELONGS TO one student)
    ├─── HostelApprovalTag (HAS MANY tags)
    └─── CallLog (HAS MANY call logs)
```

### 2.2 INNER JOIN - Get Related Data

#### **Get Outpasses WITH Student Names:**

```python
# Django: Automatically joined
approval = HostelApproval.objects.get(id=1)
student_name = approval.record.name  # Django makes a query here!

# Better: Use select_related to join
approvals = HostelApproval.objects.select_related('record')
for approval in approvals:
    print(approval.record.name)  # No extra query!
```

```sql
-- SQL: Explicit JOIN
SELECT 
    ha.id,
    ha.status,
    ha.start_date,
    ha.end_date,
    ur.name AS student_name,
    ur.uid AS student_uid,
    ur.email AS student_email
FROM hostel_hostelapproval ha
INNER JOIN base_app_userrecord ur 
    ON ha.record_id = ur.id;
```

**Visual Representation:**
```
hostel_hostelapproval          base_app_userrecord
+----+--------+-----------+    +----+--------+-------+
| id | status | record_id |    | id | name   | uid   |
+----+--------+-----------+    +----+--------+-------+
| 1  | PEND.. | 100       |───>| 100| John   | CS001 |
| 2  | APPR.. | 101       |───>| 101| Sarah  | CS002 |
+----+--------+-----------+    +----+--------+-------+
```

---

### 2.3 LEFT JOIN - Include Records Even Without Match

**Get ALL students, with their latest outpass (if any):**

```python
# Django: Not straightforward, but possible
from django.db.models import Prefetch

UserRecord.objects.prefetch_related(
    Prefetch('hostelapproval_set',
        queryset=HostelApproval.objects.order_by('-applied_at'))
)
```

```sql
-- SQL
SELECT 
    ur.id,
    ur.name,
    ur.uid,
    ha.status,
    ha.applied_at
FROM base_app_userrecord ur
LEFT JOIN hostel_hostelapproval ha 
    ON ur.id = ha.record_id
ORDER BY ur.id, ha.applied_at DESC;
```

**Difference: INNER vs LEFT JOIN**
```
INNER JOIN: Only students WHO HAVE outpasses
LEFT JOIN:  ALL students, even if NO outpasses
```

---

### 2.4 Multiple Joins

**Get Outpass with Student AND Approval Tag:**

```python
# Django
HostelApproval.objects.select_related(
    'record',
    'last_related_tag',
    'last_related_tag__tagged_by'
)
```

```sql
-- SQL
SELECT 
    ha.id,
    ha.status,
    ur.name AS student_name,
    hat.status AS tag_status,
    ur2.name AS tagged_by_name
FROM hostel_hostelapproval ha
INNER JOIN base_app_userrecord ur 
    ON ha.record_id = ur.id
LEFT JOIN hostel_hostelapproval_tag hat 
    ON ha.last_related_tag_id = hat.id
LEFT JOIN base_app_userrecord ur2 
    ON hat.tagged_by_id = ur2.id;
```

---

### 2.5 Reverse Relationships (One-to-Many)

**Get a Student with ALL their outpasses:**

```python
# Django: reverse relationship
student = UserRecord.objects.get(uid='CS001')
outpasses = student.hostelapproval_set.all()

# Or prefetch for efficiency
students = UserRecord.objects.prefetch_related('hostelapproval_set')
```

```sql
-- SQL: Same as before, just reversed perspective
SELECT 
    ur.name,
    ur.uid,
    ha.id AS outpass_id,
    ha.status,
    ha.start_date
FROM base_app_userrecord ur
LEFT JOIN hostel_hostelapproval ha 
    ON ur.id = ha.record_id
WHERE ur.uid = 'CS001';
```

---

## 📊 LEVEL 3: ADVANCED SQL - Aggregations & Analytics

### 3.1 COUNT - Counting Records

**Count Total Outpasses:**

```python
# Django
total = HostelApproval.objects.count()

# Count by status
from django.db.models import Count
HostelApproval.objects.values('status').annotate(count=Count('id'))
```

```sql
-- SQL
SELECT COUNT(*) 
FROM hostel_hostelapproval;

-- Count by status
SELECT status, COUNT(*) AS count
FROM hostel_hostelapproval
GROUP BY status;
```

**Result:**
```
status    | count
----------|------
PENDING   | 150
APPROVED  | 18500
REJECTED  | 1350
```

---

### 3.2 GROUP BY - Grouping & Aggregation

**This is SUPER IMPORTANT for analytics!**

#### **Count Outpasses Per Student:**

```python
# Django
from django.db.models import Count

UserRecord.objects.annotate(
    outpass_count=Count('hostelapproval')
).values('name', 'uid', 'outpass_count')
```

```sql
-- SQL
SELECT 
    ur.name,
    ur.uid,
    COUNT(ha.id) AS outpass_count
FROM base_app_userrecord ur
LEFT JOIN hostel_hostelapproval ha 
    ON ur.id = ha.record_id
GROUP BY ur.id, ur.name, ur.uid
ORDER BY outpass_count DESC;
```

**Key Rule:** 
```
Every column in SELECT must be either:
1. In GROUP BY, OR
2. Inside an aggregate function (COUNT, SUM, AVG, etc.)
```

---

### 3.3 HAVING - Filter After Grouping

**Find Students with MORE than 10 outpasses:**

```python
# Django
UserRecord.objects.annotate(
    outpass_count=Count('hostelapproval')
).filter(outpass_count__gt=10)
```

```sql
-- SQL
SELECT 
    ur.name,
    ur.uid,
    COUNT(ha.id) AS outpass_count
FROM base_app_userrecord ur
LEFT JOIN hostel_hostelapproval ha 
    ON ur.id = ha.record_id
GROUP BY ur.id, ur.name, ur.uid
HAVING COUNT(ha.id) > 10
ORDER BY outpass_count DESC;
```

**WHERE vs HAVING:**
```
WHERE:  Filter BEFORE grouping (filter rows)
HAVING: Filter AFTER grouping (filter groups)
```

---

### 3.4 Aggregate Functions

| Function | Django | SQL | Use Case |
|----------|--------|-----|----------|
| Count | `Count('field')` | `COUNT(field)` | Count records |
| Sum | `Sum('field')` | `SUM(field)` | Total amount |
| Average | `Avg('field')` | `AVG(field)` | Average value |
| Maximum | `Max('field')` | `MAX(field)` | Highest value |
| Minimum | `Min('field')` | `MIN(field)` | Lowest value |

**Example: Average Outpass Duration:**

```python
# Django
from django.db.models import Avg, ExpressionWrapper, F, DurationField

HostelApproval.objects.annotate(
    duration=ExpressionWrapper(
        F('end_date') - F('start_date'),
        output_field=DurationField()
    )
).aggregate(avg_duration=Avg('duration'))
```

```sql
-- SQL
SELECT 
    AVG(end_date - start_date) AS avg_duration
FROM hostel_hostelapproval;
```

---

### 3.5 CASE - Conditional Logic

**Categorize Outpasses by Duration:**

```python
# Django
from django.db.models import Case, When, Value, CharField

HostelApproval.objects.annotate(
    duration_category=Case(
        When(end_date__lte=F('start_date') + timedelta(days=1), 
             then=Value('Short')),
        When(end_date__lte=F('start_date') + timedelta(days=3), 
             then=Value('Medium')),
        default=Value('Long'),
        output_field=CharField()
    )
)
```

```sql
-- SQL
SELECT 
    id,
    status,
    CASE 
        WHEN (end_date - start_date) <= INTERVAL '1 day' THEN 'Short'
        WHEN (end_date - start_date) <= INTERVAL '3 days' THEN 'Medium'
        ELSE 'Long'
    END AS duration_category
FROM hostel_hostelapproval;
```

---

### 3.6 Subqueries

**Find Students Who Never Applied for Outpass:**

```python
# Django
UserRecord.objects.filter(hostelapproval__isnull=True)

# Or using exclude
UserRecord.objects.exclude(
    id__in=HostelApproval.objects.values_list('record_id', flat=True)
)
```

```sql
-- SQL Method 1: NOT IN
SELECT * 
FROM base_app_userrecord
WHERE id NOT IN (
    SELECT DISTINCT record_id 
    FROM hostel_hostelapproval
);

-- SQL Method 2: NOT EXISTS
SELECT * 
FROM base_app_userrecord ur
WHERE NOT EXISTS (
    SELECT 1 
    FROM hostel_hostelapproval ha
    WHERE ha.record_id = ur.id
);

-- SQL Method 3: LEFT JOIN with NULL check
SELECT ur.* 
FROM base_app_userrecord ur
LEFT JOIN hostel_hostelapproval ha 
    ON ur.id = ha.record_id
WHERE ha.id IS NULL;
```

---

## ⚡ LEVEL 4: EXPERT SQL - Performance & Optimization

### 4.1 Understanding Indexes

**Why Indexes Matter:**
```
Without Index: Database scans ALL 20,000 rows
With Index:    Database uses B-Tree, finds in ~15 lookups
```

**See Existing Indexes:**
```sql
-- PostgreSQL
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'hostel_hostelapproval';
```

**Create Index:**
```sql
-- Single column
CREATE INDEX idx_status 
ON hostel_hostelapproval(status);

-- Composite index (Your optimization!)
CREATE INDEX idx_status_applied 
ON hostel_hostelapproval(status, applied_at);

-- Django creates these automatically for ForeignKeys
CREATE INDEX idx_record_id 
ON hostel_hostelapproval(record_id);
```

---

### 4.2 EXPLAIN - Query Analysis

**See How PostgreSQL Executes a Query:**

```sql
EXPLAIN ANALYZE
SELECT ha.*, ur.name
FROM hostel_hostelapproval ha
JOIN base_app_userrecord ur ON ha.record_id = ur.id
WHERE ha.status = 'PENDING';
```

**Output Example:**
```
Nested Loop  (cost=0.29..850.42 rows=150 width=200)
  -> Index Scan using idx_status on hostel_hostelapproval
       (cost=0.29..450.00 rows=150 width=180)
       Index Cond: (status = 'PENDING')
  -> Index Scan using base_app_userrecord_pkey on base_app_userrecord
       (cost=0.29..2.50 rows=1 width=50)
       Index Cond: (id = ha.record_id)
```

**Reading EXPLAIN:**
- **Seq Scan** = BAD (full table scan)
- **Index Scan** = GOOD (using index)
- **cost** = estimated cost (lower is better)
- **rows** = estimated rows returned

---

### 4.3 The N+1 Query Problem (Critical!)

**❌ BAD - Creates 20,000 Queries:**

```python
# Django: Each approval.record makes a new query!
approvals = HostelApproval.objects.all()  # 1 query
for approval in approvals:
    print(approval.record.name)  # 20,000 queries! 😱
```

```sql
-- What Django executes:
SELECT * FROM hostel_hostelapproval;  -- Query 1

SELECT * FROM base_app_userrecord WHERE id = 1;  -- Query 2
SELECT * FROM base_app_userrecord WHERE id = 2;  -- Query 3
SELECT * FROM base_app_userrecord WHERE id = 3;  -- Query 4
-- ... 20,000 times! 💀
```

**✅ GOOD - Creates 1 Query:**

```python
# Django: select_related = JOIN
approvals = HostelApproval.objects.select_related('record')  # 1 query!
for approval in approvals:
    print(approval.record.name)  # No additional queries!
```

```sql
-- What Django executes:
SELECT 
    ha.*,
    ur.id, ur.name, ur.uid, ur.email
FROM hostel_hostelapproval ha
INNER JOIN base_app_userrecord ur 
    ON ha.record_id = ur.id;  -- Just 1 query! ✨
```

**Performance Difference:**
```
N+1 Queries:  20,001 database hits = 30-60 seconds ❌
JOIN Query:   1 database hit       = 0.5 seconds  ✅
```

---

### 4.4 select_related vs prefetch_related

| | select_related | prefetch_related |
|---|---|---|
| **Use for** | ForeignKey, OneToOne | ManyToMany, Reverse FK |
| **SQL Method** | JOIN | Separate IN query |
| **Queries** | 1 query | 2+ queries (still efficient) |

**Example:**

```python
# select_related (ForeignKey)
HostelApproval.objects.select_related('record', 'special_approval')

# prefetch_related (Reverse relationship)
HostelApproval.objects.prefetch_related('hostel_approval_tags')

# Combined
HostelApproval.objects.select_related('record').prefetch_related('hostel_approval_tags')
```

```sql
-- select_related generates:
SELECT ha.*, ur.*, sa.*
FROM hostel_hostelapproval ha
JOIN base_app_userrecord ur ON ha.record_id = ur.id
LEFT JOIN hostel_special_hostel_approvals sa ON ha.special_approval_id = sa.id;

-- prefetch_related generates:
SELECT * FROM hostel_hostelapproval;  -- Query 1
SELECT * FROM hostel_hostelapproval_tag 
WHERE approval_id IN (1, 2, 3, ...);  -- Query 2
```

---

### 4.5 Query Optimization Patterns

#### **Pattern 1: Only Select Needed Fields**

```python
# ❌ BAD: Loads ALL fields
HostelApproval.objects.all()

# ✅ GOOD: Only needed fields
HostelApproval.objects.values('id', 'status', 'start_date')

# ✅ GOOD: Only specific fields as dict
HostelApproval.objects.only('id', 'status', 'start_date')
```

```sql
-- BAD
SELECT * FROM hostel_hostelapproval;

-- GOOD
SELECT id, status, start_date 
FROM hostel_hostelapproval;
```

---

#### **Pattern 2: Use EXISTS for Boolean Checks**

```python
# ❌ BAD: Loads all records
if HostelApproval.objects.filter(status='PENDING').count() > 0:
    ...

# ✅ GOOD: Just checks existence
if HostelApproval.objects.filter(status='PENDING').exists():
    ...
```

```sql
-- BAD: Counts everything
SELECT COUNT(*) FROM hostel_hostelapproval WHERE status = 'PENDING';

-- GOOD: Stops at first match
SELECT EXISTS(
    SELECT 1 FROM hostel_hostelapproval 
    WHERE status = 'PENDING' 
    LIMIT 1
);
```

---

#### **Pattern 3: Batch Operations**

```python
# ❌ BAD: N database hits
for approval_id in [1, 2, 3, ..., 1000]:
    HostelApproval.objects.get(id=approval_id).delete()

# ✅ GOOD: 1 database hit
HostelApproval.objects.filter(id__in=[1, 2, 3, ..., 1000]).delete()
```

```sql
-- BAD: 1000 queries
DELETE FROM hostel_hostelapproval WHERE id = 1;
DELETE FROM hostel_hostelapproval WHERE id = 2;
-- ... 1000 times

-- GOOD: 1 query
DELETE FROM hostel_hostelapproval 
WHERE id IN (1, 2, 3, ..., 1000);
```

---

## 🔄 LEVEL 5: Django ORM to SQL - Complete Mapping

### Common ORM Operations

```python
# ============================================
# 1. FILTER (WHERE)
# ============================================
HostelApproval.objects.filter(status='PENDING')
# SQL: WHERE status = 'PENDING'

HostelApproval.objects.filter(status='PENDING', type='WEEKEND')
# SQL: WHERE status = 'PENDING' AND type = 'WEEKEND'

HostelApproval.objects.filter(Q(status='PENDING') | Q(status='REJECTED'))
# SQL: WHERE status = 'PENDING' OR status = 'REJECTED'

# ============================================
# 2. EXCLUDE (WHERE NOT)
# ============================================
HostelApproval.objects.exclude(status='REJECTED')
# SQL: WHERE status != 'REJECTED'

# ============================================
# 3. GET (Single Record)
# ============================================
HostelApproval.objects.get(id=1)
# SQL: SELECT * FROM hostel_hostelapproval WHERE id = 1 LIMIT 1

# ============================================
# 4. FIRST / LAST
# ============================================
HostelApproval.objects.first()
# SQL: SELECT * FROM hostel_hostelapproval ORDER BY id LIMIT 1

HostelApproval.objects.order_by('-applied_at').first()
# SQL: SELECT * FROM hostel_hostelapproval ORDER BY applied_at DESC LIMIT 1

# ============================================
# 5. COUNT
# ============================================
HostelApproval.objects.count()
# SQL: SELECT COUNT(*) FROM hostel_hostelapproval

HostelApproval.objects.filter(status='PENDING').count()
# SQL: SELECT COUNT(*) FROM hostel_hostelapproval WHERE status = 'PENDING'

# ============================================
# 6. ORDER BY
# ============================================
HostelApproval.objects.order_by('applied_at')  # ASC
# SQL: ORDER BY applied_at ASC

HostelApproval.objects.order_by('-applied_at')  # DESC
# SQL: ORDER BY applied_at DESC

# ============================================
# 7. DISTINCT
# ============================================
HostelApproval.objects.values('status').distinct()
# SQL: SELECT DISTINCT status FROM hostel_hostelapproval

# ============================================
# 8. VALUES / VALUES_LIST
# ============================================
HostelApproval.objects.values('id', 'status')
# SQL: SELECT id, status FROM hostel_hostelapproval
# Returns: [{'id': 1, 'status': 'PENDING'}, ...]

HostelApproval.objects.values_list('id', 'status')
# SQL: SELECT id, status FROM hostel_hostelapproval
# Returns: [(1, 'PENDING'), ...]

HostelApproval.objects.values_list('id', flat=True)
# SQL: SELECT id FROM hostel_hostelapproval
# Returns: [1, 2, 3, ...]

# ============================================
# 9. UPDATE
# ============================================
HostelApproval.objects.filter(status='PENDING').update(status='APPROVED')
# SQL: UPDATE hostel_hostelapproval SET status = 'APPROVED' WHERE status = 'PENDING'

# ============================================
# 10. DELETE
# ============================================
HostelApproval.objects.filter(id=1).delete()
# SQL: DELETE FROM hostel_hostelapproval WHERE id = 1

# ============================================
# 11. ANNOTATE (Add calculated field)
# ============================================
from django.db.models import Count
UserRecord.objects.annotate(outpass_count=Count('hostelapproval'))
# SQL: 
# SELECT ur.*, COUNT(ha.id) AS outpass_count
# FROM base_app_userrecord ur
# LEFT JOIN hostel_hostelapproval ha ON ur.id = ha.record_id
# GROUP BY ur.id

# ============================================
# 12. AGGREGATE (Calculate single value)
# ============================================
from django.db.models import Avg, Max, Min
HostelApproval.objects.aggregate(
    total=Count('id'),
    max_id=Max('id')
)
# SQL: SELECT COUNT(id) AS total, MAX(id) AS max_id FROM hostel_hostelapproval

# ============================================
# 13. SELECT_RELATED (JOIN - ForeignKey)
# ============================================
HostelApproval.objects.select_related('record')
# SQL:
# SELECT ha.*, ur.*
# FROM hostel_hostelapproval ha
# INNER JOIN base_app_userrecord ur ON ha.record_id = ur.id

# ============================================
# 14. PREFETCH_RELATED (Separate query)
# ============================================
HostelApproval.objects.prefetch_related('hostel_approval_tags')
# SQL: (2 queries)
# SELECT * FROM hostel_hostelapproval;
# SELECT * FROM hostel_hostelapproval_tag WHERE approval_id IN (1,2,3,...);

# ============================================
# 15. F EXPRESSIONS (Reference other fields)
# ============================================
from django.db.models import F
HostelApproval.objects.filter(end_date__gt=F('start_date') + timedelta(days=7))
# SQL: WHERE end_date > start_date + INTERVAL '7 days'

# ============================================
# 16. RAW SQL
# ============================================
HostelApproval.objects.raw(
    'SELECT * FROM hostel_hostelapproval WHERE status = %s',
    ['PENDING']
)
```

---

## 💼 LEVEL 6: Real Project Examples from Your Code

### Example 1: Leave Approvals Under Mentor

**From: `hostel/views.py` Line 80**

```python
# Django ORM
pending_approvals = HostelApproval.objects.filter(
    last_related_tag__tagged_to=record.email,
    last_related_tag__status=HostelApprovalTag.PENDING,
)
```

**SQL Translation:**
```sql
SELECT ha.*
FROM hostel_hostelapproval ha
INNER JOIN hostel_hostelapproval_tag hat 
    ON ha.last_related_tag_id = hat.id
WHERE hat.tagged_to = 'mentor@example.com'
  AND hat.status = 'PENDING';
```

**What it does:**
- Joins HostelApproval with HostelApprovalTag
- Filters by mentor email and pending status
- Returns outpasses pending on this mentor

---

### Example 2: Count Statistics

**From: `hostel/views.py` Line 215-227**

```python
# Django ORM
total_outpass_count = HostelApproval.objects.filter(
    tagged_to=record.email
).count()

pending_outpass_count = HostelApproval.objects.filter(
    tagged_to=record.email, status=HostelApproval.PENDING
).count()

approved_outpass_count = HostelApproval.objects.filter(
    tagged_to=record.email, status=HostelApproval.APPROVED
).count()
```

**SQL Translation:**
```sql
-- Total count
SELECT COUNT(*) 
FROM hostel_hostelapproval 
WHERE tagged_to = 'admin@example.com';

-- Pending count
SELECT COUNT(*) 
FROM hostel_hostelapproval 
WHERE tagged_to = 'admin@example.com' 
  AND status = 'PENDING';

-- Approved count
SELECT COUNT(*) 
FROM hostel_hostelapproval 
WHERE tagged_to = 'admin@example.com' 
  AND status = 'APPROVED';
```

**Better Optimization (Single Query):**
```python
# Django - More efficient!
from django.db.models import Count, Q

stats = HostelApproval.objects.filter(
    tagged_to=record.email
).aggregate(
    total=Count('id'),
    pending=Count('id', filter=Q(status=HostelApproval.PENDING)),
    approved=Count('id', filter=Q(status=HostelApproval.APPROVED)),
    rejected=Count('id', filter=Q(status=HostelApproval.REJECTED))
)
```

```sql
-- SQL - Single query with CASE
SELECT 
    COUNT(*) AS total,
    COUNT(CASE WHEN status = 'PENDING' THEN 1 END) AS pending,
    COUNT(CASE WHEN status = 'APPROVED' THEN 1 END) AS approved,
    COUNT(CASE WHEN status = 'REJECTED' THEN 1 END) AS rejected
FROM hostel_hostelapproval
WHERE tagged_to = 'admin@example.com';
```

---

### Example 3: Recent Outpasses (Last Week)

**From: `hostel/views.py` Line 787**

```python
# Django ORM
start_of_week = datetime.now() - timedelta(days=7)
end_of_week = datetime.now()

logs_within_week = HostelApproval.objects.filter(
    record=request.user.associated_user,
    applied_at__gte=start_of_week,
    applied_at__lte=end_of_week
)
```

**SQL Translation:**
```sql
SELECT * 
FROM hostel_hostelapproval
WHERE record_id = 123
  AND applied_at >= '2025-11-04 00:00:00'
  AND applied_at <= '2025-11-11 23:59:59';

-- Or cleaner with BETWEEN
SELECT * 
FROM hostel_hostelapproval
WHERE record_id = 123
  AND applied_at BETWEEN '2025-11-04' AND '2025-11-11';
```

---

### Example 4: Check-in with Multiple Filters

**From: `hostel/views.py` Line 1207**

```python
# Django ORM
check_ins_for_the_day = CheckIn.objects.filter(
    checked_in_at__date=date.today()
)
```

**SQL Translation:**
```sql
SELECT * 
FROM base_app_checkin
WHERE DATE(checked_in_at) = CURRENT_DATE;

-- Or with explicit date
SELECT * 
FROM base_app_checkin
WHERE checked_in_at >= '2025-11-11 00:00:00'
  AND checked_in_at < '2025-11-12 00:00:00';
```

---

### Example 5: Complex Query with Exclude

**From: `hostel/views.py` Line 794-795**

```python
# Django ORM
logs_outside_week = (
    HostelApproval.objects.filter(record=request.user.associated_user)
    .exclude(applied_at__gte=start_of_week, applied_at__lte=end_of_week)
    .order_by("-applied_at")
)
```

**SQL Translation:**
```sql
SELECT * 
FROM hostel_hostelapproval
WHERE record_id = 123
  AND NOT (
      applied_at >= '2025-11-04 00:00:00'
      AND applied_at <= '2025-11-11 23:59:59'
  )
ORDER BY applied_at DESC;

-- Simpler version
SELECT * 
FROM hostel_hostelapproval
WHERE record_id = 123
  AND (
      applied_at < '2025-11-04 00:00:00'
      OR applied_at > '2025-11-11 23:59:59'
  )
ORDER BY applied_at DESC;
```

---

## 🎮 LEVEL 7: Practice Exercises

### Exercise 1: Basic Queries
```sql
-- 1. Get all approved outpasses
SELECT * FROM hostel_hostelapproval WHERE status = 'APPROVED';

-- 2. Count rejected outpasses
SELECT COUNT(*) FROM hostel_hostelapproval WHERE status = 'REJECTED';

-- 3. Get outpasses from last month
SELECT * FROM hostel_hostelapproval 
WHERE applied_at >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
  AND applied_at < DATE_TRUNC('month', CURRENT_DATE);

-- 4. Find emergency outpasses
SELECT * FROM hostel_hostelapproval WHERE emergency = TRUE;

-- 5. Get weekend outpasses only
SELECT * FROM hostel_hostelapproval WHERE type = 'WEEKEND';
```

### Exercise 2: Joins
```sql
-- 1. Get student name with each outpass
SELECT ha.id, ha.status, ur.name, ur.uid
FROM hostel_hostelapproval ha
JOIN base_app_userrecord ur ON ha.record_id = ur.id;

-- 2. Get approved outpasses with student email
SELECT ha.id, ha.start_date, ur.name, ur.email
FROM hostel_hostelapproval ha
JOIN base_app_userrecord ur ON ha.record_id = ur.id
WHERE ha.status = 'APPROVED';

-- 3. Get outpasses with approval tags
SELECT ha.id, ha.status, hat.tagged_to, hat.status AS tag_status
FROM hostel_hostelapproval ha
LEFT JOIN hostel_hostelapproval_tag hat ON ha.last_related_tag_id = hat.id;
```

### Exercise 3: Aggregations
```sql
-- 1. Count outpasses by status
SELECT status, COUNT(*) AS count
FROM hostel_hostelapproval
GROUP BY status;

-- 2. Count outpasses per student
SELECT ur.name, ur.uid, COUNT(ha.id) AS outpass_count
FROM base_app_userrecord ur
LEFT JOIN hostel_hostelapproval ha ON ur.id = ha.record_id
GROUP BY ur.id, ur.name, ur.uid
ORDER BY outpass_count DESC;

-- 3. Find students with more than 5 outpasses
SELECT ur.name, COUNT(ha.id) AS outpass_count
FROM base_app_userrecord ur
JOIN hostel_hostelapproval ha ON ur.id = ha.record_id
GROUP BY ur.id, ur.name
HAVING COUNT(ha.id) > 5;

-- 4. Average outpass duration
SELECT AVG(end_date - start_date) AS avg_duration
FROM hostel_hostelapproval;

-- 5. Count by type and status
SELECT type, status, COUNT(*) AS count
FROM hostel_hostelapproval
GROUP BY type, status
ORDER BY type, status;
```

### Exercise 4: Complex Queries
```sql
-- 1. Find students who never applied for outpass
SELECT ur.* 
FROM base_app_userrecord ur
LEFT JOIN hostel_hostelapproval ha ON ur.id = ha.record_id
WHERE ha.id IS NULL;

-- 2. Get latest outpass for each student
SELECT DISTINCT ON (record_id)
    id, record_id, status, applied_at
FROM hostel_hostelapproval
ORDER BY record_id, applied_at DESC;

-- 3. Count outpasses by month
SELECT 
    DATE_TRUNC('month', applied_at) AS month,
    COUNT(*) AS count
FROM hostel_hostelapproval
GROUP BY DATE_TRUNC('month', applied_at)
ORDER BY month DESC;

-- 4. Students with pending and approved outpasses
SELECT ur.name, ur.uid
FROM base_app_userrecord ur
WHERE EXISTS (
    SELECT 1 FROM hostel_hostelapproval 
    WHERE record_id = ur.id AND status = 'PENDING'
)
AND EXISTS (
    SELECT 1 FROM hostel_hostelapproval 
    WHERE record_id = ur.id AND status = 'APPROVED'
);
```

---

## 🛠️ Tools & Resources

### 1. Test Queries in Django Shell
```bash
python manage.py shell

from hostel.models import *
from base_app.models import *

# See actual SQL
print(HostelApproval.objects.filter(status='PENDING').query)

# Time a query
import time
start = time.time()
list(HostelApproval.objects.all())
print(f"Time: {time.time() - start}s")
```

### 2. See All Queries
```python
# settings.py
LOGGING = {
    'version': 1,
    'handlers': {
        'console': {'class': 'logging.StreamHandler'},
    },
    'loggers': {
        'django.db.backends': {
            'handlers': ['console'],
            'level': 'DEBUG',
        },
    },
}
```

### 3. Django Debug Toolbar
```bash
pip install django-debug-toolbar
```

### 4. PostgreSQL CLI
```bash
# Connect to database
psql -U your_user -d campus_plus

# Inside psql:
\dt                          -- List tables
\d hostel_hostelapproval     -- Describe table
\di                          -- List indexes
\timing                      -- Show query time
```

---

## 📈 Performance Checklist

✅ **Always use indexes on:**
- Foreign keys (Django does this automatically)
- Frequently filtered columns (status, applied_at, etc.)
- Columns used in ORDER BY

✅ **Always use select_related for:**
- ForeignKey relationships you'll access

✅ **Always use prefetch_related for:**
- ManyToMany relationships
- Reverse ForeignKey relationships

✅ **Never do:**
- `SELECT *` in production (use only needed fields)
- N+1 queries (always check with Django Debug Toolbar)
- Count queries when you just need EXISTS

✅ **Use bulk operations:**
- `bulk_create()` instead of loop + save()
- `update()` instead of loop + save()
- `filter().delete()` instead of loop + delete()

---

## 🎓 SQL Learning Path

### Week 1-2: Basics
- [ ] SELECT, WHERE, ORDER BY, LIMIT
- [ ] Comparison operators
- [ ] Practice with your HostelApproval table

### Week 3-4: Joins
- [ ] INNER JOIN, LEFT JOIN
- [ ] Multiple joins
- [ ] Practice joining HostelApproval with UserRecord

### Week 5-6: Aggregations
- [ ] GROUP BY, HAVING
- [ ] COUNT, SUM, AVG, MAX, MIN
- [ ] Practice analytics queries

### Week 7-8: Advanced
- [ ] Subqueries
- [ ] CASE statements
- [ ] Window functions
- [ ] EXPLAIN and optimization

### Week 9-10: Expert
- [ ] Indexes and performance
- [ ] Query optimization
- [ ] Transaction management
- [ ] Database design principles

---

## 📚 Next Steps

1. **Practice Daily**: Write 5 queries every day
2. **Use Django Shell**: Test ORM vs SQL
3. **Read Query Plans**: Use EXPLAIN to understand performance
4. **Optimize Real Code**: Improve your project's queries
5. **Build Analytics**: Create dashboard queries

---

**Remember:** 
> "The best way to learn SQL is to write SQL."  
> Start with simple SELECT queries and build up!

Good luck! 🚀

