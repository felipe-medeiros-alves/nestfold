import Base
import ./json.bend as J
import ./path.bend as Path

def obj_get_leaf_b(eq: Bool, val: J.Json) -> Maybe<J.Json>:
  match eq:
    case True{}:
      Some{val}
    case False{}:
      None{}

def obj_get_leaf(k: String, val: J.Json, key: String) -> Maybe<J.Json>:
  obj_get_leaf_b(String.eq(k, key), val)

def obj_get_pick(a: Maybe<J.Json>, b: Maybe<J.Json>) -> Maybe<J.Json>:
  match a:
    case Some{x}:
      Some{x}
    case None{}:
      b

@unsafe
def obj_get_pair_step(eq: Bool, val: J.Json, t: List<J.JsonPair>, +key: String) -> Maybe<J.Json>:
  match eq:
    case True{}:
      Some{val}
    case False{}:
      obj_get_pairs(t, key)

@unsafe
def obj_get_pairs(xs: List<J.JsonPair>, +key: String) -> Maybe<J.Json>:
  match xs:
    case Nil{}:
      None{}
    case Con{J.JsonPair{k, val}, t}:
      obj_get_pair_step(String.eq(k, key), val, t, key)

def obj_get(doc: J.Json, key: String) -> Maybe<J.Json>:
  match doc:
    case J.JObj{xs}:
      obj_get_pairs(xs, key)
    case _:
      None{}

@unsafe
def arr_get_step(eq: Bool, h: J.Json, t: List<J.Json>, +i: U32, pos: U32) -> Maybe<J.Json>:
  match eq:
    case True{}:
      Some{h}
    case False{}:
      arr_get_list(t, i, pos)

@unsafe
def arr_get_list(xs: List<J.Json>, +i: U32, pos: U32) -> Maybe<J.Json>:
  match xs:
    case Nil{}:
      None{}
    case Con{h, t}:
      arr_get_list_step(h, t, i, pos)

def arr_get_list_step(h: J.Json, t: List<J.Json>, +i: U32, +pos: U32) -> Maybe<J.Json>:
  arr_get_step(U32.is_eq(pos, i), h, t, i, U32.add(pos, 1))

def arr_get(doc: J.Json, idx: U32) -> Maybe<J.Json>:
  match doc:
    case J.JArr{xs}:
      arr_get_list(xs, U32.add(idx, 1), 1)
    case _:
      None{}

@unsafe
def get(doc: J.Json, segs: Path.SegList) -> J.Json:
  match segs:
    case Path.SegNil{}:
      doc
    case Path.SegCon{h, t}:
      get_seg(doc, h, t)

@unsafe
def get_seg(doc: J.Json, seg: Path.Seg, rest: Path.SegList) -> J.Json:
  match seg:
    case Path.SegRoot{}:
      get(doc, rest)
    case Path.SegKey{+key}:
      get_after_key(obj_get(doc, key), rest)
    case Path.SegIndex{+idx}:
      get_after_key(arr_get(doc, idx), rest)
    case Path.SegEach{}:
      get_each(doc, rest)

@unsafe
def get_after_key(m: Maybe<J.Json>, rest: Path.SegList) -> J.Json:
  match m:
    case Some{val}:
      get(val, rest)
    case None{}:
      J.JNull{}

@unsafe
def map_json_list(xs: List<J.Json>, +rest: Path.SegList) -> List<J.Json>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      get(h, rest) <> map_json_list(t, rest)

def get_each(doc: J.Json, rest: Path.SegList) -> J.Json:
  match doc:
    case J.JArr{xs}:
      J.JArr{map_json_list(xs, rest)}
    case _:
      J.JArr{Nil{}}

def del_pair_key_t(+k: String, val: J.Json, +rest: Path.SegList) -> Maybe<J.JsonPair>:
  match rest:
    case Path.SegNil{}:
      None{}
    case _:
      Some{J.JsonPair{k, val}}

def del_pair_key_b(eq: Bool, +k: String, val: J.Json, +rest: Path.SegList) -> Maybe<J.JsonPair>:
  match eq:
    case True{}:
      del_pair_key_t(k, val, rest)
    case False{}:
      Some{J.JsonPair{k, val}}

def del_pair(p: J.JsonPair, +key: String, +rest: Path.SegList) -> Maybe<J.JsonPair>:
  match p:
    case J.JsonPair{+k, val}:
      del_pair_key_b(String.eq(k, key), k, val, rest)

@unsafe
def del_pairs(xs: List<J.JsonPair>, +key: String, +rest: Path.SegList) -> List<J.JsonPair>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      del_pairs_merge(del_pair(h, key, rest), t, key, rest)

def del_pairs_merge(m: Maybe<J.JsonPair>, t: List<J.JsonPair>, +key: String, +rest: Path.SegList) -> List<J.JsonPair>:
  match m:
    case Some{p}:
      p <> del_pairs(t, key, rest)
    case None{}:
      del_pairs(t, key, rest)

def del_key(doc: J.Json, +key: String, +rest: Path.SegList) -> J.Json:
  match doc:
    case J.JObj{xs}:
      J.JObj{del_pairs(xs, key, rest)}
    case _:
      doc

def del_seg(doc: J.Json, seg: Path.Seg, rest: Path.SegList) -> J.Json:
  match seg:
    case Path.SegKey{+key}:
      del_key(doc, key, rest)
    case _:
      doc

@unsafe
def del(doc: J.Json, segs: Path.SegList) -> J.Json:
  match segs:
    case Path.SegNil{}:
      doc
    case Path.SegCon{h, t}:
      del_seg(doc, h, t)

@unsafe
def set(doc: J.Json, segs: Path.SegList, +value: String) -> J.Json:
  match segs:
    case Path.SegNil{}:
      J.JStr{value}
    case Path.SegCon{h, t}:
      set_seg(doc, h, t, value)

def set_pair_key_b(eq: Bool, +k: String, val: J.Json, +rest: Path.SegList, +value: String) -> J.JsonPair:
  match eq:
    case True{}:
      J.JsonPair{k, set(val, rest, value)}
    case False{}:
      J.JsonPair{k, val}

def set_pair_key(+k: String, val: J.Json, +key: String, +rest: Path.SegList, +value: String) -> J.JsonPair:
  set_pair_key_b(String.eq(k, key), k, val, rest, value)

def set_pair(p: J.JsonPair, +key: String, +rest: Path.SegList, +value: String) -> J.JsonPair:
  match p:
    case J.JsonPair{k, val}:
      set_pair_key(k, val, key, rest, value)

@unsafe
def set_pairs(xs: List<J.JsonPair>, +key: String, +rest: Path.SegList, +value: String) -> List<J.JsonPair>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      set_pair(h, key, rest, value) <> set_pairs(t, key, rest, value)

def set_key(doc: J.Json, +key: String, +rest: Path.SegList, +value: String) -> J.Json:
  match doc:
    case J.JObj{xs}:
      J.JObj{set_pairs(xs, key, rest, value)}
    case _:
      J.JObj{Con{J.JsonPair{key, set(J.JNull{}, rest, value)}, Nil{}}}

def set_seg(doc: J.Json, seg: Path.Seg, +rest: Path.SegList, +value: String) -> J.Json:
  match seg:
    case Path.SegKey{+key}:
      set_key(doc, key, rest, value)
    case _:
      doc

def pred_ok(+pred: Path.Pred) -> Bool:
  True{}

@unsafe
def filter_list_step(ok: Bool, h: J.Json, t: List<J.Json>, +pred: Path.Pred) -> List<J.Json>:
  match ok:
    case True{}:
      h <> filter_list(t, pred)
    case False{}:
      filter_list(t, pred)

@unsafe
def filter_list(xs: List<J.Json>, +pred: Path.Pred) -> List<J.Json>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      filter_list_step(pred_ok(pred), h, t, pred)

def filter_root(doc: J.Json, pred: Path.Pred) -> J.Json:
  match doc:
    case J.JArr{xs}:
      J.JArr{filter_list(xs, pred)}
    case _:
      doc

def filter(doc: J.Json, segs: Path.SegList, pred: Path.Pred) -> J.Json:
  match segs:
    case Path.SegCon{Path.SegEach{}, Path.SegNil{}}:
      filter_root(doc, pred)
    case _:
      doc
