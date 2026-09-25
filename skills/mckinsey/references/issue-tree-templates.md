# Issue Tree Templates

Skeletons for typical classes of problems. **Use them as a cross-check, not a cookie cutter** - adapt them to the context; each template tree covers ~70% of the cases in its class, and the rest you fill in by hand.

Run a MECE check (ME + CE) on every template after adapting it.

---

## 1. Profitability Decline

**Root question:** Why did the profit of business X fall by Y% over period Z?

```
Profit fell
├── Revenue fell
│   ├── Price went down (discounting, churn in the high tier, mix shift)
│   ├── Volume went down
│   │   ├── # customers: new (acquisition) vs existing (churn)
│   │   ├── Purchase frequency per customer
│   │   └── Average ticket per purchase
│   └── Mix shifted into a low-margin segment
│
├── Cost grew
│   ├── Variable cost
│   │   ├── COGS (raw materials, production, unit cost)
│   │   └── Sales/marketing per unit (CAC is growing)
│   └── Fixed cost
│       ├── G&A, R&D, facilities
│       └── Stranded capacity (volumes fell, but the fixed cost stayed)
│
└── One of the effects compounds (Revenue ↓ + Cost ↑ at the same time)
```

**Typical mistakes:**
- Jumping straight into the "cost is growing" branch without checking revenue (the revenue gap is usually bigger)
- Not separating external (the market fell) from internal (we fell vs the market)
- Ignoring the mix shift (you can lose profit with stable volume and price)

---

## 2. Market Entry

**Root question:** Should company C enter market M within horizon T?

```
Should we enter?
├── 1. Market attractiveness
│   ├── Size (TAM/SAM/SOM, growth)
│   ├── Structural attractiveness (Porter's 5F)
│   ├── Profit pools (where the margin sits in the value chain)
│   └── Future trends (PESTEL, technology shifts)
│
├── 2. Ability to win (right to win)
│   ├── Relevant competences / assets
│   ├── Differentiation vs incumbents
│   ├── Access to channels / customers
│   └── Cost position
│
├── 3. Economics of entry
│   ├── Investment to enter (capex, R&D, GTM)
│   ├── Time to break-even
│   ├── Expected share and ARPU
│   └── Sensitivity on the key assumptions
│
└── 4. Strategic cohesion
    ├── Synergies with the existing business
    ├── Opportunity cost (what we don't do instead)
    └── Reputational / regulatory risks
```

**Typical mistakes:**
- Counting only the market size and forgetting the right to win
- Ignoring the opportunity cost
- Optimistic assumptions without a stress test

---

## 3. M&A / Make-or-Buy

**Root question:** Should C acquire / build / partner for capability X?

```
Make / Buy / Partner for X?
├── Strategic fit
│   ├── How core X is to C's strategy
│   ├── The level of control needed
│   └── Time-to-market speed
│
├── Make
│   ├── Resources needed / time to readiness
│   ├── Risk of failure / opportunity cost
│   └── Long-term cost vs Buy
│
├── Buy
│   ├── Available targets, price, premium
│   ├── Integration complexity / cultural fit
│   ├── Synergies (revenue + cost) - realistic, not presentation-grade
│   └── Risks (key talent, customer flight, antitrust)
│
└── Partner
    ├── Available partners
    ├── Stability of the partnership / lock-in
    └── The share of value the partner takes
```

**Typical mistakes:**
- Inflating synergies in Buy (historically 70-90% of deals do not deliver the promised synergies)
- Ignoring the integration cost
- Not comparing all three options (only Make vs Buy)

---

## 4. Pricing

**Root question:** What price should we set for product P in segment S?

```
What price?
├── Cost-based floor
│   ├── Variable cost (the short-run floor)
│   └── Fully-loaded cost (the long-run floor)
│
├── Value-based ceiling
│   ├── Value to customer (savings / revenue gain / outcome)
│   ├── The customer's next-best alternative (NBA) and its price
│   └── Price elasticity of the segment
│
├── Competitive context
│   ├── Direct competitors and their pricing
│   ├── Substitutes
│   └── Position (premium / parity / penetration)
│
└── Pricing structure
    ├── Model (per-unit / subscription / usage / tiered / freemium)
    ├── Discount policy and floor
    └── Bundling / price discrimination between segments
```

**Typical mistakes:**
- Cost-plus without checking willingness to pay
- Ignoring the value to the customer (you can leave 30-50% on the table)
- One price for all segments with different WTP

---

## 5. Operations / Process Improvement

**Root question:** How do we improve process P (raise throughput / cut cost / raise quality)?

```
Improving process P
├── Diagnose where the gap is
│   ├── Map current state (steps, time, cost, quality)
│   ├── Identify bottlenecks (theory of constraints)
│   └── Quantify gap vs benchmark / target
│
├── Lever 1: Eliminate (what not to do at all)
│   ├── Duplicate steps
│   └── Steps without value-add
│
├── Lever 2: Simplify (what to simplify)
│   ├── Reduce the variants
│   └── Standardisation
│
├── Lever 3: Automate (what to automate)
│   ├── Repeatable rule-based steps
│   └── ROI vs automation
│
└── Lever 4: Reorganize (how to rebuild the flow)
    ├── Parallelise sequential steps
    ├── Change the sequence
    └── Change the ownership (who does it)
```

**Typical mistakes:**
- Jumping straight into Automate without going through Eliminate / Simplify (automating an unneeded process gives you instant legacy)
- Not quantifying the gap before starting
- Local optimisations that ignore the end-to-end effect

---

## 6. Org Design / Restructuring

**Root question:** How should organisation O be structured to reach goals G?

```
Org structure
├── 1. Strategic requirements
│   ├── What the org must be able to do (capabilities)
│   ├── Critical decisions that get made (and where)
│   └── Speed vs control trade-off
│
├── 2. Structure (units / hierarchy)
│   ├── Functional / divisional / matrix / network
│   ├── Layers and spans of control
│   └── Where shared services vs embedded
│
├── 3. Governance (decision rights)
│   ├── Who makes the decisions (RACI)
│   ├── Where the accountability is
│   └── Escalation
│
├── 4. People (talent, leadership)
│   ├── Skills gaps under the new structure
│   ├── Whom to promote / hire / let go
│   └── Leadership development
│
└── 5. Culture & change management
    ├── Behaviours that support the new structure
    ├── Incentives / metrics
    └── Communication / transition plan
```

**Typical mistakes:**
- Moving boxes on the org chart without changing decision rights and incentives
- Ignoring culture (a re-org without a cultural shift rolls back)
- Underestimating the transition cost (a productivity dip of 6-12 months)

---

## 7. Customer Churn / Retention

**Root question:** Why do customers leave, and how do we reduce churn in segment S?

```
Churn in segment S
├── 1. Who leaves (segmentation)
│   ├── By acquisition cohort (when they joined)
│   ├── By tier / use case / revenue
│   └── By behaviour (high vs low engagement)
│
├── 2. When they leave (lifecycle moment)
│   ├── Onboarding (never activated)
│   ├── Mid-life (after 3-6 months of active use)
│   └── Renewal moment (contractual)
│
├── 3. Why they leave (root causes)
│   ├── Product fit (does not solve their problem)
│   ├── Value perception (they pay but do not see the value)
│   ├── Competitor switched (better alternative)
│   ├── External (their business died / changed priorities)
│   └── Service / support friction
│
└── 4. What to do
    ├── Predict (early warning signals)
    ├── Prevent (product / experience changes)
    ├── Re-engage (campaigns)
    └── Win-back (after they leave)
```

**Typical mistakes:**
- Counting the overall churn rate without a cohort/segment breakdown (an average that hides everything)
- Surveys of departed customers as the only source of "why" (sample bias - they have already left)
- Treating symptoms (a discount on renewal) without removing the root cause
