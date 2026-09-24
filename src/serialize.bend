import Base
import ./json.bend as J

def show_bool(b: Bool) -> String:
  match b:
    case True{}:
      "true"
    case False{}:
      "false"

def show(j: J.Json) -> String:
  match j:
    case J.JNull{}:
      "null"
    case J.JBool{b}:
      show_bool(b)
    case J.JNum{s}:
      s
    case J.JStr{s}:
      s
    case J.JArr{xs}:
      "[...]"
    case J.JObj{xs}:
      "{...}"
