# PRD Quality Review — Mindow

## Overall verdict

The managed PRD dramatically improves downstream usability (structured FRs with testable consequences, glossary-anchored vocabulary, cross-linked UJs and metrics) but silently drops or mutes several load-bearing emotional and strategic design principles from the source brief. The emotional framing that differentiates this from productivity tools — the explicit rejection of guilt-based engagement, the "load relief as success" positioning, and the wellbeing-first tone — has been converted to mechanical requirements rather than preserved as strategic load-bearing constraints. This risks implementation teams optimizing for the wrong local maxima (e.g., maximizing Missions completed vs. maximizing relief experienced).

## Reconciliation gaps (source brief → managed PRD)

1. **Strategic differentiation framing** — Original positioned Mindow against productivity tools ("Mindow doit devenir un espace de décharge mentale"). Managed PRD had no equivalent anti-productivity positioning statement.
2. **"Before/After" value-prop narrative** — Original psychological framing (head → stress; app → understanding → action) abstracted into glossary terms.
3. **Tone/voice as load-bearing design** — Warm, non-guilt-inducing tutoiement downgraded from first-principles strategy to feature constraint.
4. **Gamification philosophy** — "Positive-only, never punishes inactivity" stance not encoded as a design principle.
5. **Counter-metrics framing** — Present but buried without executive/governance framing.
6. **Mental Backpack/Garden as metaphors** — Psychological symbols of burden and recovery mechanized into generic features.
7. **Crisis/duty-of-care framing** — Relegated to an assumption without highlighting as responsibility.
8. **Non-Goals clarity** — Percussive "Mindow is NOT…" clarity spread across multiple sections.

## Dimension findings

- **[critical]** Emotional/strategic positioning dropped — no "why we exist differently" section. *Fix:* add anti-productivity positioning to §1 Vision.
- **[critical]** Tone as mechanical requirement, not load-bearing constraint (§10). *Fix:* add a gating filter — every feature/copy decision must relieve load, not add pressure.
- **[critical]** Counter-metrics lack governance framing (§7). *Fix:* state that counter-metric violations pause primary-metric optimization.
- **[high]** Crisis-content handling vague, decision status unclear (§9.1, §13 Q3). *Fix:* clarify MVP-blocking status + owner.
- **[high]** Glossary defines Mental Weight as output ("kg") not semantic meaning (§3). *Fix:* add qualitative definition + examples.
- **[medium]** Couple Mode framed feature-first, fairness/visibility intent muted (§4.14). *Fix:* prepend visibility-and-fairness purpose note.
- **[medium]** Activation SM lacks qualitative outcome (§7 SM-2). *Fix:* add post-activation "feel lighter" guardrail.
- **[medium]** Non-Goals scattered across §2.2/§5/§6.2. *Fix:* optionally consolidate.
- **[medium]** UJs lack emotional choreography / tone-intent annotations (§2.3). *Fix:* add a Tone Intent line per UJ.
- **[low]** Assumptions Index lacks priority/blocking status (§14).
- **[low]** Some FR consequences lack a "why it matters" anchor.

## Mechanical notes

- **Glossary drift:** Clean. Minor — "Mental Item" alias rarely used; keep for API docs or drop.
- **FR/UJ/SM ID continuity:** Pass. FR-1…FR-24 contiguous, no gaps/dupes. UJ-1…UJ-4 referenced consistently. SM-1…SM-7 + SM-C1…SM-C3. SM→FR cross-refs present.
- **Cross-references:** Resolve correctly; no dead links.
- **Assumptions Index roundtrip:** All §14 entries traceable. Minor — §11 (navigation) and §12 (WCAG AA) mentioned in index but lacked inline `[ASSUMPTION]` tags in their source sections.
- **Prioritization:** Assumptions listed in section order, not prioritized by blocking status.
