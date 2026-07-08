# Skill: Spec-Driven Development (/spec)

## Overview
This skill forces the agent to turn unstructured feature requests into a complete, bulletproof technical specification before modifying or generating application code.

## Process Steps
1. **Interview Phase:** Ask clarifying questions one at a time regarding dependencies, scope, and non-functional requirements until confidence is high.
2. **Drafting Phase:** Generate a Technical Specification containing:
   - Objectives & User Stories
   - Nuxt 4 Architecture Layout (Strictly observing the `app/` structure)
   - Tailwind styling guidelines
   - Future data contract structures (e.g. Supabase typing targets)
3. **Verification Phase:** The user must explicitly sign off on the specification before progressing to the planning or building phase.

## Anti-Rationalization Table
| Agent Excuse | Rebuttal |
| :--- | :--- |
| "This feature is simple, I can just write the file now." | No change is too trivial for architectural consistency. Draft the spec first. |
| "I'll outline the backend contract later when we install Supabase." | Leaving data contracts open-ended leads to massive UI rework later. Define the interfaces now. |