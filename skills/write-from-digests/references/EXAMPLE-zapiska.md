# Записка: переходить ли на промпты с явным рассуждением

Реальный пример выхода навыка `write-from-digests`, собранный из **двух готовых
конспектов** `digest`:

- **S1** — Yao et al., 2023, ReAct (`skills/digest/references/EXAMPLE-digest-md.md`);
- **S2** — Wei et al., 2022, Chain-of-Thought Prompting
  (`skills/digest/references/EXAMPLE-digest-docx.md`).

Каждая дословная цитата в тексте скопирована из строки соответствующего конспекта, а
не восстановлена по памяти, поэтому проходит детерминированную сверку `grep -F` в
исходном digest (см. verification log в Приложении А). Якорь `[S1.5]` читается как
«источник S1, строка 5 его evidence-таблицы».

**Источники:** S1 — Yao et al., 2023 (ReAct); S2 — Wei et al., 2022 (Chain-of-Thought).
**Вход:** 2 конспекта digest.md  ·  **Выход:** русский · Markdown  ·  **Дата:** 2026-07-16

## 1. Рекомендация (тезис)

Для задач, где ответ надо вывести пошагово — многошаговые расчёты, вопросы с
несколькими условиями, проверка фактов, — рекомендую отказаться от промптов вида
«вопрос → ответ» в пользу промптов с явным рассуждением. Там, где ответ выводится
логикой из условия, работает chain-of-thought: в few-shot-примеры кладут не только пару
«вход → ответ», но и ход рассуждения. Там, где для ответа нужен внешний факт, работает
ReAct: модель чередует рассуждение с обращением к источнику. Обе техники — это только
про формат подсказки, без дообучения модели. Существенная оговорка: выигрыш обеих
привязан к достаточно крупным моделям, поэтому на маленькой модели приём эффекта не
даст, и внедрять его «вслепую» не стоит. Практически я предлагаю начать с одного
пилотного класса задач на крупной модели, сравнить два формата подсказки на десятке
типовых примеров и только после этого раскатывать выбранную технику шире.

## 2. Аргументация

**Обычный промпт не тянет задачи на рассуждение.** Наращивание одного лишь размера
модели не закрывает трудные задачи, а стандартный few-shot на них помогает слабо
[S2.10][S2.15]. Авторы chain-of-thought прямо фиксируют границу приёма: «it works
poorly on tasks that require reasoning abilities,» (пер.: «он плохо работает на задачах,
требующих способности рассуждать») [S2.15]. Отсюда практический вывод: если наши кейсы —
это арифметика и многошаговые вопросы, улучшать их простым подбором примеров
«вход → ответ» бесперспективно, нужен другой формат подсказки.

**Chain-of-thought поднимает качество на рассуждении без дообучения.** Если в примерах
показать модели сам ход рассуждения, достаточно крупная модель воспроизводит его и
решает заметно лучше [S2.7][S2.8]. На бенчмарке школьной математики это дало рекордную
точность: «eight chain-of-thought exemplars achieves state-of-the-art accuracy on»
«the GSM8K benchmark of math word problems, surpassing even finetuned» (пер.: «восемь
примеров с цепочкой рассуждения дают рекордную точность на GSM8K, превосходя даже
дообученную модель») [S2.7][S2.8]. То есть выигрыш получен сменой формата подсказки, а
не обучением отдельной модели под задачу — для нас это дешёвый ход.

**Где ответу нужен внешний факт — ReAct.** Chain-of-thought рассуждает «в уме» и потому
может уверенно ошибиться в факте; ReAct добавляет к рассуждению действие — обращение к
внешнему источнику [S1.2]. На вопросах с проверкой фактов это снимает выдумывание: «on
question answering (HotpotQA) and fact verification (Fever), ReAct overcomes issues of
hallucination and error propagation prevalent in chain-of-thought reasoning by
interacting with a simple Wikipedia API» (пер.: «на HotpotQA и Fever ReAct снимает
галлюцинации и распространение ошибок, характерные для chain-of-thought, за счёт
обращения к простому Wikipedia API») [S1.4]. Практический разграничитель прост: ответ
выводится из условия — берём chain-of-thought; ответу нужен факт извне — берём ReAct.

**Цена приёма низкая, но не нулевая.** Обе техники не требуют обучающего набора и
работают на готовой модели: прирост success rate ReAct получает при одном-двух примерах
в подсказке — «ReAct outperforms imitation and reinforcement learning methods by an
absolute success rate of 34% and 10% respectively, while being prompted with only one or
two in-context examples» (пер.: «...превосходит методы imitation- и
reinforcement-learning на 34% и 10% при промпте всего с одним-двумя примерами») [S1.5].
Но у выигрыша есть жёсткое условие масштаба: цепочку рассуждения порождают только
достаточно крупные модели — «show that sufficiently large language models can generate
chains of» (пер.: «...достаточно крупные модели способны порождать цепочки рассуждения»)
[S2.20]. Поэтому рекомендация действует для крупной модели; для маленькой её надо
проверять отдельным пилотом, а не переносить по аналогии.

**Границы этого вывода.** Оба конспекта построены на аннотациях и вводных разделах
статей (Abstract, Introduction, начало метода); полные разделы с экспериментами и
таблицами результатов в них не вошли — это отмечено в журналах самопроверки обоих
источников. Поэтому вывод опирается на заявленные авторами результаты и качественные
формулировки, а не на воспроизведённые нами замеры; конкретные условия (какие модели,
сколько прогонов, метрика по каждому бенчмарку) остаются на проверку по полным текстам.
Для пилота этого достаточно; для масштабирования — сверить с полными статьями и
дополнить записку числами из разделов результатов, которых в текущих конспектах нет.

---

## Приложение А. Доказательная база

По каждому источнику — его evidence-таблица из digest с колонкой-id `#` первой, затем
готовые ссылки. Всё скопировано из самих конспектов, не пересобрано.

### Источник S1 — Yao et al., 2023 — ReAct: Synergizing Reasoning and Acting in Language Models

| # | Тезис | Локатор | Дословная цитата | Раздел | Проверено |
|---|---|---|---|---|---|
| S1.1 | Рассуждение и действие ранее изучались раздельно | `## Abstract`, стр. 9 | «their abilities for reasoning (e.g. chain-of-thought prompting) and acting (e.g. action plan generation) have primarily been studied as separate topics» | Abstract | ✓ |
| S1.2 | ReAct чередует reasoning traces и действия | `## Abstract`, стр. 9 | «we explore the use of LLMs to generate both reasoning traces and task-specific actions in an interleaved manner» | Abstract | ✓ |
| S1.3 | Двусторонняя синергия: рассуждение ведёт план, действия дают внешнюю информацию | `## Abstract`, стр. 9 | «reasoning traces help the model induce, track, and update action plans as well as handle exceptions, while actions allow it to interface with external sources» | Abstract | ✓ |
| S1.4 | На HotpotQA и Fever снимает галлюцинации через Wikipedia API | `## Abstract`, стр. 9 | «on question answering (HotpotQA) and fact verification (Fever), ReAct overcomes issues of hallucination and error propagation prevalent in chain-of-thought reasoning by interacting with a simple Wikipedia API» | Abstract | ✓ |
| S1.5 | Прирост success rate 34 % и 10 % на ALFWorld и WebShop при 1–2 примерах | `## Abstract`, стр. 9 | «ReAct outperforms imitation and reinforcement learning methods by an absolute success rate of 34% and 10% respectively, while being prompted with only one or two in-context examples» | Abstract | ✓ |
| S1.6 | Улучшены интерпретируемость и доверие | `## Abstract`, стр. 9 | «improved human interpretability and trustworthiness over methods without reasoning or acting components» | Abstract | ✓ |
| S1.7 | Человеческий интеллект совмещает действия с вербальным рассуждением | `## 1 Introduction`, стр. 13 | «A unique feature of human intelligence is the ability to seamlessly combine task-oriented actions with verbal reasoning» | 1 Introduction | ✓ |
| S1.8 | ReAct — общая парадигма, промптит генерировать рассуждения и действия вперемешку | `## 1 Introduction`, стр. 15 | «ReAct prompts LLMs to generate both verbal reasoning traces and actions pertaining to a task in an interleaved manner» | 1 Introduction | ✓ |
| S1.9 | Постановка агент–среда: наблюдение и действие по политике на шаге t | `## 2 ReAct`, стр. 19 | «an agent receives an observation ot ∈ O from the environment and takes an action at ∈ A following some policy» | 2 ReAct | ✓ |
| S1.10 | Пространство действий расширяется языком: Â = A ∪ L | `## 2 ReAct`, стр. 21 | «we augment the agent's action space to Â = A ∪ L, where L is the space of language» | 2 ReAct | ✓ |
| S1.11 | «Мысль» не меняет внешнюю среду и не даёт обратной связи | `## 2 ReAct`, стр. 21 | «does not affect the external environment, thus leading to no observation feedback» | 2 ReAct | ✓ |

**Ссылка для списка литературы (S1).**
ГОСТ Р 7.0.100–2018: Yao, S. ReAct: Synergizing Reasoning and Acting in Language Models / S. Yao [et al.] // International Conference on Learning Representations (ICLR 2023). — [S. l. : s. n.], 2023. — arXiv:2210.03629. — P. [проверить].
APA 7: Yao, S., Zhao, J., Yu, D., Du, N., Shafran, I., Narasimhan, K., & Cao, Y. (2023). ReAct: Synergizing reasoning and acting in language models. In *International Conference on Learning Representations (ICLR 2023)*. https://arxiv.org/abs/2210.03629

**Цитирование S1 (.bib).**
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
  % pages     = {TODO: не указано в источнике},
  % doi       = {TODO: не указано в источнике},
}
```

### Источник S2 — Wei et al., 2022 — Chain-of-Thought Prompting Elicits Reasoning in Large Language Models

| # | Тезис | Локатор | Дословная цитата | Раздел | Проверено |
|---|---|---|---|---|---|
| S2.1 | Цепочка рассуждения — серия промежуточных шагов | §Abstract, абз. 1 | «We explore how generating a chain of thought — a series of intermediate» | Abstract | ✓ |
| S2.2 | Она заметно улучшает способность LLM к сложному рассуждению | §Abstract, абз. 1 | «reasoning steps — significantly improves the ability of large language» | Abstract | ✓ |
| S2.3 | Метод назван chain-of-thought prompting | §Abstract, абз. 1 | «models via a simple method called chain-of-thought prompting, where a» | Abstract | ✓ |
| S2.4 | Несколько демонстраций CoT даются как exemplars | §Abstract, абз. 1 | «few chain of thought demonstrations are provided as exemplars in» | Abstract | ✓ |
| S2.5 | Эксперименты на трёх больших LLM | §Abstract, абз. 1 | «Experiments on three large language models show that» | Abstract | ✓ |
| S2.6 | Улучшение на арифметике, здравом смысле, символике | §Abstract, абз. 1 | «chain-of-thought prompting improves performance on a range of» | Abstract | ✓ |
| S2.7 | PaLM 540B + 8 CoT-примеров → SOTA-точность | §Abstract, абз. 1 | «eight chain-of-thought exemplars achieves state-of-the-art accuracy on» | Abstract | ✓ |
| S2.8 | На GSM8K превосходит даже дообученную модель | §Abstract, абз. 1 | «the GSM8K benchmark of math word problems, surpassing even finetuned» | Abstract | ✓ |
| S2.9 | Превзойдена именно GPT-3 с верификатором | §Abstract, абз. 1 | «GPT-3 with a verifier.» | Abstract | ✓ |
| S2.10 | Масштаб модели сам по себе недостаточен для трудных задач | §1 Introduction, абз. 1 | «up model size alone has not proved sufficient for achieving high» | 1 Introduction | ✓ |
| S2.11 | Метод мотивирован двумя идеями | §1 Introduction, абз. 2 | «can be unlocked by a simple method motivated by two ideas. First,» | 1 Introduction | ✓ |
| S2.12 | Вторая идея — in-context few-shot через prompting | §1 Introduction, абз. 2 | «large language models offer the exciting prospect of in-context few-shot» | 1 Introduction | ✓ |
| S2.13 | У обеих прежних идей есть ключевые ограничения | §1 Introduction, абз. 3 | «Both of the above ideas, however, have key limitations. For» | 1 Introduction | ✓ |
| S2.14 | Создание большого набора качественных rationales дорого | §1 Introduction, абз. 3 | «create a large set of high quality rationales, which is much more» | 1 Introduction | ✓ |
| S2.15 | Обычный few-shot плохо работает на задачах с рассуждением | §1 Introduction, абз. 3 | «it works poorly on tasks that require reasoning abilities,» | 1 Introduction | ✓ |
| S2.16 | Определение CoT: шаги, ведущие к финальному ответу | §1 Introduction, абз. 3 | «natural language reasoning steps that lead to the final output, and we» | 1 Introduction | ✓ |
| S2.17 | CoT с PaLM 540B превосходит стандартный prompting | §1 Introduction, абз. 4 | «chain-of-thought prompting with PaLM 540B outperforms standard prompting» | 1 Introduction | ✓ |
| S2.18 | Prompting-only не требует большого обучающего набора | §1 Introduction, абз. 4 | «prompting-only approach is important because it does not require a large» | 1 Introduction | ✓ |
| S2.19 | Цель — научить LM порождать цепочку рассуждения | §2 Chain-of-Thought Prompting, абз. 1 | «generate a similar chain of thought — a coherent series of intermediate» | 2 Chain-of-Thought Prompting | ✓ |
| S2.20 | CoT порождают только достаточно крупные модели | §2 Chain-of-Thought Prompting, абз. 1 | «show that sufficiently large language models can generate chains of» | 2 Chain-of-Thought Prompting | ✓ |
| S2.21 | Свойство 1: больше вычислений на сложные задачи | §2 Chain-of-Thought Prompting, абз. 2 | «into intermediate steps, which means that additional computation can be» | 2 Chain-of-Thought Prompting | ✓ |
| S2.22 | Свойство 2: интерпретируемое окно в поведение модели | §2 Chain-of-Thought Prompting, абз. 2 | «of thought provides an interpretable window into the behavior of the» | 2 Chain-of-Thought Prompting | ✓ |
| S2.23 | Свойство 3: применимо к широкому классу задач | §2 Chain-of-Thought Prompting, абз. 2 | «Third, chain-of-thought reasoning can be used for tasks such as math» | 2 Chain-of-Thought Prompting | ✓ |
| S2.24 | Свойство 4: вызывается в готовых крупных моделях | §2 Chain-of-Thought Prompting, абз. 2 | «Finally, chain-of-thought reasoning can be readily elicited in» | 2 Chain-of-Thought Prompting | ✓ |

**Ссылка для списка литературы (S2).**
ГОСТ Р 7.0.100–2018: Wei, J. Chain-of-Thought Prompting Elicits Reasoning in Large Language Models / J. Wei [et al.] // Advances in Neural Information Processing Systems 35 (NeurIPS 2022). — [S. l. : s. n.], 2022. — P. [проверить]. — arXiv:2201.11903.
APA 7: Wei, J., Wang, X., Schuurmans, D., Bosma, M., Ichter, B., Xia, F., Chi, E. H., Le, Q. V., & Zhou, D. (2022). Chain-of-thought prompting elicits reasoning in large language models. In *Advances in Neural Information Processing Systems 35 (NeurIPS 2022)* (pp. [проверить]). https://arxiv.org/abs/2201.11903

**Цитирование S2 (.bib).**
```bibtex
@inproceedings{wei2022chain,
  author        = {Wei, Jason and Wang, Xuezhi and Schuurmans, Dale and Bosma, Maarten and Ichter, Brian and Xia, Fei and Chi, Ed and Le, Quoc and Zhou, Denny},
  title         = {Chain-of-Thought Prompting Elicits Reasoning in Large Language Models},
  booktitle     = {36th Conference on Neural Information Processing Systems (NeurIPS 2022)},
  year          = {2022},
  eprint        = {2201.11903},
  archivePrefix = {arXiv},
  primaryClass  = {cs.CL},
  url           = {https://arxiv.org/abs/2201.11903},
  % volume      = {% TODO: проверить},
  % pages       = {% TODO: проверить},
  % doi         = {% TODO: проверить},
}
```

### Verification log (обратный проход)

- **Якорей в тексте:** 11 (S2.10, S2.15×2, S2.7×2, S2.8×2, S1.2, S1.4, S1.5, S2.20),
  ссылаются на 8 различных строк пула.
- **Дословных цитат сверено:** 6 из 6 — все `grep -F` в исходном digest = найдено:
  `it works poorly on tasks that require reasoning abilities,` (S2.15) → S2;
  `eight chain-of-thought exemplars achieves state-of-the-art accuracy on` (S2.7) → S2;
  `the GSM8K benchmark of math word problems, surpassing even finetuned` (S2.8) → S2;
  `on question answering (HotpotQA) and fact verification (Fever), ReAct overcomes issues of hallucination and error propagation prevalent in chain-of-thought reasoning by interacting with a simple Wikipedia API` (S1.4) → S1;
  `ReAct outperforms imitation and reinforcement learning methods by an absolute success rate of 34% and 10% respectively, while being prompted with only one or two in-context examples` (S1.5) → S1;
  `show that sufficiently large language models can generate chains of` (S2.20) → S2.
- **Флагов ⚠:** 0. Ни одно несущее утверждение не осталось без якоря (G1), ни одна
  цитата не потребовала hedge/delete.
- **Метод:** для каждой цитаты — `grep -F "цитата" исходный-digest.md` = найдено;
  локаторы (Abstract, §1 Introduction, §2 Chain-of-Thought Prompting) переоткрыты в
  соответствующем конспекте. Проверка портативная: повторное чтение того же файла и
  детерминированный `grep -F`, без Python внутри логики навыка.

---

## Приложение Б. Выход в действие (плейсхолдер fill-form)

Место под скриншоты «до/после» заполнения формы. Заполняется навыком `fill-form`; здесь —
только раздел под него.

- [ ] Скриншот: форма выбора техники промптинга до заполнения.
- [ ] Скриншот: форма после заполнения (выбрана техника под тип задачи).
- [ ] Короткая подпись: какое решение записки внесено в форму (chain-of-thought для
      задач на вывод, ReAct для задач с внешним фактом; проверка масштаба модели —
      отдельным пунктом).
