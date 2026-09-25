# Digest: Hinton, Vinyals, Dean, 2015 — Distilling the Knowledge in a Neural Network

A real output of the `digest` skill on a PDF source, built on the open preprint
arXiv:1503.02531 (the PDF itself is not shipped with this kit; download it from
arXiv to reproduce the check). The anchor table was checked by re-reading the pages;
at the end, `digest` formatted the reference and the BibTeX itself.

**Biblio:** Hinton, G., Vinyals, O., & Dean, J. (2015). Distilling the Knowledge in
a Neural Network. arXiv:1503.02531 [stat.ML]. https://arxiv.org/abs/1503.02531
**Pages read:** 1–5, 8–9  ·  **Date:** 2026-07-15

## The gist in one line
Training a small model on the "soft" probabilities of a large model or an ensemble
("distillation") carries almost all of their quality over into a compact model that
is easy to deploy.

## Problem and gap
Ensembles and very large networks give the best predictions but are expensive and
cumbersome at inference time, especially when deployed to many users (p. 1). Earlier,
Caruana and colleagues showed that an ensemble's knowledge can be transferred into a
single small model (p. 1); the authors develop this technique through distillation
with a softmax temperature.

## Method
A softmax with temperature `T` gives a "softer" distribution over classes (Eq. 1,
p. 2). Distillation: raise `T` in the large model, obtain soft targets and train the
small model on them at the same high `T`; when the true labels are known, use a
weighted sum of two cross-entropies (against the soft and the hard targets), with the
gradients multiplied by `T²` to keep them balanced (p. 3). Matching logits is a
special case of distillation in the high-temperature limit (§2.1, p. 3).

## Data / material
- MNIST: the large network has 2 hidden layers of 1200 ReLUs, trained on all 60,000
  examples (p. 3).
- Speech (ASR): an architecture of 8 hidden layers of 2560 ReLUs, 14,000 labels, ~85M
  parameters; ~2000 hours of speech, ~700M training examples (p. 4).
- JFT (an internal Google dataset): 100 million images, 15,000 labels (p. 5).

## Results
- MNIST: the large network makes 67 errors; the small one without regularization
  makes 146; the same small one with the added task of matching the soft targets
  (T = 20) makes 74 errors (p. 4).
- MNIST, transfer of generalization: even without a single example of the digit 3 in
  the training set, the distilled model makes only 206 errors (p. 4).
- Speech: the baseline DNN has a frame accuracy of 58.9 % and a WER of 10.9 % (p. 4);
  the distilled single model (60.8 % / 10.7 %) almost matches the ensemble of 10
  models (61.1 % / 10.7 %), Table 1 (p. 5); more than 80 % of the ensemble's accuracy
  gain is transferred (p. 5).

## Contribution and conclusions
The authors claim that distillation transfers knowledge well from an ensemble or from
a large regularized model into a compact one (p. 8), and they introduce ensembles of
specialist models for very large label sets, which train fast and in parallel (p. 1).

## Limitations
The authors state directly that transferring the specialists' knowledge back into a
single large network has not been shown yet (p. 8).

## Claims anchored to the source (checked)

| Claim | p. N | Verbatim quote | Section | Checked |
|---|---|---|---|---|
| Distillation transfers knowledge from a cumbersome model into a small, deployable one | 1 | “we can then use a different kind of training, which we call "distillation" to transfer the knowledge from the cumbersome model to a small model that is more suitable for deployment” | Introduction | ✓ |
| Method: raise the temperature of the final softmax to get "soft" targets | 2 | “Our more general solution, called "distillation", is to raise the temperature of the final softmax until the cumbersome model produces a suitably soft set of targets” | Introduction | ✓ |
| Soft targets carry more information per example → less data, a higher learning rate | 2 | “the soft targets have high entropy, they provide much more information per training case than hard targets … so the small model can often be trained on much less data … and using a much higher learning rate” | Introduction | ✓ |
| MNIST data: the large network has 2 layers of 1200 ReLUs on all 60,000 examples | 3 | “we trained a single large neural net with two hidden layers of 1200 rectified linear hidden units on all 60,000 training cases” | 3 Preliminary experiments on MNIST | ✓ |
| MNIST: the small network without regularization makes 146 errors, the large one 67 | 4 | “This net achieved 67 test errors whereas a smaller net with two hidden layers of 800 rectified linear hidden units and no regularization achieved 146 errors” | 3 Preliminary experiments on MNIST | ✓ |
| MNIST: with the soft-target matching task (T = 20) the small network makes 74 errors | 4 | “if the smaller net was regularized solely by adding the additional task of matching the soft targets produced by the large net at a temperature of 20, it achieved 74 test errors” | 3 Preliminary experiments on MNIST | ✓ |
| Transfer of generalization: without a single 3 in training the model makes only 206 errors | 4 | “the distilled model only makes 206 test errors of which 133 are on the 1010 threes in the test set” | 3 Preliminary experiments on MNIST | ✓ |
| Speech: the baseline DNN has frame accuracy 58.9 %, WER 10.9 % | 4 | “This system achieves a frame accuracy of 58.9%, and a Word Error Rate (WER) of 10.9% on our development set” | 4 Experiments on speech recognition | ✓ |
| Distillation transfers > 80 % of the 10-model ensemble's accuracy gain | 5 | “More than 80% of the improvement in frame classification accuracy achieved by using an ensemble of 10 models is transferred to the distilled model” | 4.1 Results | ✓ |
| Table 1: the distilled single model ≈ the ensemble of 10 models | 5 | “the distilled single model performs about as well as the averaged predictions of 10 models that were used to create the soft targets” | Table 1 | ✓ |
| Limitation: transferring the specialists' knowledge back into a large network is not shown | 8 | “We have not yet shown that we can distill the knowledge in the specialists back into the single large net” | 8 Discussion | ✓ |

**Self-check log.** Each of the 11 rows was re-checked by re-reading its page (`Read`
of the same PDF, page by page: pp. 1–5, 8). All quotes were found verbatim on the
stated pages → 11 × ✓, no ⚠ flags. The check is portable: only re-reading the PDF,
with no external scripts and no Python.

## Gaps and questions
- The numeric contribution of the specialist ensembles on JFT (top-1 gain): no single
  summary figure was written down within the pages read (pp. 1–5, 8–9); if needed,
  read pp. 6–7 (Tables 2–4).
- Compare with later work on distillation and model compression (→ lit-search).

## Citation metadata
Geoffrey Hinton · Oriol Vinyals · Jeff Dean · 2015 · Distilling the Knowledge in a
Neural Network · arXiv preprint · arXiv ID 1503.02531 · primaryClass stat.ML ·
URL https://arxiv.org/abs/1503.02531 · DOI [not assigned — preprint].

## Reference-list entry

Formatted by digest itself following `references/bibtex-fields.md`.

**APA 7:** Hinton, G., Vinyals, O., & Dean, J. (2015). *Distilling the knowledge in
a neural network*. arXiv. https://arxiv.org/abs/1503.02531

## Citation (.bib)

Entry type: `@misc` (an arXiv preprint), built by digest itself:

```bibtex
@misc{hinton2015distilling,
  author        = {Hinton, Geoffrey and Vinyals, Oriol and Dean, Jeff},
  title         = {Distilling the Knowledge in a Neural Network},
  year          = {2015},
  eprint        = {1503.02531},
  archivePrefix = {arXiv},
  primaryClass  = {stat.ML},
  url           = {https://arxiv.org/abs/1503.02531}
}
```
