# Revision 2 — Proposition 10 does philosophical work in §7

Manuscript: `one-state-many-futures.tex` (the blinded file; no separate
`manuscript_blind.tex` was attached to this round, and the repository file is
already blinded — zero hits for author name, e-mail or affiliation). Builds
clean: pdflatex ×2, **still 16 pages**, no errors, no undefined references.

The whole diff is two hunks, both inside §7. Nothing else in the file changed.

## What was inspected first

All of §7 was read before editing: opening paragraph, the Butterfield/DM2
paragraph, Reading 1, Reading 2 (two paragraphs), Reading 3, and the three
paragraphs of "What happens at $T+T_*$". The locality point already existed as
**one sentence inside the final paragraph** of that last subsection. That
sentence was replaced in place; no parallel discussion was added anywhere else.

## The paragraph that was replaced

Old final paragraph of §7, verbatim:

> As to the positions, the example adds nothing. What it adds is a test case in
> which the three readings give visibly different verdicts about one state of one
> system, with no idealisation to argue over: the equation is scalar and
> autonomous, $f$ is continuous everywhere and $C^{1}$ away from one point, and
> every quantity is exact. **Proposition~\ref{prop:locality} adds one constraint
> that any defence of either reading must accommodate --- on Reading~2 the verdict
> at a state is fixed by the law near that state, on Reading~1 it is not --- and
> we record it as a constraint and not as a reason to prefer either.** One point is
> common to all three readings: the distinction is not dissolved by demanding more
> regularity. The Lipschitz failure sits at the equilibrium alone, and the branches
> terminate because the equation is superlinear at infinity, which is ordinary
> behaviour.

The bolded sentence is the one that was doing the job badly. It was deleted from
that position; the rest of the paragraph is unchanged and now runs straight from
"every quantity is exact" into "One point is common to all three readings".

## The new text

Two paragraphs, appended after the paragraph above, so that §7 ends on the
required sentence:

> Proposition~\ref{prop:locality} bears on the three readings, and it is worth
> being exact about how. It is a statement about two classes of solutions of one
> equation, not a verdict about the world, and we claim no priority for it. What
> it supplies is this: a uniqueness-based criterion that quantifies over the
> solution classes studied in this paper should make explicit whether its
> uniqueness verdict at a state is fixed by the law in a neighbourhood of that
> state. For $\Hmax(0)$, the class Reading~2 quantifies over, the answer is yes:
> $|\Hmax(0)|=1$ exactly when (H2) fails, and (H2) is decided by $f$ near the
> origin. For $\Hglob(0)$, the class Reading~1 quantifies over, the answer is no:
> $|\Hglob(0)|=1$ exactly when (H2) fails or (H3) holds, and (H3) is a condition
> on the tail of $f$. The witness in the proof makes the difference concrete:
> $f_{\flat}$ agrees with $f$ on $[-1,1]$ and differs from it only in the tail,
> and that change alone leaves the maximal count at $\cont$ while moving the
> global count from $1$ to $\cont$.
>
> The three readings pay for this differently, and the proposition ranks nothing.
> On Reading~1 the verdict at a state depends on the law arbitrarily far from that
> state; this is a cost to be stated and answered, not a refutation of the
> reading. Reading~2 does not pay that cost and pays another: on it a
> forward-maximal branch that ends counts as a distinct future, which is what
> Reading~1 declines to allow. Reading~3 declines the uniqueness-based formulation
> altogether, so the proposition does not reach it; the cost there is that
> whatever settles the verdict must be supplied from outside that formulation. We
> adjudicate between none of the three readings.

## Required content, item by item

1. Constrains those criteria, not a verdict about the world, no priority —
   sentence 2 of the new passage.
2. "should make explicit whether its uniqueness verdict at a state is fixed by
   the law in a neighbourhood of that state" — the mandated wording, used verbatim.
3. Reading 2 / $\Hmax$ is local — stated with the iff and with "(H2) is decided
   by $f$ near the origin".
4. Reading 1 / $\Hglob$ is not — stated with the iff and with "(H3) is a
   condition on the tail of $f$".
5. Witness $f_\flat$ — agrees on $[-1,1]$, differs only in the tail, maximal
   count unchanged at $\cont$, global count $1 \to \cont$.
6. "On Reading 1 the verdict at a state depends on the law arbitrarily far from
   that state; this is a cost to be stated and answered, not a refutation."
7. Reading 2 avoids that cost, pays another (terminating branches count as
   distinct futures); Reading 3 pays a third (must supply the verdict from
   outside the uniqueness-based formulation). "the proposition ranks nothing."
8. Last sentence of §7: "We adjudicate between none of the three readings."

Scope wording used exactly as specified: "uniqueness-based criteria that
quantify over the solution classes studied in this paper", never "any
uniqueness-based criterion"; "should make explicit whether", never "must say".

## Constraints honoured

- Same $f$, Theorem 7, three readings. **Proposition 10's statement is
  byte-identical** (sha256 `579c23da…7fb7` before and after).
- No winner picked; no reading refuted; no priority claimed; no claim that any
  physical theory is indeterministic.
- No locality-of-laws metaphysics: the passage speaks only about what fixes a
  criterion's verdict, and says in terms that the proposition is "not a verdict
  about the world". The word "locality" does not appear in §7; the paper's own
  idiom ("in a neighbourhood of", "the tail of $f$") is used instead. No new
  philosophical terminology: every evaluative word in the passage — criterion,
  verdict, cost, future, history — already occurs in §7.
- No new citations. Nothing edited in §§2–6 proofs, Appendix B, or the Binding,
  Bhat–Bernstein, Malament and Earman passages.
- Boxed non-claim untouched; §7 opening neutrality untouched.
- Abstract and §8 untouched. No sentence in either became false: the abstract
  describes Proposition 10 as "locating where each of the two uniqueness
  verdicts is decided" and §8 as saying "where each of the two verdicts is
  decided", both of which the revised §7 passage still supports.
- Net length: §7 gained two paragraphs and lost one sentence. **The document is
  still 16 pages**, so §7 did not grow the paper at all.

## One deliberate non-edit, flagged for your decision

The paragraph immediately after Proposition 10 in §4 still reads:

> So the two counts are not decided in the same place. Whether one solution or
> continuum-many cannot be extended is settled by the law near the state; whether
> one solution or continuum-many are defined at every later time is not, and no
> amount of information about the law near the state settles it.

This was left alone: it is in §4, not §7, it states the mathematical fact rather
than a philosophical one, and the instruction for this round was confined to
§7. If you want it trimmed, the candidate is the trailing clause "and no amount
of information about the law near the state settles it", which is rhetorical
rather than load-bearing and is now said more carefully in §7. Say the word and
it goes; it was not removed silently.
