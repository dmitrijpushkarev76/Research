# Does Physics Permit Only One Possible History?

Research materials for an investigation of whether a complete physical state
`S_t` together with the laws `L` admits exactly one physically possible
continuation — i.e. whether `|H(S_t, L)| = 1`.

**Report (rendered):** https://claude.ai/code/artifact/8646c88b-23d2-4fd4-b709-d5e8945bf690

## Layout

```
paper/unique-history.html        The full report (23 sections + references + 2 appendices)
lean/UniqueHistory.lean          27 machine-checked theorems, Lean 4 core, no Mathlib
verification/classical_checks.py 13 symbolic checks, SymPy
```

## Reproducing the verification

Lean (4.24.0, no dependencies — the file imports nothing):

```
lean lean/UniqueHistory.lean
```

Prints only the axiom audit. Any error or `sorryAx` would appear in that output.
Current state: 0 errors, 0 `sorry`; 10 results depend on no axioms at all, and
exactly one uses `Classical.choice`.

SymPy:

```
uv run --with sympy python verification/classical_checks.py
```

Prints a pass/fail table and exits non-zero on any failure. Current state: 13/13.
Covers the Norton dome (shape, equation of motion, the non-unique solution
family, the Lipschitz failure), a generic non-uniqueness example, finite-time
blow-up, and the chaos/uniqueness distinction.

## Sourcing status

Primary literature could not be opened from the session this was produced in:
arXiv, the Stanford Encyclopedia of Philosophy, PhilSci-Archive and publisher
sites are blocked by the network egress policy. Every claim in the report
therefore carries an explicit status marker — MACHINE (verified here), DERIVED
(derived in-document), BIBLIO (source located and metadata corroborated, full
text not consulted), or UNVERIF (from background knowledge, not checked).
Claims marked BIBLIO and UNVERIF should be checked against the sources before
being quoted or relied on.
