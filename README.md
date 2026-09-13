# Research

An expository note and a critical survey on determinism, plus the retracted development that preceded them.

| Path | What it is |
|---|---|
| `paper/one-state-many-futures.html` | **One State, Many Maximal Futures** — an expository note |
| `paper/ways-determinism-fails.html` | **The Ways Determinism Fails** — a critical survey, including the retraction |
| `verification/gap_checks.py` | 49 symbolic/numerical checks for the first note |
| `verification/note_checks.py` | 14 symbolic checks for the second |
| `retracted/Indexed.lean` | The withdrawn paper's development (39 theorems) |
| `retracted/Referee.lean` | The counter-development that refutes it (7 theorems) |

## One State, Many Maximal Futures

An expository note. For `x' = f(x)`, `x(0) = 0` with `f` continuous, `f(0) = 0` and
`f > 0` off the origin, take

```
f(x) = |x|^(2/3) + x²
```

Substituting `x = u³` turns `dx/f(x)` into `3 du/(1+u⁴)`, so both endpoint integrals
converge and `T* = ∫₀^∞ dx/f(x) = 3√2·π/4 ≈ 3.3321622036` exactly.

The consequence: the origin has **exactly one** solution defined for all `t ≥ 0`
(namely `x ≡ 0`), and **continuum-many** solutions that cannot be extended forward —
one for each waiting time `T ≥ 0`, resting at the origin until `T` and reaching `+∞`
at `T + T*`. Convergence near the origin populates the second set; convergence at
infinity empties the first of everything but the zero solution. Both are needed.

**The mathematics is classical and the note says so throughout.** The solution set of
this equation was characterised by Wallach (1948) and treated in general by Binding
(1979) — his Lemma 7.5 is the structure theorem, his §6 case (6.5) is exactly the
hypothesis here. The conceptual distinction is likewise familiar: Earman (2007 §6.4)
and Smeenk & Wüthrich (2020) for general relativity, Wilson (2009) for Newtonian
blow-up, Azhar & Namjoo (2021) for termination as a failure of determination.

What the note contributes is a minimal worked example: scalar, autonomous,
elementary integrals, exact blow-up time, explicit solution family, no idealisation
to argue about. Section 6 attributes every classical ingredient to a page.

## The Ways Determinism Fails

A critical survey of determinism across classical mechanics, quantum theory and
general relativity, organised around four structurally different failure modes
that are routinely conflated:

| | Mode | What goes wrong |
|---|---|---|
| **F1** | Non-uniqueness | Two possible histories through one state. Norton's dome, GRW, space invaders, Cauchy horizons. |
| **F2** | Non-existence | No possible history past some time. Blow-up, geodesic incompleteness. Falsifies "exactly one future" while producing *no* alternative future. |
| **F3** | Directional asymmetry | Unique one way in time, not the other. `x' = -x^(1/3)`. |
| **F4** | Model underdetermination | The formalism does not fix which object the theory is about. Which models count, which self-adjoint extension, which individuation. Not a fact about the world. |

The sustained correction: the linearity of the Schrödinger equation does **not**
immunise quantum mechanics against the classical pathologies. Stone's theorem
needs self-adjointness, not symmetry. And the classical failure (F2) and the
quantum failure at the same threshold (F4) are *different failures* — the word
doing illicit work is "domain".

### What the survey claims

Nothing novel — and it says so. The central point is Earman's (*Synthese* 169, 2008; *Philosophy
of Science* 75, 2008): Stone's theorem needs self-adjointness, not symmetry, so
a Hamiltonian that is symmetric but not essentially self-adjoint generates a
family of unitary groups rather than one. The note adds a symbolic computation
of the classical side — for V = −xⁿ at zero energy the escape time to infinity
is finite exactly when n > 2, sharp at the harmonic case — and corrects the
withdrawn paper's claim that the classical and quantum failures are "the same
failure". They sit at the same threshold but are different failures: existence
classically, uniqueness quantum-mechanically.

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

## Reproducing

```bash
python3 verification/gap_checks.py     # 49/49, plus an AST audit of itself
python3 verification/note_checks.py    # 14/14, same guard
lean retracted/Indexed.lean            # the withdrawn development
lean retracted/Referee.lean            # the refutation
```

Both check files walk their own AST and fail the run if any check's predicate is
a literal constant. That guard exists because the previous verification file
shipped a check whose predicate was the literal `True`, and a "tent map" check
that only ever differentiated `2*x` — the identical check passes for `x ↦ 2x+7`,
which is not chaotic.
