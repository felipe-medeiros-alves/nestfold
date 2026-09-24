function load(path) {
  const fs = require("fs");
  const name = io_bytes(path);
  try {
    const text = fs.readFileSync(Buffer.from(name), "utf8");
    const v = JSON.parse(text);
    return io_done(js_to_json(v));
  } catch (e) {
    return io_fail(22);
  }
}

function js_to_json(v) {
  if (v === null) return {$: "JNull"};
  if (typeof v === "boolean") return {$: "JBool", b: v ? {$: "True"} : {$: "False"}};
  if (typeof v === "number") return {$: "JNum", s: String(v)};
  if (typeof v === "string") return {$: "JStr", s: v};
  if (Array.isArray(v)) {
    return {$: "JArr", xs: js_to_list(v.map(js_to_json))};
  }
  if (typeof v === "object") {
    const keys = Object.keys(v);
    const pairs = keys.map((k) => ({$: "JsonPair", key: k, val: js_to_json(v[k])}));
    return {$: "JObj", xs: js_to_list(pairs)};
  }
  return {$: "JNull"};
}

function js_to_list(items) {
  if (items.length === 0) return {$: "Nil"};
  return {$: "Con", head: items[0], tail: js_to_list(items.slice(1))};
}
