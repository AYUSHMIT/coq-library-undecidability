Require Export List Undecidability.Shared.Dec.
Export List.ListNotations.
Require Import Setoid Morphisms Lia.

Module ListAutomationNotations.

  Notation "x 'el' L" := (In x L) (at level 70).
  Notation "A '<<=' B" := (incl A B) (at level 70).
  Notation "( A × B × .. × C )" := (list_prod .. (list_prod A B) .. C) (at level 0, left associativity).
  Notation "[ s | p ∈ A ]" := (map (fun p => s) A) (p pattern).

End ListAutomationNotations.

Import ListAutomationNotations.

Ltac in_app n :=
  (match goal with
  | [ |- In _ (_ ++ _) ] => 
    match n with
    | 0 => idtac
    | 1 => eapply in_app_iff; left
    | S ?n => eapply in_app_iff; right; in_app n
    end
  | [ |- In _ (_ :: _) ] => match n with 0 => idtac | 1 => left | S ?n => right; in_app n end
  end) || (repeat (try right; eapply in_app_iff; right)).

Ltac in_collect a :=
  eapply in_map_iff; exists a; split; [ eauto | match goal with [ |- In _ (filter _ _) ] =>  eapply filter_In; split; [ try (rewrite !in_prod_iff; repeat split) | eapply Dec_auto; repeat split; eauto ] | _ => try (rewrite !in_prod_iff; repeat split) end ].

Local Set Implicit Arguments.
Local Unset Strict Implicit.

Module ListAutomationFacts.

Lemma app_incl_l X (A B C : list X) : A ++ B <<= C -> A <<= C.
Proof. now intros [? ?]%incl_app_inv. Qed.

Lemma app_incl_R X (A B C : list X) : A ++ B <<= C -> B <<= C.
Proof. now intros [? ?]%incl_app_inv. Qed.

Lemma cons_incl X (a : X) (A B : list X) : a :: A <<= B -> A <<= B.
Proof. now intros [_ ?]%incl_cons_inv. Qed.

Lemma incl_sing X (a : X) A : a el A -> [a] <<= A.
Proof. now intros ? ? [-> | [] ]. Qed.

End ListAutomationFacts.
Import ListAutomationFacts.

Module ListAutomationHints.

#[export] Hint Extern 4 =>
  match goal with
  |[ H: In _ nil |- _ ] => destruct H
  end : core.

#[export] Hint Extern 4 =>
  match goal with
  |[ H: False |- _ ] => destruct H
  end : core.

#[export] Hint Rewrite <- app_assoc : list.
#[export] Hint Rewrite rev_app_distr map_app prod_length : list.
#[export] Hint Resolve in_eq in_nil in_cons in_or_app : core.
#[export] Hint Resolve incl_refl incl_tl incl_cons incl_appl incl_appr incl_app incl_nil_l : core.
#[export] Hint Resolve app_incl_l app_incl_R cons_incl incl_sing : core.

End ListAutomationHints.

Module ListAutomationInstances.
#[export] Instance incl_preorder X : 
  PreOrder (@incl X).
Proof. constructor; hnf; [apply incl_refl|apply incl_tran]. Qed.

#[export] Instance cons_incl_proper X x : 
  Proper (@incl X ==> @incl X) (@cons X x).
Proof. intros l1 l2 H. auto using incl_cons, in_eq, incl_tl. Qed.

#[export] Instance in_incl_proper X x : 
  Proper (@incl X ==> Basics.impl) (@In X x).
Proof. intros A B D ?. now apply D. Qed.
End ListAutomationInstances.
