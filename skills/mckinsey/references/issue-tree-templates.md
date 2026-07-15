# Issue Tree Templates

Скелеты для типовых классов задач. **Использовать как сверку, не как cookie cutter** - адаптировать под контекст; каждое шаблонное дерево покрывает ~70% случаев своего класса, остальное добивать вручную.

Каждый шаблон проверять MECE-чеком (ME + CE) после адаптации.

---

## 1. Profitability Decline

**Root question:** Почему прибыль X-бизнеса упала на Y% за период Z?

```
Прибыль упала
├── Revenue упала
│   ├── Цена снизилась (discounting, churn в high-tier, mix shift)
│   ├── Volume снизился
│   │   ├── # клиентов: новые (acquisition) vs существующие (churn)
│   │   ├── Частота покупки на клиента
│   │   └── Средний чек на покупку
│   └── Mix сдвинулся в low-margin segment
│
├── Cost вырос
│   ├── Variable cost
│   │   ├── COGS (сырьё, производство, единичная себестоимость)
│   │   └── Sales/marketing per unit (CAC растёт)
│   └── Fixed cost
│       ├── G&A, R&D, facilities
│       └── Stranded capacity (объёмы упали, но fixed cost остался)
│
└── Один из эффектов compound (Revenue ↓ + Cost ↑ одновременно)
```

**Типичные ошибки:**
- Сразу спрыгнуть в ветку «cost растёт», не проверив revenue (revenue гэп обычно крупнее)
- Не разделить external (рынок упал) vs internal (мы упали vs рынок)
- Игнорировать mix shift (можно потерять прибыль при стабильных volume и price)

---

## 2. Market Entry

**Root question:** Стоит ли компании C войти на рынок M в горизонте T?

```
Стоит ли войти?
├── 1. Привлекательность рынка
│   ├── Размер (TAM/SAM/SOM, рост)
│   ├── Структурная привлекательность (Porter's 5F)
│   ├── Profit pools (где маржа в value chain)
│   └── Будущие тренды (PESTEL, технологические шифты)
│
├── 2. Способность выиграть (right to win)
│   ├── Релевантные компетенции / активы
│   ├── Дифференциация vs incumbents
│   ├── Доступ к каналам / клиентам
│   └── Cost position
│
├── 3. Экономика входа
│   ├── Investment to enter (capex, R&D, GTM)
│   ├── Время до break-even
│   ├── Ожидаемая доля и ARPU
│   └── Sensitivity по ключевым допущениям
│
└── 4. Стратегическая cohesion
    ├── Synergies с существующим бизнесом
    ├── Opportunity cost (что не делаем взамен)
    └── Reputational / regulatory risks
```

**Типичные ошибки:**
- Считать только размер рынка, забывая про right to win
- Игнорировать opportunity cost
- Optimistic assumptions без stress-test

---

## 3. M&A / Make-or-Buy

**Root question:** Должна ли C приобрести / построить / партнёриться для capability X?

```
Make / Buy / Partner для X?
├── Strategic fit
│   ├── Насколько X core к стратегии C
│   ├── Уровень контроля, который нужен
│   └── Скорость time-to-market
│
├── Make
│   ├── Необходимые ресурсы / срок до готовности
│   ├── Risk of failure / opportunity cost
│   └── Long-term cost vs Buy
│
├── Buy
│   ├── Доступные targets, цена, premium
│   ├── Integration complexity / cultural fit
│   ├── Synergies (revenue + cost) - реалистичные, не презентационные
│   └── Risks (key talent, customer flight, antitrust)
│
└── Partner
    ├── Доступные partners
    ├── Stability партнёрства / lock-in
    └── Доля value, которую партнёр забирает
```

**Типичные ошибки:**
- Завышать synergies в Buy (исторически 70-90% deals не дают обещанных synergies)
- Игнорировать integration cost
- Не сравнивать все три варианта (только Make vs Buy)

---

## 4. Pricing

**Root question:** Какую цену установить для продукта P в сегменте S?

```
Какую цену?
├── Cost-based floor
│   ├── Variable cost (нижняя граница short-run)
│   └── Fully-loaded cost (нижняя граница long-run)
│
├── Value-based ceiling
│   ├── Value to customer (savings / revenue gain / outcome)
│   ├── Next-best alternative customer (NBA) и её цена
│   └── Price elasticity сегмента
│
├── Competitive context
│   ├── Прямые конкуренты, их прайсинг
│   ├── Substitutes
│   └── Position (premium / parity / penetration)
│
└── Pricing structure
    ├── Модель (per-unit / subscription / usage / tiered / freemium)
    ├── Discount policy и floor
    └── Bundling / price discrimination между сегментами
```

**Типичные ошибки:**
- Cost-plus без проверки willingness to pay
- Игнорировать value to customer (можно недозабрать 30-50%)
- Одна цена для всех сегментов с разной WTP

---

## 5. Operations / Process Improvement

**Root question:** Как улучшить процесс P (повысить throughput / снизить cost / повысить quality)?

```
Улучшение процесса P
├── Diagnose where the gap is
│   ├── Map current state (steps, time, cost, quality)
│   ├── Identify bottlenecks (по теории ограничений)
│   └── Quantify gap vs benchmark / target
│
├── Lever 1: Eliminate (что не нужно делать вообще)
│   ├── Дублирующие шаги
│   └── Steps без value-add
│
├── Lever 2: Simplify (что упростить)
│   ├── Уменьшить варианты
│   └── Стандартизация
│
├── Lever 3: Automate (что автоматизировать)
│   ├── Repeatable rule-based steps
│   └── ROI vs автоматизация
│
└── Lever 4: Reorganize (как перестроить flow)
    ├── Параллелизация sequential steps
    ├── Изменить sequence
    └── Изменить ownership (кто делает)
```

**Типичные ошибки:**
- Сразу прыгать в Automate, не пройдя Eliminate / Simplify (автоматизация ненужного процесса даёт быстрый legacy)
- Не quantify gap до начала
- Локальные оптимизации без учёта end-to-end эффекта

---

## 6. Org Design / Restructuring

**Root question:** Как структурировать организацию O для достижения целей G?

```
Org structure
├── 1. Стратегические требования
│   ├── Что org должен уметь делать (capabilities)
│   ├── Critical decisions, которые принимаются (где)
│   └── Speed vs control trade-off
│
├── 2. Структура (units / hierarchy)
│   ├── Functional / divisional / matrix / network
│   ├── Уровни и spans of control
│   └── Где shared services vs embedded
│
├── 3. Governance (decision rights)
│   ├── Кто принимает решения (RACI)
│   ├── Где accountability
│   └── Эскалация
│
├── 4. People (talent, leadership)
│   ├── Skills gaps по новой структуре
│   ├── Кого продвигать / нанимать / отпускать
│   └── Leadership development
│
└── 5. Culture & change management
    ├── Behaviors, которые поддерживают новую структуру
    ├── Incentives / metrics
    └── Communication / transition план
```

**Типичные ошибки:**
- Менять boxes на org chart, не меняя decision rights и incentives
- Игнорировать culture (re-org без культурного сдвига откатывается обратно)
- Underestimate transition cost (productivity dip 6-12 мес)

---

## 7. Customer Churn / Retention

**Root question:** Почему клиенты уходят и как снизить churn в сегменте S?

```
Churn в сегменте S
├── 1. Кто уходит (segmentation)
│   ├── По cohort (когда пришли)
│   ├── По tier / use case / revenue
│   └── По behavior (high vs low engagement)
│
├── 2. Когда уходят (lifecycle moment)
│   ├── Onboarding (не активировались)
│   ├── Mid-life (после 3-6 мес активного использования)
│   └── Renewal moment (контрактные)
│
├── 3. Почему уходят (root causes)
│   ├── Product fit (не решает их problem)
│   ├── Value-perception (платят, но не видят value)
│   ├── Competitor switched (better alternative)
│   ├── Внешние (их бизнес умер / поменял приоритеты)
│   └── Service / support friction
│
└── 4. Что делать
    ├── Predict (early warning signals)
    ├── Prevent (product / experience changes)
    ├── Re-engage (campaigns)
    └── Win-back (после ухода)
```

**Типичные ошибки:**
- Считать общий churn rate без cohort/segment break-down (среднее по больнице)
- Опросы exited клиентов как единственный источник «почему» (sample bias - они уже ушли)
- Лечить симптомы (discount on renewal) без устранения root cause
