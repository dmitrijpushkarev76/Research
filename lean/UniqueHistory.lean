/-
  UniqueHistory.lean

  A non-circular formalization of the logical core of the argument:

      "If the complete state at t and the laws fix exactly one possible history,
       then no alternative history -- and no alternative action -- is possible."

  Deliberately written against Lean 4 CORE ONLY (no Mathlib). The abstract
  argument needs no analysis, so nothing is imported; the trusted base is as
  small as it can be, and `#print axioms` at the end reports exactly what each
  theorem depends on.

  Design constraint (brief section 27): the conclusion must NOT be encoded into
  the definition of determinism. So `Law` is a bare predicate on total histories
  -- NOT an evolution operator, NOT a transition function. Uniqueness is
  something a law may or may not have, stated separately.

  Checked with: Lean (version 4.24.0)
-/

namespace UniqueHistory

/-! ## 1. Primitives -/

/-- A history: a total assignment of a state to every time.
    `H_{>t}` in the brief is a restriction of this. -/
abbrev History (Time State : Type) := Time → State

/-- A law. Officially: a predicate saying which total histories are physically
    possible. This is the weakest reasonable notion -- it presupposes no
    initial-value formulation, no time-evolution operator, and no direction of
    time, so "all-at-once"/global-constraint laws are in scope too. -/
structure Law (Time State : Type) where
  PossibleHistory : History Time State → Prop

/-- `Hist L t s` is the brief's `𝓗(S_t, L)`: the possible histories passing
    through state `s` at time `t`. -/
def Hist {Time State : Type} (L : Law Time State) (t : Time) (s : State) :
    History Time State → Prop :=
  fun h => L.PossibleHistory h ∧ h t = s

/-- `|X| ≤ 1`. -/
def AtMostOne {α : Type} (P : α → Prop) : Prop := ∀ a b, P a → P b → a = b

/-- `|X| = 1`: existence AND uniqueness. The brief's `∃!`. -/
def ExactlyOne {α : Type} (P : α → Prop) : Prop := ∃ a, P a ∧ ∀ b, P b → b = a

theorem exactlyOne_imp_atMostOne {α : Type} {P : α → Prop} :
    ExactlyOne P → AtMostOne P := by
  intro h a b ha hb
  cases h with
  | intro c hc =>
    cases hc with
    | intro _ hu => rw [hu a ha, hu b hb]

/-! ## 2. Determinism, stated without presupposing the conclusion -/

/-- Laplacian (Montague/Lewis-style) determinism: any two possible histories
    that agree at even one instant agree at every instant.

    Note what this does NOT say: it does not say a history exists. -/
def Deterministic {Time State : Type} (L : Law Time State) : Prop :=
  ∀ h₁ h₂, L.PossibleHistory h₁ → L.PossibleHistory h₂ → ∀ t, h₁ t = h₂ t → h₁ = h₂

/-- Forward-only determinism, over `Nat` time. -/
def FutureDeterministic {State : Type} (L : Law Nat State) : Prop :=
  ∀ h₁ h₂, L.PossibleHistory h₁ → L.PossibleHistory h₂ →
    ∀ n, h₁ n = h₂ n → ∀ m, n ≤ m → h₁ m = h₂ m

/-! ## 3. Theorem 1: determinism IS uniqueness-of-histories-through-a-state.

This is the bridge between the two ways the brief states the thesis. -/

theorem deterministic_iff_atMostOne {Time State : Type} (L : Law Time State) :
    Deterministic L ↔ ∀ t s, AtMostOne (Hist L t s) := by
  constructor
  · intro hdet t s h₁ h₂ p₁ p₂
    exact hdet h₁ h₂ p₁.1 p₂.1 t (by rw [p₁.2, p₂.2])
  · intro huniq h₁ h₂ p₁ p₂ t hagree
    exact huniq t (h₁ t) h₁ h₂ ⟨p₁, rfl⟩ ⟨p₂, hagree.symm⟩

/-! ## 4. Theorem 2: the brief's boxed claim (section 35).

    |𝓗(S_t,L)| = 1  ⟹  ¬∃ H' ≠ H with H' ∈ 𝓗(S_t,L).

The proof is three lines. That is the point: the claim is a definitional
unfolding, carrying no physical content whatever. All the content is in the
antecedent. -/

theorem no_distinct_possible_history {Time State : Type}
    {L : Law Time State} {t : Time} {s : State} {H : History Time State}
    (hone : ExactlyOne (Hist L t s)) (hH : Hist L t s H) :
    ¬ ∃ H', H' ≠ H ∧ Hist L t s H' := by
  intro hex
  cases hex with
  | intro H' hH' =>
    cases hone with
    | intro a ha =>
      exact hH'.1 (by rw [ha.2 H' hH'.2, ha.2 H hH])

/-! ## 5. Theorem 3: `exactly one` is STRICTLY stronger than determinism.

A theory all of whose solutions blow up in finite time -- so that no total
history exists at all -- is vacuously deterministic and has `|𝓗| = 0`.
So `Deterministic` gives `|𝓗| ≤ 1`, never `|𝓗| = 1`. Uniqueness without
existence is not "one possible future"; it is *no* possible future. -/

def vacuousLaw (Time State : Type) : Law Time State := ⟨fun _ => False⟩

theorem vacuous_deterministic (Time State : Type) :
    Deterministic (vacuousLaw Time State) := by
  intro _ _ p₁ _ _ _; exact absurd p₁ (fun h => h)

theorem vacuous_atMostOne (Time State : Type) (t : Time) (s : State) :
    AtMostOne (Hist (vacuousLaw Time State) t s) := by
  intro _ _ p₁ _; exact absurd p₁.1 (fun h => h)

theorem vacuous_not_exactlyOne (Time State : Type) (t : Time) (s : State) :
    ¬ ExactlyOne (Hist (vacuousLaw Time State) t s) := by
  intro h; cases h with | intro _ ha => exact ha.1.1

/-! ## 6. Theorem 4: forward determinism does not give two-way determinism.

An irreversible law: two possible histories that agree from time 1 onwards but
disagree at time 0. -/

def forgetful : Law Nat Bool :=
  ⟨fun h => h = (fun _ => true) ∨ h = (fun n => if n = 0 then false else true)⟩

theorem forgetful_future : FutureDeterministic forgetful := by
  intro h₁ h₂ p₁ p₂ n hn m hm
  cases p₁ with
  | inl e₁ => cases p₂ with
    | inl e₂ => rw [e₁, e₂]
    | inr e₂ =>
      subst e₁; subst e₂
      cases n with
      | zero => simp at hn
      | succ k => simp; omega
  | inr e₁ => cases p₂ with
    | inl e₂ =>
      subst e₁; subst e₂
      cases n with
      | zero => simp at hn
      | succ k => simp; omega
    | inr e₂ => rw [e₁, e₂]

theorem forgetful_not_deterministic : ¬ Deterministic forgetful := by
  intro hdet
  have h := hdet (fun _ => true) (fun n => if n = 0 then false else true)
              (Or.inl rfl) (Or.inr rfl) 1 (by simp)
  have := congrFun h 0
  simp at this

/-! ## 7. Theorem 5: "one history" and "many histories" can both hold, at
different levels of description (the Everettian situation).

The universal history is unique; the branch-relative histories are many.
So the English question "is there only one possible history?" is not yet a
question until the level of description is fixed. -/

/-- A universal state assigns a local state to each branch label. -/
abbrev UnivState (Branch State : Type) := Branch → State

/-- Time 0: both branches undifferentiated (`false`). From time 1: branch `b`
    records outcome `b`. -/
def univ : History Nat (UnivState Bool Bool) :=
  fun n b => if n = 0 then false else b

def everettLaw : Law Nat (UnivState Bool Bool) := ⟨fun h => h = univ⟩

/-- The universal history is unique. -/
theorem everett_universal_unique :
    ExactlyOne (Hist everettLaw 0 (univ 0)) := by
  refine ⟨univ, ⟨rfl, rfl⟩, ?_⟩
  intro b hb; exact hb.1

/-- Yet the two branch-relative histories are distinct. -/
theorem everett_branches_differ :
    (fun n => univ n true) ≠ (fun n => univ n false) := by
  intro h
  have := congrFun h 1
  simp [univ] at this

/-! ## 8. Theorem 6: the step from "one history" to "one action" needs
supervenience -- and that premise is doing real work. -/

/-- If an action-ascription is a function of the physical history, then a unique
    physical history leaves no room for a different action. -/
theorem no_alternative_action {Time State Act : Type}
    {L : Law Time State} {t₀ : Time} {s : State}
    (A : History Time State → Time → Act)
    (hone : ExactlyOne (Hist L t₀ s)) :
    ∀ H H', Hist L t₀ s H → Hist L t₀ s H' → ∀ t, A H t = A H' t := by
  intro H H' hH hH' t
  have : H = H' := exactlyOne_imp_atMostOne hone H H' hH hH'
  rw [this]

/-- But if the action is NOT a function of the physical history alone -- if it
    depends on any further parameter -- then a unique physical history is
    perfectly compatible with distinct actions.

    So Conclusion 2 of the brief (section 25) does not follow from uniqueness
    alone. It requires the separate premise that action supervenes on physical
    history. That premise is substantive, and it is exactly what an interactionist
    dualist or a strong emergentist denies. -/
theorem alternative_action_without_supervenience :
    ∃ (A : History Nat Bool → Bool → Nat → Bool) (H : History Nat Bool) (t : Nat),
      A H true t ≠ A H false t := by
  refine ⟨fun _ e _ => e, (fun _ => true), 0, ?_⟩
  simp

/-! ## 9. Theorem 7: determinism is a property of a world UNDER A DESCRIPTION.

Coarse-graining the state space can manufacture determinism; refining it can
destroy it. Any determinism claim must therefore fix the individuation of
states first. (This is the abstract shape of the hole-argument problem.) -/

/-- Push a law forward along a redescription of the state space. -/
def pushforward {Time State State' : Type}
    (L : Law Time State) (r : State → State') : Law Time State' :=
  ⟨fun h' => ∃ h, L.PossibleHistory h ∧ h' = fun t => r (h t)⟩

/-- Under a description that identifies all states, EVERY law is deterministic. -/
theorem coarsening_trivializes {Time State State' : Type}
    (L : Law Time State) (r : State → State') (hsub : ∀ a b : State', a = b) :
    Deterministic (pushforward L r) := by
  intro h₁ h₂ _ _ _ _
  funext t; exact hsub (h₁ t) (h₂ t)

/-- And the same law can be indeterministic under a finer description while
    deterministic under a coarser one. -/
theorem determinism_is_description_relative :
    ∃ (L : Law Nat Bool) (r : Bool → Unit),
      ¬ Deterministic L ∧ Deterministic (pushforward L r) := by
  refine ⟨forgetful, fun _ => (), forgetful_not_deterministic, ?_⟩
  exact coarsening_trivializes forgetful (fun _ => ()) (fun a b => by
    cases a; cases b; rfl)

/-! ## 10. Theorem 8: a unique chance function does not give a unique history.

The GRW-style situation: the dynamics may fix one and only one probability
assignment over histories while leaving many histories possible. -/

def coin : Law Nat Bool :=
  ⟨fun h => h 0 = false ∧
      (h = (fun n => if n = 0 then false else true) ∨ h = (fun _ => false))⟩

/-- For ANY chance function whatsoever, non-uniqueness of the history persists. -/
theorem unique_chance_does_not_give_unique_history
    (_w : History Nat Bool → Nat) : ¬ AtMostOne (Hist coin 0 false) := by
  intro h
  have e := h (fun n => if n = 0 then false else true) (fun _ => false)
              ⟨⟨by simp, Or.inl rfl⟩, by simp⟩ ⟨⟨rfl, Or.inr rfl⟩, rfl⟩
  have := congrFun e 1
  simp at this

theorem coin_not_deterministic : ¬ Deterministic coin := by
  intro hdet
  have e := hdet (fun n => if n = 0 then false else true) (fun _ => false)
              ⟨by simp, Or.inl rfl⟩ ⟨rfl, Or.inr rfl⟩ 0 (by simp)
  have := congrFun e 1
  simp at this

/-! ## 11. Theorem 9: in DISCRETE time, step-uniqueness gives global forward
uniqueness -- by induction. (The continuous-time analogue is exactly what the
Norton dome refutes; see verification/classical_checks.py.) -/

def StepGoverned {State : Type} (F : State → State) (L : Law Nat State) : Prop :=
  ∀ h, L.PossibleHistory h → ∀ n, h (n + 1) = F (h n)

theorem step_implies_forward_agreement {State : Type}
    {F : State → State} {L : Law Nat State} (hF : StepGoverned F L)
    (h₁ h₂ : History Nat State)
    (p₁ : L.PossibleHistory h₁) (p₂ : L.PossibleHistory h₂)
    (n : Nat) (hn : h₁ n = h₂ n) :
    ∀ m, h₁ (n + m) = h₂ (n + m) := by
  intro m
  induction m with
  | zero => exact hn
  | succ k ih =>
    have e₁ : h₁ (n + k + 1) = F (h₁ (n + k)) := hF h₁ p₁ (n + k)
    have e₂ : h₂ (n + k + 1) = F (h₂ (n + k)) := hF h₂ p₂ (n + k)
    show h₁ (n + (k + 1)) = h₂ (n + (k + 1))
    rw [show n + (k + 1) = n + k + 1 from rfl, e₁, e₂, ih]

/-- `F` above is an ARBITRARY function, computable or not. Determinism is
    therefore insensitive to computability: it entails nothing about
    predictability. (P2 does not imply P4.) -/
theorem determinism_indifferent_to_computability {State : Type}
    (F : State → State) :
    StepGoverned F ⟨fun h => ∀ n, h (n + 1) = F (h n)⟩ :=
  fun _ hp n => hp n

/-! ## 12. `Alternative`, stated explicitly -/

/-- `H'` is an ALTERNATIVE to `H` given state `s` at `t` under laws `L`. -/
def Alternative {Time State : Type} (L : Law Time State) (t : Time) (s : State)
    (H H' : History Time State) : Prop :=
  Hist L t s H ∧ Hist L t s H' ∧ H ≠ H'

theorem no_alternative_iff_atMostOne {Time State : Type}
    (L : Law Time State) (t : Time) (s : State) :
    (∀ H H', ¬ Alternative L t s H H') ↔ AtMostOne (Hist L t s) := by
  constructor
  · -- This direction, and ONLY this one in the whole file, needs classical logic:
    -- refuting a difference is constructively weaker than establishing identity.
    intro hno H H' hH hH'
    exact Classical.byContradiction (fun hne => hno H H' ⟨hH, hH', hne⟩)
  · intro hone H H' halt
    exact halt.2.2 (hone H H' halt.1 halt.2.1)

/-! ## 13. Evolution operators: sufficient for determinism, not necessary.

The initial-value paradigm is one way to get uniqueness, not the only way.
A law can be a global constraint on whole histories and still be deterministic
while admitting NO step function at all. -/

/-- An evolution operator in the initial-value paradigm. -/
structure Evolution (State : Type) where
  step : State → State

def lawOfEvolution {State : Type} (E : Evolution State) : Law Nat State :=
  ⟨fun h => ∀ n, h (n + 1) = E.step (h n)⟩

/-- Having an evolution operator SUFFICES for forward determinism. -/
theorem evolution_gives_future_determinism {State : Type} (E : Evolution State) :
    FutureDeterministic (lawOfEvolution E) := by
  intro h₁ h₂ p₁ p₂ n hn m hm
  cases Nat.le.dest hm with
  | intro k hk =>
    have hstep : StepGoverned E.step (lawOfEvolution E) := fun _ hp n => hp n
    have := step_implies_forward_agreement hstep h₁ h₂ p₁ p₂ n hn k
    rw [← hk]; exact this

/-- A history with period 3 in a two-state space. -/
def period3 : History Nat Bool := fun n => if n % 3 = 2 then false else true

/-- The law "the history is exactly `period3`" -- a global constraint on whole
    histories, not a rule for stepping forward. -/
def globalLaw : Law Nat Bool := ⟨fun h => h = period3⟩

theorem globalLaw_deterministic : Deterministic globalLaw := by
  intro h₁ h₂ p₁ p₂ _ _; rw [p₁, p₂]

/-- ...and it is deterministic in the strongest sense: exactly one history. -/
theorem globalLaw_exactlyOne : ExactlyOne (Hist globalLaw 0 (period3 0)) := by
  refine ⟨period3, ⟨rfl, rfl⟩, ?_⟩
  intro b hb; exact hb.1

/-- Yet NO evolution operator generates it: the instantaneous state does not
    carry enough information to fix its own successor. Determinism therefore
    does not presuppose the initial-value formulation. -/
theorem globalLaw_has_no_evolution : ¬ ∃ F : Bool → Bool, StepGoverned F globalLaw := by
  intro hex
  cases hex with
  | intro F hF =>
    have e0 : period3 1 = F (period3 0) := hF period3 rfl 0
    have e1 : period3 2 = F (period3 1) := hF period3 rfl 1
    have p0 : period3 0 = true := rfl
    have p1 : period3 1 = true := rfl
    have p2 : period3 2 = false := rfl
    rw [p0, p1] at e0
    rw [p1, p2] at e1
    rw [← e0] at e1
    exact Bool.noConfusion e1

/-! ## 14. Modal semantics (brief section 21).

`◇` and `□` are read relative to a fixed state and a fixed set of laws:
nomological possibility, not logical or metaphysical possibility. -/

/-- `◇`: some possible history through `s` at `t` satisfies `A`. -/
def Dia {Time State : Type} (L : Law Time State) (t : Time) (s : State)
    (A : History Time State → Prop) : Prop := ∃ h, Hist L t s h ∧ A h

/-- `□`: every possible history through `s` at `t` satisfies `A`. -/
def Box {Time State : Type} (L : Law Time State) (t : Time) (s : State)
    (A : History Time State → Prop) : Prop := ∀ h, Hist L t s h → A h

/-- Uniqueness alone collapses `◇` into `□`. -/
theorem dia_imp_box_of_atMostOne {Time State : Type}
    {L : Law Time State} {t : Time} {s : State}
    (hone : AtMostOne (Hist L t s)) (A : History Time State → Prop) :
    Dia L t s A → Box L t s A := by
  intro hd h' hh'
  cases hd with
  | intro h hh => rw [hone h' h hh' hh.1]; exact hh.2

/-- The converse needs EXISTENCE as well: with no possible history at all, `□`
    is vacuously true and `◇` is false. So the full modal collapse is exactly
    `|𝓗| = 1`, not `|𝓗| ≤ 1`. -/
theorem modal_collapse {Time State : Type}
    {L : Law Time State} {t : Time} {s : State}
    (hone : ExactlyOne (Hist L t s)) (A : History Time State → Prop) :
    Dia L t s A ↔ Box L t s A := by
  constructor
  · exact dia_imp_box_of_atMostOne (exactlyOne_imp_atMostOne hone) A
  · intro hb
    cases hone with
    | intro a ha => exact ⟨a, ha.1, hb a ha.1⟩

/-- Concretely: under `|𝓗| = 1` nothing about the future is contingent. -/
theorem nothing_contingent {Time State : Type}
    {L : Law Time State} {t : Time} {s : State}
    (hone : ExactlyOne (Hist L t s)) (A : History Time State → Prop) :
    ¬ (Dia L t s A ∧ Dia L t s (fun h => ¬ A h)) := by
  intro hc
  cases hc.2 with
  | intro h hh =>
    exact hh.2 ((modal_collapse hone A).mp hc.1 h hh.1)

/-! ## 15. Three readings of "it could have been otherwise" (brief section 22).

Determinism forecloses reading A ONLY. B and C survive untouched -- and they are
the readings on which most ordinary counterfactual talk actually runs. -/

/-- Two histories that never agree at any time. -/
def twoWorlds : Law Nat Bool :=
  ⟨fun h => h = (fun _ => true) ∨ h = (fun _ => false)⟩

theorem twoWorlds_deterministic : Deterministic twoWorlds := by
  intro h₁ h₂ p₁ p₂ t hagree
  cases p₁ with
  | inl e₁ => cases p₂ with
    | inl e₂ => rw [e₁, e₂]
    | inr e₂ => rw [e₁, e₂] at hagree; exact absurd hagree (by simp)
  | inr e₁ => cases p₂ with
    | inl e₂ => rw [e₁, e₂] at hagree; exact absurd hagree (by simp)
    | inr e₂ => rw [e₁, e₂]

/-- READING B -- different prior state, same laws -- remains possible even for a
    fully deterministic law. -/
theorem readingB_survives_determinism :
    ∃ (L : Law Nat Bool) (H H' : History Nat Bool),
      Deterministic L ∧ Hist L 0 true H ∧ Hist L 0 false H' ∧ H ≠ H' := by
  refine ⟨twoWorlds, (fun _ => true), (fun _ => false), twoWorlds_deterministic,
          ⟨Or.inl rfl, rfl⟩, ⟨Or.inr rfl, rfl⟩, ?_⟩
  intro h; exact Bool.noConfusion (congrFun h 0)

/-- READING C -- same prior state, DIFFERENT laws -- also remains possible, and
    both laws may be deterministic. -/
theorem readingC_survives_determinism :
    ∃ (L L' : Law Nat Bool) (H H' : History Nat Bool),
      Deterministic L ∧ Deterministic L' ∧
      Hist L 0 false H ∧ Hist L' 0 false H' ∧ H ≠ H' := by
  refine ⟨⟨fun h => h = (fun _ => false)⟩,
          ⟨fun h => h = (fun n => if n = 0 then false else true)⟩,
          (fun _ => false), (fun n => if n = 0 then false else true),
          ?_, ?_, ⟨rfl, rfl⟩, ⟨rfl, rfl⟩, ?_⟩
  · intro h₁ h₂ p₁ p₂ _ _; rw [p₁, p₂]
  · intro h₁ h₂ p₁ p₂ _ _; rw [p₁, p₂]
  · intro h; exact Bool.noConfusion (congrFun h 1)

end UniqueHistory

/-! ## Axiom audit -/
open UniqueHistory
#print axioms exactlyOne_imp_atMostOne
#print axioms deterministic_iff_atMostOne
#print axioms no_distinct_possible_history
#print axioms vacuous_deterministic
#print axioms vacuous_not_exactlyOne
#print axioms forgetful_future
#print axioms forgetful_not_deterministic
#print axioms everett_universal_unique
#print axioms everett_branches_differ
#print axioms no_alternative_action
#print axioms alternative_action_without_supervenience
#print axioms coarsening_trivializes
#print axioms determinism_is_description_relative
#print axioms unique_chance_does_not_give_unique_history
#print axioms coin_not_deterministic
#print axioms step_implies_forward_agreement
#print axioms determinism_indifferent_to_computability
#print axioms no_alternative_iff_atMostOne
#print axioms evolution_gives_future_determinism
#print axioms globalLaw_exactlyOne
#print axioms globalLaw_has_no_evolution
#print axioms dia_imp_box_of_atMostOne
#print axioms modal_collapse
#print axioms nothing_contingent
#print axioms twoWorlds_deterministic
#print axioms readingB_survives_determinism
#print axioms readingC_survives_determinism
