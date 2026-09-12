# Determinism Is an Indexed Predicate

A determinism verdict is not a function of a law. It is a function of a law and
three further coordinates, each independently able to flip the answer:

- **σ** — individuation: which redescription of the state space carries the physics
- **δ** — temporal domain: must a history be total in time, or merely maximal
- **μ** — admissibility: which models count as models of the theory

A fourth coordinate, the agreement relation, is already well mapped in the
literature and is held fixed throughout.

## Contents

| Path | What it is |
|---|---|
| `paper/indexed-determinism.html` | The paper |
| `lean/Indexed.lean` | 39 theorems, Lean 4.24.0 core, no Mathlib, no `sorry` |
| `verification/classical_checks.py` | 17 symbolic checks (SymPy) |

## Reproducing

```bash
lean lean/Indexed.lean            # prints the axiom audit and nothing else
python3 verification/classical_checks.py   # pass/fail table; non-zero exit on failure
```

Audit as printed: **39 theorems, all 39 audited — 28 depend on no axioms
whatever, 11 on `propext` and/or `Quot.sound`, none on `Classical.choice`.**
Symbolic checks: **17/17 passing.**

## Main results

- **Independence** (Thms 3–6): each coordinate can reverse a verdict with the
  other two held fixed, so none is eliminable.
- **σ is non-monotone in both directions** (Thms 4–5): coarsening the state
  space can manufacture determinism *and* can destroy it, with non-degenerate
  witnesses. The second direction is the one matching Ornstein–Weiss, and the
  one usually stated backwards.
- **Everettian level-relativity is a σ-shift** (Thm 9): the branch projection
  is a pushforward, so the branching puzzle and the hole argument are the same
  coordinate.
- **The coordinates interact** (Thm 7): on one law both δ settings return
  "deterministic" while disagreeing about whether anything is possible at all.

## Supersedes

An earlier survey, *One History or Many?* (10–11 September 2026). Section 14 of
the paper lists ten corrections to it, including two false claims (the linearity
of the Schrödinger equation does **not** avoid the classical pathologies; local
uniqueness **does** propagate to global uniqueness in continuous time) and a
transposed pair of figures in its own axiom audit.
