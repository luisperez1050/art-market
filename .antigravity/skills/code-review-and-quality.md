# Skill: Code Review & Quality (/review)

## Overview
This skill implements strict engineering verification over all generated code to catch syntax, logic, security, and stylistic regressions.

## Process Steps
1. **Static Analysis Check:** Verify the code compiles with Nuxt 4 conventions (e.g., checking that file architecture sits inside `/app` or `/server`).
2. **Idempotency & Resilience Check:** Verify that asynchronous calls (Supabase fetches) handle pending, loading, and error states elegantly in the Vue template.
3. **Code Cleanliness:** Ensure utility styling (Tailwind) is clean, legible, and doesn't contain duplicate or conflicting responsive classes.

## Anti-Rationalization Table
| Agent Excuse | Rebuttal |
| :--- | :--- |
| "The code runs fine, we don't need to wrap this fetch in a try/catch or useAsyncData." | Unhandled errors crash modern web frontends. Every asynchronous operation requires an explicit error state handler. |
| "It works on my machine/simulation." | The ReviewAgent tests for network latency, mobile responsiveness, and invalid user input. Fix the edge cases. |