(**************************************************************)
(*   Copyright Dominique Larchey-Wendling [*]                 *)
(*                                                            *)
(*                             [*] Affiliation LORIA -- CNRS  *)
(**************************************************************)
(*      This file is distributed under the terms of the       *)
(*         CeCILL v2 FREE SOFTWARE LICENSE AGREEMENT          *)
(**************************************************************)

Require Import List Permutation.

Set Implicit Arguments.

(* Small inversion lemma *)

Fact app_eq_single_inv X (l m : list X) x :
       l++m = x::nil 
    -> l = nil /\ m = x::nil 
    \/ l = x::nil /\ m = nil.
Proof.
  intros H.
  destruct l as [ | y l ]; auto.
  right.
  inversion H.
  destruct l; destruct m; auto; discriminate.
Qed.

Tactic Notation "app" "inv" "singleton" "in" hyp(H) :=
  apply app_eq_single_inv in H as [ (-> & ->) | (-> & ->) ].

Tactic Notation "app" "inv" "nil" "in" hyp(H) :=
  apply app_eq_nil in H as (-> & ->).

(** * Classical Linear Logic vs Intuitionnisitc Linear Logic 

       derived from the work of H. Schellinx JLC 91 *)

Local Infix "~p" := (@Permutation _) (at level 70).

Definition cll_vars := nat.

Inductive cll_conn := cll_with | cll_plus | cll_limp | cll_times | cll_par.
Inductive cll_cst := cll_1 | cll_0 | cll_bot | cll_top.
Inductive cll_mod := cll_bang | cll_qmark.

Inductive cll_form : Set :=
  | cll_var  : cll_vars -> cll_form
  | cll_zero : cll_cst  -> cll_form
  | cll_una  : cll_mod -> cll_form -> cll_form
  | cll_bin  : cll_conn -> cll_form -> cll_form -> cll_form.

Fixpoint cll_contains_bz f :=
  match f with
    | cll_var _     => False
    | cll_zero x    => x = cll_bot \/ x = cll_0
    | cll_una _ f   => cll_contains_bz f
    | cll_bin _ f g => cll_contains_bz f \/ cll_contains_bz g
  end.

Fixpoint cll_contains_bzqp f :=
  match f with
    | cll_var _     => False
    | cll_zero x    => x = cll_bot \/ x = cll_0
    | cll_una x f   => x = cll_qmark \/ cll_contains_bzqp f
    | cll_bin x f g => x = cll_par \/ cll_contains_bzqp f \/ cll_contains_bzqp g
  end.

Fact cll_contains_bz_bzqp f : cll_contains_bz f -> cll_contains_bzqp f.
Proof. induction f; simpl; tauto. Qed.

(* Symbols for cut&paste ⟙   ⟘   𝝐  ﹠ ⊗  ⊕  ⊸  ❗   ‼  ∅  ⊢ *)

Notation "⟙" := (cll_zero cll_top).
Notation "⟘" := (cll_zero cll_bot).
Notation "𝟘" := (cll_zero cll_0).
Notation "𝟙" := (cll_zero cll_1).

Infix "&" := (cll_bin cll_with) (at level 50, only parsing).
Infix "﹠" := (cll_bin cll_with) (at level 50).
Infix "⅋" := (cll_bin cll_par) (at level 50).
Infix "⊗" := (cll_bin cll_times) (at level 50).
Infix "⊕" := (cll_bin cll_plus) (at level 50).
Infix "⊸" := (cll_bin cll_limp) (at level 51, right associativity).

Notation "'!' x" := (cll_una cll_bang x) (at level 52).
Notation "'？' x" := (cll_una cll_qmark x) (at level 52).

Notation "£" := cll_var.

Definition cll_lbang := map (fun x => !x).
Definition cll_lqmrk := map (fun x => ？x).

Notation "‼ x" := (cll_lbang x) (at level 60).
Notation "⁇ x" := (cll_lqmrk x) (at level 60).

Notation "∅" := nil (only parsing).

Reserved Notation "l '⊢i' x" (at level 70, no associativity).
Reserved Notation "l '⊢c' x" (at level 70, no associativity).

Inductive S_ill : list cll_form -> cll_form -> Prop :=

  | in_ill_ax    : forall A,                         A::∅ ⊢i A

(*
  | in_ill_cut   : forall Γ Δ A B,              Γ ⊢i A    ->   A::Δ ⊢i B
                                           (*-----------------------------*)    
                                      ->              Γ++Δ ⊢i B
*)

  | in_ill_perm  : forall Γ Δ A,              Γ ~p Δ     ->   Γ ⊢i A 
                                           (*-----------------------------*)
                                      ->                 Δ ⊢i A

  | in_ill_limp_l : forall Γ Δ A B C,         Γ ⊢i A      ->   B::Δ ⊢i C
                                           (*-----------------------------*)    
                                      ->           A ⊸ B::Γ++Δ ⊢i C

  | in_ill_limp_r : forall Γ A B,                   A::Γ ⊢i B
                                           (*-----------------------------*)
                                      ->            Γ ⊢i A ⊸ B

  | in_ill_with_l1 : forall Γ A B C,                  A::Γ ⊢i C 
                                           (*-----------------------------*)
                                      ->           A﹠B::Γ ⊢i C

  | in_ill_with_l2 : forall Γ A B C,                  B::Γ ⊢i C 
                                           (*-----------------------------*)
                                      ->           A﹠B::Γ ⊢i C
 
  | in_ill_with_r : forall Γ A B,               Γ ⊢i A     ->   Γ ⊢i B
                                           (*-----------------------------*)
                                      ->              Γ ⊢i A﹠B

  | in_ill_bang_l : forall Γ A B,                    A::Γ ⊢i B
                                           (*-----------------------------*)
                                      ->            !A::Γ ⊢i B

  | in_ill_bang_r : forall Γ A,                       ‼Γ ⊢i A
                                           (*-----------------------------*)
                                      ->              ‼Γ ⊢i !A

  | in_ill_weak : forall Γ A B,                        Γ ⊢i B
                                           (*-----------------------------*)
                                      ->           !A::Γ ⊢i B

  | in_ill_cntr : forall Γ A B,                    !A::!A::Γ ⊢i B
                                           (*-----------------------------*)
                                      ->             !A::Γ ⊢i B


  | in_ill_times_l : forall Γ A B C,               A::B::Γ ⊢i C 
                                           (*-----------------------------*)
                                      ->            A⊗B::Γ ⊢i C
 
  | in_ill_times_r : forall Γ Δ A B,             Γ ⊢i A    ->   Δ ⊢i B
                                           (*-----------------------------*)
                                      ->              Γ++Δ ⊢i A⊗B

  | in_ill_plus_l :  forall Γ A B C,            A::Γ ⊢i C  ->  B::Γ ⊢i C 
                                           (*-----------------------------*)
                                      ->            A⊕B::Γ ⊢i C

  | in_ill_plus_r1 : forall Γ A B,                    Γ ⊢i A  
                                           (*-----------------------------*)
                                      ->              Γ ⊢i A⊕B

  | in_ill_plus_r2 : forall Γ A B,                    Γ ⊢i B  
                                           (*-----------------------------*)
                                      ->              Γ ⊢i A⊕B

(*
  | in_ill_bot_l : forall Γ A,                     ⟘::Γ ⊢i A
*)

  | in_ill_top_r : forall Γ,                          Γ ⊢i ⟙

  | in_ill_unit_l : forall Γ A,                       Γ ⊢i A  
                                           (*-----------------------------*)
                                      ->           𝟙::Γ ⊢i A

  | in_ill_unit_r :                                   ∅ ⊢i 𝟙

where "l ⊢i x" := (S_ill l x).

Inductive S_cll : list cll_form -> list cll_form -> Prop :=

  | in_cll_ax    : forall A,                         A::∅ ⊢c A::∅

(*
  | in_cll_cut   : forall Γ Δ Γ' Δ' A,          Γ ⊢c A::Δ    ->   A::Γ' ⊢c Δ'
                                           (*-----------------------------*)    
                                      ->              Γ++Γ' ⊢c Δ++Δ'
*)

  | in_cll_perm  : forall Γ Δ Γ' Δ',        Γ ~p Γ' -> Δ ~p Δ' ->   Γ ⊢c Δ 
                                           (*-----------------------------*)
                                      ->                 Γ' ⊢c Δ'

  | in_cll_limp_l : forall Γ Δ Γ' Δ' A B,     Γ ⊢c A::Δ      ->   B::Γ' ⊢c Δ'
                                           (*-----------------------------*)    
                                      ->           A ⊸ B::Γ++Γ' ⊢c Δ++Δ'

  | in_cll_limp_r : forall Γ Δ A B,                 A::Γ ⊢c B::Δ
                                           (*-----------------------------*)
                                      ->            Γ ⊢c A ⊸ B::Δ

  | in_cll_with_l1 : forall Γ Δ A B,                  A::Γ ⊢c Δ 
                                           (*-----------------------------*)
                                      ->           A﹠B::Γ ⊢c Δ

  | in_cll_with_l2 : forall Γ Δ A B,                  B::Γ ⊢c Δ 
                                           (*-----------------------------*)
                                      ->           A﹠B::Γ ⊢c Δ
 
  | in_cll_with_r : forall Γ Δ A B,               Γ ⊢c A::Δ     ->   Γ ⊢c B::Δ
                                           (*-----------------------------*)
                                      ->              Γ ⊢c A﹠B::Δ

  | in_cll_times_l : forall Γ A B Δ,               A::B::Γ ⊢c Δ 
                                           (*-----------------------------*)
                                      ->            A⊗B::Γ ⊢c Δ
 
  | in_cll_times_r : forall Γ Δ Γ' Δ' A B,             Γ ⊢c A::Δ    ->   Γ' ⊢c B::Δ'
                                           (*-----------------------------*)
                                      ->              Γ++Γ' ⊢c A⊗B::Δ++Δ'

(*
  | in_cll_par_l : forall Γ Δ Γ' Δ' A B,             A::Γ ⊢c Δ    ->   B::Γ' ⊢c Δ'
                                           (*-----------------------------*)
                                      ->             A⅋B::Γ++Γ' ⊢c Δ++Δ'

  | in_cll_par_r : forall Γ A B Δ,                     Γ ⊢c A::B::Δ 
                                           (*-----------------------------*)
                                      ->               Γ ⊢c A⅋B::Δ
*)

  | in_cll_plus_l :  forall Γ A B Δ,            A::Γ ⊢c Δ  ->  B::Γ ⊢c Δ 
                                           (*-----------------------------*)
                                      ->            A⊕B::Γ ⊢c Δ

  | in_cll_plus_r1 : forall Γ A B Δ,                    Γ ⊢c A::Δ  
                                           (*-----------------------------*)
                                      ->              Γ ⊢c A⊕B::Δ

  | in_cll_plus_r2 : forall Γ A B Δ,                    Γ ⊢c B::Δ  
                                           (*-----------------------------*)
                                      ->              Γ ⊢c A⊕B::Δ

(*
  | in_cll_bot_l : forall Γ Δ,                     ⟘::Γ ⊢c Δ
*)

  | in_cll_top_r : forall Γ Δ,                        Γ ⊢c ⟙::Δ

  | in_cll_unit_l : forall Γ Δ,                       Γ ⊢c Δ  
                                           (*-----------------------------*)
                                      ->           𝟙::Γ ⊢c Δ

  | in_cll_unit_r :                                   ∅ ⊢c 𝟙::∅

(*
  | in_cll_zero_l :                        (*-----------------------------*)
                                             (* *)      𝟘::∅ ⊢c ∅

  | in_cll_zero_r : forall Γ Δ,                       Γ ⊢c Δ  
                                           (*-----------------------------*)
                                      ->              Γ ⊢c 𝟘::Δ
*)


  | in_cll_bang_l : forall Γ A Δ,                    A::Γ ⊢c Δ
                                           (*-----------------------------*)
                                      ->            !A::Γ ⊢c Δ

  | in_cll_bang_r : forall Γ A Δ,                     ‼Γ ⊢c A::⁇Δ
                                           (*-----------------------------*)
                                      ->              ‼Γ ⊢c !A::⁇Δ

(*
  | in_cll_qmrk_l : forall Γ A Δ,                     A::‼Γ ⊢c ⁇Δ
                                           (*-----------------------------*)
                                      ->              ？A::‼Γ ⊢c ⁇Δ

  | in_cll_qmrk_r : forall Γ A Δ,                    Γ ⊢c A::Δ
                                           (*-----------------------------*)
                                      ->             Γ ⊢c ？A::Δ
*)

  | in_cll_weak_l : forall Γ A Δ,                        Γ ⊢c Δ
                                             (*-----------------------------*)
                                        ->           !A::Γ ⊢c Δ

  | in_cll_weak_r : forall Γ A Δ,                        Γ ⊢c Δ
                                             (*-----------------------------*)
                                        ->               Γ ⊢c ？A::Δ

  | in_cll_cntr_l : forall Γ A Δ,                    !A::!A::Γ ⊢c Δ
                                           (*-----------------------------*)
                                      ->             !A::Γ ⊢c Δ

  | in_cll_cntr_r : forall Γ A Δ,                    Γ ⊢c ？A::？A::Δ
                                           (*-----------------------------*)
                                      ->             Γ ⊢c ？A::Δ

where "Γ ⊢c Δ" := (S_cll Γ Δ).

Theorem ill_cll Γ A : Γ ⊢i A -> Γ ⊢c A::∅.
Proof.
  induction 1.
  + apply in_cll_ax.
  + now apply (@in_cll_perm Γ (A::nil)).
  + now apply in_cll_limp_l with (Δ := ∅) (Δ' := _::_).
  + now apply in_cll_limp_r with (Δ := ∅).
  + now apply in_cll_with_l1.
  + now apply in_cll_with_l2.
  + now apply in_cll_with_r with (Δ := ∅).
  + now apply in_cll_bang_l.
  + now apply in_cll_bang_r with (Δ := ∅).
  + now apply in_cll_weak_l.
  + now apply in_cll_cntr_l.
  + now apply in_cll_times_l.
  + now apply in_cll_times_r with (Δ := ∅) (Δ' := ∅).
  + now apply in_cll_plus_l.
  + now apply in_cll_plus_r1.
  + now apply in_cll_plus_r2.
(*  + apply in_cll_bot_l. *)
  + apply in_cll_top_r.
  + now apply in_cll_unit_l.
  + apply in_cll_unit_r.
Qed.

Section cll_ill_empty.

Let cll_ill_empty_rec Γ Δ : Γ ⊢c Δ -> Δ <> ∅.
  Proof.
  induction 1 as [ A                                                        (* ax *)
                 | Γ Δ Γ' Δ' H1 H2 H3 IH3                                   (* perm *)
                 | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2 | Γ Δ A B H1 IH1             (* -o *)
                 | Γ Δ A B H1 IH1 | Γ Δ A B H1 IH1 | Γ Δ A B H1 IH1 H2 IH2  (* & *)
                 | Γ A B Δ H1 IH1 | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2             (* * *)
               (* | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2 | Γ A B Δ H1 IH1  *)           (* par *)
                 | Γ A B Δ H1 IH1 H2 IH2 | Γ A B Δ H1 IH1 | Γ A B Δ H1 IH1  (* + *)
               (*  | *) |                                                        (* bot, top *)
                 | Γ Δ H1 IH1 |                                             (* unit *)
               (*  | |  *)                                                       (* zero *) 
                 | Γ A Δ H1 IH1 | Γ A Δ H1 IH1                              (* bang *)
               (*  | Γ A Δ H1 IH1 |  *)                                         (* qmrk *)
                 | Γ A Δ H1 IH1 |                                           (* weak *)
                 | Γ A Δ H1 IH1 | ]; auto; try discriminate.                (* cntr *)
  + intros ->; now apply IH3, Permutation_nil, Permutation_sym.
  + intros H; now app inv nil in H.
Qed.

Fact qmarkinv A Σ : A::nil = ⁇Σ -> exists B, A = ？B /\ Σ = B::nil.
Proof.
  intros H.
  destruct Σ as [ | B [ | ] ]; try discriminate.
  inversion H; exists B; auto.
Qed.

Tactic Notation "singleton" "qmark" "inv" "in" hyp(H) "as" ident(B) :=
  apply qmarkinv in H as (B & -> & ->). 

Let cll_ill_empty_rec' Γ Δ : Γ ⊢c Δ -> forall Σ, Δ = ⁇Σ -> exists A, Γ = ？A::nil /\ Δ = ？A::nil.
  Proof.
  induction 1 as [ A                                                        (* ax *)
                 | Γ Δ Γ' Δ' H1 H2 H3 IH3                                   (* perm *)
                 | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2 | Γ Δ A B H1 IH1             (* -o *)
                 | Γ Δ A B H1 IH1 | Γ Δ A B H1 IH1 | Γ Δ A B H1 IH1 H2 IH2  (* & *)
                 | Γ A B Δ H1 IH1 | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2             (* * *)
               (* | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2 | Γ A B Δ H1 IH1  *)           (* par *)
                 | Γ A B Δ H1 IH1 H2 IH2 | Γ A B Δ H1 IH1 | Γ A B Δ H1 IH1  (* + *)
               (*  | *) |                                                        (* bot, top *)
                 | Γ Δ H1 IH1 |                                             (* unit *)
               (*  | |  *)                                                       (* zero *) 
                 | Γ A Δ H1 IH1 | Γ A Δ H1 IH1                              (* bang *)
               (*  | Γ A Δ H1 IH1 |  *)                                         (* qmrk *)
                 | Γ A Δ H1 IH1 |                                           (* weak *)
                 | Γ A Δ H1 IH1 | ]; intros Σ HΣ; try discriminate.                (* cntr *)
  + singleton qmark inv in HΣ as B; exists B; auto.
  + subst.
    apply Permutation_map_inv in H2.
    destruct H2 as (Σ' & -> & H2).
    destruct (IH3 _ eq_refl) as (A & G1 & G2).
    symmetry in G2. apply qmarkinv in G2.
    destruct G2 as (B & HB & ->); inversion HB; subst B.
    apply Permutation_sym, Permutation_length_1_inv in H2.
    subst; apply Permutation_length_1_inv in H1; subst.
    exists A; auto.
  + symmetry in HΣ.
    apply map_eq_app in HΣ as (Σ1 & Σ2 & -> & <- & <-).
    destruct (IH2 _ eq_refl) as (C & HC1 & HC2).
    inversion HC1; subst.
    rewrite HC2 in H2.
Search map app.
    s
    Search Permutation nil.
singleton qmark inv in G2 as B.

intros ->; now apply IH3, Permutation_nil, Permutation_sym.
  + intros H; now app inv nil in H.
Qed.


(*
Let cll_ill_empty_rec Γ Δ : Γ ⊢c Δ -> Δ = ∅ -> exists f, In f Γ /\ cll_contains_bz f.
  Proof.
  induction 1 as [ A                                                        (* ax *)
                 | Γ Δ Γ' Δ' H1 H2 H3 IH3                                   (* perm *)
                 | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2 | Γ Δ A B H1 IH1             (* -o *)
                 | Γ Δ A B H1 IH1 | Γ Δ A B H1 IH1 | Γ Δ A B H1 IH1 H2 IH2  (* & *)
                 | Γ A B Δ H1 IH1 | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2             (* * *)
                 | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2 | Γ A B Δ H1 IH1             (* par *)
                 | Γ A B Δ H1 IH1 H2 IH2 | Γ A B Δ H1 IH1 | Γ A B Δ H1 IH1  (* + *)
               (*  | *) |                                                        (* bot, top *)
                 | Γ Δ H1 IH1 |                                             (* unit *)
               (*  | |  *)                                                       (* zero *) 
                 | Γ A Δ H1 IH1 | Γ A Δ H1 IH1                              (* bang *)
                 | Γ A Δ H1 IH1 |                                           (* qmrk *)
                 | Γ A Δ H1 IH1 |                                           (* weak *)
                 | Γ A Δ H1 IH1 | ].                                        (* cntr *)
  + discriminate.
  + intros ->.
    destruct IH3 as (f & G1 & G2).
    apply Permutation_sym, Permutation_nil in H2 as ->; auto.
    exists f; split; auto.
    revert G1; now apply Permutation_in.
  + intros H.
    destruct IH2 as (f & G1 & G2).
    apply app_eq_nil in H as (-> & ->); auto.
    destruct G1 as [ <- | G1 ].
    * exists (A ⊸ B); simpl; split; auto.
    * exists f; split; auto.
      right; apply in_or_app; tauto.
  + discriminate.
  + intros ->.
    destruct IH1 as (f & G1 & G2); auto.
    destruct G1 as [ <- | G1 ].
    * exists (A ﹠ B); simpl; auto.
    * exists f; simpl; auto.
  + intros ->.
    destruct IH1 as (f & G1 & G2); auto.
    destruct G1 as [ <- | G1 ].
    * exists (A ﹠ B); simpl; auto.
    * exists f; simpl; auto.
  + discriminate.
  + intros ->.
    destruct IH1 as (f & G1 & G2); auto.
    destruct G1 as [ <- | [ <- | G1 ] ].
    * exists (A ⊗ B); simpl; auto.
    * exists (A ⊗ B); simpl; auto.
    * exists f; simpl; auto.
  + discriminate.
  + destruct Δ; destruct Δ'; try discriminate; intros _.
    destruct IH1 as (f & Hf1 & Hf2); auto.
    destruct Hf1 as [ <- | Hf1 ].
    * exists (A⅋B); simpl; auto.
    * exists f; simpl; split; auto.
      rewrite in_app_iff; auto.
  + discriminate.
  + intros ->; destruct IH1 as (f & G1 & G2); auto.
    destruct G1 as [ <- | G1 ].
    * exists (A ⊕ B); simpl; auto.
    * exists f; simpl; auto.
  + discriminate.
  + discriminate.
  + exists ⟘; simpl; auto.
  + discriminate.
  + intros ->.
    destruct IH1 as (f & ? & ?); auto.
    exists f; simpl; auto.
  + discriminate.
  + exists 𝟘; simpl; auto.
  + discriminate.
  + intros ->.
    destruct IH1 as (f & G1 & G2); auto.
    destruct G1 as [ <- | G1 ].
    * exists (!A); simpl; auto.
    * exists f; simpl; auto.
  + discriminate.
  + destruct Δ; try discriminate; intros _.
    destruct IH1 as (f & G1 & G2); auto.
    destruct G1 as [ <- | G1 ].
    * exists (？ A); simpl; auto.
    * exists f; simpl; auto.
  + discriminate.
  + intros ->.
    destruct IH1 as (f & G1 & G2); auto.
    exists f; simpl; auto.
  + discriminate.
  + intros ->.
    destruct IH1 as (f & G1 & G2); auto.
    destruct G1 as [ <- | [ <- | G1 ] ].
    * exists (!A); simpl; auto.
    * exists (!A); simpl; auto.
    * exists f; simpl; auto.
  + discriminate.
Qed.
*)

Theorem cll_ill_empty Γ : ~ Γ ⊢c ∅.
Proof. intros H; now apply cll_ill_empty_rec with (1 := H). Qed.

End cll_ill_empty.

Theorem cll_ill Γ Δ  : Γ ⊢c Δ -> forall A, Δ = A::∅ -> Γ ⊢i A.
Proof.
  induction 1 as [ A                                                        (* ax *)
                 | Γ Δ Γ' Δ' H1 H2 H3 IH3                                   (* perm *)
                 | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2 | Γ Δ A B H1 IH1             (* -o *)
                 | Γ Δ A B H1 IH1 | Γ Δ A B H1 IH1 | Γ Δ A B H1 IH1 H2 IH2  (* & *)
                 | Γ A B Δ H1 IH1 | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2             (* * *)
               (*  | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2 | Γ A B Δ H1 IH1 *)             (* par *)
                 | Γ A B Δ H1 IH1 H2 IH2 | Γ A B Δ H1 IH1 | Γ A B Δ H1 IH1  (* + *)
               (*  | *) |                                                        (* bot, top *)
                 | Γ Δ H1 IH1 |                                             (* unit *)
               (*  | |  *)                                                       (* zero *) 
                 | Γ A Δ H1 IH1 | Γ A Δ H1 IH1                              (* bang *)
               (*  | Γ A Δ H1 IH1 | *)                                          (* qmrk *)
                 | Γ A Δ H1 IH1 |                                           (* weak *)
                 | Γ A Δ H1 IH1 | ]; intros C HC; try discriminate.
  + inversion HC; constructor.
  + constructor 2 with (1 := H1).
    rewrite HC in *.
    apply Permutation_sym, Permutation_length_1_inv in H2 as ->.
    apply IH3; auto.
  + app inv singleton in HC.
    * constructor; auto.
    * apply cll_ill_empty in H2 as [].
  + inversion HC; subst.
    constructor; apply IH1; auto.
  + rewrite HC in *.
    apply in_ill_with_l1, IH1; auto.
  + rewrite HC in *.
    apply in_ill_with_l2, IH1; auto.
  + inversion HC; subst; clear HC.
    constructor; auto.
  + subst; constructor; apply IH1; auto.
  + inversion HC.
    app inv nil in H3.
    subst C; constructor; auto.
  + subst; constructor; auto.
  + inversion HC; subst.
    apply in_ill_plus_r1; auto.
  + inversion HC; subst.
    apply in_ill_plus_r2; auto.
  + inversion HC; subst; constructor.
  + subst; constructor; auto.
  + inversion HC; constructor.
  + subst; constructor; auto.
  + inversion HC.
    destruct Δ; try discriminate; subst.
    constructor; apply IH1; auto.
  + subst; apply in_ill_weak; auto.
  + inversion HC; subst.
    apply cll_ill_empty in H as [].
  + subst; apply in_ill_cntr; auto.
  + inversion HC; subst.
    destruct (HS (？A)); simpl; auto.
Qed.


Theorem cll_ill Γ Δ  : Γ ⊢c Δ -> forall A, Δ = A::∅ -> (forall f, In f (A::Γ) -> ~ cll_contains_bzqp f) -> Γ ⊢i A.
Proof.
  induction 1 as [ A 
                 | Γ Δ Γ' Δ' H1 H2 H3 IH3 
                 | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2 | Γ Δ A B H1 IH1 
                 | Γ Δ A B H1 IH1 | Γ Δ A B H1 IH1 | Γ Δ A B H1 IH1 H2 IH2
                 | Γ A B Δ H1 IH1 | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2
                 | Γ Δ Γ' Δ' A B H1 IH1 H2 IH2 | Γ A B Δ H1 IH1
                 | Γ A B Δ H1 IH1 H2 IH2 | Γ A B Δ H1 IH1 | Γ A B Δ H1 IH1
                 | | 
                 | Γ Δ H1 IH1 | 
                 | | 
                 | Γ A Δ H1 IH1 | Γ A Δ H1 IH1 
                 | Γ A Δ H1 IH1 | | Γ A Δ H1 IH1 | | Γ A Δ H1 IH1 | ]; intros C HC HS; try discriminate.
  + inversion HC; constructor.
  + constructor 2 with (1 := H1).
    rewrite HC in *.
    apply Permutation_sym, Permutation_length_1_inv in H2 as ->.
    apply IH3; auto.
    intros f Hf; apply HS.
    destruct Hf as [ <- | Hf ]; [ left | right ]; auto.
    revert Hf; now apply Permutation_in.
  + app inv singleton in HC.
    * constructor.
      - apply IH1; auto.
        intros f Hf1 Hf2.
        destruct Hf1 as [ <- | Hf1 ].
        ++ apply HS with (f := A ⊸ B); simpl; auto.
        ++ apply (HS f); simpl; auto; do 2 right.
           apply in_or_app; auto. 
      - apply IH2; auto.
        intros f Hf1 Hf2.
        destruct Hf1 as [ <- | [ <- | Hf1 ] ].
        ++ apply (HS C); simpl; auto.
        ++ apply (HS (A ⊸ B)); simpl; auto.
        ++ apply (HS f); simpl; auto; do 2 right.
           apply in_or_app; auto.
    * apply cll_ill_empty in H2 as (f & Hf1 & Hf2).
      destruct Hf1 as [ <- | Hf1 ].
      - destruct (HS (A ⊸ B)); simpl; auto; do 2 right.
        apply cll_contains_bz_bzqp; auto.
      - apply cll_contains_bz_bzqp in Hf2.
        destruct HS with (2 := Hf2).
        do 2 right; apply in_or_app; auto.
  + inversion HC; subst.
    constructor; apply IH1; auto.
    intros f [ <- | [ <- | Hf1 ] ] Hf2.
    * apply (HS (A ⊸ B)); simpl; auto.
    * apply (HS (A ⊸ B)); simpl; auto.
    * revert Hf2; apply HS; simpl; auto.
  + rewrite HC in *.
    apply in_ill_with_l1, IH1; auto.
    intros f [ <- | [ <- | Hf1 ] ] Hf2.
    * apply (HS C); simpl; auto.
    * apply (HS (A & B)); simpl; auto.
    * revert Hf2; apply HS; simpl; auto.
  + rewrite HC in *.
    apply in_ill_with_l2, IH1; auto.
    intros f [ <- | [ <- | Hf1 ] ] Hf2.
    * apply (HS C); simpl; auto.
    * apply (HS (A & B)); simpl; auto.
    * revert Hf2; apply HS; simpl; auto.
  + inversion HC; subst; clear HC.
    constructor.
    * apply IH1; auto.
      intros f [ <- | Hf1 ] Hf2.
      - apply (HS (A & B)); simpl; auto.
      - revert Hf2; apply HS; simpl; auto.
    * apply IH2; auto.
      intros f [ <- | Hf1 ] Hf2.
      - apply (HS (A & B)); simpl; auto.
      - revert Hf2; apply HS; simpl; auto.
  + subst; constructor; apply IH1; auto.
    intros f [ <- | [ <- | [ <- | Hf1 ] ] ] Hf2.
    * apply (HS C); simpl; auto.
    * apply (HS (A ⊗ B)); simpl; auto.
    * apply (HS (A ⊗ B)); simpl; auto.
    * revert Hf2; apply HS; simpl; auto.
  + inversion HC.
    destruct Δ; destruct Δ'; try discriminate.
    subst C.
    constructor.
    * apply IH1; auto.
      intros f [ <- | Hf1 ] Hf2.
      - apply (HS (A ⊗ B)); simpl; auto.
      - revert Hf2; apply HS; right; apply in_or_app; simpl; auto.
    * apply IH2; auto.
      intros f [ <- | Hf1 ] Hf2.
      - apply (HS (A ⊗ B)); simpl; auto.
      - revert Hf2; apply HS; right; apply in_or_app; simpl; auto.
  + destruct (HS (A ⅋ B)); simpl; auto.
  + inversion HC; subst.
    destruct (HS (A ⅋ B)); simpl; auto.
  + subst; constructor.
    * apply IH1; auto.
      intros f [ <- | [ <- | Hf1 ] ] Hf2.
      - apply (HS C); simpl; auto.
      - apply (HS (A ⊕ B)); simpl; auto.
      - revert Hf2; apply HS; simpl; auto.
    * apply IH2; auto.
      intros f [ <- | [ <- | Hf1 ] ] Hf2.
      - apply (HS C); simpl; auto.
      - apply (HS (A ⊕ B)); simpl; auto.
      - revert Hf2; apply HS; simpl; auto.
  + inversion HC; subst.
    apply in_ill_plus_r1, IH1; auto.
    intros f [ <- | Hf1 ] Hf2.
    * apply (HS (A ⊕ B)); simpl; auto.
    * revert Hf2; apply HS; simpl; auto.
  + inversion HC; subst.
    apply in_ill_plus_r2, IH1; auto.
    intros f [ <- | Hf1 ] Hf2.
    * apply (HS (A ⊕ B)); simpl; auto.
    * revert Hf2; apply HS; simpl; auto.
  + constructor.
  + inversion HC; subst; clear HC.
    constructor.
  + subst.
    constructor; apply IH1; auto.
    intros f [ <- | Hf1 ] Hf2.
    * apply (HS C); simpl; auto.
    * revert Hf2; apply HS; simpl; auto.
  + inversion HC; constructor.
  + inversion HC; subst; clear HC.
    destruct (HS 𝟘); simpl; auto.
  + subst; constructor.
    apply IH1; auto.
    intros f [ <- | [ <- | Hf1 ] ] Hf2.
    * apply (HS C); simpl; auto.
    * apply (HS (!A)); simpl; auto.
    * revert Hf2; apply HS; simpl; auto.
  + inversion HC.
    destruct Δ; try discriminate; subst.
    constructor; apply IH1; auto.
    intros f [ <- | Hf1 ] Hf2.
    * apply (HS (!A)); simpl; auto.
    * revert Hf2; apply HS; simpl; auto.
  + destruct (HS (？A)); simpl; auto.
  + inversion HC; subst.
    destruct (HS (？A)); simpl; auto.
  + subst.
    apply in_ill_weak, IH1; auto.
    intros f [ <- | Hf1 ] Hf2.
    * apply (HS C); simpl; auto.
    * revert Hf2; apply HS; simpl; auto.
  + inversion HC; subst.
    destruct (HS (？A)); simpl; auto.
  + subst.
    apply in_ill_cntr, IH1; auto.
    intros f [ <- | [ <- | [ <- | Hf1 ] ] ] Hf2.
    * apply (HS C); simpl; auto.
    * apply (HS (!A)); simpl; auto.
    * apply (HS (!A)); simpl; auto.
    * revert Hf2; apply HS; simpl; auto.
  + inversion HC; subst.
    destruct (HS (？A)); simpl; auto.
Qed.

(* If the sequent Γ ⊢ A does not contain either ? or ⟘ or 0 or ⅋ 
   then it is provable in ILL iff it is provable in CLL 

   Notice that ?, ⅋ and 0 are not part of ILL syntax anyway.

   So when an ILL sequent does not contain ⟘, then CLL
   (cut-free) provability and ILL (cut-free) provability
   match on it 
*)

Theorem cll_ill_equiv Γ A  : 
          (forall f, In f (A::Γ) -> ~ cll_contains_bzqp f) 
       -> Γ ⊢i A <-> Γ ⊢c A::∅.
Proof.
  intros H; split.
  + apply ill_cll.
  + intros H1. 
    apply cll_ill with (1 := H1); auto.
Qed.
