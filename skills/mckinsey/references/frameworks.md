# Frameworks Reference

Расширенный методологический арсенал. Подгружается режимами **Issue Tree**, **Расчёт**, **Draft** или когда задача требует не-ядерного фреймворка.

---

## Базовые (применять без подгрузки, здесь — точные формулировки)

### MECE Principle
Mutually Exclusive, Collectively Exhaustive. Любая группировка - без перекрытий, без пробелов.

**ME-check:** найти сущность (клиент / продукт / сценарий), попадающую в 2+ категории. Если есть - переопределить границы.
**CE-check:** что не попало никуда (residual)? Если >10% значимого - добавить категорию или явно вынести в scope-out.

Анти-паттерны: catch-all «Другое» >30%; интуитивные лейблы без определения порога («крупные/средние/малые» без чисел).

### SCQA
Situation (что есть, аудитория согласна) → Complication (что изменилось / почему статус-кво нежизнеспособен) → Question (естественно возникает, часто не озвучивается) → Answer (вершина пирамиды).

### Pyramid Principle (Minto)
Answer first, evidence second. Governing thought (вершина) → 3-5 supporting pillars (MECE) → evidence per pillar.

Правило: первый абзац = полный ответ; всё остальное - доказательства. Никогда не хоронить вывод.

### Issue Tree
Top-down декомпозиция:
- Root question - одно предложение с границами (география, горизонт, цель)
- Level 1 (3-5 веток) - основные измерения, MECE
- Level 2+ - конкретные, эмпирически проверяемые подвопросы
- Для каждого терминала: источник данных + формат ответа + какое решение информирует
- Критический путь: 2-3 ветки, ответ на которые снимает больше всего неопределённости

Анти-паттерн: solution tree (декомпозиция готовых ответов) вместо issue tree (декомпозиция вопроса) → confirmation bias.

### Hypothesis-Driven
Формат: «Мы считаем, что [X], потому что [Y], что означает [Z] должно наблюдаться».

1. Сформулировать гипотезу (одно фальсифицируемое предложение)
2. 3 strongest confirming evidence
3. **1 killer fact (самое убедительное опровержение) - искать первым** (по Попперу)
4. Confidence calibration
5. Документировать эволюцию гипотезы

---

## So-What Test

Каждый finding проходит три уровня:
```
FINDING:    [наблюдение]
SO WHAT:    [конкретная импликация для решения]
THEREFORE:  [конкретное рекомендуемое действие]
```

Тест удаления: если finding убрать и рекомендация не изменится - finding не нужен. Описания без So-What → приложение, не основной текст.

---

## Specificity Filter

Если предложение можно вставить в отчёт о ЛЮБОЙ компании / любом рынке - удалить.

Запрещено / Замена:
- «Рынок конкурентный» → «3 игрока контролируют 72% рынка, HHI = 2100»
- «Технологии важны» → «LLM-интеграция - table stakes с 2025, 8/10 конкурентов имеют AI-фичи»
- «Потребности клиентов различаются» → «Enterprise платит 5× SMB, требует SOC2 и SLA 99.9%»

Тест фальсифицируемости: можно ли опровергнуть утверждение данными? Если нет - оно не аналитическое.

---

## Расширенные структурные фреймворки

### Profitability Tree
**Когда:** падение прибыли, оценка экономики бизнес-юнита.

```
Profit = Revenue − Cost
  Revenue = Price × Volume
    Price = базовая цена − скидки/возвраты
    Volume = # клиентов × частота × средний чек
  Cost = Variable + Fixed
    Variable = COGS + sales/marketing per unit
    Fixed = G&A + R&D + facilities
```

Стартовать всегда отсюда для profitability-кейсов; декомпозировать только ту ветку, где найден gap.

### Porter's Five Forces
**Когда:** оценка структурной привлекательности рынка / отрасли.

1. Угроза новых игроков (барьеры входа)
2. Угроза заменителей (substitution)
3. Власть поставщиков
4. Власть покупателей
5. Внутриотраслевая конкуренция

Анти-паттерн: применять механически. Спрашивать: «какая из 5 сил доминирует здесь и почему?» Если ни одна не критична - не использовать Porter, использовать что-то ещё.

### BCG Growth-Share Matrix
**Когда:** портфель продуктов / бизнес-юнитов, аллокация инвестиций.

Оси: market growth (Y) × relative market share (X). Квадранты: Stars / Cash Cows / Question Marks / Dogs.

Ловушка: «Dog» не всегда плохо, если генерирует cash без инвестиций; «Star» не всегда хорошо, если требует постоянных вливаний.

### McKinsey 7-S
**Когда:** organizational diagnosis / change management.

Hard: Strategy, Structure, Systems.
Soft: Shared Values (центр), Skills, Style, Staff.

Используется для проверки выравнивания: если меняется один S, какие из остальных тоже должны измениться?

### Ansoff Matrix
**Когда:** growth strategy.

Оси: market (existing / new) × product (existing / new). Квадранты: Market Penetration / Product Development / Market Development / Diversification (риск растёт по диагонали).

### Value Chain (Porter)
**Когда:** анализ источника competitive advantage / поиск процесса для оптимизации.

Primary: Inbound Logistics → Operations → Outbound Logistics → Marketing & Sales → Service.
Support: Firm Infrastructure, HR, Technology, Procurement.

Margin = разница между value, который покупатель готов платить, и стоимостью activities.

### 4P / 4C
**4P (firm view):** Product, Price, Place, Promotion.
**4C (customer view):** Customer Solution, Cost, Convenience, Communication.

Когда: маркетинговый mix, go-to-market.

### Double Diamond
**Когда:** problem discovery > solutioning. Разделяет divergent (поиск) и convergent (выбор) на двух уровнях.

Discover (divergent: понять проблему) → Define (convergent: сформулировать) → Develop (divergent: генерировать решения) → Deliver (convergent: выбрать и внедрить).

Защита от framework dump: заставляет провести real problem discovery до прыжка в решения.

---

## Расчётные фреймворки

### TAM / SAM / SOM
- **TAM** (Total Addressable Market) - весь рынок, если бы продукт купили все, кому он применим
- **SAM** (Serviceable Addressable) - часть TAM, реально доступная (география, регуляции, каналы)
- **SOM** (Serviceable Obtainable) - реалистичная доля SAM, которую можно захватить за горизонт

Считать **двумя способами** (top-down: рынок × доля; bottom-up: # клиентов × средний чек × частота). Если разлёт >2× - где-то ошибка в допущениях.

### Sanity Checks для расчётов
- Порядок величины vs benchmark (известные конкуренты, отраслевые отчёты)
- Cross-check альтернативной формулой
- Sensitivity: ±20% по 2-3 ключевым допущениям → как меняется результат
- «Реально ли столько людей купят?» - bottom-up проверка через население / организации / транзакции

### Unit Economics базовые
- **CAC** (Customer Acquisition Cost) - sales + marketing / # новых клиентов
- **LTV** (Lifetime Value) - средний чек × частота × срок жизни × gross margin
- **Payback period** - CAC / (monthly contribution margin per customer)
- **LTV/CAC** ≥ 3 - здоровая модель; < 1 - убыточная

---

## Тактические инструменты

### 5 Whys
Для root cause analysis. Спрашивать «почему?» 5 раз подряд от симптома вглубь.

Ловушка: 5 Whys предполагает линейную причину; для systemic issues лучше Issue Tree.

### 80/20 (Pareto)
Принцип неравномерности. 80% impact обычно от 20% factors.

В консалтинге: после Issue Tree спросить «какая ветка даёт 80% impact?» и фокусироваться там, не пытаться decompose всё.

---

## Cross-Framework Integration

| Задача | Primary | Supporting | Последовательность |
|--------|---------|-----------|-------------------|
| Падение прибыли | Profitability Tree | 5 Whys по найденной ветке | Tree → найти gap → 5 Whys |
| Входить ли на рынок | Market Attractiveness | Porter's → TAM/SAM/SOM | Porter's → Sizing → Score |
| Как конкурировать | Competitive Positioning | Value Chain, 4P | Где margin → как защищать |
| Уязвимость конкурента | Issue Tree + Hypothesis | 7-S, Value Chain | Hypothesis → Evidence |
| Устойчива ли модель | Unit Economics | Scenario Planning | LTV/CAC → Stress |
| Как структурировать отчёт | Pyramid | MECE, Issue Tree | Tree → MECE → Pyramid |
| Growth strategy | Ansoff | BCG | Ansoff (где растём) → BCG (что инвестируем) |
| Org redesign | 7-S | Value Chain | 7-S (alignment) → Value Chain (где value) |
