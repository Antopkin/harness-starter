# Memo: should we switch to prompts with explicit reasoning

A real output of the `write-from-digests` skill, built from **two finished `digest`
files**:

- **S1**: Yao et al., 2023, ReAct (`skills/digest/references/EXAMPLE-digest-md.md`);
- **S2**: Wei et al., 2022, Chain-of-Thought Prompting
  (`skills/digest/references/EXAMPLE-digest-docx.md`).

Every verbatim quote in the text is copied from a row of the corresponding digest,
not reconstructed from memory, so it passes the deterministic `grep -F` check in the
source digest (see the verification log in Appendix A). The anchor `[S1.5]` reads as
"source S1, row 5 of its evidence table". The memo is in English, like the request
it answers, so the English quotes need no translation.

**Sources:** S1 — Yao et al., 2023 (ReAct); S2 — Wei et al., 2022 (Chain-of-Thought).
**Input:** 2 digest.md files  ·  **Output:** English · Markdown  ·  **Date:** 2026-07-16

## 1. Recommendation (thesis)

For tasks where the answer has to be worked out step by step (multi-step
calculations, questions with several conditions, fact checking), I recommend moving
away from "question → answer" prompts to prompts with explicit reasoning. Where the
answer follows logically from the problem statement, chain-of-thought works: the
few-shot examples contain not only the "input → answer" pair but also the reasoning.
Where the answer needs an outside fact, ReAct works: the model interleaves reasoning
with lookups in a source. Both techniques only change the prompt format; the model is
not fine-tuned. An important caveat: the gain of both is tied to sufficiently large
models, so on a small model the technique will not help, and it should not be rolled
out "blind". In practice I suggest starting with one pilot class of tasks on a large
model, comparing the two prompt formats on a dozen typical examples, and only then
rolling the chosen technique out more widely.

## 2. Argument

**A plain prompt cannot carry reasoning tasks.** Scaling up model size alone does not
solve hard tasks, and standard few-shot prompting helps little with them
[S2.10][S2.15]. The chain-of-thought authors state the limit of the technique
directly: “it works poorly on tasks that require reasoning abilities,” [S2.15]. The
practical conclusion: if our cases are arithmetic and multi-step questions, improving
them by just picking better "input → answer" examples is hopeless; a different prompt
format is needed.

**Chain-of-thought improves reasoning without fine-tuning.** If the examples show the
model the reasoning itself, a large enough model reproduces it and solves the tasks
noticeably better [S2.7][S2.8]. On a benchmark of math word problems this gave record accuracy:
“eight chain-of-thought exemplars achieves state-of-the-art accuracy on” “the GSM8K
benchmark of math word problems, surpassing even finetuned” [S2.7][S2.8]. So the gain
came from changing the prompt format, not from training a separate model for the
task, which makes it a cheap move for us.

**Where the answer needs an outside fact: ReAct.** Chain-of-thought reasons "in its
head" and so can confidently get a fact wrong; ReAct adds an action to the reasoning,
a lookup in an external source [S1.2]. On fact-checking questions this removes the
invention: “on question answering (HotpotQA) and fact verification (Fever), ReAct
overcomes issues of hallucination and error propagation prevalent in chain-of-thought
reasoning by interacting with a simple Wikipedia API” [S1.4]. The practical dividing
line is simple: if the answer follows from the problem statement, use
chain-of-thought; if the answer needs a fact from outside, use ReAct.

**The technique is cheap, but not free.** Neither technique needs a training set,
and both work on an off-the-shelf model: ReAct gets its success-rate gain with one or
two examples in the prompt, “ReAct outperforms imitation and reinforcement learning
methods by an absolute success rate of 34% and 10% respectively, while being prompted
with only one or two in-context examples” [S1.5]. But the gain has a hard condition of
scale: only sufficiently large models produce a chain of thought, “show that
sufficiently large language models can generate chains of” [S2.20]. So the
recommendation holds for a large model; for a small one it must be tested in a
separate pilot, not carried over by analogy.

**The limits of this conclusion.** Both digests are built on the abstracts and
introductory sections of the papers (Abstract, Introduction, the beginning of the
method); the full sections with experiments and result tables are not in them, as
the self-check logs of both sources note. So the conclusion rests on the results and
qualitative statements the authors report, not on measurements we reproduced; the
specific conditions (which models, how many runs, the metric per benchmark) remain to
be checked against the full texts. That is enough for a pilot; before scaling up,
check against the full papers and add to the memo the numbers from the results
sections, which the current digests lack.

---

## Appendix A. Evidence base

For each source, its evidence table from the digest with the `#` id column first,
then the ready-made references. Everything is copied from the digests themselves, not
rebuilt.

### Source S1 — Yao et al., 2023 — ReAct: Synergizing Reasoning and Acting in Language Models

| # | Claim | Locator | Verbatim quote | Section | Checked |
|---|---|---|---|---|---|
| S1.1 | Reasoning and acting were previously studied separately | `## Abstract`, line 9 | “their abilities for reasoning (e.g. chain-of-thought prompting) and acting (e.g. action plan generation) have primarily been studied as separate topics” | Abstract | ✓ |
| S1.2 | ReAct interleaves reasoning traces and actions | `## Abstract`, line 9 | “we explore the use of LLMs to generate both reasoning traces and task-specific actions in an interleaved manner” | Abstract | ✓ |
| S1.3 | Two-way synergy: reasoning steers the plan, actions bring outside information | `## Abstract`, line 9 | “reasoning traces help the model induce, track, and update action plans as well as handle exceptions, while actions allow it to interface with external sources” | Abstract | ✓ |
| S1.4 | On HotpotQA and Fever it overcomes hallucination via a Wikipedia API | `## Abstract`, line 9 | “on question answering (HotpotQA) and fact verification (Fever), ReAct overcomes issues of hallucination and error propagation prevalent in chain-of-thought reasoning by interacting with a simple Wikipedia API” | Abstract | ✓ |
| S1.5 | Success-rate gain of 34 % and 10 % on ALFWorld and WebShop with 1–2 examples | `## Abstract`, line 9 | “ReAct outperforms imitation and reinforcement learning methods by an absolute success rate of 34% and 10% respectively, while being prompted with only one or two in-context examples” | Abstract | ✓ |
| S1.6 | Improved interpretability and trustworthiness | `## Abstract`, line 9 | “improved human interpretability and trustworthiness over methods without reasoning or acting components” | Abstract | ✓ |
| S1.7 | Human intelligence combines actions with verbal reasoning | `## 1 Introduction`, line 13 | “A unique feature of human intelligence is the ability to seamlessly combine task-oriented actions with verbal reasoning” | 1 Introduction | ✓ |
| S1.8 | ReAct is a general paradigm that prompts for interleaved reasoning and actions | `## 1 Introduction`, line 15 | “ReAct prompts LLMs to generate both verbal reasoning traces and actions pertaining to a task in an interleaved manner” | 1 Introduction | ✓ |
| S1.9 | Agent–environment setting: observation and action by a policy at step t | `## 2 ReAct`, line 19 | “an agent receives an observation ot ∈ O from the environment and takes an action at ∈ A following some policy” | 2 ReAct | ✓ |
| S1.10 | The action space is extended with language: Â = A ∪ L | `## 2 ReAct`, line 21 | “we augment the agent's action space to Â = A ∪ L, where L is the space of language” | 2 ReAct | ✓ |
| S1.11 | A "thought" does not change the environment and yields no feedback | `## 2 ReAct`, line 21 | “does not affect the external environment, thus leading to no observation feedback” | 2 ReAct | ✓ |

**Reference-list entry (S1).**
APA 7: Yao, S., Zhao, J., Yu, D., Du, N., Shafran, I., Narasimhan, K., & Cao, Y. (2023). ReAct: Synergizing reasoning and acting in language models. In *International Conference on Learning Representations (ICLR 2023)*. https://arxiv.org/abs/2210.03629
GOST R 7.0.100-2018: Yao, S. ReAct: Synergizing Reasoning and Acting in Language Models / S. Yao [et al.] // International Conference on Learning Representations (ICLR 2023). — [S. l. : s. n.], 2023. — arXiv:2210.03629. — P. [verify].

**Citation S1 (.bib).**
```bibtex
@inproceedings{yao2023react,
  author       = {Yao, Shunyu and Zhao, Jeffrey and Yu, Dian and Du, Nan and Shafran, Izhak and Narasimhan, Karthik and Cao, Yuan},
  title        = {ReAct: Synergizing Reasoning and Acting in Language Models},
  booktitle    = {International Conference on Learning Representations (ICLR)},
  year         = {2023},
  eprint       = {2210.03629},
  archivePrefix = {arXiv},
  primaryClass = {cs.CL},
  url          = {https://arxiv.org/abs/2210.03629},
  % pages     = {TODO: not stated in the source},
  % doi       = {TODO: not stated in the source},
}
```

### Source S2 — Wei et al., 2022 — Chain-of-Thought Prompting Elicits Reasoning in Large Language Models

| # | Claim | Locator | Verbatim quote | Section | Checked |
|---|---|---|---|---|---|
| S2.1 | A chain of thought is a series of intermediate steps | §Abstract, para. 1 | “We explore how generating a chain of thought — a series of intermediate” | Abstract | ✓ |
| S2.2 | It significantly improves LLMs' ability to reason | §Abstract, para. 1 | “reasoning steps — significantly improves the ability of large language” | Abstract | ✓ |
| S2.3 | The method is called chain-of-thought prompting | §Abstract, para. 1 | “models via a simple method called chain-of-thought prompting, where a” | Abstract | ✓ |
| S2.4 | A few CoT demonstrations are given as exemplars | §Abstract, para. 1 | “few chain of thought demonstrations are provided as exemplars in” | Abstract | ✓ |
| S2.5 | Experiments on three large LLMs | §Abstract, para. 1 | “Experiments on three large language models show that” | Abstract | ✓ |
| S2.6 | Improvement on arithmetic, commonsense, symbolic tasks | §Abstract, para. 1 | “chain-of-thought prompting improves performance on a range of” | Abstract | ✓ |
| S2.7 | PaLM 540B + 8 CoT exemplars → SOTA accuracy | §Abstract, para. 1 | “eight chain-of-thought exemplars achieves state-of-the-art accuracy on” | Abstract | ✓ |
| S2.8 | On GSM8K it surpasses even a fine-tuned model | §Abstract, para. 1 | “the GSM8K benchmark of math word problems, surpassing even finetuned” | Abstract | ✓ |
| S2.9 | The model surpassed is GPT-3 with a verifier | §Abstract, para. 1 | “GPT-3 with a verifier.” | Abstract | ✓ |
| S2.10 | Model scale alone is not enough for hard tasks | §1 Introduction, para. 1 | “up model size alone has not proved sufficient for achieving high” | 1 Introduction | ✓ |
| S2.11 | The method is motivated by two ideas | §1 Introduction, para. 2 | “can be unlocked by a simple method motivated by two ideas. First,” | 1 Introduction | ✓ |
| S2.12 | Second idea: in-context few-shot via prompting | §1 Introduction, para. 2 | “large language models offer the exciting prospect of in-context few-shot” | 1 Introduction | ✓ |
| S2.13 | Both earlier ideas have key limitations | §1 Introduction, para. 3 | “Both of the above ideas, however, have key limitations. For” | 1 Introduction | ✓ |
| S2.14 | Building a large set of quality rationales is costly | §1 Introduction, para. 3 | “create a large set of high quality rationales, which is much more” | 1 Introduction | ✓ |
| S2.15 | Plain few-shot works poorly on reasoning tasks | §1 Introduction, para. 3 | “it works poorly on tasks that require reasoning abilities,” | 1 Introduction | ✓ |
| S2.16 | CoT definition: steps leading to the final answer | §1 Introduction, para. 3 | “natural language reasoning steps that lead to the final output, and we” | 1 Introduction | ✓ |
| S2.17 | CoT with PaLM 540B beats standard prompting | §1 Introduction, para. 4 | “chain-of-thought prompting with PaLM 540B outperforms standard prompting” | 1 Introduction | ✓ |
| S2.18 | Prompting-only needs no large training set | §1 Introduction, para. 4 | “prompting-only approach is important because it does not require a large” | 1 Introduction | ✓ |
| S2.19 | Goal: get the LM to generate a chain of thought | §2 Chain-of-Thought Prompting, para. 1 | “generate a similar chain of thought — a coherent series of intermediate” | 2 Chain-of-Thought Prompting | ✓ |
| S2.20 | Only sufficiently large models produce CoT | §2 Chain-of-Thought Prompting, para. 1 | “show that sufficiently large language models can generate chains of” | 2 Chain-of-Thought Prompting | ✓ |
| S2.21 | Property 1: more computation for hard problems | §2 Chain-of-Thought Prompting, para. 2 | “into intermediate steps, which means that additional computation can be” | 2 Chain-of-Thought Prompting | ✓ |
| S2.22 | Property 2: an interpretable window into the model | §2 Chain-of-Thought Prompting, para. 2 | “of thought provides an interpretable window into the behavior of the” | 2 Chain-of-Thought Prompting | ✓ |
| S2.23 | Property 3: applies to a wide class of tasks | §2 Chain-of-Thought Prompting, para. 2 | “Third, chain-of-thought reasoning can be used for tasks such as math” | 2 Chain-of-Thought Prompting | ✓ |
| S2.24 | Property 4: elicited in off-the-shelf large models | §2 Chain-of-Thought Prompting, para. 2 | “Finally, chain-of-thought reasoning can be readily elicited in” | 2 Chain-of-Thought Prompting | ✓ |

**Reference-list entry (S2).**
APA 7: Wei, J., Wang, X., Schuurmans, D., Bosma, M., Ichter, B., Xia, F., Chi, E. H., Le, Q. V., & Zhou, D. (2022). Chain-of-thought prompting elicits reasoning in large language models. In *Advances in Neural Information Processing Systems 35 (NeurIPS 2022)* (pp. [verify]). https://arxiv.org/abs/2201.11903
GOST R 7.0.100-2018: Wei, J. Chain-of-Thought Prompting Elicits Reasoning in Large Language Models / J. Wei [et al.] // Advances in Neural Information Processing Systems 35 (NeurIPS 2022). — [S. l. : s. n.], 2022. — P. [verify]. — arXiv:2201.11903.

**Citation S2 (.bib).**
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

### Verification log (backward pass)

- **Anchors in the text:** 11 (S2.10, S2.15×2, S2.7×2, S2.8×2, S1.2, S1.4, S1.5, S2.20),
  pointing to 8 distinct pool rows.
- **Verbatim quotes checked:** 6 of 6; every `grep -F` in the source digest = found:
  `it works poorly on tasks that require reasoning abilities,` (S2.15) → S2;
  `eight chain-of-thought exemplars achieves state-of-the-art accuracy on` (S2.7) → S2;
  `the GSM8K benchmark of math word problems, surpassing even finetuned` (S2.8) → S2;
  `on question answering (HotpotQA) and fact verification (Fever), ReAct overcomes issues of hallucination and error propagation prevalent in chain-of-thought reasoning by interacting with a simple Wikipedia API` (S1.4) → S1;
  `ReAct outperforms imitation and reinforcement learning methods by an absolute success rate of 34% and 10% respectively, while being prompted with only one or two in-context examples` (S1.5) → S1;
  `show that sufficiently large language models can generate chains of` (S2.20) → S2.
- **⚠ flags:** 0. No load-bearing claim was left without an anchor (G1), and no quote
  needed a hedge or a deletion.
- **Method:** for each quote, `grep -F "quote" source-digest.md` = found; the locators
  (Abstract, §1 Introduction, §2 Chain-of-Thought Prompting) were re-opened in the
  corresponding digest. The check is portable: re-reading the same file and a
  deterministic `grep -F`, with no Python inside the skill's logic.

---

## Appendix B. Into action (fill-form placeholder)

The place for "before/after" screenshots of a filled-in form. It is filled by the
`fill-form` skill; here there is only the section for it.

- [ ] Screenshot: the prompting-technique form before it is filled in.
- [ ] Screenshot: the form after it is filled in (the technique chosen for the task type).
- [ ] A short caption: which decision from the memo went into the form (chain-of-thought
      for derivation tasks, ReAct for tasks that need an outside fact; the model-scale
      check as a separate item).
