# nestfold

CLI to get, set, delete, and filter fields in nested JSON. The transformation core is [Bend 2](https://bend-lang.com); parse/serialize uses C ([yyjson](https://github.com/ibireme/yyjson)).

## Commands

```bash
bend src/main.bend -- get    PATH FILE
bend src/main.bend -- set    PATH VALUE FILE
bend src/main.bend -- del    PATH FILE
bend src/main.bend -- filter PATH PRED FILE
```

Paths (jq subset): `.foo`, `[n]`, `[]`, chained (e.g. `.users[].email`).

## Requirements

- Bend 2 (`bend` on PATH)
- Python 3 (benchmark fixtures)
- `jq` and optionally `hyperfine` for benchmarks
- Clang 14+ for a native binary (`bend src/main.bend -o nestfold`)

## Tests

```bash
chmod +x tests/run.sh benches/run.sh
./tests/run.sh
```

## Benchmark vs jq

```bash
./benches/run.sh
```

Total nestfold time includes read + parse (yyjson on the native target; the `load` effect on the JS interpreter) + recursive traversal in Bend. On the JS target (`bend src/main.bend`), parse uses `JSON.parse` in the `load` effect.

Example on `benches/data/wide_1mb.json`, path `.chunks[0].kids[0].kids[0].kids[0].id` (dev machine; `time(1)`):

| Tool      | Approx. time |
|-----------|--------------|
| jq        | ~0.03 s      |
| nestfold  | ~0.9 s       |

In this MVP, nestfold is slower than jq because it builds a full in-memory ADT and walks linked lists in Bend; jq streams and applies the filter in one pass.

## Layout

- `src/` — `Json` ADT, path parser, operations, CLI
- `native/` — `load` / `parse` / `dump` effects (C + JS)
- `tests/` — fixtures and golden tests
- `benches/` — wide JSON generator and comparison with jq

## MVP limitations

- `set` writes literals as strings at the leaf node (does not replace the root document with arbitrary JSON)
- `filter` uses a stub predicate (always true)
- Simplified output serialization (`[...]` / `{...}` for whole arrays/objects; full scalars)
