---
name: latex-fix
description: Repairs a LaTeX document that fails to compile. Reads the .log file, traces each error back to its line in the .tex source, fixes it and recompiles with latexmk or pdflatex until the build is clean. Use when pdflatex, xelatex or latexmk stops with an error or leaves undefined references behind.
---
# Repairing a LaTeX build

Work from the compiler's own record, not from guesses about the source.

Start with the log. It sits next to the main file and shares its name (`paper.tex` writes `paper.log`); if the build ran in another output directory, look there. Error lines begin with `!`, and the line number follows as `l.<n>` a little further down. Warnings worth acting on mention undefined references, undefined citations or missing files. Fix the first error before any other, because a single missing brace or package can cascade into dozens of later messages that vanish once it is gone.

For each error, say in one or two sentences what went wrong, open the source at the reported line (and the few lines before it, since TeX often notices a problem late), and make the smallest change that removes the cause. The usual causes are a package that is not loaded or not installed, an unbalanced brace or environment, a special character such as `&`, `%`, `_` or `#` left unescaped in text, an input encoding or font that does not match the engine, a file named in `\input` or `\includegraphics` that does not exist, and a bibliography that was never built or has a malformed entry.

Then rebuild, preferably with `latexmk -pdf <file>.tex` (use `-xelatex` or `-lualatex` when the document needs that engine), otherwise with `pdflatex <file>.tex` run again after `bibtex` or `biber` when citations are involved. Read the new log and repeat until the run finishes without errors and without undefined references. If an error cannot be fixed without changing the author's content or layout, stop and ask instead of rewriting it.

Report to the user in the language of their request: which errors you found, what you changed and where, and anything left as a warning.
