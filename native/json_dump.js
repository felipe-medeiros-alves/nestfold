function dump(value) {
  return io_done(bend_json_to_text(value));
}

function bend_json_to_text(v) {
  if (v === null || v === undefined) return "null";
  if (typeof v === "string" || typeof v === "number" || typeof v === "boolean") {
    return JSON.stringify(v);
  }
  const tag = v.$ || v.name || (v.constructor && v.constructor.name);
  if (tag === "JNull" || tag === "json/JNull") return "null";
  if (tag === "JBool" || tag === "json/JBool") {
    const b = v.b;
    if (b && (b.$ === "True" || b === true)) return "true";
    return "false";
  }
  if (tag === "JNum" || tag === "json/JNum") return String(v.s);
  if (tag === "JStr" || tag === "json/JStr") return JSON.stringify(v.s);
  if (tag === "JArrEmpty" || tag === "json/JArrEmpty") return "[]";
  if (tag === "JObjEmpty" || tag === "json/JObjEmpty") return "{}";
  if (tag === "JArr" || tag === "json/JArr") return "[" + bend_array_flat(v.a).map(bend_json_to_text).join(",") + "]";
  if (tag === "JObj" || tag === "json/JObj") {
    const pairs = bend_array_flat(v.a);
    return "{" + pairs.map(bend_pair_entry).join(",") + "}";
  }
  if (tag === "JsonPair" || tag === "json/JsonPair") return bend_pair_entry(v);
  if (tag === "ALeaf") return bend_json_to_text(v.value);
  if (tag === "ANode") {
    return bend_array_flat(v).map(bend_json_to_text);
  }
  try {
    return JSON.stringify(v);
  } catch (e) {
    return String(v);
  }
}

function bend_pair_entry(p) {
  return JSON.stringify(p.key) + ":" + bend_json_to_text(p.val);
}

function bend_array_flat(a) {
  if (!a) return [];
  const tag = a.$;
  if (tag === "ALeaf") return [a.value];
  if (tag === "ANode") return bend_array_flat(a.xs).concat(bend_array_flat(a.ys));
  if (Array.isArray(a)) return a;
  return [];
}
