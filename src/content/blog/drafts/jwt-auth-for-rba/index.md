---
title: Jwt auth for  RBA
date: "2025-12-13"
draft: true
summary: This is an learning project for the Role based authentication
tags: ["node.js", "Express Rba"]
---

# Role-Based Task Management System - Interview Q&A Guide

---

## 📚 **TABLE OF CONTENTS**
1. [Project Overview Questions](#project-overview)
2. [Backend Architecture Questions](#backend-architecture)
3. [Authentication & Security Questions](#authentication-security)
4. [Database Questions](#database)
5. [Frontend Questions](#frontend)
6. [API Questions](#api)
7. [Testing & Debugging Questions](#testing-debugging)
8. [Advanced Concepts](#advanced-concepts)

---

## 🎯 PROJECT OVERVIEW

### Q1: What is this project about?
**Answer:**
This is a **Role-Based Access Control (RBAC) Task Management System** built with Node.js, Express, and SQLite. The system allows:
- Users to register and login
- Admin users to view ALL tasks in the system
- Regular users to view ONLY their own tasks
- JWT-based authentication for secure API access

**Key Features:**
- User registration with password hashing
- Login with JWT token generation
- Role-based dashboards (Admin vs User)
- Pre-populated database with admin and sample users
- RESTful API design

---

### Q2: Why did you use this tech stack?
**Answer:**

**Backend:**
- **Node.js + Express**: Lightweight, fast, and perfect for RESTful APIs
- **Sequelize ORM**: Easy database management with JavaScript instead of raw SQL
- **SQLite**: Simple, file-based database - no complex setup needed
- **bcrypt**: Industry-standard for password hashing
- **JWT (jsonwebtoken)**: Stateless authentication, scalable

**Frontend:**
- **Vanilla JavaScript**: No framework overhead, faster load times
- **CSS3**: Modern styling with gradients and animations
- **HTML5**: Semantic markup

**Why this is good:**
✅ Easy to set up and deploy
✅ Good for small to medium applications
✅ Demonstrates understanding of full-stack development
✅ Production-ready security practices

---

## 🏗️ BACKEND ARCHITECTURE

### Q3: Explain the folder structure of your backend
**Answer:**

```
Rba/
├── config/
│   └── database.js          # Sequelize database configuration
├── controllers/
│   ├── userController.js    # User registration & login logic
│   └── taskController.js    # Task CRUD operations
├── models/
│   ├── user.js             # User database schema
│   └── task.js             # Task database schema
├── routes/
│   ├── users.js            # User API routes
│   └── task.js             # Task API routes
├── middleware/
│   └── auth.js             # JWT authentication middleware
├── frontend/               # Client-side code
├── utils.js               # Helper functions (password hashing)
├── server.js              # Main entry point
└── sampledata.js          # Database seeding script
```

**Why this structure?**
- **Separation of Concerns**: Each folder has a specific purpose
- **MVC Pattern**: Models, Views (frontend), Controllers
- **Scalability**: Easy to add new features
- **Maintainability**: Easy to find and fix bugs

---

### Q4: How does the MVC pattern work in your project?
**Answer:**

**Model (M):**
- `models/user.js` and `models/task.js` define database structure
- Uses Sequelize ORM to interact with SQLite database
- Example: `User.create()`, `Task.findAll()`

**View (V):**
- `frontend/index.html` - Structure
- `frontend/style.css` - Styling
- Dynamic content rendered via JavaScript

**Controller (C):**
- `controllers/userController.js` - Handles business logic
- `controllers/taskController.js` - Processes requests
- Example: `register()`, `login()`, `getTasks()`

**Request Flow:**
```
Client Request → Route → Controller → Model → Database
                                      ↓
Client Response ← Controller ← Model ← Database
```

---

## 🔐 AUTHENTICATION & SECURITY

### Q5: How does authentication work in your system?
**Answer:**

**Registration Flow:**
1. User submits username, email, password
2. Backend validates input (email format, password length ≥6)
3. Check if email already exists (prevent duplicates)
4. Hash password using bcrypt with 10 salt rounds
5. Store user in database with hashed password
6. Return success response

**Login Flow:**
1. User submits email and password
2. Backend finds user by email
3. Compare submitted password with stored hash using `bcrypt.compare()`
4. If valid, generate JWT token with payload: `{id, role}`
5. Return token + user data to client
6. Client stores token in localStorage

**Token Usage:**
- Every protected API request includes: `Authorization: Bearer <token>`
- Backend middleware verifies token
- Extracts user info and attaches to `req.user`

---

### Q6: What is JWT and why did you use it?
**Answer:**

**JWT (JSON Web Token)** is a compact, self-contained token for securely transmitting information between parties.

**Structure:**
```
Header.Payload.Signature
```

**Your Token Payload:**
```javascript
{
  id: 5,           // User ID
  role: 'admin',   // User role
  iat: 1702345678, // Issued at timestamp
  exp: 1702395678  // Expiration timestamp
}
```

**Why JWT?**
✅ **Stateless**: Server doesn't store session data
✅ **Scalable**: Works across multiple servers
✅ **Secure**: Signed with secret key (can't be tampered)
✅ **Compact**: Sent in HTTP headers easily
✅ **Self-contained**: All user info in token

**Security in Your Implementation:**
- Secret key: `"mogeshm"` (should be in .env in production)
- Expiry: 50000 seconds (~13.8 hours)
- Verification on every protected route

---

### Q7: How is password security handled?
**Answer:**

**Password Hashing with bcrypt:**

```javascript
// Registration
const hashedPassword = await bcrypt.hash(password, 10);
// Output: $2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
```

**How it works:**
1. **Salt Generation**: Random 10-round salt
2. **Hashing**: Password + salt → one-way hash
3. **Storage**: Only hash stored, never plain password

**Login Verification:**
```javascript
const isValid = await bcrypt.compare(plainPassword, hashedPassword);
// Returns true/false
```

**Why bcrypt?**
✅ **One-way**: Can't reverse hash to get password
✅ **Slow by design**: Prevents brute-force attacks
✅ **Salt**: Each password has unique hash (prevents rainbow tables)
✅ **Adaptive**: Can increase rounds as computers get faster

**Security Best Practices:**
- Minimum 6 characters enforced
- Email validation with regex
- Duplicate email check
- Never log passwords

---

### Q8: Explain the authentication middleware
**Answer:**

**Code:**
```javascript
function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Extract after "Bearer "
    
    if (!token) {
        return res.status(401).json({message: 'No token provided'});
    }
    
    jwt.verify(token, SECRET, (err, decoded) => {
        if (err) {
            return res.status(403).json({message: 'Invalid token'});
        }
        req.user = {
            userId: decoded.id,
            userRole: decoded.role
        };
        next(); // Continue to route handler
    });
}
```

**How it works:**
1. Extracts token from `Authorization: Bearer <token>` header
2. Splits string to remove "Bearer " prefix
3. Verifies token signature with SECRET key
4. If valid, decodes payload and attaches to `req.user`
5. Calls `next()` to proceed to route handler
6. If invalid/missing, returns 401/403 error

**Usage:**
```javascript
router.get('/tasks', authenticateToken, getTasks);
//                    ↑ Middleware runs first
```

---

## 💾 DATABASE

### Q9: Explain your database schema
**Answer:**

**Users Table:**
```javascript
{
  id: INTEGER (Primary Key, Auto-increment),
  username: STRING (Required),
  email: STRING (Unique, Required, Email validation),
  password: STRING (Required, Hashed),
  role: STRING (Default: 'user', Enum: ['user', 'admin']),
  createdAt: DATETIME (Auto-generated),
  updatedAt: DATETIME (Auto-updated)
}
```

**Tasks Table:**
```javascript
{
  id: INTEGER (Primary Key, Auto-increment),
  userId: INTEGER (Foreign Key → Users.id, Required),
  title: STRING (Required),
  description: TEXT (Optional),
  createdAt: DATETIME (Auto-generated),
  updatedAt: DATETIME (Auto-updated)
}
```

**Relationship:**
- **One-to-Many**: One User can have many Tasks
- **Foreign Key**: `Task.userId` references `User.id`
- **Cascade Delete**: If user deleted, their tasks also deleted

**Why this design?**
✅ Normalized database (no redundancy)
✅ Enforced referential integrity
✅ Scalable (can add more fields easily)

---

### Q10: How does Sequelize ORM help you?
**Answer:**

**Sequelize** is a promise-based ORM (Object-Relational Mapping) that lets you work with databases using JavaScript objects instead of SQL.

**Without ORM (Raw SQL):**
```sql
SELECT * FROM Tasks WHERE userId = 5;
```

**With Sequelize:**
```javascript
Task.findAll({ where: { userId: 5 } });
```

**Benefits:**
✅ **Type Safety**: JavaScript objects instead of SQL strings
✅ **Security**: Prevents SQL injection automatically
✅ **Relationships**: Easy to define and query
✅ **Migrations**: Easy schema changes
✅ **Database Agnostic**: Switch from SQLite to PostgreSQL easily

**Your Usage:**
```javascript
// Create
await User.create({ username, email, password, role });

// Read
await User.findOne({ where: { email } });

// Update
await user.update({ username: 'New Name' });

// Delete
await user.destroy();
```

---

### Q11: How did you seed the database?
**Answer:**

**Seeding Script (`sampledata.js`):**

```javascript
async function seedDatabase() {
    // 1. Drop and recreate tables
    await sequelize.sync({ force: true });
    
    // 2. Create admin
    const admin = await User.create({
        username: 'Admin',
        email: 'admin@hyperverge.co',
        password: hashedPassword,
        role: 'admin'
    });
    
    // 3. Create regular users
    const user1 = await User.create({...});
    const user2 = await User.create({...});
    
    // 4. Create tasks for each user
    await Task.create({ userId: admin.id, title: '...', description: '...' });
    // ... 8 total tasks
}
```

**What gets created:**
- 1 Admin user: `admin@hyperverge.co` / `admin123`
- 2 Regular users: `john@example.com` / `user123`, `jane@example.com` / `user123`
- 8 Tasks: 2 for admin, 3 for user1, 3 for user2

**Run command:**
```bash
node sampledata.js
```

**Why seed data?**
✅ Test role-based access immediately
✅ Demonstrate functionality without manual entry
✅ Meets requirement: "Pre-registered admin"

---

## 🎨 FRONTEND

### Q12: How does the frontend communicate with backend?
**Answer:**

**Fetch API:**
```javascript
// Login Example
const response = await fetch('http://localhost:3000/user/login', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({ email, password })
});
const data = await response.json();
```

**Protected Routes:**
```javascript
// Get Tasks (with authentication)
const token = JSON.parse(localStorage.getItem('accessToken'));
const response = await fetch('http://localhost:3000/task', {
    method: 'GET',
    headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}` // JWT token here
    }
});
```

**Flow:**
1. User fills form
2. JavaScript captures form data
3. Sends HTTP request to backend
4. Backend processes and responds
5. Frontend updates UI based on response

---

### Q13: How is user state managed in the frontend?
**Answer:**

**localStorage Usage:**

```javascript
// After successful login
localStorage.setItem('user', JSON.stringify({
    id: 5,
    username: 'John Doe',
    email: 'john@example.com',
    role: 'user',
    accessToken: 'eyJhbGc...'
}));

localStorage.setItem('accessToken', JSON.stringify('eyJhbGc...'));

// Retrieving
const user = JSON.parse(localStorage.getItem('user'));
const token = JSON.parse(localStorage.getItem('accessToken'));

// On logout
localStorage.removeItem('user');
localStorage.removeItem('accessToken');
```

**Persistence:**
- Survives page refresh
- Stays until manually cleared or logout
- Accessible across tabs (same domain)

**On Page Load:**
```javascript
if (localStorage.getItem('accessToken')) {
    // User logged in
    showDashboard();
    getTasks();
} else {
    // User not logged in
    showLoginForm();
}
```

---

## 🚀 API

### Q14: List all your API endpoints
**Answer:**

**User Routes:**
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/user/register` | ❌ No | Register new user |
| POST | `/user/login` | ❌ No | Login user |

**Task Routes:**
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/task/` | ✅ Yes | Get tasks (role-based) |
| POST | `/task/createTask` | ❌ No* | Create new task |

*Note: Should have auth (security issue to fix)

---

### Q15: How does role-based access control work?
**Answer:**

**Controller Logic:**

```javascript
async function getTasks(req, res) {
    const { userId, userRole } = req.user; // From JWT token
    
    let tasks;
    
    if (userRole === 'admin') {
        // Admin sees ALL tasks
        tasks = await Task.findAll();
    } else if (userRole === 'user') {
        // User sees ONLY their tasks
        tasks = await Task.findAll({ where: { userId: userId } });
    }
    
    res.status(200).json(tasks);
}
```

**Flow:**
1. Client sends request with JWT token
2. Middleware verifies token → extracts `userId` and `userRole`
3. Controller checks role:
   - **Admin**: Query all tasks
   - **User**: Query tasks with `userId = current user`
4. Return filtered results

**Example:**
- Admin (userId=1) → Gets tasks [1,2,3,4,5,6,7,8]
- User (userId=2) → Gets tasks [3,6,7] (only theirs)

---

## 🧪 TESTING & DEBUGGING

### Q16: How would you test this system?
**Answer:**

**Manual Testing:**

1. **Registration Test:**
   - Valid data → Should create user
   - Duplicate email → Should return 409 error
   - Short password → Should return 400 error
   - Invalid email → Should return 400 error

2. **Login Test:**
   - Valid credentials → Should return token
   - Invalid password → Should return 401
   - Non-existent email → Should return 404

3. **Role-Based Access:**
   - Login as admin → Should see all 8 tasks
   - Login as user → Should see only 3 tasks

4. **Security Test:**
   - Access `/task` without token → Should get 401
   - Access with invalid token → Should get 403

**Automated Testing (could implement):**
```javascript
// Using Jest + Supertest
describe('POST /user/register', () => {
    it('should create a new user', async () => {
        const res = await request(app)
            .post('/user/register')
            .send({ username: 'Test', email: 'test@test.com', password: 'test123' });
        expect(res.status).toBe(201);
        expect(res.body.success).toBe(true);
    });
});
```

---

### Q17: What console.log statements did you add and why?
**Answer:**

**Strategic Logging:**

```javascript
// User Registration
console.log("Registering user:", req.body);
// → Helps debug what data is received

// Login
console.log("Login attempt for email:", email);
// → Track login attempts

// getTasks
console.log("getTasks called");
console.log("UserID:", userId, "UserRole:", userRole);
console.log("Tasks:", tasks);
// → Verify role-based logic working

// Auth Middleware
console.log("Token:", token);
console.log("Error:", err);
// → Debug token issues
```

**Why this helps:**
✅ Track request flow
✅ Identify where errors occur
✅ Verify data transformations
✅ Debug authentication issues

**Production:**
- Remove or use proper logging library (Winston, Pino)
- Don't log sensitive data (passwords, full tokens)

---

## 🎓 ADVANCED CONCEPTS

### Q18: What are the security vulnerabilities in your current code?
**Answer:**

**Identified Issues:**

1. **Hardcoded JWT Secret**
   - Current: `SECRET = "mogeshm"` in code
   - Should: Store in `.env` file
   - Risk: If code is public, secret is exposed

2. **No Rate Limiting**
   - Risk: Brute force attacks on login
   - Fix: Use `express-rate-limit` middleware

3. **createTask Not Protected**
   - Current: No authentication middleware
   - Risk: Anyone can create tasks
   - Fix: Add `authenticateToken` middleware

4. **CORS Wide Open**
   - Current: `app.use(cors())` allows all origins
   - Risk: CSRF attacks
   - Fix: Specify allowed origins

5. **No Input Sanitization**
   - Risk: XSS attacks through task descriptions
   - Fix: Use libraries like `validator`, `express-validator`

6. **Error Messages Too Detailed**
   - Example: "User with this email already exists"
   - Risk: Email enumeration attack
   - Fix: Generic messages like "Invalid credentials"

---

### Q19: How would you improve this project?
**Answer:**

**Backend Improvements:**
1. **Environment Variables**: Move secrets to `.env`
2. **Validation Layer**: Use `express-validator`
3. **Error Handling**: Centralized error middleware
4. **Logging**: Winston/Pino for production
5. **API Versioning**: `/api/v1/users`
6. **Pagination**: For tasks list
7. **Refresh Tokens**: Long-lived authentication

**Frontend Improvements:**
1. **Error Handling**: Try-catch on all fetches
2. **Loading States**: Spinners during API calls
3. **Task CRUD**: Add create, update, delete
4. **Role Indication**: Visual badge for admin
5. **Form Validation**: Better UX feedback
6. **Responsive Design**: Mobile optimization

**DevOps:**
1. **Dockerization**: Container deployment
2. **CI/CD**: GitHub Actions
3. **Testing**: Jest + Supertest
4. **Documentation**: Swagger/OpenAPI

---

### Q20: Explain the difference between authentication and authorization
**Answer:**

**Authentication (Who are you?)**
- Verifying identity
- Login process
- Example: Checking email + password
- Your code: `bcrypt.compare()`, JWT generation

**Authorization (What can you do?)**
- Verifying permissions
- Access control
- Example: Admin can see all tasks, user can't
- Your code: Role checking in `getTasks()`

**In Your System:**

```javascript
// AUTHENTICATION
const user = await User.findOne({ where: { email } });
const isValid = await bcrypt.compare(password, user.password);
const token = jwt.sign({ id: user.id, role: user.role }, SECRET);

// AUTHORIZATION
if (userRole === 'admin') {
    tasks = await Task.findAll(); // Allowed
} else {
    tasks = await Task.findAll({ where: { userId } }); // Restricted
}
```

**Analogy:**
- Authentication = Showing ID at building entrance
- Authorization = Which floors you can access with that ID

---

## 🎯 PROJECT SUMMARY

### Q21: Give a 2-minute project explanation
**Answer:**

"I built a **Role-Based Task Management System** using the **MERN-like stack** with Node.js, Express, and SQLite.

The system has **two types of users**: regular users and admins. When someone registers, their **password is hashed using bcrypt** with 10 salt rounds for security. Upon login, the system generates a **JWT token** that contains the user's ID and role.

The most interesting part is the **role-based access control**. When fetching tasks, the system checks the user's role from the JWT token. If they're an **admin, they see all tasks** in the system. If they're a **regular user, they only see their own tasks**. This is achieved through a Sequelize query that filters by userId.

I implemented **proper authentication middleware** that validates JWT tokens on protected routes. The frontend uses **localStorage to persist user sessions** across page refreshes.

For database setup, I created a **seeding script** that pre-populates an admin account (`admin@hyperverge.co`) and sample users with tasks, meeting the requirement for pre-registered admins.

The **security features** include email validation, password strength requirements, duplicate email checking, and hashed passwords. The API follows **RESTful principles** with proper HTTP status codes.

One improvement would be adding **authentication to the task creation endpoint** and moving the JWT secret to environment variables for production deployment."

---

## 📝 BONUS: Common Follow-up Questions

### Q22: How would you deploy this to production?
**Answer:**

**Steps:**
1. **Environment Setup**
   - Create `.env` file with secrets
   - Use PostgreSQL instead of SQLite
   
2. **Backend Deployment (Heroku/Railway)**
   ```bash
   git push heroku main
   ```

3. **Frontend Deployment (Netlify/Vercel)**
   - Update API URLs to production
   - Deploy static files

4. **Database Migration**
   - Run `sequelize.sync()` on production DB
   - Run seed script

5. **Security Hardening**
   - Enable HTTPS only
   - Set up CORS whitelist
   - Add rate limiting
   - Use Helmet.js

---

### Q23: What did you learn from this project?
**Answer:**

**Technical Skills:**
✅ JWT authentication implementation
✅ Password hashing with bcrypt
✅ Sequelize ORM and relationships
✅ Middleware pattern in Express
✅ Role-based access control

**Best Practices:**
✅ MVC architecture
✅ Separation of concerns
✅ RESTful API design
✅ Error handling
✅ Input validation

**Challenges Overcome:**
- Understanding JWT token flow
- Implementing role-based queries
- Frontend-backend token communication
- Database seeding strategy

---

## 🎉 END OF Q&A GUIDE

**Study Tips:**
1. Understand the **flow of data** from frontend → backend → database
2. Be able to **explain WHY** you made each architectural decision
3. Know the **security implications** of your code
4. Practice explaining code **line by line**
5. Prepare to discuss **improvements** and **scaling**

**Good luck with your preparation! 🚀**

