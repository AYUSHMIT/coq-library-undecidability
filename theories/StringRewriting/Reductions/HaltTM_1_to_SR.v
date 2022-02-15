Require Import Undecidability.Synthetic.Definitions Undecidability.Synthetic.ReducibilityFacts.

Require Import Undecidability.TM.TM.
Require Import Undecidability.TM.SBTM.
Require Import Undecidability.StringRewriting.SR.

Require Undecidability.TM.Reductions.HaltTM_1_to_SBTM2_HALT.
Require Undecidability.StringRewriting.Reductions.SBTM2_HALT_to_SR.

(* Many-one reduction from Turing machine halting to string rewriting *)
Theorem reduction : HaltTM 1 ⪯ SR.
Proof.
  apply (reduces_transitive HaltTM_1_to_SBTM2_HALT.reduction).
  exact SBTM2_HALT_to_SR.reduction.
Qed.
