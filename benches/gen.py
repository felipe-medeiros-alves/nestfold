#!/usr/bin/env python3
import json
import os
import sys

out_dir = os.path.join(os.path.dirname(__file__), "data")
os.makedirs(out_dir, exist_ok=True)


def wide_tree(width: int, depth: int):
    node = {"v": 0, "kids": []}
    if depth == 0:
        for i in range(width):
            node["kids"].append({"id": i, "email": f"u{i}@example.com", "age": 20 + (i % 10)})
        return node
    for _ in range(width):
        node["kids"].append(wide_tree(width, depth - 1))
    return node


def write(name: str, obj: object) -> None:
    path = os.path.join(out_dir, name)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, separators=(",", ":"))
    print(path, os.path.getsize(path))


def main() -> None:
    target_mb = float(sys.argv[1]) if len(sys.argv) > 1 else 1.0
    base = wide_tree(8, 2)
    chunk = json.dumps(base, separators=(",", ":"))
    reps = max(1, int((target_mb * 1024 * 1024) / len(chunk)))
    doc = {"chunks": [json.loads(chunk) for _ in range(reps)]}
    write(f"wide_{int(target_mb)}mb.json", doc)


if __name__ == "__main__":
    main()
