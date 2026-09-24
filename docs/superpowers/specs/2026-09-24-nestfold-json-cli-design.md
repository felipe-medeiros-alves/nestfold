# nestfold — CLI JSON com árvore binária e transformação paralela

## Objetivo

CLI `nestfold` que ingere JSON aninhado, representa arrays/objetos como árvores binárias (`Array`), e aplica operações estilo jq-subset via caminhos. Parse e serialização em C (yyjson); transformações em Bend 2.

## Comandos

```text
nestfold get    PATH FILE
nestfold set    PATH VALUE FILE
nestfold del    PATH FILE
nestfold filter PATH PRED FILE
```

## Caminhos

- `.` raiz; `.key`; `[n]`; `[]` (todos os elementos de array)
- Predicado em `filter`: `.field OP literal` (`==`, `!=`, `<`, `>`, `<=`, `>=`)

## ADT Json

- `JNull`, `JBool`, `JNum` (String), `JStr`, `JArr(Array<Json>)`, `JObj(Array<JsonPair>)`
- `JsonPair{key: String, val: Json}`

## Arquitetura híbrida

1. `Json.load(path)` — C lê arquivo, yyjson parse, monta termos Bend balanceados
2. Operações puras em Bend (`get`, `set`, `del`, `filter`)
3. `Json.dump(json)` — C serializa para stdout

## Benchmark

`benches/run.sh` compara wall clock com `jq` em fixtures 1MB e ~10MB; README documenta parse vs transform.

## Fora de escopo

API HTTP, AST, CUDA, jq completo, streaming SAX.
