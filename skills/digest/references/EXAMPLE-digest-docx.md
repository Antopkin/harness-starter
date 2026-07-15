# Конспект: Wei et al., 2022 — Chain-of-Thought Prompting Elicits Reasoning in Large Language Models

Реальный пример выхода навыка `digest`, собранный на препринте arXiv:2201.11903,
источник — файл в формате docx. Навык `docx` был недоступен, поэтому текст извлечён
через `pandoc -t plain` (мягкая деградация); таблица привязки проверена литеральным
поиском цитат в извлечённом тексте, BibTeX собран вручную — навык `cite` был
недоступен.

**Библио:** Wei, J., Wang, X., Schuurmans, D., Bosma, M., Ichter, B., Xia, F., Chi, E., Le, Q., & Zhou, D. (2022). Chain-of-Thought Prompting Elicits Reasoning in Large Language Models. 36th Conference on Neural Information Processing Systems (NeurIPS 2022). arXiv:2201.11903 [cs.CL]. https://arxiv.org/abs/2201.11903
**Формат источника:** docx (текст извлечён pandoc; навык docx недоступен → мягкая деградация)  ·  **Прочитано:** §Abstract; §1 Introduction (абз. 1–4); §2 Chain-of-Thought Prompting (абз. 1–2)  ·  **Дата:** 2026-07-15

> **Ограничение извлечения.** Навык `docx` в репозитории недоступен, поэтому текст получен мягкой деградацией — командой `pandoc … -t plain`. Единица якоря в этом формате — секция (heading) плюс номер абзаца внутри секции. Извлечённый фрагмент охватывает только титул, аннотацию, Введение и начало раздела 2; последующие разделы (детали экспериментов, таблицы результатов по бенчмаркам, разбор ошибок, ограничения) в извлечённом тексте отсутствуют. Конспект отражает ровно то, что есть в извлечении, и не восполняет недостающие разделы по внешней памяти.

## Суть одной строкой
Если в few-shot-примерах показать модели не только пару вход-ответ, а цепочку промежуточных шагов рассуждения (chain of thought), достаточно крупная языковая модель воспроизводит такую цепочку и заметно лучше решает арифметические, здравосмысловые и символические задачи — без дообучения.

## Проблема и пробел
Наращивание одного лишь размера модели не даёт высокого качества на трудных задачах — арифметике, здравом смысле, символических манипуляциях (§1 Introduction, абз. 1). Два известных подхода имеют собственные ограничения: обучение/дообучение на естественно-языковых обоснованиях дорого из-за необходимости большого набора качественных rationales, а традиционный few-shot prompting плохо работает там, где нужно рассуждение, и слабо улучшается с ростом масштаба (§1 Introduction, абз. 2–3).

## Метод
Chain-of-thought prompting: модели предъявляют few-shot-примеры, где каждый пример — тройка ⟨вход, цепочка рассуждения, выход⟩; цепочка рассуждения — это серия промежуточных естественно-языковых шагов, ведущих к финальному ответу (§1 Introduction, абз. 3). Метод не требует дообучения — достаточно включить несколько демонстраций chain of thought в качестве exemplars во few-shot-подсказку (§Abstract, абз. 1; §2 Chain-of-Thought Prompting, абз. 2). Ключевое эмпирическое условие: способность порождать цепочку рассуждения проявляется только у достаточно крупных моделей (§2 Chain-of-Thought Prompting, абз. 1).

## Данные / материал
Извлечённый фрагмент называет только уровень бенчмарков и моделей, без числовых характеристик выборок. Эксперименты проведены на трёх больших языковых моделях и на задачах арифметического, здравосмыслового и символического рассуждения; из именованных бенчмарков в извлечении фигурирует GSM8K (математические текстовые задачи) (§Abstract, абз. 1; §1 Introduction, абз. 4). Объёмы наборов, число примеров по каждой задаче и состав бенчмарков в извлечённом тексте не указаны.

## Результаты
Числовые метрики точности в извлечённом фрагменте не приведены; результаты сформулированы качественно и через масштаб моделей.
- Chain-of-thought prompting улучшает качество на арифметических, здравосмысловых и символических задачах на трёх больших языковых моделях (§Abstract, абз. 1).
- PaLM 540B с восемью chain-of-thought-примерами достигает state-of-the-art точности на GSM8K, превосходя даже дообученную GPT-3 с верификатором (§Abstract, абз. 1).
- Chain-of-thought prompting с PaLM 540B превосходит стандартный prompting с большим отрывом и ставит новый state-of-the-art на GSM8K (§1 Introduction, абз. 4).

## Вклад и выводы
Работа предлагает chain-of-thought prompting как простой метод, раскрывающий способность крупных языковых моделей к рассуждению, и заявляет четыре его свойства (§2 Chain-of-Thought Prompting, абз. 2): (1) декомпозиция многошаговой задачи на промежуточные шаги, что позволяет выделить больше вычислений сложным задачам; (2) интерпретируемое окно в поведение модели, дающее возможность отладки хода рассуждения; (3) применимость к широкому классу задач, решаемых человеком через язык; (4) метод вызывается в готовых (off-the-shelf) достаточно крупных моделях простым включением примеров. Отдельно подчёркнуто преимущество prompting-only-подхода: он не требует большого обучающего набора, а один чекпойнт решает много задач (§1 Introduction, абз. 4).

## Ограничения
Отдельного раздела ограничений в извлечённом фрагменте нет — не указано (в извлечение вошли только аннотация, Введение и начало раздела 2). Из самого текста следует ограничение по масштабу: выигрыш метода привязан к достаточно крупным моделям, то есть на малых моделях эффект не гарантирован (§2 Chain-of-Thought Prompting, абз. 1). Замечание проверяющего (моё): авторы подают зависимость от масштаба как свойство/эмерджентность, а не как ограничение — трактовка её как ограничения здесь моя.

## Привязка тезисов к источнику (проверено)

| Тезис | Локатор | Дословная цитата | Раздел | Проверено |
|---|---|---|---|---|
| Цепочка рассуждения — серия промежуточных шагов | §Abstract, абз. 1 | «We explore how generating a chain of thought — a series of intermediate» | Abstract | ✓ |
| Она заметно улучшает способность LLM к сложному рассуждению | §Abstract, абз. 1 | «reasoning steps — significantly improves the ability of large language» | Abstract | ✓ |
| Метод назван chain-of-thought prompting | §Abstract, абз. 1 | «models via a simple method called chain-of-thought prompting, where a» | Abstract | ✓ |
| Несколько демонстраций CoT даются как exemplars | §Abstract, абз. 1 | «few chain of thought demonstrations are provided as exemplars in» | Abstract | ✓ |
| Эксперименты на трёх больших LLM | §Abstract, абз. 1 | «Experiments on three large language models show that» | Abstract | ✓ |
| Улучшение на арифметике, здравом смысле, символике | §Abstract, абз. 1 | «chain-of-thought prompting improves performance on a range of» | Abstract | ✓ |
| PaLM 540B + 8 CoT-примеров → SOTA-точность | §Abstract, абз. 1 | «eight chain-of-thought exemplars achieves state-of-the-art accuracy on» | Abstract | ✓ |
| На GSM8K превосходит даже дообученную модель | §Abstract, абз. 1 | «the GSM8K benchmark of math word problems, surpassing even finetuned» | Abstract | ✓ |
| Превзойдена именно GPT-3 с верификатором | §Abstract, абз. 1 | «GPT-3 with a verifier.» | Abstract | ✓ |
| Масштаб модели сам по себе недостаточен для трудных задач | §1 Introduction, абз. 1 | «up model size alone has not proved sufficient for achieving high» | 1 Introduction | ✓ |
| Метод мотивирован двумя идеями | §1 Introduction, абз. 2 | «can be unlocked by a simple method motivated by two ideas. First,» | 1 Introduction | ✓ |
| Вторая идея — in-context few-shot через prompting | §1 Introduction, абз. 2 | «large language models offer the exciting prospect of in-context few-shot» | 1 Introduction | ✓ |
| У обеих прежних идей есть ключевые ограничения | §1 Introduction, абз. 3 | «Both of the above ideas, however, have key limitations. For» | 1 Introduction | ✓ |
| Создание большого набора качественных rationales дорого | §1 Introduction, абз. 3 | «create a large set of high quality rationales, which is much more» | 1 Introduction | ✓ |
| Обычный few-shot плохо работает на задачах с рассуждением | §1 Introduction, абз. 3 | «it works poorly on tasks that require reasoning abilities,» | 1 Introduction | ✓ |
| Определение CoT: шаги, ведущие к финальному ответу | §1 Introduction, абз. 3 | «natural language reasoning steps that lead to the final output, and we» | 1 Introduction | ✓ |
| CoT с PaLM 540B превосходит стандартный prompting | §1 Introduction, абз. 4 | «chain-of-thought prompting with PaLM 540B outperforms standard prompting» | 1 Introduction | ✓ |
| Prompting-only не требует большого обучающего набора | §1 Introduction, абз. 4 | «prompting-only approach is important because it does not require a large» | 1 Introduction | ✓ |
| Цель — научить LM порождать цепочку рассуждения | §2 Chain-of-Thought Prompting, абз. 1 | «generate a similar chain of thought — a coherent series of intermediate» | 2 Chain-of-Thought Prompting | ✓ |
| CoT порождают только достаточно крупные модели | §2 Chain-of-Thought Prompting, абз. 1 | «show that sufficiently large language models can generate chains of» | 2 Chain-of-Thought Prompting | ✓ |
| Свойство 1: больше вычислений на сложные задачи | §2 Chain-of-Thought Prompting, абз. 2 | «into intermediate steps, which means that additional computation can be» | 2 Chain-of-Thought Prompting | ✓ |
| Свойство 2: интерпретируемое окно в поведение модели | §2 Chain-of-Thought Prompting, абз. 2 | «of thought provides an interpretable window into the behavior of the» | 2 Chain-of-Thought Prompting | ✓ |
| Свойство 3: применимо к широкому классу задач | §2 Chain-of-Thought Prompting, абз. 2 | «Third, chain-of-thought reasoning can be used for tasks such as math» | 2 Chain-of-Thought Prompting | ✓ |
| Свойство 4: вызывается в готовых крупных моделях | §2 Chain-of-Thought Prompting, абз. 2 | «Finally, chain-of-thought reasoning can be readily elicited in» | 2 Chain-of-Thought Prompting | ✓ |

**Журнал самопроверки.** Строк: 24. Подтверждено: 24 × ✓. Флагов ⚠: 0. Метод: переоткрытие извлечённого текста источника и литеральный поиск подстроки (`grep -F`) для каждой из 24 цитат — по разделам Abstract, 1 Introduction, 2 Chain-of-Thought Prompting. Проверка портативная: только повторное чтение того же текста, без внешних скриптов и Python внутри логики навыка (grep использован как эквивалент повторного чтения строки).

## Пробелы и вопросы
- **Ограничение извлечения (docx-навык недоступен).** Текст получен через `pandoc -t plain`; иерархия заголовков реконструирована из плоского вывода, номера абзацев проставлены по извлечённому тексту. Точность разбиения на абзацы зависит от того, как pandoc свернул docx.
- **Фрагментарность источника.** В извлечении присутствуют только Abstract, §1 и начало §2. Разделы с методикой экспериментов, полными таблицами точности по всем бенчмаркам (кроме упоминания GSM8K), ablation и авторскими ограничениями — не указано в извлечённом тексте.
- **Числа результатов.** Конкретные значения точности (проценты) в извлечённом фрагменте отсутствуют; заявлено лишь «state-of-the-art» и «new state-of-the-art». Абсолютные метрики — [проверить] по полному тексту статьи.
- Дальше (→ lit-search): полный текст NeurIPS-версии для разделов Results/Limitations; сверка страниц и DOI для BibTeX.

## Метаданные для ссылки (→ cite)
Jason Wei · Xuezhi Wang · Dale Schuurmans · Maarten Bosma · Brian Ichter · Fei Xia · Ed Chi · Quoc Le · Denny Zhou · 2022 · Chain-of-Thought Prompting Elicits Reasoning in Large Language Models · 36th Conference on Neural Information Processing Systems (NeurIPS 2022) · том/выпуск [проверить] · страницы [проверить] · arXiv:2201.11903v6 [cs.CL] · https://arxiv.org/abs/2201.11903.

## Цитирование (BibTeX)

Навык `cite` в репозитории недоступен (мягкая деградация) — запись собрана напрямую из метаданных источника; отсутствующие поля помечены `% TODO`, не выдуманы. Тип — `@inproceedings` (конференционная статья NeurIPS 2022).

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
  volume        = {% TODO: проверить},
  pages         = {% TODO: проверить},
  doi           = {% TODO: проверить}
}
```
