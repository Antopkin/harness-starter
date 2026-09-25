# Frameworks Reference

The extended methodological arsenal. Loaded by the **Issue Tree**, **Calculation** and **Draft** modes, or when a task needs a non-core framework.

---

## Basic (apply without loading; here are the exact wordings)

### MECE Principle
Mutually Exclusive, Collectively Exhaustive. Any grouping has no overlaps and no gaps.

**ME check:** find an entity (client / product / scenario) that falls into 2+ categories. If there is one, redraw the boundaries.
**CE check:** what did not land anywhere (residual)? If it is >10% of what matters, add a category or move it explicitly to scope-out.

Anti-patterns: a catch-all "Other" >30%; intuitive labels without a defined threshold ("large/medium/small" without numbers).

### SCQA
Situation (what is, the audience agrees) → Complication (what has changed / why the status quo is not viable) → Question (arises naturally, often unspoken) → Answer (the top of the pyramid).

### Pyramid Principle (Minto)
Answer first, evidence second. Governing thought (the top) → 3-5 supporting pillars (MECE) → evidence per pillar.

Rule: the first paragraph = the full answer; everything else is proof. Never bury the conclusion.

### Issue Tree
Top-down decomposition:
- Root question - one sentence with boundaries (geography, horizon, goal)
- Level 1 (3-5 branches) - the main dimensions, MECE
- Level 2+ - concrete, empirically testable sub-questions
- For each leaf: data source + answer format + which decision it informs
- Critical path: the 2-3 branches whose answers remove the most uncertainty

Anti-pattern: a solution tree (decomposing ready-made answers) instead of an issue tree (decomposing the question) → confirmation bias.

### Hypothesis-Driven
Format: "We believe that [X], because [Y], which means [Z] should be observed".

1. Formulate the hypothesis (one falsifiable sentence)
2. The 3 strongest confirming pieces of evidence
3. **1 killer fact (the most convincing refutation) - look for it first** (after Popper)
4. Confidence calibration
5. Document how the hypothesis evolves

---

## So-What Test

Every finding passes three levels:
```
FINDING:    [observation]
SO WHAT:    [concrete implication for the decision]
THEREFORE:  [concrete recommended action]
```

Removal test: if you remove the finding and the recommendation does not change, the finding is not needed. Descriptions without a So-What go to the appendix, not the main text.

---

## Specificity Filter

If a sentence could be pasted into a report about ANY company / any market, delete it.

Forbidden / Replacement:
- "The market is competitive" → "3 players control 72% of the market, HHI = 2100"
- "Technology matters" → "LLM integration has been table stakes since 2025; 8/10 competitors have AI features"
- "Customer needs differ" → "Enterprise pays 5× SMB and requires SOC2 and a 99.9% SLA"

Falsifiability test: can the statement be refuted with data? If not, it is not analytical.

---

## Extended structural frameworks

### Profitability Tree
**When:** falling profit, assessing the economics of a business unit.

```
Profit = Revenue − Cost
  Revenue = Price × Volume
    Price = base price − discounts/returns
    Volume = # customers × frequency × average ticket
  Cost = Variable + Fixed
    Variable = COGS + sales/marketing per unit
    Fixed = G&A + R&D + facilities
```

Always start here for profitability cases; decompose only the branch where the gap is found.

### Porter's Five Forces
**When:** assessing the structural attractiveness of a market / industry.

1. Threat of new entrants (barriers to entry)
2. Threat of substitutes (substitution)
3. Supplier power
4. Buyer power
5. Rivalry within the industry

Anti-pattern: applying it mechanically. Ask: "which of the 5 forces dominates here, and why?" If none is critical, do not use Porter; use something else.

### BCG Growth-Share Matrix
**When:** a portfolio of products / business units, allocating investment.

Axes: market growth (Y) × relative market share (X). Quadrants: Stars / Cash Cows / Question Marks / Dogs.

Trap: a "Dog" is not always bad if it generates cash without investment; a "Star" is not always good if it needs constant injections.

### McKinsey 7-S
**When:** organisational diagnosis / change management.

Hard: Strategy, Structure, Systems.
Soft: Shared Values (the centre), Skills, Style, Staff.

Used to check alignment: if one S changes, which of the others must change too?

### Ansoff Matrix
**When:** growth strategy.

Axes: market (existing / new) × product (existing / new). Quadrants: Market Penetration / Product Development / Market Development / Diversification (risk grows along the diagonal).

### Value Chain (Porter)
**When:** analysing the source of competitive advantage / looking for a process to optimise.

Primary: Inbound Logistics → Operations → Outbound Logistics → Marketing & Sales → Service.
Support: Firm Infrastructure, HR, Technology, Procurement.

Margin = the difference between the value the buyer is willing to pay for and the cost of the activities.

### 4P / 4C
**4P (firm view):** Product, Price, Place, Promotion.
**4C (customer view):** Customer Solution, Cost, Convenience, Communication.

When: the marketing mix, go-to-market.

### Double Diamond
**When:** problem discovery > solutioning. Separates divergent (search) and convergent (choice) thinking on two levels.

Discover (divergent: understand the problem) → Define (convergent: formulate it) → Develop (divergent: generate solutions) → Deliver (convergent: choose and implement).

Protection against a framework dump: it forces real problem discovery before the jump to solutions.

---

## Calculation frameworks

### TAM / SAM / SOM
- **TAM** (Total Addressable Market) - the whole market, if everyone the product applies to bought it
- **SAM** (Serviceable Addressable) - the part of TAM that is really reachable (geography, regulation, channels)
- **SOM** (Serviceable Obtainable) - the realistic share of SAM that can be captured within the horizon

Calculate it **two ways** (top-down: market × share; bottom-up: # customers × average ticket × frequency). If the gap is >2×, there is an error somewhere in the assumptions.

### Sanity Checks for calculations
- Order of magnitude vs a benchmark (known competitors, industry reports)
- Cross-check with an alternative formula
- Sensitivity: ±20% on 2-3 key assumptions → how the result changes
- "Will that many people really buy?" - a bottom-up check through population / organisations / transactions

### Basic Unit Economics
- **CAC** (Customer Acquisition Cost) - sales + marketing / # new customers
- **LTV** (Lifetime Value) - average ticket × frequency × lifetime × gross margin
- **Payback period** - CAC / (monthly contribution margin per customer)
- **LTV/CAC** ≥ 3 - a healthy model; < 1 - a loss-making one

---

## Tactical tools

### 5 Whys
For root cause analysis. Ask "why?" 5 times in a row, from the symptom downwards.

Trap: 5 Whys assumes a linear cause; for systemic issues an Issue Tree is better.

### 80/20 (Pareto)
The principle of unevenness. 80% of the impact usually comes from 20% of the factors.

In consulting: after the Issue Tree, ask "which branch gives 80% of the impact?" and focus there instead of trying to decompose everything.

---

## Cross-Framework Integration

| Task | Primary | Supporting | Sequence |
|--------|---------|-----------|-------------------|
| Falling profit | Profitability Tree | 5 Whys on the branch found | Tree → find the gap → 5 Whys |
| Whether to enter a market | Market Attractiveness | Porter's → TAM/SAM/SOM | Porter's → Sizing → Score |
| How to compete | Competitive Positioning | Value Chain, 4P | Where the margin is → how to defend it |
| A competitor's vulnerability | Issue Tree + Hypothesis | 7-S, Value Chain | Hypothesis → Evidence |
| Is the model sustainable | Unit Economics | Scenario Planning | LTV/CAC → Stress |
| How to structure a report | Pyramid | MECE, Issue Tree | Tree → MECE → Pyramid |
| Growth strategy | Ansoff | BCG | Ansoff (where we grow) → BCG (what we invest in) |
| Org redesign | 7-S | Value Chain | 7-S (alignment) → Value Chain (where the value is) |
