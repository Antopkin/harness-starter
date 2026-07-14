# Конспект: Hinton, Vinyals, Dean, 2015 — Distilling the Knowledge in a Neural Network

Реальный пример выхода навыка `pdf-digest`, собранный на открытом препринте
arXiv:1503.02531 (файл `1503.02531.pdf` в этом же каталоге). Таблица привязки
проверена перечитыванием страниц; в конце — BibTeX через `cite`.

**Библио:** Hinton, G., Vinyals, O., & Dean, J. (2015). Distilling the Knowledge in
a Neural Network. arXiv:1503.02531 [stat.ML]. https://arxiv.org/abs/1503.02531
**Страниц прочитано:** 1–5, 8–9  ·  **Дата:** 2026-07-15

## Суть одной строкой
Обучение маленькой модели на «мягких» вероятностях большой модели или ансамбля
(«дистилляция») переносит почти всё их качество в компактную модель, удобную для
развёртывания.

## Проблема и пробел
Ансамбли и очень большие сети дают лучшие предсказания, но дороги и громоздки в
инференсе, особенно при деплое многим пользователям (с. 1). Ранее Caruana с
коллегами показали, что знание ансамбля можно перенести в одну малую модель (с. 1);
авторы развивают этот приём через дистилляцию с температурой softmax.

## Метод
Softmax с температурой `T` даёт более «мягкое» распределение по классам (Eq. 1,
с. 2). Дистилляция: поднять `T` у большой модели, получить мягкие цели и обучить
малую модель на них при той же высокой `T`; при известных истинных метках —
взвешенная сумма двух кросс-энтропий (по мягким и по жёстким целям), с умножением
градиентов на `T²`, чтобы сохранить их баланс (с. 3). Совпадение логитов (matching
logits) — частный случай дистилляции в пределе высокой температуры (§2.1, с. 3).

## Данные / материал
- MNIST: большая сеть — 2 скрытых слоя по 1200 ReLU, обучение на всех 60 000
  примерах (с. 3).
- Речь (ASR): архитектура 8 скрытых слоёв по 2560 ReLU, 14 000 меток, ~85M
  параметров; ~2000 часов речи, ~700M обучающих примеров (с. 4).
- JFT (внутренний датасет Google): 100 млн изображений, 15 000 меток (с. 5).

## Результаты
- MNIST: большая сеть — 67 ошибок; малая без регуляризации — 146; та же малая с
  добавленной задачей совпадения с мягкими целями (T = 20) — 74 ошибки (с. 4).
- MNIST, перенос обобщения: даже без единого примера цифры 3 в обучающем наборе
  дистиллированная модель делает всего 206 ошибок (с. 4).
- Речь: базовая DNN — frame accuracy 58,9 %, WER 10,9 % (с. 4); дистиллированная
  одиночная модель (60,8 % / 10,7 %) почти сравнивается с ансамблем из 10 моделей
  (61,1 % / 10,7 %), Таблица 1 (с. 5); перенесено > 80 % прироста точности ансамбля
  (с. 5).

## Вклад и выводы
Авторы заявляют, что дистилляция хорошо переносит знание из ансамбля или из большой
регуляризованной модели в компактную (с. 8), и вводят ансамбли моделей-специалистов
для очень больших наборов классов, которые обучаются быстро и параллельно (с. 1).

## Ограничения
Авторы прямо отмечают: обратный перенос знания моделей-специалистов в единую большую
сеть пока не показан (с. 8).

## Привязка тезисов к источнику (проверено)

| Тезис | с. N | Дословная цитата | Раздел | Проверено |
|---|---|---|---|---|
| Дистилляция переносит знание из громоздкой модели в малую, удобную для деплоя | 1 | «we can then use a different kind of training, which we call "distillation" to transfer the knowledge from the cumbersome model to a small model that is more suitable for deployment» | Introduction | ✓ |
| Метод: поднять температуру финального softmax, чтобы получить «мягкие» цели | 2 | «Our more general solution, called "distillation", is to raise the temperature of the final softmax until the cumbersome model produces a suitably soft set of targets» | Introduction | ✓ |
| «Мягкие» цели несут больше информации на пример → меньше данных, выше learning rate | 2 | «the soft targets have high entropy, they provide much more information per training case than hard targets … so the small model can often be trained on much less data … and using a much higher learning rate» | Introduction | ✓ |
| Данные MNIST: большая сеть — 2 слоя по 1200 ReLU на всех 60 000 примерах | 3 | «we trained a single large neural net with two hidden layers of 1200 rectified linear hidden units on all 60,000 training cases» | 3 Preliminary experiments on MNIST | ✓ |
| MNIST: малая сеть без регуляризации — 146 ошибок, большая — 67 | 4 | «This net achieved 67 test errors whereas a smaller net with two hidden layers of 800 rectified linear hidden units and no regularization achieved 146 errors» | 3 Preliminary experiments on MNIST | ✓ |
| MNIST: с задачей совпадения с мягкими целями (T = 20) малая сеть — 74 ошибки | 4 | «if the smaller net was regularized solely by adding the additional task of matching the soft targets produced by the large net at a temperature of 20, it achieved 74 test errors» | 3 Preliminary experiments on MNIST | ✓ |
| Перенос обобщения: без единого примера цифры 3 модель делает лишь 206 ошибок | 4 | «the distilled model only makes 206 test errors of which 133 are on the 1010 threes in the test set» | 3 Preliminary experiments on MNIST | ✓ |
| Речь: базовая DNN — frame accuracy 58,9 %, WER 10,9 % | 4 | «This system achieves a frame accuracy of 58.9%, and a Word Error Rate (WER) of 10.9% on our development set» | 4 Experiments on speech recognition | ✓ |
| Дистилляция переносит > 80 % прироста точности ансамбля из 10 моделей | 5 | «More than 80% of the improvement in frame classification accuracy achieved by using an ensemble of 10 models is transferred to the distilled model» | 4.1 Results | ✓ |
| Таблица 1: дистиллированная одиночная модель ≈ ансамбль из 10 моделей | 5 | «the distilled single model performs about as well as the averaged predictions of 10 models that were used to create the soft targets» | Table 1 | ✓ |
| Ограничение: обратный перенос знания специалистов в большую сеть не показан | 8 | «We have not yet shown that we can distill the knowledge in the specialists back into the single large net» | 8 Discussion | ✓ |

**Журнал самопроверки.** Каждая из 11 строк перепроверена повторным чтением её
страницы (`Read` того же PDF, постранично: с. 1–5, 8). Все цитаты найдены дословно
на указанных страницах → 11 × ✓, флагов ⚠ нет. Проверка портативная: только
повторное чтение PDF, без внешних скриптов и Python.

## Пробелы и вопросы
- Численный вклад ансамблей специалистов на JFT (top-1 прирост) — в прочитанном
  диапазоне (с. 1–5, 8–9) отдельной итоговой цифры не выписано; при необходимости
  добрать с. 6–7 (Таблицы 2–4).
- Сравнить с более поздними работами по дистилляции и сжатию моделей (→ lit-search).

## Метаданные для ссылки (→ cite)
Geoffrey Hinton · Oriol Vinyals · Jeff Dean · 2015 · Distilling the Knowledge in a
Neural Network · препринт arXiv · arXiv ID 1503.02531 · primaryClass stat.ML ·
URL https://arxiv.org/abs/1503.02531 · DOI [не присвоен — препринт].

## Цитирование (BibTeX)

Тип записи — `@misc` (препринт arXiv), собран навыком `cite`:

```bibtex
@misc{hinton2015distilling,
  author        = {Hinton, Geoffrey and Vinyals, Oriol and Dean, Jeff},
  title         = {Distilling the Knowledge in a Neural Network},
  year          = {2015},
  eprint        = {1503.02531},
  archivePrefix = {arXiv},
  primaryClass  = {stat.ML},
  url           = {https://arxiv.org/abs/1503.02531}
}
```

**APA 7:** Hinton, G., Vinyals, O., & Dean, J. (2015). *Distilling the knowledge in
a neural network*. arXiv. https://arxiv.org/abs/1503.02531
