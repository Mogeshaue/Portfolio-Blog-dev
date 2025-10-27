---
title: "CruXcipher Writeup"
summary: "A detailed writeup on solving the CruXcipher challenge."
date: "Apr 29 2025"
draft: false
tags:
  - Misc
---




![Pasted-image-20241110194126.png](/Pasted-image-20241110194126.png)

We began with the repository [https://github.com/crux-bphc/ctf-git-lost](https://github.com/crux-bphc/ctf-git-lost), where the main branch didn’t reveal much initially. However, the commit message’s hint, “Empty start, but secrets lie beneath,” pushed us to dig deeper.

## Clues in the Activity View

![Pasted-image-20241110194321.png](/Pasted-image-20241110194321.png)

Examining the repository’s activity, we noticed the creation and deletion of a branch named `lost-and-found`. This looked suspicious, so we explored the commit changes and found an encrypted text.

## Changes in the Commit Message

![Pasted-image-20241110194510.png](/Pasted-image-20241110194510.png)

Deciphering this encrypted content seemed essential for unlocking the hidden secrets in the repository.

## Discovering the Dangling Repo

![Pasted-image-20241110194614.png](/Pasted-image-20241110194614.png)

Changing the commit view to a tree structure led us to several dangling files, providing potential sources for the key elements of the challenge.

### Decoding the Secrets in Each File

Here’s the process I followed for each file in the repository:

1. **`.env`:** Using `ROT13`, I decrypted `vcc3q_zl_` to reveal `ipp3d_my_`.
    
2. **`archive.tmp`:** Recognizing it as an XOR cipher and using “the answer to life, the universe, and everything” (hint: **42**) as the key, I decrypted `BCY^\x1aXSuFEFW` to `hist0ry_lol`.
    
3. **`note1.txt`:** The base64-encoded text `Y3J1WGlwaGVye3kwdV8K` decoded to `cruXipher{y0u_`.
    
4. **`temp_config.txt`:** I realized the file contained binary representations (spaces as `0` and tabs as `1`). Using a Python script, I decoded it to `ju5t_unz`.
    
```python
def decode_whitespace_from_file(filename):
    # Define the binary translation for spaces and tabs
    binary_translation = {' ': '0', '\t': '1'}
    
    # Read the file content
    with open(filename, 'r') as file:
        lines = file.readlines()
    
    # Convert each line to binary, then concatenate all binary strings
    binary_string = ''.join(
        ''.join(binary_translation[char] for char in line if char in binary_translation)
        for line in lines
    )
    
    # Convert binary to ASCII text (each 8 bits -> 1 character)
    text = ''.join(chr(int(binary_string[i:i+8], 2)) for i in range(0, len(binary_string), 8))
    
    return text

# Usage example
filename = 'temp_config.txt'
decoded_text = decode_whitespace_from_file(filename)
print("Decoded Text:", decoded_text)
```
    
5. **`logfile.tmp`:** The final piece was AES-encrypted text `U2FsdGVkX1+NHOZKkOJXRLcJxUjzvblDEgXOijcs8Jk=`, which required a key I couldn’t initially determine.
    

## Discovering New Updates in the Repo

![Pasted-image-20241110200554.png](/Pasted-image-20241110200554.png)

Using `git ls-remote --refs origin`, I found the newly hidden `repo sauce`. Browsing the tree structure didn’t yield results, leading me to try accessing the blob directly.

## Accessing the Blob Object

![Pasted-image-20241110200835.png](/Pasted-image-20241110200835.png)

Opening the blob object gave me the final key needed for decryption!

## Using the Key to Decrypt the AES Cipher

![Pasted-image-20241110201026.png](/Pasted-image-20241110201026.png)

With this decryption key, I unlocked `logfile.tmp`, revealing the challenge’s final flag:

![Pasted-image-20241110201055.png](/Pasted-image-20241110201055.png)

---

### The Final Flag

`cruXipher{y0u_ju5t_unzipp3d_my_wh0le_git_hist0ry_lol}` 🎉

---

### Join NOVA! 🌌

As a proud member of team NOVA (Rank 16), I invite anyone interested to join our journey. If you’re up for the challenge, just DM `5pideyy`. Thanks for reading and happy hacking!