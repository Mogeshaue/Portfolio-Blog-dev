---
title: "How I Sweet-Talked a DNS Server into Giving Me the Flag (Nullcon Goa HackIM 2025 CTF)"
summary: "A thrilling tale of me vs. a DNS server, where a little NSEC-walking magic turned a stubborn server into a snitch."
date: "Feb 02 2025"
draft: false
tags:
  - Web 
  - Networking
---


When I saw the challenge name—**"ZONEy.eno"**—it immediately screamed **DNS** at me. And with UDP port `5007` open, I knew I was dealing with something interesting. Time to roll up my sleeves and start digging (pun absolutely intended).  

---

## **Checking What’s Running on Port 5007**  

First, I needed to figure out what was actually running on this port. So, I fired up **Nmap**:  

```bash
nmap -p 5007 52.59.124.14 -sCV
```

Boom! The scan confirmed that this was a **DNS server**, specifically running **NLnet Labs NSD**.  
Alright, time to throw some DNS queries at it and see what sticks.  

---

## **Asking the Obvious Question**  

A good starting point in any DNS challenge is to just ask for **everything** using an `ANY` query.  

```bash
dig @52.59.124.14 -p 5007 ANY zoney.eno
```

This gave me a **Start of Authority (SOA) record**, which told me the nameservers handling this domain:  

```
ns1.zoney.eno
ns2.zoney.eno
```

Nice to know, but not exactly what I was looking for. No flag in sight yet, so time to dig deeper.  

---

## **Throwing Random Guesses at the Server**  

A lot of times, CTF challenges hide flags in **subdomains**. So, I tried querying some common ones:  

```bash
for sub in flag hidden secret backup test admin; do
    dig @52.59.124.14 -p 5007 ANY $sub.zoney.eno
done
```

Every single one came back with **NXDOMAIN**, which is the DNS equivalent of getting ghosted.  
Either I was looking in the wrong places, or the server had something sneaky going on.  

---

## **Time to Bring in the NSEC Trick**  

Since normal queries weren’t getting me anywhere, I decided to check if the server had **DNSSEC** enabled:  

```bash
dig @52.59.124.14 -p 5007 ANY zoney.eno +dnssec
```

The response included **RRSIG** records, which meant **DNSSEC was in play**. But that wasn’t what I was really after.  

Instead, I turned to **NSEC queries**. These are meant to *prove* that certain domains don’t exist, but sometimes they accidentally **expose valid subdomains**.  

So, I asked:  

```bash
dig @52.59.124.14 -p 5007 NSEC zoney.eno
```

And jackpot! The response revealed a new subdomain:  

```
challenge.zoney.eno
```

Alright, that looked promising.  

---

## **Checking Out This “Challenge” Subdomain**  

Now that I had a lead, I queried the new subdomain:  

```bash
dig @52.59.124.14 -p 5007 ANY challenge.zoney.eno
```

It pointed to `127.0.0.1`.  
Wait, what?  

A **loopback address?** That’s a classic CTF move—redirecting traffic back to itself.  
This wasn’t the final destination, which meant I had to **NSEC-walk** further.  

```bash
dig @52.59.124.14 -p 5007 NSEC challenge.zoney.eno
```

And sure enough, it led me to another subdomain:  

```
hereisthe1337flag.zoney.eno
```

That had to be it.  

---

## **Going for the Final Query**  

I ran the last command to grab whatever was hiding in there:  

```bash
dig @52.59.124.14 -p 5007 ANY hereisthe1337flag.zoney.eno
```

And there it was. The **flag** was chilling in a **TXT record**:  

```bash
dig @52.59.124.14 -p 5007 TXT hereisthe1337flag.zoney.eno
```


```
ENO{1337_Fl4G_NSeC_W4LK3R}
```


---

## **Takeaways from This Challenge**  

This was a **classic case of NSEC-walking**, where a misconfigured DNSSEC setup accidentally leaks valid subdomains.  

Moral of the story? If a challenge involves **DNS**, don't just fire random queries and hope for the best. **Use NSEC queries to uncover hidden zones.**  

Alright, time to move on to the next challenge. Hopefully, it’s not another DNS one...

## Want to join a crew of like-minded problem solvers?

NOVA is the place to be! If you're looking to level up your skills, collaborate on cool projects, and have fun along the way, hit me up. Drop a DM to `5pidey` on Discord, and let’s make things happen! 🔥
