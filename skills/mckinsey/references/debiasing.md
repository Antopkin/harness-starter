# Debiasing Toolkit

Protocols against the typical biases in analysis and recommendations. Load it before a major recommendation or on an explicit request from the user for a strong challenge ("challenge this", "find the weak spots", "tear it apart", "devil's advocate", "red team", and so on).

---

## 1. Premortem

**When:** before every recommendation (built into the text, 3-5 lines). For major deliverables, a separate micro-section.

**Protocol:**
1. Imagine: "6 months have passed since we carried out this recommendation. It failed."
2. Answer the questions:
   - What is the most likely cause of the failure?
   - Which assumption, if it turns out wrong, breaks the whole logic?
   - What are we ignoring right now because we don't want to think about it?
3. Formulate the 2-3 most plausible failure modes

**Example of building it in:**

> Recommendation - move three key contracts to usage-based pricing.
>
> *Premortem:* in 6 months this may fail if (a) volume turns out below forecast - then usage-based gives a smaller cash flow; (b) X revises its offer after Y signs and raises the rate; (c) the operations team does not manage to rebuild its processes for variable invoicing. Mitigations: floor pricing in the contract; parallel negotiations with all three; pre-work with finance ops.

**Anti-pattern:** a premortem for form's sake ("something might go wrong"). It has to be concrete and attackable.

---

## 2. Outside View (Reference Class Forecasting)

**When:** estimating project duration, the ROI of an initiative, the success of a market entry, M&A synergies, any forecast where precedents exist.

**Protocol:**
1. Inside view (the usual one): "here are our specific factors, so it will be X"
2. **Outside view:** find a reference class - similar projects / initiatives / deals in the industry or at the company. What is the base rate?
3. Compare: your inside-view forecast vs the base rate. If the gap is >20%, why do you think you are the exception?

**Example reference classes:**
- M&A synergies: 70-90% of deals do not reach 100% of the announced synergies; average realisation is 40-60%
- IT projects in large corporations: ~50% overrun the budget by 2×, ~30% never reach production
- Market entry into a new geography: the average break-even is 2-3× the original plan
- Time to MVP in start-ups: middle estimate × 1.6-2.2

**Protection against the planning fallacy** (systematic underestimation of duration / overestimation of success).

---

## 3. Red Team / Blue Team

**When:** a major strategic decision, an investment, readiness to defend a recommendation in public.

**Protocol:**
1. **Blue team** - your current position, with all its arguments
2. **Red team** - the strongest counter-case. Not a strawman; the task is to make Blue team **lose** the debate
   - Find the 3 strongest contrarian arguments
   - Point out which data Blue team ignores / interprets favourably
   - Offer an alternative interpretation of the same facts
3. Compare: where Blue team holds, where Red team breaks through
4. Decide: either strengthen Blue team (close the weaknesses found) or revise the position

**Critical:** Red team has to be honest. Done for form's sake, it is pointless. Test: after Red team, do you want to revise the recommendation on at least one point? If not, either the position really is unbreakable (rare) or Red team was weak.

---

## 4. Devil's Advocate

**When:** the user explicitly asked for it ("challenge this", "critique it", "be harsher", "devil's advocate", "not convinced", "I doubt it", "tear it apart").

**Difference from Red Team:** less structured, more aggressive; the task is to shake the user's position as hard as possible.

**Protocol:**
1. Take the contrarian position fully; do not hedge with "on the one hand / on the other hand"
2. Formulate the 3-5 strongest arguments **against** the user's position
3. State what would have to be true for the user's position to turn out wrong
4. Name the weakest point of their argument
5. **At the end** - an honest assessment: "if these counter-arguments did not get through to you, your position held; if even one caught, here is what to rethink"

**Don't:**
- Don't turn it into Q&A ("maybe you took X into account?"). Devil's advocate makes statements, not questions
- Don't leave "safe" caveats ("you are most likely right, but just in case...")
- Don't go after straw men - attack the strongest version of the user's argument

---

## 5. Bias Busters (typical traps)

A checklist to run before the final recommendation. Not all of them apply every time - pick the relevant ones.

| Bias | How it shows up | How to check |
|------|----------------|---------------|
| **Anchoring** | The first figure named (plan, estimate, price) sets the range for everything that follows | Name your figure independently, before you hear anyone else's; recalculate from scratch |
| **Confirmation** | We look for confirmation of the hypothesis and ignore refutations | Look for the killer fact first; ask explicitly "what data would refute this?" |
| **Sunk cost** | "We already invested X, we have to keep going" | Ignore past costs; decide from zero: "would I invest Y now to get Z?" |
| **Availability** | Recent / vivid cases seem more frequent | Ask "what is the base rate?" (see Outside View) |
| **Overconfidence** | A narrow range of estimates with no admission of the unknown | Let the 90% confidence interval be really wide; explicit Low/Med/High calibration |
| **Halo effect** | A good impression of X carries over to the assessment of everything linked to X | Assess each aspect separately; do not let "the company is great" → "their idea is great" |
| **Sunflower bias** | The team adjusts to the opinion of the leader / client | Everyone formulates a position **before** the discussion; pre-mortem individually, then discuss |
| **Loss aversion** | We overweight potential losses vs equivalent gains | Reframe: instead of "may lose X" - "may not gain the equivalent of X" |
| **Status quo bias** | Keeping the current state by default | Compare "carry on as now" vs "starting from zero today - would I choose this?" |
| **Framing** | The same situation framed positively vs negatively leads to different decisions | Reframe the problem statement and the recommendation; does everything still look fine? |

---

## When to use what

| Situation | Tool |
|----------|-----------|
| Any recommendation (always) | **Premortem** (short, built in) |
| Forecast of time / ROI / success | **Outside View** (reference class) |
| A major decision, readiness to defend it | **Red Team / Blue Team** |
| The user explicitly asks to challenge | **Devil's Advocate** (strong-form) |
| Final check before a deliverable | **Bias Busters** (checklist) |

Do not apply everything at once - it tires the reader and breaks the flow. Pick the tool to match the stakes.
