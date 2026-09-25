# The mapping contract: input → form fields

How to match values from the input to the fields of a form. The key rule is
**matching by role and accessible name, not by CSS selectors**: an accessible name
survives layout changes and carries over between forms; a CSS path does not.

## The input comes in two kinds

- **Structured** (JSON/YAML): ready-made "field name → value" pairs. The mapping is
  almost direct: the input key is matched to the field's accessible name.
- **Prose (a memo):** the agent extracts the field values from the text itself (LLM
  mapping). For example, from an argumentative memo: title, abstract, keywords, the
  list of sources. What is extracted then follows the same contract as structured
  input.

## The matching rule

For every form field from `snapshot -i` (role + accessible name):

1. Take the field's accessible name.
2. **Normalise** both sides the same way: trim the edges, lowercase, collapse
   repeated spaces. (Also drop a trailing colon of the label, e.g. "E-mail:".)
3. **An exact match** of the normalised accessible name with the normalised input
   key → that is a pair. Act natively by name:
   - `find label "<Label>" fill "<value>"`: find by label and enter in one command;
   - `find role <role> --name "<Name>" <action>`: by role and accessible name;
   - the fallback is `snapshot -i` + `@eN`; **the last resort** is raw CSS.

Order of preference: `find label` / `find role --name` (native, by accessible name)
→ `@eN` from the snapshot → CSS. Raw CSS only when the semantic locators have
failed.

## Ambiguity → human gate, do not guess

Stop and ask the human if:

- **accessible names are duplicated**: two or more fields with the same label;
- **labels are empty or unreadable**: a field has no accessible name;
- **an input key matches several fields**, or none with confidence;
- **the field type does not fit** the value (the value is a date, the field is free
  text; the value is a single option, the field is a multi-select).

In these cases the cost of a silent guess is a value that lands in the wrong place.
Ask the human which field was meant (by order, by a neighbouring label, by
placeholder), and record their choice. Guessing is not allowed.

An input field with no counterpart in the form, and a form field with no value in the
input, are also shown to the human at the human gate before submit, rather than
filled with a guess or left silently.

## Non-text fields

Match by role and name, but act by type:

| Field role | Action |
|---|---|
| `textbox`, `searchbox` | `fill` (if events are intercepted, the ladder from `failure-modes.md`) |
| `checkbox` | `check` / `uncheck` (idempotent) |
| `radio` | `find role radio --name "<option>" click` or `check` the right option |
| `combobox`, `listbox` (select) | `select @eN "<value>"` |
| file | `upload @eN <file>` |

## Appendix B: a demo form built from the memo's fields

A demo form for practice is chosen so that its fields **follow from the memo**:
title, abstract, keywords, sources, that is, what the memo already contains, map to
the form's fields one to one. On such a form the contract works cleanly.

**The honest limit (a limitation, not a bug):** an arbitrary university course
syllabus does **NOT map automatically** field-to-field from an argumentative memo. A
syllabus has its own fields (learning outcomes, topics, hours, assessment forms)
that an argumentative memo does not contain, so no direct key correspondence exists.
This is a limitation of the matching itself, not a defect of the skill: where there
is no correspondence, the skill honestly brings the field to the human gate instead
of inventing a value.
