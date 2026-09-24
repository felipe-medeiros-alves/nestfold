import Base

type Seg is Data:
  SegRoot{}
  SegKey{key: String}
  SegIndex{idx: U32}
  SegEach{}

type SegList is Data:
  SegNil{}
  SegCon{head: Seg, tail: SegList}

type PredOp is Data:
  PredEq{}
  PredNe{}
  PredLt{}
  PredGt{}
  PredLe{}
  PredGe{}

type Pred is Data:
  Pred{field: String, op: PredOp, lit: String}

def seg_cons(h: Seg, t: SegList) -> SegList:
  SegCon{h, t}

def ch_dot() -> Char:
  Chr{46}

def ch_lbr() -> Char:
  Chr{91}

def ch_rbr() -> Char:
  Chr{93}

def is_dot(+c: Char) -> Bool:
  Char.is_eq(c, ch_dot())

def is_lbr(+c: Char) -> Bool:
  Char.is_eq(c, ch_lbr())

def is_rbr(+c: Char) -> Bool:
  Char.is_eq(c, ch_rbr())

def rev_segs_go(xs: SegList, acc: SegList) -> SegList:
  match xs:
    case SegNil{}:
      acc
    case SegCon{h, t}:
      rev_segs_go(t, SegCon{h, acc})

def rev_segs(xs: SegList) -> SegList:
  rev_segs_go(xs, SegNil{})

@unsafe
def reverse_str_go(s: String, acc: String) -> String:
  match s:
    case SNil{}:
      acc
    case SCon{c, t}:
      reverse_str_go(t, SCon{c, acc})

def reverse_str(s: String) -> String:
  reverse_str_go(s, SNil{})

@unsafe
def read_name_go(s: String, acc: String) -> String & String:
  match s:
    case SNil{}:
      (reverse_str(acc), SNil{})
    case SCon{c, t}:
      read_name_next(c, t, acc)

@unsafe
def read_name_next(+c: Char, t: String, acc: String) -> String & String:
  read_name_next_d(c, is_dot(c), t, acc)

@unsafe
def read_name_next_d(+c: Char, dot: Bool, t: String, acc: String) -> String & String:
  match dot:
    case True{}:
      (reverse_str(acc), t)
    case False{}:
      read_name_next_l(c, t, acc)

@unsafe
def read_name_next_l(+c: Char, t: String, acc: String) -> String & String:
  read_name_next_lb(c, is_lbr(c), t, acc)

@unsafe
def read_name_next_lb(+c: Char, lbr: Bool, t: String, acc: String) -> String & String:
  match lbr:
    case True{}:
      (reverse_str(acc), SCon{c, t})
    case False{}:
      read_name_go(t, SCon{c, acc})

def read_name(s: String) -> String & String:
  read_name_go(s, SNil{})

@unsafe
def parse_go(s: String, acc: SegList) -> SegList:
  match s:
    case SNil{}:
      acc
    case SCon{c, t}:
      parse_head(c, t, acc)

@unsafe
def parse_head(+c: Char, t: String, acc: SegList) -> SegList:
  parse_head_b(c, is_dot(c), t, acc)

@unsafe
def parse_head_b(+c: Char, dot: Bool, t: String, acc: SegList) -> SegList:
  match dot:
    case True{}:
      parse_go(t, acc)
    case False{}:
      parse_head_nd(c, t, acc)

@unsafe
def parse_head_nd(+c: Char, t: String, acc: SegList) -> SegList:
  parse_head_l(c, is_lbr(c), t, acc)

@unsafe
def parse_head_l(+c: Char, lbr: Bool, t: String, acc: SegList) -> SegList:
  match lbr:
    case True{}:
      parse_bracket(t, acc)
    case False{}:
      parse_key(SCon{c, t}, acc)

@unsafe
def parse_key(s: String, acc: SegList) -> SegList:
  parse_key_go(read_name(s), acc)

@unsafe
def parse_key_go(r: String & String, acc: SegList) -> SegList:
  (name, rest) = r
  parse_go(rest, seg_cons(SegKey{name}, acc))

@unsafe
def parse_bracket(s: String, acc: SegList) -> SegList:
  match s:
    case SNil{}:
      acc
    case SCon{c, t}:
      parse_bracket_c(c, t, acc)

@unsafe
def parse_bracket_c(+c: Char, t: String, acc: SegList) -> SegList:
  parse_bracket_r(c, is_rbr(c), t, acc)

@unsafe
def parse_bracket_r(+c: Char, rbr: Bool, t: String, acc: SegList) -> SegList:
  match rbr:
    case True{}:
      parse_go(t, seg_cons(SegEach{}, acc))
    case False{}:
      parse_index_digits(c, t, acc, 0)

@unsafe
def parse_index_end_r(+c: Char, rbr: Bool, rest: String, acc: SegList, n: U32) -> SegList:
  match rbr:
    case True{}:
      parse_go(rest, seg_cons(SegIndex{n}, acc))
    case False{}:
      parse_index_digits(c, rest, acc, n)

@unsafe
def parse_index_end(+c: Char, rest: String, acc: SegList, n: U32) -> SegList:
  parse_index_end_r(c, is_rbr(c), rest, acc, n)

@unsafe
def parse_index_more(t: String, acc: SegList, n: U32) -> SegList:
  match t:
    case SNil{}:
      acc
    case SCon{c, rest}:
      parse_index_end(c, rest, acc, n)

@unsafe
def parse_index_digit(+c: Char, t: String, acc: SegList, n: U32) -> SegList:
  parse_index_more(t, acc, U32.add(U32.mul(n, 10), U32.sub(Char.to_u32(c), 48)))

@unsafe
def parse_index_step(+c: Char, t: String, acc: SegList, n: U32) -> SegList:
  parse_index_digit(c, t, acc, n)

@unsafe
def parse_index_d(+c: Char, dig: Bool, t: String, acc: SegList, n: U32) -> SegList:
  match dig:
    case True{}:
      parse_index_step(c, t, acc, n)
    case False{}:
      acc

@unsafe
def parse_index_digits(+c: Char, t: String, acc: SegList, n: U32) -> SegList:
  parse_index_d(c, Char.is_digit(c), t, acc, n)

def parse(s: String) -> SegList:
  rev_segs(parse_go(s, SegNil{}))

def parse_pred_go(s: String) -> Pred:
  Pred{SNil{}, PredEq{}, SNil{}}

def parse_pred(s: String) -> Pred:
  parse_pred_go(s)
