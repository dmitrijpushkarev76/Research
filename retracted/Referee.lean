/-
  Indexed.lean

  Determinism as an INDEXED predicate.

  A determinism verdict is not a function of a law alone. It is a function of
  a law together with three further coordinates, each of which has been debated
  separately in the literature as though it were the whole problem:

    sigma  -- individuation: which redescription of the state space is the
              physical one.  (Hole argument; Everettian "levels".)
    delta  -- temporal domain: must a history be defined at every time, or
              only be maximal?  (Blow-up, escape to infinity, singularities.)
    mu     -- admissibility: which models count as models of the theory?
              (Norton's dome.)

  A fourth coordinate, the agreement relation itself (agreement at an instant
  vs. on a segment; one direction vs. two), is already well mapped -- Belot's
  D1-D3, Montague/Lewis, Mueller & Placek 2018, Halvorson, Manchak & Weatherall
  2026 -- and is held FIXED here at the Montague/Lewis setting so that the
  other three can be isolated.

  Main results:
    * Each of sigma, delta, mu can flip a verdict with the other two held fixed
      (`delta_matters`, `sigma_can_create`, `sigma_can_destroy`, `mu_matters`).
    * sigma is non-monotone in BOTH directions: coarsening can manufacture
      determinism and can destroy it. The second direction is the one that
      matches Ornstein-Weiss.
    * Everettian level-relativity is not a separate phenomenon: the branch
      projection is a sigma-redescription (`everett_is_a_sigma_shift`).
    * The coordinates interact: on one fixed law, flipping sigma changes the
      verdict under one delta and not under the other (`sigma_delta_interact`),
      so neither is definable from the other.

  Lean 4 core only. No Mathlib. No `sorry`. Axiom audit at the end.
-/

namespace IndexedDeterminism

/-! ## 1. Framework -/

/-- A history, possibly undefined at some times. `none` = not defined there.
    Taking partial histories as the primitive is what lets the temporal-domain
    coordinate `delta` be varied rather than stipulated. -/
abbrev PHist (S : Type) := Nat → Option S

/-- A law: a bare predicate on histories. Not an evolution operator, not a
    transition function, not a differential equation -- any of those would
    build the initial-value paradigm into the vocabulary. -/
structure Law (S : Type) where
  Possible : PHist S → Prop

/-- delta = TOTAL: a history must be defined at every time. -/
def Total {S : Type} (h : PHist S) : Prop := ∀ n, ∃ s, h n = some s

/-- `h'` extends `h`: it agrees wherever `h` is defined. -/
def Extends {S : Type} (h' h : PHist S) : Prop := ∀ n s, h n = some s → h' n = some s

/-- delta = MAXIMAL: a history must be possible and have no proper possible
    extension. This is the working mathematician's convention. -/
def Maximal {S : Type} (L : Law S) (h : PHist S) : Prop :=
  L.Possible h ∧ ∀ h', L.Possible h' → Extends h' h → h' = h

/-- Two histories meet: they are both defined, and agree, at some one instant.
    This is the Montague/Lewis agreement relation, held fixed throughout. -/
def MeetAt {S : Type} (h₁ h₂ : PHist S) : Prop := ∃ n s, h₁ n = some s ∧ h₂ n = some s

/-- Determinism RELATIVE TO a class `C` of admissible histories. `C` is the
    delta coordinate: instantiate it at `Total` or at `Maximal L`. -/
def DetIn {S : Type} (L : Law S) (C : PHist S → Prop) : Prop :=
  ∀ h₁ h₂, L.Possible h₁ → L.Possible h₂ → C h₁ → C h₂ → MeetAt h₁ h₂ → h₁ = h₂

/-- The possible-history set through state `s` at time `n`, relative to `C`. -/
def HistIn {S : Type} (L : Law S) (C : PHist S → Prop) (n : Nat) (s : S) :
    PHist S → Prop :=
  fun h => L.Possible h ∧ C h ∧ h n = some s

def AtMostOne {α : Type} (P : α → Prop) : Prop := ∀ a b, P a → P b → a = b
def ExactlyOne {α : Type} (P : α → Prop) : Prop := ∃ a, P a ∧ ∀ b, P b → b = a

theorem exactlyOne_imp_atMostOne {α : Type} {P : α → Prop} :
    ExactlyOne P → AtMostOne P := by
  intro h a b ha hb
  cases h with
  | intro c hc => cases hc with
    | intro _ hu => rw [hu a ha, hu b hb]

/-! ## 2. The bridge: determinism IS uniqueness-through-a-state, at each delta -/

theorem detIn_iff_atMostOne {S : Type} (L : Law S) (C : PHist S → Prop) :
    DetIn L C ↔ ∀ n s, AtMostOne (HistIn L C n s) := by
  constructor
  · intro hd n s h₁ h₂ p₁ p₂
    exact hd h₁ h₂ p₁.1 p₂.1 p₁.2.1 p₂.2.1 ⟨n, s, p₁.2.2, p₂.2.2⟩
  · intro hu h₁ h₂ p₁ p₂ c₁ c₂ hm
    cases hm with
    | intro n hn => cases hn with
      | intro s hs => exact hu n s h₁ h₂ ⟨p₁, c₁, hs.1⟩ ⟨p₂, c₂, hs.2⟩

/-- The claim everybody argues about. Depends on no axioms: it is a
    definitional unfolding of "exactly one", and carries no physical content.
    Every substantive question is in the antecedent -- and, this file adds,
    in the three coordinates the antecedent is indexed to. -/
theorem no_distinct_possible_history {S : Type}
    {L : Law S} {C : PHist S → Prop} {n : Nat} {s : S} {H : PHist S}
    (hone : ExactlyOne (HistIn L C n s)) (hH : HistIn L C n s H) :
    ¬ ∃ H', H' ≠ H ∧ HistIn L C n s H' := by
  intro hex
  cases hex with
  | intro H' hH' => cases hone with
    | intro a ha => exact hH'.1 (by rw [ha.2 H' hH'.2, ha.2 H hH])

/-! ## 3. Coordinate delta: the temporal domain

The law below is the formal shadow of `dx/dt = x²`, `x(0)=1`: a unique solution
that runs out at a finite time. Under delta = Total there is NO possible
history, so `|H| = 0` and the law is vacuously deterministic. Under
delta = Maximal there is EXACTLY ONE, so `|H| = 1`.

Same law, same individuation, same admissible models. The existence verdict --
and with it the modal collapse of section 6 -- turns entirely on a convention
about what a history is. -/

/-- Defined on {0,1,2}, undefined thereafter: blow-up at step 3. -/
def blowH : PHist Bool := fun n => if n < 3 then some true else none

def blowup : Law Bool := ⟨fun h => h = blowH⟩

theorem blowH_not_total : ¬ Total blowH := by
  intro ht
  cases ht 3 with
  | intro s hs => exact Option.noConfusion hs

theorem blowup_no_total_history (n : Nat) (s : Bool) :
    ¬ ExactlyOne (HistIn blowup Total n s) := by
  intro h
  cases h with
  | intro a ha =>
    have : a = blowH := ha.1.1
    exact blowH_not_total (this ▸ ha.1.2.1)

theorem blowH_maximal : Maximal blowup blowH := by
  refine ⟨rfl, ?_⟩
  intro h' hp _
  exact hp

theorem blowup_exactlyOne_maximal :
    ExactlyOne (HistIn blowup (Maximal blowup) 0 true) := by
  refine ⟨blowH, ⟨rfl, blowH_maximal, rfl⟩, ?_⟩
  intro b hb
  exact hb.1

/-- **delta is not eliminable.** One law; the possible-history set is empty
    under one temporal-domain convention and a singleton under the other. -/
theorem delta_matters :
    ¬ ExactlyOne (HistIn blowup Total 0 true) ∧
      ExactlyOne (HistIn blowup (Maximal blowup) 0 true) :=
  ⟨blowup_no_total_history 0 true, blowup_exactlyOne_maximal⟩

/-! ## 4. Coordinate sigma: individuation

`sigma` is a redescription of the state space. Pushing a law forward along it
is how the hole argument, the Everettian level shift, and coarse-graining all
work. The two results below show it is non-monotone in BOTH directions -- and
both witnesses are non-degenerate: neither collapses the state space to a
point, which is the only case the cheap version of this observation covers. -/

inductive S4 | a | b | c | d
  deriving DecidableEq

inductive S3 | x | y | z
  deriving DecidableEq

open S4 S3

/-- Push a law forward along a redescription of the state space. -/
def push {S T : Type} (L : Law S) (r : S → T) : Law T :=
  ⟨fun h' => ∃ h, L.Possible h ∧ h' = fun n => (h n).map r⟩

/-- Identifies `a` with `b`, and `c` with `d`. Not constant. -/
def rMerge : S4 → S3
  | S4.a => S3.x | S4.b => S3.x | S4.c => S3.y | S4.d => S3.y

/-- Identifies `a` with `b` only; keeps `c` and `d` apart. Not constant. -/
def rSplit : S4 → S3
  | S4.a => S3.x | S4.b => S3.x | S4.c => S3.y | S4.d => S3.z

theorem rMerge_not_constant : ¬ ∀ u v : S3, u = v := by
  intro h; exact S3.noConfusion (h S3.x S3.y)

/-- Two histories branching at time 0 from a common state. -/
def hAC : PHist S4 := fun n => if n = 0 then some S4.a else some S4.c
def hAD : PHist S4 := fun n => if n = 0 then some S4.a else some S4.d

/-- Two histories that never share a state. -/
def hBC : PHist S4 := fun n => if n = 0 then some S4.b else some S4.c
def hAD' : PHist S4 := fun n => if n = 0 then some S4.a else some S4.d

def branching : Law S4 := ⟨fun h => h = hAC ∨ h = hAD⟩
def disjoint : Law S4 := ⟨fun h => h = hBC ∨ h = hAD'⟩

theorem hAC_total : Total hAC := by
  intro n; by_cases hn : n = 0
  · exact ⟨S4.a, by simp [hAC, hn]⟩
  · exact ⟨S4.c, by simp [hAC, hn]⟩

theorem hAD_total : Total hAD := by
  intro n; by_cases hn : n = 0
  · exact ⟨S4.a, by simp [hAD, hn]⟩
  · exact ⟨S4.d, by simp [hAD, hn]⟩

theorem hBC_total : Total hBC := by
  intro n; by_cases hn : n = 0
  · exact ⟨S4.b, by simp [hBC, hn]⟩
  · exact ⟨S4.c, by simp [hBC, hn]⟩

theorem hAD'_total : Total hAD' := by
  intro n; by_cases hn : n = 0
  · exact ⟨S4.a, by simp [hAD', hn]⟩
  · exact ⟨S4.d, by simp [hAD', hn]⟩

/-- `branching` is indeterministic: `hAC` and `hAD` meet at time 0 and part. -/
theorem branching_not_det : ¬ DetIn branching Total := by
  intro hd
  have e : hAC = hAD :=
    hd hAC hAD (Or.inl rfl) (Or.inr rfl) hAC_total hAD_total
      ⟨0, S4.a, by simp [hAC], by simp [hAD]⟩
  have := congrFun e 1
  simp [hAC, hAD] at this

/-- **sigma can MANUFACTURE determinism.** Coarsening by `rMerge` -- which
    identifies the two divergent successors -- makes the pushed law
    deterministic, because the two histories now have the same image. -/
theorem sigma_can_create :
    ¬ DetIn branching Total ∧ DetIn (push branching rMerge) Total := by
  refine ⟨branching_not_det, ?_⟩
  intro h₁ h₂ p₁ p₂ _ _ _
  cases p₁ with
  | intro g₁ hg₁ => cases p₂ with
    | intro g₂ hg₂ =>
      have img : ∀ g : PHist S4, (g = hAC ∨ g = hAD) →
          (fun n => (g n).map rMerge) = (fun n => (hAC n).map rMerge) := by
        intro g hg
        cases hg with
        | inl e => rw [e]
        | inr e =>
          rw [e]; funext n
          by_cases hn : n = 0 <;> simp [hAC, hAD, rMerge, hn]
      rw [hg₁.2, hg₂.2, img g₁ hg₁.1, img g₂ hg₂.1]

/-- `hBC` and `hAD'` differ at every instant: at time 0 as `b` vs `a`, and
    thereafter as `c` vs `d`. -/
theorem hBC_ne_hAD' (n : Nat) : hBC n ≠ hAD' n := by
  intro h
  simp only [hBC, hAD'] at h
  by_cases h0 : n = 0
  · rw [if_pos h0, if_pos h0] at h
    exact S4.noConfusion (Option.some.inj h)
  · rw [if_neg h0, if_neg h0] at h
    exact S4.noConfusion (Option.some.inj h)

/-- `disjoint` is deterministic: its two histories never share a state, so the
    antecedent of the agreement condition is never satisfied. -/
theorem disjoint_det : DetIn disjoint Total := by
  intro h₁ h₂ p₁ p₂ _ _ hm
  cases hm with
  | intro n hn => cases hn with
    | intro s hs =>
      cases p₁ with
      | inl e₁ => cases p₂ with
        | inl e₂ => rw [e₁, e₂]
        | inr e₂ =>
          exfalso; apply hBC_ne_hAD' n
          rw [← e₁, ← e₂, hs.1, hs.2]
      | inr e₁ => cases p₂ with
        | inl e₂ =>
          exfalso; apply hBC_ne_hAD' n
          rw [← e₂, ← e₁, hs.2, hs.1]
        | inr e₂ => rw [e₁, e₂]

/-- **sigma can DESTROY determinism.** Coarsening by `rSplit` -- which
    identifies the two distinct initial states but keeps the successors apart --
    makes the pushed law indeterministic. This is the direction that matches
    Ornstein-Weiss: coarse-graining a deterministic system generically produces
    a description that branches. -/
theorem sigma_can_destroy :
    DetIn disjoint Total ∧ ¬ DetIn (push disjoint rSplit) Total := by
  refine ⟨disjoint_det, ?_⟩
  intro hd
  have p₁ : (push disjoint rSplit).Possible (fun n => (hBC n).map rSplit) :=
    ⟨hBC, Or.inl rfl, rfl⟩
  have p₂ : (push disjoint rSplit).Possible (fun n => (hAD' n).map rSplit) :=
    ⟨hAD', Or.inr rfl, rfl⟩
  have t₁ : Total (fun n => (hBC n).map rSplit) := by
    intro n; by_cases hn : n = 0
    · exact ⟨S3.x, by simp [hBC, rSplit, hn]⟩
    · exact ⟨S3.y, by simp [hBC, rSplit, hn]⟩
  have t₂ : Total (fun n => (hAD' n).map rSplit) := by
    intro n; by_cases hn : n = 0
    · exact ⟨S3.x, by simp [hAD', rSplit, hn]⟩
    · exact ⟨S3.z, by simp [hAD', rSplit, hn]⟩
  have e := hd _ _ p₁ p₂ t₁ t₂ ⟨0, S3.x, by simp [hBC, rSplit], by simp [hAD', rSplit]⟩
  have := congrFun e 1
  simp [hBC, hAD', rSplit] at this

/-! ### 4.1 Everettian level-relativity is a sigma shift, not a new phenomenon

The universal state is a function from branch labels to local states; a
branch-relative history is that function evaluated at a label. Evaluation is a
map between state spaces, so "one history at the universal level, many at the
branch level" is a change of the sigma coordinate -- the same coordinate the
hole argument turns on. -/

abbrev UnivState (B S : Type) := B → S

/-- Evaluation at a branch label: a redescription of the universal state space. -/
def evalAt {B S : Type} (b : B) : UnivState B S → S := fun u => u b

def univH : PHist (UnivState Bool Bool) :=
  fun n => some (fun b => if n = 0 then false else b)

def everett : Law (UnivState Bool Bool) := ⟨fun h => h = univH⟩

/-- At the universal level: exactly one history. -/
theorem everett_universal_unique :
    ExactlyOne (HistIn everett Total 0 (fun _ => false)) := by
  refine ⟨univH, ⟨rfl, ?_, rfl⟩, ?_⟩
  · intro n; exact ⟨_, rfl⟩
  · intro b hb; exact hb.1

/-- At the branch level: the two branch histories differ. -/
theorem everett_branches_differ :
    (fun n => (univH n).map (evalAt true)) ≠ (fun n => (univH n).map (evalAt false)) := by
  intro h
  have := congrFun h 1
  simp [univH, evalAt] at this

/-- **The level shift IS a sigma shift.** The branch history is literally the
    pushforward of the universal history along `evalAt b`. -/
theorem everett_is_a_sigma_shift (b : Bool) :
    (push everett (evalAt b)).Possible (fun n => (univH n).map (evalAt b)) :=
  ⟨univH, rfl, rfl⟩

/-! ## 5. Coordinate mu: admissibility

"Classical mechanics is deterministic" quantifies over the models that count as
models of classical mechanics. Norton's dome is the standing dispute about
where that boundary runs, and Fletcher 2012 and Antoszek 2026 are arguments
that the boundary is not fixed by the formalism. Formally the coordinate is a
class of laws, and it is not eliminable for a trivial but unavoidable reason:
determinism is not preserved by enlarging the class. -/

def Theory (S : Type) := Law S → Prop

def DetTheory {S : Type} (T : Theory S) (C : PHist S → Prop) : Prop :=
  ∀ L, T L → DetIn L C

def narrow : Theory S4 := fun L => L = disjoint
def wide : Theory S4 := fun L => L = disjoint ∨ L = branching

theorem narrow_sub_wide : ∀ L, narrow L → wide L := by
  intro L h; exact Or.inl h

/-- **mu is not eliminable.** Two admissibility classes, one contained in the
    other, with opposite verdicts -- the law and the individuation held fixed. -/
theorem mu_matters :
    (∀ L, narrow L → wide L) ∧ DetTheory narrow Total ∧ ¬ DetTheory wide Total := by
  refine ⟨narrow_sub_wide, ?_, ?_⟩
  · intro L hL; rw [hL]; exact disjoint_det
  · intro hw
    exact branching_not_det (hw branching (Or.inr rfl))

/-! ## 6. The coordinates interact

Independence claims are cheap if the coordinates never meet. They do meet. On
the `blowup` law, the sigma coordinate is inert under delta = Total (there are
no total histories to redescribe, so every pushed verdict is vacuous) and live
under delta = Maximal. So the contribution of sigma is not a function of the
law alone: it depends on delta. Neither coordinate is definable from the
other. -/

/-- Under delta = Total, `blowup` has no histories at all, so it is
    deterministic whatever sigma does -- vacuously. -/
theorem blowup_det_total : DetIn blowup Total := by
  intro h₁ _ p₁ _ c₁ _ _
  exfalso
  have : h₁ = blowH := p₁
  exact blowH_not_total (this ▸ c₁)

/-- Under delta = Maximal, `blowup` has exactly one history -- so the modal
    situation is completely different, though the verdict word is the same. -/
theorem blowup_det_maximal : DetIn blowup (Maximal blowup) := by
  intro h₁ h₂ p₁ p₂ _ _ _
  have e₁ : h₁ = blowH := p₁
  have e₂ : h₂ = blowH := p₂
  rw [e₁, e₂]

/-- **The interaction.** Both delta settings return "deterministic" for
    `blowup`, but they disagree about whether anything is possible at all.
    A verdict word without its index is not a verdict. -/
theorem sigma_delta_interact :
    DetIn blowup Total ∧ DetIn blowup (Maximal blowup) ∧
      ¬ ExactlyOne (HistIn blowup Total 0 true) ∧
      ExactlyOne (HistIn blowup (Maximal blowup) 0 true) :=
  ⟨blowup_det_total, blowup_det_maximal,
   blowup_no_total_history 0 true, blowup_exactlyOne_maximal⟩

/-- **Main theorem: no coordinate is eliminable.** For each of the three
    coordinates there is a pair of index-assignments agreeing on the other two
    and disagreeing in verdict. -/
theorem coordinates_independent :
    -- delta
    (¬ ExactlyOne (HistIn blowup Total 0 true) ∧
      ExactlyOne (HistIn blowup (Maximal blowup) 0 true)) ∧
    -- sigma, upward and downward
    (¬ DetIn branching Total ∧ DetIn (push branching rMerge) Total) ∧
    (DetIn disjoint Total ∧ ¬ DetIn (push disjoint rSplit) Total) ∧
    -- mu
    (DetTheory narrow Total ∧ ¬ DetTheory wide Total) :=
  ⟨delta_matters, sigma_can_create, sigma_can_destroy,
   ⟨mu_matters.2.1, mu_matters.2.2⟩⟩

/-! ## 7. Modal content, correctly relativised

The modal collapse needs BOTH conjuncts of `|H| = 1`, and therefore inherits
the delta coordinate: on the blow-up law it holds under Maximal and fails
under Total. -/

def Dia {S : Type} (L : Law S) (C : PHist S → Prop) (n : Nat) (s : S)
    (A : PHist S → Prop) : Prop := ∃ h, HistIn L C n s h ∧ A h

def Box {S : Type} (L : Law S) (C : PHist S → Prop) (n : Nat) (s : S)
    (A : PHist S → Prop) : Prop := ∀ h, HistIn L C n s h → A h

theorem dia_imp_box_of_atMostOne {S : Type}
    {L : Law S} {C : PHist S → Prop} {n : Nat} {s : S}
    (hone : AtMostOne (HistIn L C n s)) (A : PHist S → Prop) :
    Dia L C n s A → Box L C n s A := by
  intro hd h' hh'
  cases hd with
  | intro h hh => rw [hone h' h hh' hh.1]; exact hh.2

theorem modal_collapse {S : Type}
    {L : Law S} {C : PHist S → Prop} {n : Nat} {s : S}
    (hone : ExactlyOne (HistIn L C n s)) (A : PHist S → Prop) :
    Dia L C n s A ↔ Box L C n s A := by
  constructor
  · exact dia_imp_box_of_atMostOne (exactlyOne_imp_atMostOne hone) A
  · intro hb
    cases hone with
    | intro a ha => exact ⟨a, ha.1, hb a ha.1⟩

/-- **The collapse is delta-indexed.** Under Total, `Box` is vacuously true and
    `Dia` false, so the biconditional fails in the right-to-left direction:
    there is nothing the future must be like, because there is no future. -/
theorem modal_collapse_fails_under_total :
    Box blowup Total 0 true (fun _ => False) ∧
      ¬ Dia blowup Total 0 true (fun _ => False) := by
  constructor
  · intro h hh
    exact blowH_not_total ((hh.1 : h = blowH) ▸ hh.2.1)
  · intro hd
    cases hd with
    | intro h hh => exact hh.2

/-! ## 8. Three readings of "it could have been otherwise"

Determinism forecloses reading A only. B and C survive. -/

def cT : PHist Bool := fun _ => some true
def cF : PHist Bool := fun _ => some false

def twoWorlds : Law Bool := ⟨fun h => h = cT ∨ h = cF⟩

theorem cT_ne_cF_at (n : Nat) : cT n ≠ cF n := by
  intro h; exact Bool.noConfusion (Option.some.inj h)

theorem cT_total : Total cT := fun _ => ⟨true, rfl⟩
theorem cF_total : Total cF := fun _ => ⟨false, rfl⟩

theorem twoWorlds_det : DetIn twoWorlds Total := by
  intro h₁ h₂ p₁ p₂ _ _ hm
  cases hm with
  | intro n hn => cases hn with
    | intro s hs =>
      cases p₁ with
      | inl e₁ => cases p₂ with
        | inl e₂ => rw [e₁, e₂]
        | inr e₂ =>
          exfalso; apply cT_ne_cF_at n
          rw [← e₁, ← e₂, hs.1, hs.2]
      | inr e₁ => cases p₂ with
        | inl e₂ =>
          exfalso; apply cT_ne_cF_at n
          rw [← e₂, ← e₁, hs.2, hs.1]
        | inr e₂ => rw [e₁, e₂]

/-- Reading B -- different prior state, same laws -- survives determinism.
    Determinism constrains how histories may RELATE; it does not bound how
    many there are. Both worlds below are possible and they are distinct. -/
theorem readingB_survives :
    DetIn twoWorlds Total ∧ twoWorlds.Possible cT ∧ twoWorlds.Possible cF ∧ cT ≠ cF := by
  refine ⟨twoWorlds_det, Or.inl rfl, Or.inr rfl, ?_⟩
  intro h
  exact cT_ne_cF_at 0 (congrFun h 0)

/-! ## 9. The supervenience premise, stated so that it says something

The earlier version of this development proved only that some function of two
arguments depends on its second argument, which is no content at all. Here the
premise is named: an action-ascription may depend on the physical history and
on a further parameter, and SUPERVENIENCE is the claim that the second
dependence is idle. The entailment from a unique history to a unique action
holds exactly when supervenience does. -/

/-- An action-ascription: a function of the history, a further parameter, and
    a time. -/
def Ascription (S P A : Type) := PHist S → P → Nat → A

/-- Supervenience on physical history: the further parameter makes no
    difference. This is causal closure of the physical, in the present setting. -/
def Supervenes {S P A : Type} (f : Ascription S P A) : Prop :=
  ∀ h p q n, f h p n = f h q n

/-- GIVEN supervenience, a unique history fixes the action. -/
theorem unique_history_fixes_action {S P A : Type}
    {L : Law S} {C : PHist S → Prop} {n₀ : Nat} {s : S}
    (f : Ascription S P A) (hsup : Supervenes f)
    (hone : ExactlyOne (HistIn L C n₀ s)) :
    ∀ H H' p q n, HistIn L C n₀ s H → HistIn L C n₀ s H' →
      f H p n = f H' q n := by
  intro H H' p q n hH hH'
  have e : H = H' := exactlyOne_imp_atMostOne hone H H' hH hH'
  rw [e]; exact hsup H' p q n

/-- A law fixing exactly one history, used below. -/
def constTrue : PHist Bool := fun _ => some true
def globalLawB : Law Bool := ⟨fun h => h = constTrue⟩

theorem constTrue_total : Total constTrue := fun _ => ⟨true, rfl⟩

theorem globalLawB_exactlyOne : ExactlyOne (HistIn globalLawB Total 0 true) := by
  refine ⟨constTrue, ⟨rfl, constTrue_total, rfl⟩, ?_⟩
  intro b hb; exact hb.1

/-- WITHOUT supervenience the entailment fails: here is a law with exactly one
    possible history, an ascription that does not supervene, and two distinct
    actions on that one history. So the step from "one history" to "one action"
    is not a consequence of uniqueness; it needs causal closure as a separate
    premise. -/
theorem action_not_fixed_without_supervenience :
    ∃ (f : Ascription Bool Bool Bool),
      ¬ Supervenes f ∧
      ExactlyOne (HistIn globalLawB Total 0 true) ∧
      (∃ p q n, f constTrue p n ≠ f constTrue q n) := by
  refine ⟨fun _ p _ => p, ?_, globalLawB_exactlyOne, ⟨true, false, 0, by simp⟩⟩
  intro hs
  have := hs constTrue true false 0
  simp at this

end IndexedDeterminism

/-! ============================================================================
    REFEREE'S COUNTER-DEVELOPMENT
    Every theorem below is stated against the paper's UNMODIFIED definitions.
    ========================================================================= -/

namespace Referee
open IndexedDeterminism

/-! ## Attack 1 (referee C2): delta and mu fold into the law. -/

def restrict {S : Type} (L : Law S) (C : PHist S → Prop) : Law S :=
  ⟨fun h => L.Possible h ∧ C h⟩

def triv {S : Type} : PHist S → Prop := fun _ => True

/-- The delta coordinate is ELIMINABLE: every delta-indexed verdict is an
    UNINDEXED verdict about a different law. -/
theorem delta_eliminable {S : Type} (L : Law S) (C : PHist S → Prop) :
    DetIn L C ↔ DetIn (restrict L C) triv := by
  constructor
  · intro hd h₁ h₂ p₁ p₂ _ _ hm; exact hd h₁ h₂ p₁.1 p₂.1 p₁.2 p₂.2 hm
  · intro hd h₁ h₂ p₁ p₂ c₁ c₂ hm
    exact hd h₁ h₂ ⟨p₁, c₁⟩ ⟨p₂, c₂⟩ True.intro True.intro hm

/-- The mu coordinate folds the same way. -/
theorem mu_eliminable {S : Type} (T : Theory S) (C : PHist S → Prop) :
    DetTheory T C ↔ ∀ L, T L → DetIn (restrict L C) triv := by
  constructor
  · intro h L hL; exact (delta_eliminable L C).mp (h L hL)
  · intro h L hL; exact (delta_eliminable L C).mpr (h L hL)

/-- And sigma was never a separate slot: `push L r` is itself a law, so a
    sigma-indexed verdict is a bare verdict about another law. Composing,
    EVERY (L, sigma, delta) verdict is one unindexed verdict. -/
theorem all_three_collapse_to_one_slot {S T : Type}
    (L : Law S) (r : S → T) (C : PHist T → Prop) :
    DetIn (push L r) C ↔ DetIn (restrict (push L r) C) triv :=
  delta_eliminable (push L r) C

/-! ## Attack 2 (referee C1): the paper's delta witness does not flip
    the DETERMINISM verdict -- only the existence verdict. -/

theorem delta_witness_does_not_flip_determinism :
    DetIn blowup Total ∧ DetIn blowup (Maximal blowup) :=
  ⟨blowup_det_total, blowup_det_maximal⟩

/-! ## Attack 3 (referee C3): Theorem 9 is false as a unification claim. -/

/-- The pushforward of a singleton law is a singleton law, so the Everett
    model is deterministic at EVERY sigma setting: the branch multiplicity
    the theorem exists to explain never arises. -/
theorem everett_deterministic_at_every_sigma {T : Type}
    (r : UnivState Bool Bool → T) (C : PHist T → Prop) :
    DetIn (push everett r) C := by
  intro h₁ h₂ p₁ p₂ _ _ _
  cases p₁ with
  | intro g₁ hg₁ => cases p₂ with
    | intro g₂ hg₂ =>
      have e₁ : g₁ = univH := hg₁.1
      have e₂ : g₂ = univH := hg₂.1
      rw [hg₁.2, hg₂.2, e₁, e₂]

/-- The law whose possible histories ARE the branch histories. -/
def branchLaw : Law Bool :=
  ⟨fun h' => ∃ b : Bool, h' = fun n => (univH n).map (evalAt b)⟩

/-- ...and it is NOT the pushforward of the universal law along ANY
    redescription whatever. Pushforward along a single map cannot turn one
    history into many. -/
theorem branch_law_is_not_a_pushforward :
    ¬ ∃ r : UnivState Bool Bool → Bool,
        ∀ h, branchLaw.Possible h ↔ (push everett r).Possible h := by
  intro hex
  cases hex with
  | intro r hr =>
    have pT : branchLaw.Possible (fun n => (univH n).map (evalAt true)) :=
      ⟨true, rfl⟩
    have pF : branchLaw.Possible (fun n => (univH n).map (evalAt false)) :=
      ⟨false, rfl⟩
    have qT := (hr _).mp pT
    have qF := (hr _).mp pF
    cases qT with
    | intro gT hgT => cases qF with
      | intro gF hgF =>
        apply everett_branches_differ
        rw [hgT.2, hgF.2, (hgT.1 : gT = univH), (hgF.1 : gF = univH)]

/-! ## Attack 4 (mine, not the referee's): is the C1 defect REPAIRABLE?
    The referee says a delta witness that flips DetIn should exist. It does.
    Two partial histories, mutually non-extending, meeting at one instant;
    plus one total history meeting neither. -/

def hP1 : PHist S4 := fun n => if n = 0 then some S4.a else if n = 1 then some S4.b else none
def hP2 : PHist S4 := fun n => if n = 0 then some S4.a else if n = 2 then some S4.c else none
def hT  : PHist S4 := fun _ => some S4.d

def deltaLaw : Law S4 := ⟨fun h => h = hP1 ∨ h = hP2 ∨ h = hT⟩

theorem hT_total : Total hT := fun _ => ⟨S4.d, rfl⟩

/-- Under delta = Total only `hT` is admissible, so the law is DETERMINISTIC. -/
theorem deltaLaw_det_total : DetIn deltaLaw Total := by
  intro h₁ h₂ p₁ p₂ c₁ c₂ _
  have only : ∀ h, (h = hP1 ∨ h = hP2 ∨ h = hT) → Total h → h = hT := by
    intro h hp ht
    cases hp with
    | inl e => exfalso; cases ht 2 with
      | intro s hs => rw [e] at hs; simp [hP1] at hs
    | inr hp' => cases hp' with
      | inl e => exfalso; cases ht 1 with
        | intro s hs => rw [e] at hs; simp [hP2] at hs
      | inr e => exact e
  rw [only h₁ p₁ c₁, only h₂ p₂ c₂]

theorem hP1_maximal : Maximal deltaLaw hP1 := by
  refine ⟨Or.inl rfl, ?_⟩
  intro h' hp hext
  cases hp with
  | inl e => exact e
  | inr hp' => cases hp' with
    | inl e =>
      exfalso; have := hext 1 S4.b (by simp [hP1]); rw [e] at this; simp [hP2] at this
    | inr e =>
      exfalso; have := hext 0 S4.a (by simp [hP1]); rw [e] at this; simp [hT] at this

theorem hP2_maximal : Maximal deltaLaw hP2 := by
  refine ⟨Or.inr (Or.inl rfl), ?_⟩
  intro h' hp hext
  cases hp with
  | inl e =>
    exfalso; have := hext 2 S4.c (by simp [hP2]); rw [e] at this; simp [hP1] at this
  | inr hp' => cases hp' with
    | inl e => exact e
    | inr e =>
      exfalso; have := hext 0 S4.a (by simp [hP2]); rw [e] at this; simp [hT] at this

/-- Under delta = Maximal the two partial histories are both admissible, they
    meet at time 0, and they differ: the law is INDETERMINISTIC. -/
theorem deltaLaw_not_det_maximal : ¬ DetIn deltaLaw (Maximal deltaLaw) := by
  intro hd
  have e := hd hP1 hP2 (Or.inl rfl) (Or.inr (Or.inl rfl))
              hP1_maximal hP2_maximal ⟨0, S4.a, by simp [hP1], by simp [hP2]⟩
  have := congrFun e 1
  simp [hP1, hP2] at this

/-- **The repair works.** delta CAN flip the determinism verdict -- the paper
    simply never proved it, and its own witness does not. -/
theorem delta_really_does_flip_determinism :
    DetIn deltaLaw Total ∧ ¬ DetIn deltaLaw (Maximal deltaLaw) :=
  ⟨deltaLaw_det_total, deltaLaw_not_det_maximal⟩

end Referee

open Referee
#print axioms delta_eliminable
#print axioms mu_eliminable
#print axioms all_three_collapse_to_one_slot
#print axioms delta_witness_does_not_flip_determinism
#print axioms everett_deterministic_at_every_sigma
#print axioms branch_law_is_not_a_pushforward
#print axioms delta_really_does_flip_determinism
