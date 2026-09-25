# Digest: Wei et al., 2022 — Chain-of-Thought Prompting Elicits Reasoning in Large Language Models

A real output of the `digest` skill, built on the arXiv preprint 2201.11903 with a
docx file as the source. No `docx` skill was installed, so the text was extracted with
`pandoc -t plain` (graceful fallback); the anchor table was checked by a literal
search for each quote in the extracted text, and `digest` formatted the reference and
the BibTeX itself. This example was produced with an earlier fallback (`pandoc -t plain`,
with the headings rebuilt by hand); the skill now uses `pandoc -t markdown`, which keeps
the heading levels.

**Biblio:** Wei, J., Wang, X., Schuurmans, D., Bosma, M., Ichter, B., Xia, F., Chi, E., Le, Q., & Zhou, D. (2022). Chain-of-Thought Prompting Elicits Reasoning in Large Language Models. 36th Conference on Neural Information Processing Systems (NeurIPS 2022). arXiv:2201.11903 [cs.CL]. https://arxiv.org/abs/2201.11903
**Source format:** docx (text extracted with pandoc; no docx skill → graceful fallback)  ·  **Read:** §Abstract; §1 Introduction (paras. 1–4); §2 Chain-of-Thought Prompting (paras. 1–2)  ·  **Date:** 2026-07-15

> **Extraction limitation.** No `docx` skill is installed, so the text was obtained by graceful fallback, with the command `pandoc … -t plain`. The anchor unit in this format is a section (heading) plus a paragraph number within the section. The extracted fragment covers only the title, the abstract, the Introduction and the beginning of section 2; the later sections (experiment details, per-benchmark result tables, error analysis, limitations) are missing from the extracted text. The digest reflects exactly what the extraction contains and does not fill in the missing sections from outside memory.

## The gist in one line
If the few-shot examples show the model not just input-answer pairs but a chain of intermediate reasoning steps (a chain of thought), a large enough language model reproduces such a chain and solves arithmetic, commonsense and symbolic tasks noticeably better, without any fine-tuning.

## Problem and gap
Scaling up model size alone does not yield high performance on hard tasks such as arithmetic, commonsense and symbolic manipulation (§1 Introduction, para. 1). Two known approaches have their own limits: training or fine-tuning on natural-language rationales is expensive because it needs a large set of high-quality rationales, and traditional few-shot prompting works poorly where reasoning is needed and improves little with scale (§1 Introduction, paras. 2–3).

## Method
Chain-of-thought prompting: the model is given few-shot examples in which each example is a triple ⟨input, chain of thought, output⟩; the chain of thought is a series of intermediate natural-language steps that lead to the final answer (§1 Introduction, para. 3). The method needs no fine-tuning: it is enough to include a few chain-of-thought demonstrations as exemplars in the few-shot prompt (§Abstract, para. 1; §2 Chain-of-Thought Prompting, para. 2). The key empirical condition: the ability to produce a chain of thought shows up only in sufficiently large models (§2 Chain-of-Thought Prompting, para. 1).

## Data / material
The extracted fragment names benchmarks and models only at a high level, with no numbers on the samples. The experiments use three large language models and tasks of arithmetic, commonsense and symbolic reasoning; the only benchmark named in the extraction is GSM8K (math word problems) (§Abstract, para. 1; §1 Introduction, para. 4). Dataset sizes, the number of examples per task and the benchmark composition are not stated in the extracted text.

## Results
The extracted fragment gives no numeric accuracy metrics; the results are stated qualitatively and in terms of model scale.
- Chain-of-thought prompting improves performance on arithmetic, commonsense and symbolic tasks across three large language models (§Abstract, para. 1).
- PaLM 540B with eight chain-of-thought exemplars reaches state-of-the-art accuracy on GSM8K, surpassing even fine-tuned GPT-3 with a verifier (§Abstract, para. 1).
- Chain-of-thought prompting with PaLM 540B beats standard prompting by a large margin and sets a new state of the art on GSM8K (§1 Introduction, para. 4).

## Contribution and conclusions
The paper proposes chain-of-thought prompting as a simple method that unlocks the reasoning ability of large language models and claims four properties for it (§2 Chain-of-Thought Prompting, para. 2): (1) it decomposes a multi-step problem into intermediate steps, which lets harder problems get more computation; (2) it gives an interpretable window into the model's behaviour, which makes it possible to debug the reasoning path; (3) it applies to a wide class of tasks that humans solve through language; (4) it can be elicited in off-the-shelf, sufficiently large models just by including examples. The paper separately stresses the advantage of a prompting-only approach: it needs no large training set, and one checkpoint handles many tasks (§1 Introduction, para. 4).

## Limitations
The extracted fragment has no separate limitations section: not stated (the extraction contains only the abstract, the Introduction and the beginning of section 2). The text itself implies a limitation of scale: the method's gain is tied to sufficiently large models, so on small models the effect is not guaranteed (§2 Chain-of-Thought Prompting, para. 1). Reviewer's note (mine): the authors present the dependence on scale as a property, an emergent ability, not as a limitation; treating it as a limitation is my reading.

## Claims anchored to the source (checked)

| Claim | Locator | Verbatim quote | Section | Checked |
|---|---|---|---|---|
| A chain of thought is a series of intermediate steps | §Abstract, para. 1 | “We explore how generating a chain of thought — a series of intermediate” | Abstract | ✓ |
| It significantly improves LLMs' ability to reason | §Abstract, para. 1 | “reasoning steps — significantly improves the ability of large language” | Abstract | ✓ |
| The method is called chain-of-thought prompting | §Abstract, para. 1 | “models via a simple method called chain-of-thought prompting, where a” | Abstract | ✓ |
| A few CoT demonstrations are given as exemplars | §Abstract, para. 1 | “few chain of thought demonstrations are provided as exemplars in” | Abstract | ✓ |
| Experiments on three large LLMs | §Abstract, para. 1 | “Experiments on three large language models show that” | Abstract | ✓ |
| Improvement on arithmetic, commonsense, symbolic tasks | §Abstract, para. 1 | “chain-of-thought prompting improves performance on a range of” | Abstract | ✓ |
| PaLM 540B + 8 CoT exemplars → SOTA accuracy | §Abstract, para. 1 | “eight chain-of-thought exemplars achieves state-of-the-art accuracy on” | Abstract | ✓ |
| On GSM8K it surpasses even a fine-tuned model | §Abstract, para. 1 | “the GSM8K benchmark of math word problems, surpassing even finetuned” | Abstract | ✓ |
| The model surpassed is GPT-3 with a verifier | §Abstract, para. 1 | “GPT-3 with a verifier.” | Abstract | ✓ |
| Model scale alone is not enough for hard tasks | §1 Introduction, para. 1 | “up model size alone has not proved sufficient for achieving high” | 1 Introduction | ✓ |
| The method is motivated by two ideas | §1 Introduction, para. 2 | “can be unlocked by a simple method motivated by two ideas. First,” | 1 Introduction | ✓ |
| Second idea: in-context few-shot via prompting | §1 Introduction, para. 2 | “large language models offer the exciting prospect of in-context few-shot” | 1 Introduction | ✓ |
| Both earlier ideas have key limitations | §1 Introduction, para. 3 | “Both of the above ideas, however, have key limitations. For” | 1 Introduction | ✓ |
| Building a large set of quality rationales is costly | §1 Introduction, para. 3 | “create a large set of high quality rationales, which is much more” | 1 Introduction | ✓ |
| Plain few-shot works poorly on reasoning tasks | §1 Introduction, para. 3 | “it works poorly on tasks that require reasoning abilities,” | 1 Introduction | ✓ |
| CoT definition: steps leading to the final answer | §1 Introduction, para. 3 | “natural language reasoning steps that lead to the final output, and we” | 1 Introduction | ✓ |
| CoT with PaLM 540B beats standard prompting | §1 Introduction, para. 4 | “chain-of-thought prompting with PaLM 540B outperforms standard prompting” | 1 Introduction | ✓ |
| Prompting-only needs no large training set | §1 Introduction, para. 4 | “prompting-only approach is important because it does not require a large” | 1 Introduction | ✓ |
| Goal: get the LM to generate a chain of thought | §2 Chain-of-Thought Prompting, para. 1 | “generate a similar chain of thought — a coherent series of intermediate” | 2 Chain-of-Thought Prompting | ✓ |
| Only sufficiently large models produce CoT | §2 Chain-of-Thought Prompting, para. 1 | “show that sufficiently large language models can generate chains of” | 2 Chain-of-Thought Prompting | ✓ |
| Property 1: more computation for hard problems | §2 Chain-of-Thought Prompting, para. 2 | “into intermediate steps, which means that additional computation can be” | 2 Chain-of-Thought Prompting | ✓ |
| Property 2: an interpretable window into the model | §2 Chain-of-Thought Prompting, para. 2 | “of thought provides an interpretable window into the behavior of the” | 2 Chain-of-Thought Prompting | ✓ |
| Property 3: applies to a wide class of tasks | §2 Chain-of-Thought Prompting, para. 2 | “Third, chain-of-thought reasoning can be used for tasks such as math” | 2 Chain-of-Thought Prompting | ✓ |
| Property 4: elicited in off-the-shelf large models | §2 Chain-of-Thought Prompting, para. 2 | “Finally, chain-of-thought reasoning can be readily elicited in” | 2 Chain-of-Thought Prompting | ✓ |

**Self-check log.** Rows: 24. Confirmed: 24 × ✓. ⚠ flags: 0. Method: re-opening the extracted source text and a literal substring search (`grep -F`) for each of the 24 quotes, across the sections Abstract, 1 Introduction, 2 Chain-of-Thought Prompting. The check is portable: only re-reading the same text, with no external scripts and no Python inside the skill's logic (grep served as the equivalent of re-reading the line).

## Gaps and questions
- **Extraction limitation (no docx skill).** The text came from `pandoc -t plain`; the heading hierarchy was reconstructed from flat output, and paragraph numbers follow the extracted text. How accurately paragraphs are split depends on how pandoc flattened the docx.
- **The source is fragmentary.** The extraction contains only the Abstract, §1 and the beginning of §2. The sections on experimental setup, full accuracy tables for all benchmarks (beyond the mention of GSM8K), ablations and the authors' limitations are not stated in the extracted text.
- **Result numbers.** Specific accuracy values (percentages) are missing from the extracted fragment; it only says "state-of-the-art" and "new state-of-the-art". Absolute metrics: [verify] against the full text of the paper.
- Next (→ lit-search): the full text of the NeurIPS version for the Results/Limitations sections; check pages and DOI for the BibTeX.

## Citation metadata
Jason Wei · Xuezhi Wang · Dale Schuurmans · Maarten Bosma · Brian Ichter · Fei Xia · Ed Chi · Quoc Le · Denny Zhou · 2022 · Chain-of-Thought Prompting Elicits Reasoning in Large Language Models · 36th Conference on Neural Information Processing Systems (NeurIPS 2022) · volume/issue [verify] · pages [verify] · arXiv:2201.11903v6 [cs.CL] · https://arxiv.org/abs/2201.11903.

## Reference-list entry

Formatted by digest itself following `references/bibtex-fields.md`. The exact pages and volume of the NeurIPS version are not in the source; they are marked `[verify]`, not invented.

**APA 7:** Wei, J., Wang, X., Schuurmans, D., Bosma, M., Ichter, B., Xia, F., Chi, E. H., Le, Q. V., & Zhou, D. (2022). Chain-of-thought prompting elicits reasoning in large language models. In *Advances in Neural Information Processing Systems 35 (NeurIPS 2022)* (pp. [verify]). https://arxiv.org/abs/2201.11903

**GOST R 7.0.100-2018 (optional, for a Russian-language list):** Wei, J. Chain-of-Thought Prompting Elicits Reasoning in Large Language Models / J. Wei [et al.] // Advances in Neural Information Processing Systems 35 (NeurIPS 2022). — [S. l. : s. n.], 2022. — P. [verify]. — arXiv:2201.11903.

## Citation (.bib)

The entry is built directly from the source's metadata; missing fields are marked `% TODO`, not invented. Type: `@inproceedings` (a NeurIPS 2022 conference paper).

```bibtex
@inproceedings{wei2022chain,
  author        = {Wei, Jason and Wang, Xuezhi and Schuurmans, Dale and Bosma, Maarten and Ichter, Brian and Xia, Fei and Chi, Ed and Le, Quoc and Zhou, Denny},
  title         = {Chain-of-Thought Prompting Elicits Reasoning in Large Language Models},
  booktitle     = {36th Conference on Neural Information Processing Systems (NeurIPS 2022)},
  year          = {2022},
  eprint        = {2201.11903},
  archivePrefix = {arXiv},
  primaryClass  = {cs.CL},
  url           = {https://arxiv.org/abs/2201.11903},
  % volume      = {% TODO: verify},
  % pages       = {% TODO: verify},
  % doi         = {% TODO: verify},
}
```
