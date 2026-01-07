---
title: Prompts
date: "2026-01-07"
draft: true
tags: []
---

# Universal Topic Exploration Prompt Template

Use this prompt structure to deeply explore ANY technical topic:

---

## The Prompt:

```
I want to learn about [TOPIC]. Before diving in, help me understand:

1. PREREQUISITES - What foundational knowledge do I need first?
   - What concepts should I already understand?
   - What terms/jargon will come up?
   - What related topics connect to this?

2. THE BIG PICTURE - Why does this exist?
   - What problem does it solve?
   - What would happen without it?
   - Where does it fit in the larger ecosystem?

3. CORE CONCEPTS - Break down the main ideas
   - Explain like I'm a [YOUR LEVEL: beginner/intermediate/expert]
   - Focus on WHY things work this way, not just WHAT they are
   - Use real-world analogies and examples

4. COMMON MISCONCEPTIONS - What do people get wrong?
   - What did YOU initially misunderstand about this?
   - What are the "gotchas" or tricky parts?
   - What's the difference between similar concepts?

5. PRACTICAL PERSPECTIVE - How is this used in real scenarios?
   - Show actual code/configuration examples
   - What are common use cases?
   - What are anti-patterns to avoid?

6. SECURITY/CRITICAL IMPLICATIONS (if applicable)
   - What vulnerabilities or risks exist?
   - What are best practices?
   - What mistakes do people make that cause problems?

7. DEEPER DIVE - What's next after understanding basics?
   - What advanced topics build on this?
   - What should I explore next?
   - What resources/documentation should I check?

8. HANDS-ON EXPLORATION - How can I test this myself?
   - What can I try right now to see it in action?
   - What experiments help solidify understanding?
   - What tools help visualize or debug this?

Format your response so I can:
- Start learning even if I'm missing prerequisites (tell me what to learn first)
- Understand WHY before diving into HOW
- Avoid common beginner mistakes
- Know what questions to ask as I go deeper
```

---

## Example Usage:

### For Cybersecurity Topics:
```
I want to learn about JWT (JSON Web Tokens). Before diving in, help me understand:
[Follow the 8 points above]
```

### For Programming Concepts:
```
I want to learn about async/await in JavaScript. Before diving in, help me understand:
[Follow the 8 points above]
```

### For Infrastructure:
```
I want to learn about Kubernetes. Before diving in, help me understand:
[Follow the 8 points above]
```

---

## Pro Tips:

**Add context to get better responses:**
- "I understand HTTP basics but not authentication" 
- "I'm a cybersecurity learner focusing on web application security"
- "I know Python but new to JavaScript"

**Ask follow-up questions like:**
- "What's the difference between X and Y?"
- "Why would someone choose A over B?"
- "What happens in the background when..."
- "Show me what this looks like in actual code/configuration"

**For interconnected topics:**
```
I want to understand how [TOPIC A], [TOPIC B], and [TOPIC C] work together.
Map out their relationships and explain the flow between them.
```

---

## Quick Prompts for Specific Needs:

### Just Prerequisites:
```
What do I need to know before learning [TOPIC]? 
Create a learning path from basics to advanced.
```

### Just Misconceptions:
```
What are the most common misconceptions about [TOPIC]?
What do beginners usually get wrong?
```

### Just Security Angle:
```
Explain [TOPIC] from a cybersecurity perspective.
What vulnerabilities and security implications should I know?
```

### Just Practical Examples:
```
Show me real-world examples of [TOPIC] with actual code/configs.
Include both correct usage and common mistakes.
```

### Compare Related Topics:
```
Explain the differences between [TOPIC A] vs [TOPIC B] vs [TOPIC C].
When would I use each one? Create a comparison table.
```

---

## Advanced: Create Your Learning Roadmap

```
I want to master [BROAD FIELD, e.g., "Web Application Security"].

Create a complete learning roadmap that:
1. Lists all major topics I need to learn
2. Orders them by prerequisites (what to learn first)
3. Shows how topics interconnect
4. Estimates difficulty level for each
5. Suggests hands-on projects to practice
6. Points to key resources for each topic

My current level: [beginner/intermediate/advanced]
My goal: [e.g., "become a penetration tester", "build secure APIs"]
Time available: [e.g., "2 hours daily for 3 months"]
```

---

## Remember:

The key to deep learning is asking:
- **WHY** does this exist?
- **WHAT** problem does it solve?
- **HOW** does it actually work underneath?
- **WHEN** should/shouldn't I use this?
- **WHERE** does this fit in the bigger picture?

Don't just memorize WHAT things are. Understand the reasoning behind them!
