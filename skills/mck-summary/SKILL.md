---
name: mck-summary
description: "Pyramid executive summary в стиле Big-3 из готового материала. Слэш-вызов /mck-summary [тема или путь]."
argument-hint: "тема или путь к материалу"
disable-model-invocation: true
---

Тонкая обёртка, не копия. Правила формата НЕ переписываем — читаем источник и следуем ему.

1. **Прочитай источник структуры:** `~/.claude/skills/mckinsey/references/deliverables.md` §1 «Pyramid Executive Summary» (SCQA-opening; governing thought в первом-втором абзаце; 3 MECE-pillar'а, каждый с evidence; So-What в конце; 250–500 слов; без bullet'ов в основном тексте).
2. **Собери summary** строго по этому каркасу из переданного материала (тема или путь в аргументе).
3. **Прогони через `/ru-text`** (типографика + инфостиль) перед выдачей.

Для полноценной проблемной работы (issue/hypothesis trees, market sizing, push-back) — не сюда, а скилл `/mckinsey`.
