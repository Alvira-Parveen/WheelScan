# AGENTS.md — WheelScan

This file tells Codex (and any agent working in this repo) how this project is structured, what rules to follow, and what "good" looks like — so every change stays consistent without needing a giant master file.

## What this project is

WheelScan is a Flutter app that scores the physical accessibility of a space from a photo (Ramp, Doorway, Elevator, Parking, Staircase, and 7+ custom categories), then generates an AI Action Plan — a prioritized, standards-based set of recommendations explaining what's wrong and how to fix it.

## Core rule: don't touch the scorer

`lib/services/scoring_service.dart` is the original rule-based scoring engine. **Do not modify its scoring logic.** Any new agent/recommendation feature must read the scorer's output and build on top of it, never change how scores are calculated. This separation is intentional and stated publicly in our hackathon submission — keep it true.

## Coding conventions

- Follow existing Flutter/Dart patterns already used in the repo: `StatefulWidget`/`StatelessWidget`, `setState`, `CustomPainter` for canvas drawing, `AnimationController` with `CurvedAnimation` for motion.
- Match the existing dark theme — primary color `#00D261` (green), defined in `lib/config/theme.dart`. Reuse existing theme tokens rather than hardcoding new colors.
- New agent logic belongs in `lib/services/recommendation_agent.dart`. New UI for agent output belongs in `result_screen.dart`, added below the existing score breakdown — never replacing it.
- Keep model changes additive: extend `AuditResult`/`AuditIssue` in `audit_model.dart` rather than restructuring them, so existing scoring code keeps working unchanged.

## Review rubric (read by /review and @codex review)

When reviewing any change to the recommendation agent, flag:
- Any recommendation missing one of: **Why it matters**, **Recommended fix**, **Standard reference**, **Priority rank**
- Any recommendation that restates the score instead of giving specific, actionable advice (vague output = fail)
- Any missing **confidence flag** (`High confidence` vs `Verify on-site`) — the agent must never overstate certainty it doesn't have
- Any missing **agent self-check line** (e.g. "Draft generated from CRITICAL criterion and checked for actionability") — this line is required, it's the visible proof of the agent's self-review step
- Any change that touches `scoring_service.dart`'s scoring math — this should never happen without an explicit, separate task

## Verification standard

Before accepting any generated fix as final:
- Confirm it references a real, sensible accessibility standard (not an invented one)
- Confirm the "How to verify" step describes an actual physical check, not just "confirm it's fixed"
- Re-run the app on at least one real scanned example after any change, don't just trust the diff

## Submission context

This repo is being submitted to the ChatGPT Codex Hackathon 2026 (Theme 8: AI for Societal Good), deadline 3 August 2026. Priority from here forward is **stability over new features** — fix bugs and polish existing behavior rather than adding new capabilities.

---