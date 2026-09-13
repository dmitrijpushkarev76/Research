# Research

Two notes on determinism, plus the retracted development that preceded them.

| Path | What it is |
|---|---|
| `paper/global-maximal-gap.html` | **The Global–Maximal Gap** — a theorem and an explicit witness |
| `paper/ways-determinism-fails.html` | **The Ways Determinism Fails** — a critical survey, including the retraction |
| `verification/gap_checks.py` | 40 symbolic/numerical checks for the first note |
| `verification/note_checks.py` | 14 symbolic checks for the second |
| `retracted/Indexed.lean` | The withdrawn paper's development (39 theorems) |
| `retracted/Referee.lean` | The counter-development that refutes it (7 theorems) |

## The Global–Maximal Gap

For the scalar autonomous problem `x' = f(x)`, `x(0) = 0` with `f` continuous,
`f(0) = 0` and `f > 0` off the origin, the convergence of one integral

```
T* = ∫₀^∞ du/f(u) < ∞
```

is **necessary and sufficient** for a configuration in which all three of the
following hold at once:

- uniqueness fails at the origin — a solution may rest at `0` for any waiting
  time `T ≥ 0` and then depart;
- every departing branch is non-continuable with a bounded maximal interval,
  blowing up at `T + T*`;
- exactly one solution is defined for all forward time, namely `x ≡ 0`.

So `|ℋ_glob(0)| = 1` while `|ℋ_max(0)| = 𝔠`. Uniqueness among globally defined
histories and uniqueness among maximal histories are different properties of
the same law, and here they disagree.

The two hypotheses are the two ends of one integral: `∫₀¹ du/f < ∞` is what
lets a branch leave the equilibrium, `∫₁^∞ du/f < ∞` is what makes it blow up.
Both are convergence conditions, **not** statements about the growth ratio
`f(u)/u` — Proposition 8 gives counterexamples in both directions, so the
tempting "sublinear at 0, superlinear at ∞" formulation is false as stated and
the note does not use it.

**Witness.** `f(x) = |x|^(2/3) + x²`, with `T* = 3√2·π/4 ≈ 3.3321622036` in
closed form via the substitution `x = u³`.

Two further results, both proved in §11:

- **No surface of revolution supports it.** Arc-length parametrisation forces
  `|h'(r)| ≤ 1`, hence `|r̈| ≤ g`, hence at most quadratic growth. A Norton-style
  dome can produce spontaneous departure but never finite-time escape. *(This is
  why the obvious candidate `h(r) = (1/g)(⅔r^{3/2} + ⅓r³)` fails: it needs
  `√r + r² ≤ g`, which breaks at `r ≈ 2.85` for `g = 9.8`.)*
- **A potential does.** A unit-mass particle in `V(x) = −(⅔x^{3/2} + ⅓x³)`
  reduces at zero energy to `ẋ = G(x)`, which satisfies the hypotheses, with
  `T*_mech = (2/3)√(3/2)·2^(−1/3)·B(⅙,⅓) ≈ 5.4521363617`.

**On novelty.** The note claims only what a bounded search supports: *in the
literature searched for this project, no example was found satisfying all four
tested conditions simultaneously*. That is not a priority claim. The ingredients
are classical — Osgood's uniqueness criterion dates from 1898 — and the standard
textbooks were searched by keyword, not read.

**On interpretation.** §9 sets out three readings of whether this is
indeterminism and endorses none as established. Whether it is depends on a prior
question the mathematics does not settle: whether a history that ceases to exist
at a finite time counts as a complete physical history.

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
python3 verification/gap_checks.py     # 40/40, plus an AST audit of itself
python3 verification/note_checks.py    # 14/14, same guard
lean retracted/Indexed.lean            # the withdrawn development
lean retracted/Referee.lean            # the refutation
```

Both check files walk their own AST and fail the run if any check's predicate is
a literal constant. That guard exists because the previous verification file
shipped a check whose predicate was the literal `True`, and a "tent map" check
that only ever differentiated `2*x` — the identical check passes for `x ↦ 2x+7`,
which is not chaotic.
