function parse(text) {
  try {
    const v = JSON.parse(io_bytes(text).toString());
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
    if (v.length === 0) return {$: "JArrEmpty"};
    return {$: "JArr", a: js_to_array(v)};
  }
  if (typeof v === "object") {
    const keys = Object.keys(v);
    if (keys.length === 0) return {$: "JObjEmpty"};
    const pairs = keys.map((k) => ({$: "JsonPair", key: k, val: js_to_json(v[k])}));
    return {$: "JObj", a: js_to_array(pairs)};
  }
  return {$: "JNull"};
}

function js_to_array(items) {
  if (items.length === 1) {
    return {$: "ALeaf", value: items[0]};
  }
  const mid = Math.floor(items.length / 2);
  return {
    $: "ANode",
    xs: js_to_array(items.slice(0, mid)),
    ys: js_to_array(items.slice(mid)),
  };
}
