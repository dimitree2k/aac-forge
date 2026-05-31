# Golden-File Tests

Each test directory contains:

```
NNN_name/
├── input/              # BR documents and BPMN files
├── initial-model/      # Model state BEFORE the solution is applied
├── expected-model/     # Expected model state AFTER generation
│   └── model.diff      # Expected diff from generate skill
├── expected-sad-sections.json  # Expected SAD section contents
└── expected-review-sections.json  # Expected review findings
```

## Test Protocol

### Generate Test

1. Copy `initial-model/` to a temp workspace
2. Run `arch-generate-solution` against `input/`
3. Diff the resulting model against `expected-model/`
4. Assert SAD sections match `expected-sad-sections.json`
5. Report pass/fail

### Review Test

1. Run `arch-review-solution` against the generated SAD
2. Assert review findings match `expected-review-sections.json`
3. Report pass/fail

## Running

```bash
# All golden-file tests
bash tests/smoke-test.sh

# Single golden-file test
# TODO: test runner script
```
