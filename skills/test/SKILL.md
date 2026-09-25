---
name: test
description: Generate pytest tests for a Python module or function
---
# Test generation

For the given Python code, generate pytest tests:

1. Read the target code
2. Check whether `tests/` already holds tests; do not overwrite existing test files
3. Identify every public function and method
4. Generate tests that cover:
   - The main scenario (happy path)
   - Edge cases (empty input, None, wrong types)
   - Error states
5. Use fixtures where they fit
6. Write the tests to `tests/test_<module>.py` (if the file already exists, add the new tests and do not overwrite the old ones)
7. Run `python -m pytest tests/test_<module>.py -v` to check them

Use descriptive test names in the form `test_<function>_<scenario>`.
Answer in the language of the user's request.
