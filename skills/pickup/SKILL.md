---
name: pickup
description: "Подхватить работу из свежайшего (или указанного) handoff-документа. Слэш-вызов /pickup [абсолютный путь]."
argument-hint: "optional: absolute path to a handoff .md"
disable-model-invocation: true
---

Указатель, не копия ритуала. Canonical-инструкции для подхватывающего агента уже впечатаны в каждый handoff-док (`skills/handoff` пишет их дословно) — здесь их НЕ дублируем.

1. **Определи handoff.** Передан абсолютный путь аргументом → он. Иначе — свежайший в `~/.claude/handoffs/`: `ls -t ~/.claude/handoffs/*.md 2>/dev/null | head -1`.
2. **Прочитай файл целиком** и следуй ЕГО встроенным инструкциям — секции «⚡ Инструкции для подхватывающего агента», Memory refs (загрузить первыми), Suggested skills, Active plan.
3. **EXECUTED-контракт.** Если первая строка файла — `> EXECUTED …`, handoff уже закрыт: не переисполняй, спроси владельца, что делать.
4. **Нет handoff'ов** — скажи об этом прямо, ничего не выдумывай.

Пара к `/handoff` (пишет) — этот скилл читает. Для исполнения готового плана — не сюда, а триггер «выполни план …» (см. `contexts/workflow-orchestration.md` § Plan execute pickup).
