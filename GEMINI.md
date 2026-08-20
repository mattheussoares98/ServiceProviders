# ServicePro

Flutter CMMS, package `o_jogo_da_obra`. Clean Architecture + Cubit.
Supabase (auth, Postgres, RLS, Edge Functions) · Drift (local SQLite) · Cloudflare R2 (files).

**Read `.agents/rules/orchestrator.md` first — it holds the global constraints and routes you to the specialist rule file for the task at hand. Read the matching rule file before writing code, not after.**

Rules are tool-neutral and live only in `.agents/rules/`. Never add a rule to this file.
