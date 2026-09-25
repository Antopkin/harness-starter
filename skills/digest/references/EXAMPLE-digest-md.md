# Digest: Yao et al., 2023 — ReAct: Synergizing Reasoning and Acting in Language Models

A real output of the `digest` skill, built on the arXiv preprint 2210.03629 with a
markdown file as the source (digital-born, no extraction fallback). The anchor table
was checked by a literal search for each quote in the source text; `digest` formatted
the reference and the BibTeX itself.

**Biblio:** Yao, S., Zhao, J., Yu, D., Du, N., Shafran, I., Narasimhan, K., & Cao, Y. (2023). ReAct: Synergizing Reasoning and Acting in Language Models. Published as a conference paper at ICLR 2023. arXiv:2210.03629 [cs.CL]. https://arxiv.org/abs/2210.03629
**Source format:** markdown  ·  **Read:** lines 1–21 — metadata, Abstract, §1 Introduction, §2 (beginning)  ·  **Date:** 2026-07-15

## The gist in one line
ReAct is an LLM prompting paradigm in which reasoning traces and actions are interleaved in one stream, so that reasoning steers the action plan and actions feed outside information back into the reasoning.

## Problem and gap
LLMs' abilities to reason (chain-of-thought) and to act (action plan generation) have so far been studied as separate topics; the paper combines them in an interleaved mode (`## Abstract`, line 9). The starting point is the observation that human intelligence seamlessly combines task-oriented actions with verbal reasoning (`## 1 Introduction`, line 13).

## Method
The LLM is prompted to generate both verbal reasoning traces and task-specific actions in an interleaved order; this gives "reason to act" (reasoning creates and adjusts the plan) and "act to reason" (actions pull in information from an external environment such as Wikipedia) (`## 1 Introduction`, line 15). Formally the agent's action space is extended with language: Â = A ∪ L, where L is the space of language; a "thought" (a reasoning trace) does not change the external environment and yields no observation feedback (`## 2 ReAct: Synergizing Reasoning + Acting`, lines 19, 21). The general setting: at step t the agent receives an observation and chooses an action according to some policy (`## 2 ReAct`, line 19).

## Data / material
Four benchmarks are named: question answering (HotpotQA), fact verification (Fever), and interactive decision making (ALFWorld and WebShop) (`## Abstract`, line 9). Sample sizes, dataset sizes and how they were built are not stated in the available fragment (the text has no Data/Experiments sections).

## Results
All numbers below come from the abstract; the available fragment has no separate section with result tables.
- On ALFWorld and WebShop, ReAct beats imitation- and reinforcement-learning methods by an absolute success rate of 34 % and 10 % respectively, while being prompted with only one or two in-context examples (`## Abstract`, line 9).
- On HotpotQA and Fever, ReAct overcomes the hallucination and error-propagation problems typical of chain-of-thought by interacting with a simple Wikipedia API (`## Abstract`, line 9).
- The authors claim improved human interpretability and trustworthiness compared with methods lacking reasoning or acting components (`## Abstract`, line 9).

## Contribution and conclusions
The authors position ReAct as a general paradigm that combines reasoning and acting for language and decision-making tasks; the contribution is interleaving reasoning traces and actions, which yields synergy in both directions (`## 1 Introduction`, line 15; `## Abstract`, line 9).

## Limitations
In the available fragment (Abstract, Introduction, the beginning of §2) the authors do not state a limitations section; it is not part of the text. Compiler's note (mine): the fragment breaks off at the beginning of §2, so method details, the experimental procedure and the full results are outside this digest's scope.

## Claims anchored to the source (checked)

| Claim | Locator | Verbatim quote | Section | Checked |
|---|---|---|---|---|
| Reasoning and acting were previously studied separately | `## Abstract`, line 9 | “their abilities for reasoning (e.g. chain-of-thought prompting) and acting (e.g. action plan generation) have primarily been studied as separate topics” | Abstract | ✓ |
| ReAct interleaves reasoning traces and actions | `## Abstract`, line 9 | “we explore the use of LLMs to generate both reasoning traces and task-specific actions in an interleaved manner” | Abstract | ✓ |
| Two-way synergy: reasoning steers the plan, actions bring outside information | `## Abstract`, line 9 | “reasoning traces help the model induce, track, and update action plans as well as handle exceptions, while actions allow it to interface with external sources” | Abstract | ✓ |
| On HotpotQA and Fever it overcomes hallucination via a Wikipedia API | `## Abstract`, line 9 | “on question answering (HotpotQA) and fact verification (Fever), ReAct overcomes issues of hallucination and error propagation prevalent in chain-of-thought reasoning by interacting with a simple Wikipedia API” | Abstract | ✓ |
| Success-rate gain of 34 % and 10 % on ALFWorld and WebShop with 1–2 examples | `## Abstract`, line 9 | “ReAct outperforms imitation and reinforcement learning methods by an absolute success rate of 34% and 10% respectively, while being prompted with only one or two in-context examples” | Abstract | ✓ |
| Improved interpretability and trustworthiness | `## Abstract`, line 9 | “improved human interpretability and trustworthiness over methods without reasoning or acting components” | Abstract | ✓ |
| Human intelligence combines actions with verbal reasoning | `## 1 Introduction`, line 13 | “A unique feature of human intelligence is the ability to seamlessly combine task-oriented actions with verbal reasoning” | 1 Introduction | ✓ |
| ReAct is a general paradigm that prompts for interleaved reasoning and actions | `## 1 Introduction`, line 15 | “ReAct prompts LLMs to generate both verbal reasoning traces and actions pertaining to a task in an interleaved manner” | 1 Introduction | ✓ |
| Agent–environment setting: observation and action by a policy at step t | `## 2 ReAct`, line 19 | “an agent receives an observation ot ∈ O from the environment and takes an action at ∈ A following some policy” | 2 ReAct | ✓ |
| The action space is extended with language: Â = A ∪ L | `## 2 ReAct`, line 21 | “we augment the agent's action space to Â = A ∪ L, where L is the space of language” | 2 ReAct | ✓ |
| A "thought" does not change the environment and yields no feedback | `## 2 ReAct`, line 21 | “does not affect the external environment, thus leading to no observation feedback” | 2 ReAct | ✓ |

**Self-check log.** Rows: 11. Confirmed: 11 × ✓. ⚠ flags: 0. Method: re-opening the source text and a literal substring search (`grep -F`) for each of the 11 quotes (line 9 — Abstract, lines 13 and 15 — Introduction, lines 19 and 21 — §2); every quote was found as an exact substring. The check is portable: only re-reading the same file, with no external scripts and no Python (the grep check is a deterministic substring test, not a rewrite).

## Gaps and questions
- The available fragment has no Related work, Method (details), Data/Experiments, Results (tables) or Limitations sections; the whole digest rests on the Abstract, §1 and the beginning of §2.
- The 34 % and 10 % figures appear only in the abstract; the measurement conditions (which models, how many runs, the success-rate metric per benchmark) are not disclosed in the text: "not stated".
- The sizes of the HotpotQA, Fever, ALFWorld and WebShop datasets are not given.
- The DOI and page numbers of the ICLR 2023 publication are missing from the file; check them against the original (→ lit-search).

## Citation metadata
Shunyu Yao · Jeffrey Zhao · Dian Yu · Nan Du · Izhak Shafran · Karthik Narasimhan · Yuan Cao · 2023 · ReAct: Synergizing Reasoning and Acting in Language Models · Published as a conference paper at ICLR 2023 · arXiv:2210.03629v3 [cs.CL] · Volume/issue — [verify] · Pages — [verify] · DOI — [verify].

## Reference-list entry

Formatted by digest itself following `references/bibtex-fields.md`. The exact pages and DOI of the ICLR 2023 publication are not in the source; they are marked `[verify]`, not invented.

**APA 7:** Yao, S., Zhao, J., Yu, D., Du, N., Shafran, I., Narasimhan, K., & Cao, Y. (2023). ReAct: Synergizing reasoning and acting in language models. In *International Conference on Learning Representations (ICLR 2023)*. https://arxiv.org/abs/2210.03629

**GOST R 7.0.100-2018 (optional, for a Russian-language list):** Yao, S. ReAct: Synergizing Reasoning and Acting in Language Models / S. Yao [et al.] // International Conference on Learning Representations (ICLR 2023). — [S. l. : s. n.], 2023. — arXiv:2210.03629. — P. [verify].

## Citation (.bib)

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
