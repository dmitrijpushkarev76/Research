# Linearity Does Not Immunise

A short note on why the Schrödinger equation's linearity does **not** free
quantum mechanics from the determinism pathologies of classical mechanics, and
three corrections about ordinary differential equations.

**Read it:** `paper/note-linearity.html`

## Status: this repository contains a retraction

An earlier paper here, *Determinism Is an Indexed Predicate*, argued that a
determinism verdict is a function of a law plus three independent,
non-eliminable coordinates (σ individuation, δ temporal domain, μ
admissibility). **Its central claims are withdrawn.** A referee refuted two of
the three with counter-theorems stated against the paper's own definitions, and
they compile:

| Withdrawn | Refutation |
|---|---|
| "No definition of determinism that suppresses σ, δ or μ is well-formed" | `DetIn L C ↔ DetIn (restrict L C) triv`, **axiom-free**. δ and μ fold into the law; `push L r` was always just another law. One slot, not four. |
| The independence theorem | Its δ conjunct is about `ExactlyOne`, its σ/μ conjuncts about `DetIn`. On the paper's own δ witness the determinism verdict does not move. *(Repairable — see `delta_really_does_flip_determinism`.)* |
| "Everettian branching is a σ-shift" | The pushforward of a singleton law is a singleton law, so the model is deterministic at every σ setting; and the branch law is not a pushforward along any redescription. |

Both Lean files are kept under `retracted/` as the record. They compile; the
second refutes the first.

## Contents

| Path | What it is |
|---|---|
| `paper/note-linearity.html` | The note, with the retraction in full (§6) |
| `verification/note_checks.py` | 14 symbolic checks, all passing; audits its own source |
| `retracted/Indexed.lean` | The withdrawn paper's development (39 theorems) |
| `retracted/Referee.lean` | The counter-development that refutes it (7 theorems) |

## Reproducing

```bash
python3 verification/note_checks.py    # 14/14, plus an AST audit of itself
lean retracted/Indexed.lean            # the withdrawn development
lean retracted/Referee.lean            # the refutation
```

`note_checks.py` walks its own AST and fails the run if any check's predicate is
a literal constant. That guard exists because the previous verification file
shipped a check whose predicate was the literal `True`, and a "tent map" check
that only ever differentiated `2*x` — the identical check passes for `x ↦ 2x+7`,
which is not chaotic.

## What the note claims

Nothing novel. The central point is Earman's (*Synthese* 169, 2008; *Philosophy
of Science* 75, 2008): Stone's theorem needs self-adjointness, not symmetry, so
a Hamiltonian that is symmetric but not essentially self-adjoint generates a
family of unitary groups rather than one. The note adds a symbolic computation
of the classical side — for V = −xⁿ at zero energy the escape time to infinity
is finite exactly when n > 2, sharp at the harmonic case — and corrects the
withdrawn paper's claim that the classical and quantum failures are "the same
failure". They sit at the same threshold but are different failures: existence
classically, uniqueness quantum-mechanically.
