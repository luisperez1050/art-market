# Skill: Staff Architectural Governance (/staff)

## Overview
This skill implements high-level architectural oversight, cross-cutting technical trade-off evaluation, system maintainability tracking, and systemic de-risking for the Nuxt 4 + Supabase + Vercel ecosystem.

## Process Steps
1. **Architectural Review:** Evaluate all technical specifications for paradigm alignment (e.g., verifying strict encapsulation within Nuxt 4's `/app` and `/server` boundaries).
2. **Dependency Risk Mitigation:** Explicitly analyze third-party module footprints, caching paradigms, state encapsulation rules, and edge environment constraints.
3. **Data Boundary Verification:** Ensure future data access patterns do not leak raw, unvetted database structures directly to client-facing Vue components.

## Anti-Rationalization Table
| Agent Excuse | Rebuttal |
| :--- | :--- |
| "We can just drop all state management into a loose global variable for now." | Bad encapsulation is a vector for systemic fragility. Design state structures with crisp local scopes or dedicated composables. |
| "We don't need to document the edge-runtime limitations of this Vercel deployment yet." | Discovering runtime or serverless cold-start limitations at deployment time is an architectural failure. Plan for edge constraints immediately. |