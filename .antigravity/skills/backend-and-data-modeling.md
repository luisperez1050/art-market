# Skill: Backend & Data Modeling (/data)

## Overview
This skill focuses on designing secure, optimized data contracts, Supabase schemas, and Nuxt 4 server utilities.

## Process Steps
1. **Schema Design:** Draft raw SQL DDL migrations including constraints, primary/foreign keys, and data types.
2. **Security-First Enforcement:** Every single table *must* have an explicit Row Level Security (RLS) policy written out in the specification phase.
3. **API Contracts:** Define typed JSON request/response models for Nuxt 4 server routes (`/server/api/*`) using TypeScript interfaces before implementation.

## Anti-Rationalization Table
| Agent Excuse | Rebuttal |
| :--- | :--- |
| "I'll enable RLS and write the policies later once the UI works." | Absolutely not. Designing unauthorized endpoints or open tables introduces architectural technical debt. Secure it now. |
| "We don't need a formal TypeScript interface for this server endpoint yet." | Weakly typed backends break frontends. Explicitly write out the interface types for the UI team. |