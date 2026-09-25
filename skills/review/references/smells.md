# Smell baseline for the Standards axis

The Standards axis always carries this baseline: a fixed set of code smells from Martin Fowler's _Refactoring_ (chapter 3). It applies even when a repo documents nothing, and two rules bind it.

- **The repo overrides.** A documented repo standard (CLAUDE.md, AGENTS.md, CONTEXT.md, an ADR) always wins. Where the repo endorses something the baseline would flag, the smell is suppressed.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation, so its severity never rises above `low`. As with any standard, skip anything that tooling (linters, formatters, type checkers) already enforces.

Each entry reads as what the smell is, then how to fix it. Match it against the diff, not against untouched code.

- **Mysterious Name**: a function, variable or type whose name does not reveal what it does or holds. Rename it; if no honest name comes, the design is murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file of the change. Extract the shared shape and call it from both places.
- **Feature Envy**: a method that reaches into another object's data more than its own. Move the method onto the data it envies.
- **Data Clumps**: the same few fields or parameters keep travelling together, a type waiting to be born. Bundle them into one type and pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. Give the concept its own small type.
- **Repeated Switches**: the same `switch` or `if` cascade on the same type recurs across the change. Replace it with polymorphism, or with one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. Gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. Split it so each module changes for one reason.
- **Speculative Generality**: abstractions, parameters or hooks added for needs the spec does not have. Delete them and inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller should not depend on. Hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. Cut it and call the real target directly.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. Drop the inheritance and use composition.

Adapted from mattpocock/skills@c55ee46 engineering/code-review (MIT).
