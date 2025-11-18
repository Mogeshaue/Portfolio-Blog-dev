---
title: Sql Cheet sheet
date: "2025-11-18"
draft: false
summary: this is an cheet sheet of sql prctice
tags: []
---


# 🚀 SQL Quick Reference - Django ORM to SQL Cheat Sheet

---

## 📋 BASIC OPERATIONS

| Django ORM | SQL | Description |
|------------|-----|-------------|
| `Model.objects.all()` | `SELECT * FROM table` | Get all records |
| `Model.objects.get(id=1)` | `SELECT * FROM table WHERE id = 1 LIMIT 1` | Get single record |
| `Model.objects.filter(field=value)` | `SELECT * FROM table WHERE field = value` | Filter records |
| `Model.objects.exclude(field=value)` | `SELECT * FROM table WHERE field != value` | Exclude records |
| `Model.objects.count()` | `SELECT COUNT(*) FROM table` | Count records |
| `Model.objects.first()` | `SELECT * FROM table LIMIT 1` | First record |
| `Model.objects.last()` | `SELECT * FROM table ORDER BY id DESC LIMIT 1` | Last record |
| `Model.objects.exists()` | `SELECT EXISTS(SELECT 1 FROM table LIMIT 1)` | Check if exists |

---

## 🔍 FILTERING

| Django ORM | SQL | Description |
|------------|-----|-------------|
| `filter(age__gt=18)` | `WHERE age > 18` | Greater than |
| `filter(age__gte=18)` | `WHERE age >= 18` | Greater or equal |
| `filter(age__lt=18)` | `WHERE age < 18` | Less than |
| `filter(age__lte=18)` | `WHERE age <= 18` | Less or equal |
| `filter(name__contains='John')` | `WHERE name LIKE '%John%'` | Contains |
| `filter(name__icontains='john')` | `WHERE name ILIKE '%john%'` | Case-insensitive contains |
| `filter(name__startswith='J')` | `WHERE name LIKE 'J%'` | Starts with |
| `filter(name__endswith='n')` | `WHERE name LIKE '%n'` | Ends with |
| `filter(age__in=[18,19,20])` | `WHERE age IN (18,19,20)` | In list |
| `filter(age__range=[18,25])` | `WHERE age BETWEEN 18 AND 25` | Range |
| `filter(field__isnull=True)` | `WHERE field IS NULL` | Is null |
| `filter(field__isnull=False)` | `WHERE field IS NOT NULL` | Is not null |

---

## 🔗 JOINS

| Django ORM | SQL | Description |
|------------|-----|-------------|
| `select_related('foreign_key')` | `INNER JOIN` | ForeignKey/OneToOne (1 query) |
| `prefetch_related('many_to_many')` | `SELECT ... WHERE id IN (...)` | ManyToMany/Reverse FK (2 queries) |
| `filter(fk__field=value)` | `JOIN table ON ... WHERE field = value` | Filter through relationship |

**Example:**
```python
# Django
HostelApproval.objects.select_related('record')

# SQL
SELECT ha.*, ur.*
FROM hostel_hostelapproval ha
INNER JOIN base_app_userrecord ur ON ha.record_id = ur.id
```

---

## 📊 AGGREGATIONS

| Django ORM | SQL | Description |
|------------|-----|-------------|
| `Count('field')` | `COUNT(field)` | Count records |
| `Sum('field')` | `SUM(field)` | Sum values |
| `Avg('field')` | `AVG(field)` | Average value |
| `Max('field')` | `MAX(field)` | Maximum value |
| `Min('field')` | `MIN(field)` | Minimum value |

**aggregate() - Single value:**
```python
# Django
Model.objects.aggregate(total=Count('id'))
# Returns: {'total': 100}

# SQL
SELECT COUNT(id) AS total FROM table
```

**annotate() - Add field to each record:**
```python
# Django
User.objects.annotate(post_count=Count('posts'))
# Each user now has .post_count attribute

# SQL
SELECT u.*, COUNT(p.id) AS post_count
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
GROUP BY u.id
```

---

## 🎯 GROUP BY

```python
# Django
Model.objects.values('category').annotate(count=Count('id'))

# SQL
SELECT category, COUNT(id) AS count
FROM table
GROUP BY category
```

**With HAVING:**
```python
# Django
Model.objects.values('category').annotate(
    count=Count('id')
).filter(count__gt=5)

# SQL
SELECT category, COUNT(id) AS count
FROM table
GROUP BY category
HAVING COUNT(id) > 5
```

---

## 🔢 ORDERING

| Django ORM | SQL | Description |
|------------|-----|-------------|
| `order_by('field')` | `ORDER BY field ASC` | Ascending |
| `order_by('-field')` | `ORDER BY field DESC` | Descending |
| `order_by('field1', '-field2')` | `ORDER BY field1 ASC, field2 DESC` | Multiple fields |

---

## 📄 PAGINATION

| Django ORM | SQL | Description |
|------------|-----|-------------|
| `[:10]` | `LIMIT 10` | First 10 records |
| `[10:20]` | `LIMIT 10 OFFSET 10` | Records 11-20 |

---

## ❓ Q OBJECTS (Complex Logic)

```python
from django.db.models import Q

# OR
Model.objects.filter(Q(field1=value) | Q(field2=value))
# SQL: WHERE field1 = value OR field2 = value

# AND
Model.objects.filter(Q(field1=value) & Q(field2=value))
# SQL: WHERE field1 = value AND field2 = value

# NOT
Model.objects.filter(~Q(field=value))
# SQL: WHERE NOT field = value

# Complex
Model.objects.filter(
    Q(status='APPROVED') | Q(status='PENDING'),
    created_at__gte=date
)
# SQL: WHERE (status = 'APPROVED' OR status = 'PENDING') 
#      AND created_at >= date
```

---

## 🔧 F EXPRESSIONS (Field References)

```python
from django.db.models import F

# Compare two fields
Model.objects.filter(end_date__gt=F('start_date'))
# SQL: WHERE end_date > start_date

# Math operations
Model.objects.update(price=F('price') * 1.1)
# SQL: UPDATE table SET price = price * 1.1

# With timedelta
Model.objects.filter(
    end_date__lt=F('start_date') + timedelta(days=7)
)
# SQL: WHERE end_date < start_date + INTERVAL '7 days'
```

---

## 📝 CRUD OPERATIONS

### CREATE
```python
# Django
obj = Model.objects.create(field1=value1, field2=value2)

# SQL
INSERT INTO table (field1, field2) VALUES (value1, value2)
```

### READ
```python
# Django
obj = Model.objects.get(id=1)

# SQL
SELECT * FROM table WHERE id = 1
```

### UPDATE
```python
# Django - Single object
obj.field = new_value
obj.save()

# Django - Bulk update
Model.objects.filter(status='PENDING').update(status='APPROVED')

# SQL
UPDATE table SET status = 'APPROVED' WHERE status = 'PENDING'
```

### DELETE
```python
# Django
Model.objects.filter(id=1).delete()

# SQL
DELETE FROM table WHERE id = 1
```

---

## 🎨 VALUES & VALUES_LIST

```python
# values() - Returns list of dicts
Model.objects.values('id', 'name')
# Returns: [{'id': 1, 'name': 'John'}, {'id': 2, 'name': 'Jane'}]

# values_list() - Returns list of tuples
Model.objects.values_list('id', 'name')
# Returns: [(1, 'John'), (2, 'Jane')]

# flat=True - Returns list of single values
Model.objects.values_list('name', flat=True)
# Returns: ['John', 'Jane']

# SQL
SELECT id, name FROM table
```

---

## 🔍 DISTINCT

```python
# Django
Model.objects.values('category').distinct()

# SQL
SELECT DISTINCT category FROM table
```

---

## 📊 CONDITIONAL AGGREGATION

```python
from django.db.models import Case, When, Value, IntegerField

# Django
Model.objects.aggregate(
    pending_count=Count('id', filter=Q(status='PENDING')),
    approved_count=Count('id', filter=Q(status='APPROVED'))
)

# SQL
SELECT 
    COUNT(CASE WHEN status = 'PENDING' THEN 1 END) AS pending_count,
    COUNT(CASE WHEN status = 'APPROVED' THEN 1 END) AS approved_count
FROM table
```

---

## 🎯 CASE WHEN

```python
from django.db.models import Case, When, Value, CharField

# Django
Model.objects.annotate(
    category=Case(
        When(age__lt=18, then=Value('Minor')),
        When(age__gte=18, then=Value('Adult')),
        default=Value('Unknown'),
        output_field=CharField()
    )
)

# SQL
SELECT *,
    CASE 
        WHEN age < 18 THEN 'Minor'
        WHEN age >= 18 THEN 'Adult'
        ELSE 'Unknown'
    END AS category
FROM table
```

---

## 🔄 SUBQUERIES

```python
from django.db.models import Subquery, OuterRef

# Django
newest = Post.objects.filter(
    user=OuterRef('pk')
).order_by('-created_at')

User.objects.annotate(
    newest_post_date=Subquery(newest.values('created_at')[:1])
)

# SQL
SELECT u.*,
    (SELECT created_at 
     FROM posts 
     WHERE user_id = u.id 
     ORDER BY created_at DESC 
     LIMIT 1) AS newest_post_date
FROM users u
```

---

## 🚀 PERFORMANCE TIPS

### ❌ BAD - N+1 Queries
```python
users = User.objects.all()
for user in users:
    print(user.profile.bio)  # 1000 queries if 1000 users!
```

### ✅ GOOD - Use select_related
```python
users = User.objects.select_related('profile').all()
for user in users:
    print(user.profile.bio)  # Just 1 query!
```

### ❌ BAD - Count when checking existence
```python
if MyModel.objects.filter(field=value).count() > 0:
    ...
```

### ✅ GOOD - Use exists()
```python
if MyModel.objects.filter(field=value).exists():
    ...
```

### ❌ BAD - Load full objects when not needed
```python
names = [user.name for user in User.objects.all()]
```

### ✅ GOOD - Use values_list
```python
names = User.objects.values_list('name', flat=True)
```

---

## 🛠️ DEBUG QUERIES

### See Generated SQL
```python
queryset = Model.objects.filter(field=value)
print(queryset.query)
```

### Count Queries Executed
```python
from django.db import connection
from django.db import reset_queries

reset_queries()
# ... your code ...
print(f"Queries executed: {len(connection.queries)}")
for query in connection.queries:
    print(query['sql'])
```

### Time Queries
```python
import time
start = time.time()
list(queryset)  # Force evaluation
print(f"Time: {time.time() - start}s")
```

---

## 📚 REAL EXAMPLES FROM YOUR PROJECT

### 1. Pending Outpasses for Mentor
```python
# Django
HostelApproval.objects.filter(
    last_related_tag__tagged_to='mentor@email.com',
    last_related_tag__status='PENDING'
)

# SQL
SELECT ha.*
FROM hostel_hostelapproval ha
JOIN hostel_hostelapproval_tag hat ON ha.last_related_tag_id = hat.id
WHERE hat.tagged_to = 'mentor@email.com'
  AND hat.status = 'PENDING'
```

### 2. Count by Status
```python
# Django
HostelApproval.objects.values('status').annotate(count=Count('id'))

# SQL
SELECT status, COUNT(id) AS count
FROM hostel_hostelapproval
GROUP BY status
```

### 3. Students with Outpass Count
```python
# Django
UserRecord.objects.annotate(
    outpass_count=Count('hostelapproval')
).filter(outpass_count__gt=5)

# SQL
SELECT ur.*, COUNT(ha.id) AS outpass_count
FROM base_app_userrecord ur
LEFT JOIN hostel_hostelapproval ha ON ur.id = ha.record_id
GROUP BY ur.id
HAVING COUNT(ha.id) > 5
```

### 4. Optimized Dashboard Query
```python
# Django - OPTIMIZED (1 query)
HostelApproval.objects.filter(
    tagged_to='admin@email.com'
).aggregate(
    total=Count('id'),
    pending=Count('id', filter=Q(status='PENDING')),
    approved=Count('id', filter=Q(status='APPROVED')),
    rejected=Count('id', filter=Q(status='REJECTED'))
)

# SQL
SELECT 
    COUNT(*) AS total,
    COUNT(CASE WHEN status = 'PENDING' THEN 1 END) AS pending,
    COUNT(CASE WHEN status = 'APPROVED' THEN 1 END) AS approved,
    COUNT(CASE WHEN status = 'REJECTED' THEN 1 END) AS rejected
FROM hostel_hostelapproval
WHERE tagged_to = 'admin@email.com'
```

---

## 🎯 OPTIMIZATION CHECKLIST

- [ ] Use `select_related()` for ForeignKey/OneToOne
- [ ] Use `prefetch_related()` for ManyToMany/Reverse FK
- [ ] Use `values()` when full objects not needed
- [ ] Use `only()` to limit fields loaded
- [ ] Use `defer()` to exclude heavy fields
- [ ] Use `exists()` instead of `count() > 0`
- [ ] Use `update()` instead of loop + save()
- [ ] Use `bulk_create()` instead of loop + create()
- [ ] Add indexes to frequently filtered fields
- [ ] Use `aggregate()` with filter for conditional counts

---

## 📖 Learning Resources

1. **Django Shell**: `python manage.py shell`
2. **Debug Toolbar**: `pip install django-debug-toolbar`
3. **SQL Formatter**: https://sqlformat.org/
4. **PostgreSQL Docs**: https://www.postgresql.org/docs/
5. **Django ORM Docs**: https://docs.djangoproject.com/en/stable/topics/db/

---

**Quick Test Command:**
```bash
# Django shell
python manage.py shell

# Import models
from hostel.models import *
from base_app.models import *

# See query
print(HostelApproval.objects.filter(status='PENDING').query)
```

---

**Remember: The best way to learn is to practice! 🚀**


