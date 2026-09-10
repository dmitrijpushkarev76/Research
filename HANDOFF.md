# Handoff: source-verification pass

The report in `paper/unique-history.html` was written in a session where all
scholarly hosts were blocked by the network egress policy. Every claim carries
an explicit status marker. This pass replaces the unverified ones with real,
anchored citations.

## Step 0 — confirm you actually have access

Run this first. If it fails, the egress policy change did not take effect for
this session and there is no point continuing.

```bash
for h in arxiv.org plato.stanford.edu philsci-archive.pitt.edu link.springer.com; do
  printf '%s ' "$h"; curl -sS -o /dev/null -w '%{http_code}\n' --max-time 20 "https://$h/" 2>&1 | tail -1
done
```

Expect 200/301/302. A `000` or a 403 from the proxy means still blocked — check
`curl -sS "$HTTPS_PROXY/__agentproxy/status"` for the refused host, and report
it rather than working around it. Also test the WebFetch tool separately: it
has its own egress path and was blocked independently of curl last time.

## Step 1 — what to verify, in priority order

Search `paper/unique-history.html` for `st-b` (BIBLIO) and `st-u` (UNVERIF).
BIBLIO means the source was located and its metadata corroborated, but the
full text was never opened and the characterisation is unchecked. UNVERIF
means not even that.

Highest value first — these carry actual argumentative weight:

1. **Bell 1964 + Bell 1976, "The theory of local beables."** Section 10.1
   claims determinism is *derived from locality, not assumed*. This is the most
   contrarian claim in the paper. If it is wrong, §10 needs rewriting.
2. **Adlam, arXiv:2110.07656.** The constraint-based reformulation in §8 leans
   on it. Check that "strong determinism" is used as §8 uses it.
3. **Dafermos & Luk, arXiv:1710.01722.** §7.2 states a conditional: *if* the
   Kerr exterior is dynamically stable, C0-inextendibility SCC is false. Verify
   the conditional's exact form and that the "weak null singularities" repair is
   stated as expected rather than proved.
4. **Berndl et al., quant-ph/9503013.** §11 and the table say global existence
   holds "for typical initial values". Confirm the measure-zero qualification
   and which potentials the theorem covers.
5. **Malament, Phil Sci 75 (2008); Fletcher, EJPS 2 (2012); Norton,
   philsci-archive 2943.** §5.3 attributes specific positions. The dome
   mathematics is already machine-verified and needs no source — only the
   *claims* the three authors make.
6. **Durr, Goldstein & Zanghi, JSP 67 (1992).** §11 says quantum equilibrium is
   a typicality claim rather than a dynamical postulate. Currently UNVERIF.
7. **Choquet-Bruhat & Geroch, CMP 14 (1969).** Exact theorem statement for §7.1.
8. **SEP**: Causal Determinism, Bohmian Mechanics, Bell's Theorem, Many-Worlds,
   Collapse Theories, The Hole Argument. Broad corroboration across §§5-14.

Lower priority, all free: Hossenfelder & Palmer 1912.06462; Manchak et al.
2503.05668; Halvorson & Manchak "Closing the Hole Argument"; Werndl 1310.1615;
Del Santo & Gisin 1909.03697; Conway-Kochen (ams.org Notices 2009); Xia
(Annals 135, 1992); Dowker & Kent (JSP 82, 1996); GRW (PRD 34, 1986).

Books, hardest to obtain — leave UNVERIF rather than guessing: Earman *A Primer
on Determinism*; Wallace *The Emergent Multiverse*; Wilson *The Nature of
Contingency*; van Inwagen *An Essay on Free Will*.

## Step 2 — the rule

Do not simply bolt page numbers onto the existing sentences. Re-derive each
claim against the actual text. Where the characterisation turns out wrong,
**change the claim and say so explicitly in the response** — finding errors is
the point of this pass, not a failure of it. An earlier session already caught
one bad arXiv number this way.

Update the status marker on each claim you check:
- `st-b` / `st-u` -> a real citation with section, page or equation number.
- If a source does not support the claim, either weaken the claim or cut it.
- If a source cannot be reached, leave the marker and say which ones failed.

## Step 3 — republish

Republish `paper/unique-history.html` to the SAME artifact so the link is
stable, by passing the URL:

    https://claude.ai/code/artifact/8646c88b-23d2-4fd4-b709-d5e8945bf690

Read the artifact first (`action: "read"` with that url) before publishing to
it. Then update the "How claims are marked" callout and the sourcing note under
the comparison table to describe what was actually verified this time, and
commit to `claude/clever-noether-dtrqru`.

## What needs no re-verification

These were machine-checked and recompile from the repo. Leave them alone unless
you change a claim that depends on them:

- `lean/UniqueHistory.lean` — 27 theorems, Lean 4.24.0 core, no Mathlib, no
  `sorry`. Run `lean lean/UniqueHistory.lean`; it prints only the axiom audit.
- `verification/classical_checks.py` — 13 SymPy checks including the full
  Norton dome derivation. Run
  `uv run --with sympy python verification/classical_checks.py`; exits non-zero
  on any failure.

Note that Lean was installed from the GitHub release asset, not from
`release.lean-lang.org`, which the egress policy refused. If Lean is missing,
fetch `https://github.com/leanprover/lean4/releases/download/v4.24.0/lean-4.24.0-linux.tar.zst`.
