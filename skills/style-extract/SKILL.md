---
name: style-extract
description: "Extract a writing style profile from text samples using a two-prompt analysis method. Use when the user asks to extract a style, build a style profile from samples, analyze their writing style or create a style profile, in whatever language they ask."
---

# Style Extract Skill

Extract a personal writing style profile from 3-7 text samples.

## Method: Two-Prompt Analysis

### Phase 1: Analyze (style_analyzer)
Input: 3-7 text samples from the user

1. **Structural analysis**: paragraph length, sentence length distribution, heading patterns
2. **Lexical analysis**: vocabulary richness, formality level, technical density, repeated phrases
3. **Rhetorical analysis**: argument structure, hedging patterns, evidence presentation, transitions
4. **Voice markers**: active/passive ratio, person (1st/2nd/3rd), tone (authoritative/tentative/conversational)
5. **Anti-patterns**: phrases the author consistently avoids, structural patterns not used

Output: Raw 15-dimension profile + signature phrases + characteristic patterns

**Output language:** the language of the user's request; signature phrases are quoted verbatim in the language of the samples. **Length cap:** at most 800 words. **Return shape:** the 15 dimensions grouped as Structural, Lexical, Rhetorical, Voice markers and Anti-patterns, plus Signature phrases and Characteristic patterns.

### Phase 2: Validate (style_validator)
1. Generate a test paragraph using the extracted profile
2. Compare test output against original samples
3. Score similarity on: tone, structure, vocabulary, sentence rhythm
4. If score < 70% match → refine profile and re-test
5. If score >= 70% → finalize profile

**Output language:** the language of the user's request; the test paragraph is written in the language of the samples. **Length cap:** at most 300 words. **Return shape:** per-axis scores for tone, structure, vocabulary and sentence rhythm, the overall match percentage against the 70% threshold, the refine-or-finalize verdict, and the path of the profile file written under `memory/style-profiles/`.

## Output Format

Creates a `.md` file in `memory/style-profiles/` (relative to the repository root) with sections:
- **Rules**: Concrete, actionable writing rules extracted from samples
- **Reference Samples**: 2-3 representative excerpts from the user's text
- **Anti-Patterns**: Phrases and structures the user avoids

## Input Requirements

- Minimum 3 text samples (ideally 5-7)
- Samples should be 200+ words each
- Samples should represent the user's best/target writing
- Same genre preferred (all academic, all consulting, etc.)

## Usage

```
/style-extract [path-to-samples-dir]
/style-extract --name "my-consulting-style" [file1.md] [file2.md] [file3.md]
```

## Status: Scaffold

This skill is a scaffold. Full implementation will be completed when the user provides text samples. The two-prompt method and validation loop are defined but not yet tested with real data.
