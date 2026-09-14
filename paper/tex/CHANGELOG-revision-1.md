# Revision 1 — response to referee punch list

Manuscript: `one-state-many-futures.tex`. Builds clean (pdflatex ×2, 16 pp.,
no errors, no undefined references or citations).

**Blinding.** Author name, affiliation, postal address and e-mail removed from
the `\author` block; the file-header comment now records that the manuscript is
anonymised and that the block must be restored before publication. PDF metadata
carries no author. The header comment's venue line was changed from
"Monthly / Mathematics Magazine house style" to a philosophy-of-science venue
(EJPS). No change to the prose register.

## Must fix

**1. Example-choice contradiction — chose (B).**
Kept `f(x)=|x|^{2/3}+x^2` as the headline and deleted every cheapness /
minimality / economy framing. (A) was not attempted: promoting
`√|x|(1+|x|)` would require regenerating Figure 1 (whose coordinates come from
`F` for the current `f` via `make_figure_data.py`) and re-anchoring Appendix B,
which already realises a third member of the class.
Four deletions/rewrites:
- Abstract: "a minimal worked example" → "an explicit worked example …,
  together with one proposition (Prop. 10) locating where each of the two
  uniqueness verdicts is decided".
- §2: deleted the sentence advertising `√|x|(1+|x|)` as "in some respects more
  economical" together with the `F=2arctan√x`, `T*=π`, `tan²` clause. The
  neutral disclaimers ("We claim no uniqueness or optimality for the choice";
  "any member of the class would serve") are kept, with the scope of the
  general results now stated by cross-reference.
- §6: deleted "It is not the most economical member of the class — Section 2
  names one that is — and we claim no advantage for it beyond convenience."
- §8: deleted "It is that the whole thing is cheap: …" and "one equation that
  fits on a line"; §8 now states two contributions, the worked example and
  Prop. 10, with an explicit no-priority disclaimer.

**2. "Illegible scan" hedge — deleted.**
Replaced by direct attribution: "The form (3) is Binding's own: it is the
definition printed immediately before his Lemma 6.3, and his inversion identity
— the display numbered (6.6) in the JDE printing — is the computation just
given." No quotation invented. A `% TODO` asks for p. 193 and the display
number to be re-checked against the offprint at proof stage. See the
interpretation note below.

**3. Binding's case (6.5).**
Sentence changed was: *"Case (6.5) is exactly hypothesis (H3): when ∫^∞ 1/f<∞,
Binding writes, …"*. Now: "His case (6.5) corresponds to (H2) and (H3)
together, not to (H3) alone: the integral in that case runs from the
equilibrium, so its convergence near the origin is (H2) and its convergence at
infinity is (H3). With (H2) standing, as it does throughout this note, it is
(H3) that does the work." The Binding quotation and the (6.2) gloss are
unchanged.

**4. "Follows in two lines" — qualified.**
Now: "Theorem 7 is close to immediate, with one gap that has to be closed by
hand: Binding's §7 carries the standing hypothesis that all solutions are
positive for t>0, which excludes x_∞ — the one solution whose status in
H⁺_glob(0) is the point at issue — so the zero solution and the bookkeeping of
Steps 3 and 4 are not supplied by his Lemma 7.5 as printed."

**5. Locality proposition — added as Proposition 10** (immediately after
Remark 9, inside §4). States, under (H1) alone,
`|H⁺_max(0)|=1 ⟺ ¬(H2)` and `|H⁺_glob(0)|=1 ⟺ ¬(H2) ∨ (H3)`, with the two
locality claims. Proof is the three-case reading plus a two-line witness: `f♭`
equal to `f` on `[-1,1]` and `2|x|` outside, continuous because `f(±1)=2`,
satisfying (H1) and (H2) and failing (H3). A lead-in sentence says the
ingredients are the classical dichotomies of §6 and claims no priority. One
sentence added in §7 (see item 18).

**6. Appendix B.1.**
- Bibliography entries added for Bhat & Bernstein (1997) and Malament (2008),
  each with a `% TODO` that the author must confirm the details against the
  printed article and that neither has been read.
- The `|h'| ≤ 1` bound is now cited to Norton's own presentation: the tangential
  force is `g sin θ` with `sin θ = dh/dr`, so `|h'| ≤ 1` is forced by
  trigonometry, which is also what arc length forces.
- Novelty status stated explicitly: "Neither the bound nor Proposition 12 below
  is claimed as new."
- The Bhat–Bernstein relation is stated only as antecedence, not as "limiting
  case", with a `% TODO` recording that the stronger statement was not checked.

**7. Skipped — `gap_checks.py` and `README` were not attached.** No change made
to either; the manuscript makes no reference to them.

## Should fix

**8.** Appendix A: "These are the maximal solutions in the standard sense" →
"Each of these is maximal in the standard sense, and among them x≡0 is the only
one defined on all of R. We do not claim this family is exhaustive; nothing
below needs that…". The paragraph opening was adjusted to match ("exhibits
solutions maximal in the standard sense", not "identifies the solutions").

**9.** "they are logically separate" → "they can fail independently in at least
one direction; the converse witness is not given here". The following paragraph
now reads: "In general they need not: Example 11 exhibits (H4b) without (H4a),
so (H4a) does not follow from the conditions imposed on the positive half-line.
We do not give the witness in the other direction."

**10.** One paragraph added after Proposition 5 explaining that the
continuous-singular component of the Wallach/Binding structure theorem
contributes nothing and the jump part reduces to one number because
`f^{-1}(0)={0}`, with an explicit note that Theorem 7 proves completeness
directly and does not rely on it.

**11.** §5: "the pointwise largest solution" → "the largest solution pointwise
on the common interval of existence — the qualification matters here, since the
candidates have different domains".

**12.** Appendix B.2: the specific attribution to Earman of an objection to
unbounded-below potentials is removed. Now: "The potential is unbounded below;
finite-time escape in Newtonian systems, and the responses available to it, are
discussed by Earman [8]." `% TODO` for a page or section reference, recording
why the earlier wording was weakened.

**13.** Reading 2, one sentence: "The parallel is one of form and not of kind:
in general relativity the restriction that secures uniqueness is a restriction
on which models count as models of the theory, whereas the restriction at issue
here is on the temporal domain a solution must have."

**14.** Yoshizawa restored: "he credits awareness of it to Wintner, to Brauer
and Sternberg, and to Yoshizawa." No bibliography entry added — Wintner and
Brauer–Sternberg have none either, and a `%` comment records that this matches
the existing treatment of authors Binding credits.

## Optional

**15.** Moot. The sentence containing "φ itself has no elementary closed form"
was inside the §2 paragraph deleted under item 1(B); the claim is no longer
made anywhere.

**16.** Done, costless: "and, up to the orientation of the two integrals,
dx/f(x)=dα/f̂(α)".

**17.** Done, costless: "The even extension Ĝ(x)=G(|x|) — an extension of the
vector field, not something derived from a potential on x<0, where V is not
defined — is continuous with …".

**18.** §7 neutrality preserved. The abstract still ends "adjudicates between
none of them"; §7 still opens "None of them is introduced here. We set them out
with attributions and do not adjudicate between them"; the boxed non-claim
("We therefore make no unconditional claim that any physical theory is
indeterministic") is untouched. §7 grew by exactly two sentences, both mandated
(items 5 and 13).

## Interpretations recorded

- **Item 2.** The instruction branched on whether p. 193 / display (6.6) is
  already verified in the author's notes. It is: the JDE offprint the author
  holds shows the definition and the display on that page. Both branches were
  therefore taken — the direct attribution *and* a `% TODO` for a proof-stage
  re-check — on the view that a confirmable pointer plus a re-check flag is
  strictly safer than either alone. No quotation from Binding was added.
- **Item 5.** The instruction says the added §7 sentence should say the locality
  fact "constrains Reading 2 more than Reading 1". Read literally as a burden,
  the asymmetry falls on Reading 1, whose verdict is the non-local one; read as
  "pins down", it falls on Reading 2, whose verdict is fixed by the germ. The
  sentence was written so that it is correct under either reading and picks no
  winner: "on Reading 2 the verdict at a state is fixed by the law near that
  state, on Reading 1 it is not — and we record it as a constraint and not as a
  reason to prefer either."
- **Item 1.** "Delete every cheapness framing" was read to include "one equation
  that fits on a line" in §8, which is minimality framing in a different idiom.
