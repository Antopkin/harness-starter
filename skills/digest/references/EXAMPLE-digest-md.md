# Конспект: Yao et al., 2023 — ReAct: Synergizing Reasoning and Acting in Language Models

Реальный пример выхода навыка `digest`, собранный на препринте arXiv:2210.03629,
источник — файл в формате markdown (digital-born, без деградации извлечения).
Таблица привязки проверена литеральным поиском цитат в исходном тексте; BibTeX
собран вручную — навык `cite` был недоступен.

**Библио:** Yao, S., Zhao, J., Yu, D., Du, N., Shafran, I., Narasimhan, K., & Cao, Y. (2023). ReAct: Synergizing Reasoning and Acting in Language Models. Published as a conference paper at ICLR 2023. arXiv:2210.03629 [cs.CL]. https://arxiv.org/abs/2210.03629
**Формат источника:** markdown  ·  **Прочитано:** стр. 1–21 — метаданные, Abstract, §1 Introduction, §2 (начало)  ·  **Дата:** 2026-07-15

## Суть одной строкой
ReAct — парадигма промптинга LLM, в которой рассуждения (reasoning traces) и действия чередуются в одном потоке, так что рассуждение направляет план действий, а действия подтягивают внешнюю информацию обратно в рассуждение.

## Проблема и пробел
Способности LLM к рассуждению (chain-of-thought) и к действию (генерация плана действий) до сих пор изучались как отдельные темы; работа объединяет их в чередующемся режиме (`## Abstract`, стр. 9). Отправная точка — наблюдение, что человеческий интеллект бесшовно совмещает целевые действия с вербальным рассуждением (`## 1 Introduction`, стр. 13).

## Метод
LLM промптится генерировать одновременно вербальные reasoning traces и действия, относящиеся к задаче, в чередующемся порядке; это даёт «reason to act» (рассуждение создаёт и корректирует план) и «act to reason» (действие подтягивает информацию из внешней среды, напр. Wikipedia) (`## 1 Introduction`, стр. 15). Формально пространство действий агента расширяется языком: Â = A ∪ L, где L — пространство языка; «мысль» (thought / reasoning trace) не меняет внешнюю среду и не даёт наблюдения-обратной связи (`## 2 ReAct: Synergizing Reasoning + Acting`, стр. 19, 21). Общая постановка: на шаге t агент получает наблюдение и выбирает действие согласно некоторой политике (`## 2 ReAct`, стр. 19).

## Данные / материал
Названы четыре бенчмарка: question answering — HotpotQA, fact verification — Fever, интерактивное принятие решений — ALFWorld и WebShop (`## Abstract`, стр. 9). Объём выборок, размеры датасетов и процедура их формирования в доступном фрагменте не указаны (в тексте нет разделов Data/Experiments).

## Результаты
Все числа ниже приведены в аннотации; отдельного раздела с таблицами результатов в доступном фрагменте нет.
- На ALFWorld и WebShop ReAct превосходит методы imitation- и reinforcement-learning по абсолютному success rate на 34 % и 10 % соответственно, при промпте всего с одним-двумя in-context примерами (`## Abstract`, стр. 9).
- На HotpotQA и Fever ReAct снимает проблемы галлюцинаций и распространения ошибок, характерные для chain-of-thought, за счёт взаимодействия с простым Wikipedia API (`## Abstract`, стр. 9).
- Заявлены улучшенная интерпретируемость для человека и доверие по сравнению с методами без компонентов рассуждения или действия (`## Abstract`, стр. 9).

## Вклад и выводы
Авторы позиционируют ReAct как общую парадигму, объединяющую рассуждение и действие для языковых и decision-making задач; вклад — чередование reasoning traces и действий, дающее синергию в обе стороны (`## 1 Introduction`, стр. 15; `## Abstract`, стр. 9).

## Ограничения
В доступном фрагменте (Abstract, Introduction, начало §2) авторы не формулируют раздел ограничений — он в текст не вошёл. Замечание составителя (моё): фрагмент обрывается в начале §2, поэтому детали метода, экспериментальная процедура и полные результаты вне охвата этого конспекта.

## Привязка тезисов к источнику (проверено)

| Тезис | Локатор | Дословная цитата | Раздел | Проверено |
|---|---|---|---|---|
| Рассуждение и действие ранее изучались раздельно | `## Abstract`, стр. 9 | «their abilities for reasoning (e.g. chain-of-thought prompting) and acting (e.g. action plan generation) have primarily been studied as separate topics» | Abstract | ✓ |
| ReAct чередует reasoning traces и действия | `## Abstract`, стр. 9 | «we explore the use of LLMs to generate both reasoning traces and task-specific actions in an interleaved manner» | Abstract | ✓ |
| Двусторонняя синергия: рассуждение ведёт план, действия дают внешнюю информацию | `## Abstract`, стр. 9 | «reasoning traces help the model induce, track, and update action plans as well as handle exceptions, while actions allow it to interface with external sources» | Abstract | ✓ |
| На HotpotQA и Fever снимает галлюцинации через Wikipedia API | `## Abstract`, стр. 9 | «on question answering (HotpotQA) and fact verification (Fever), ReAct overcomes issues of hallucination and error propagation prevalent in chain-of-thought reasoning by interacting with a simple Wikipedia API» | Abstract | ✓ |
| Прирост success rate 34 % и 10 % на ALFWorld и WebShop при 1–2 примерах | `## Abstract`, стр. 9 | «ReAct outperforms imitation and reinforcement learning methods by an absolute success rate of 34% and 10% respectively, while being prompted with only one or two in-context examples» | Abstract | ✓ |
| Улучшены интерпретируемость и доверие | `## Abstract`, стр. 9 | «improved human interpretability and trustworthiness over methods without reasoning or acting components» | Abstract | ✓ |
| Человеческий интеллект совмещает действия с вербальным рассуждением | `## 1 Introduction`, стр. 13 | «A unique feature of human intelligence is the ability to seamlessly combine task-oriented actions with verbal reasoning» | 1 Introduction | ✓ |
| ReAct — общая парадигма, промптит генерировать рассуждения и действия вперемешку | `## 1 Introduction`, стр. 15 | «ReAct prompts LLMs to generate both verbal reasoning traces and actions pertaining to a task in an interleaved manner» | 1 Introduction | ✓ |
| Постановка агент–среда: наблюдение и действие по политике на шаге t | `## 2 ReAct`, стр. 19 | «an agent receives an observation ot ∈ O from the environment and takes an action at ∈ A following some policy» | 2 ReAct | ✓ |
| Пространство действий расширяется языком: Â = A ∪ L | `## 2 ReAct`, стр. 21 | «we augment the agent's action space to Â = A ∪ L, where L is the space of language» | 2 ReAct | ✓ |
| «Мысль» не меняет внешнюю среду и не даёт обратной связи | `## 2 ReAct`, стр. 21 | «does not affect the external environment, thus leading to no observation feedback» | 2 ReAct | ✓ |

**Журнал самопроверки.** Строк: 11. Подтверждено: 11 × ✓. Флагов ⚠: 0. Метод: переоткрытие извлечённого текста источника и литеральный поиск подстроки (`grep -F`) для каждой из 11 цитат (стр. 9 — Abstract, стр. 13 и 15 — Introduction, стр. 19 и 21 — §2); каждая цитата найдена как точная подстрока. Проверка портативная: только повторное чтение того же файла, без внешних скриптов и Python (grep-сверка — детерминированная проверка подстроки, не переписывание).

## Пробелы и вопросы
- В доступном фрагменте нет разделов Related work, Method (детали), Data/Experiments, Results (таблицы) и Limitations — весь конспект опирается на Abstract, §1 и начало §2.
- Числа 34 % и 10 % даны только в аннотации; условия замера (какие модели, сколько прогонов, метрика success rate по каждому бенчмарку) в тексте не раскрыты — «не указано».
- Объёмы датасетов HotpotQA, Fever, ALFWorld, WebShop не приведены.
- DOI и страницы публикации ICLR 2023 в файле отсутствуют — сверить по первоисточнику (→ lit-search / cite).

## Метаданные для ссылки (→ cite)
Shunyu Yao · Jeffrey Zhao · Dian Yu · Nan Du · Izhak Shafran · Karthik Narasimhan · Yuan Cao · 2023 · ReAct: Synergizing Reasoning and Acting in Language Models · Published as a conference paper at ICLR 2023 · arXiv:2210.03629v3 [cs.CL] · Том/выпуск — [проверить] · Страницы — [проверить] · DOI — [проверить].

## Цитирование (BibTeX)

@inproceedings{yao2023react,
  author       = {Yao, Shunyu and Zhao, Jeffrey and Yu, Dian and Du, Nan and Shafran, Izhak and Narasimhan, Karthik and Cao, Yuan},
  title        = {ReAct: Synergizing Reasoning and Acting in Language Models},
  booktitle    = {International Conference on Learning Representations (ICLR)},
  year         = {2023},
  eprint       = {2210.03629},
  archivePrefix = {arXiv},
  primaryClass = {cs.CL},
  url          = {https://arxiv.org/abs/2210.03629}
  % pages     = {TODO: не указано в источнике}
  % doi       = {TODO: не указано в источнике}
}
