import Base
import ./json.bend as J
import ./io_json.bend as JsonIO
import ./path.bend as Path
import ./ops.bend as Ops
import ./cli.bend as Cli
import ./serialize.bend as Ser

def usage() -> String:
  "usage: nestfold get PATH FILE | set PATH VALUE FILE | del PATH FILE | filter PATH PRED FILE"

def main_die(+msg: String) -> IO(Unit):
  do IO<Unit>:
    IO.print_err(msg)
    IO.die(Unit, 2, msg)

def main_get_go(path_s: String, file_s: String) -> IO(Unit):
  do IO<Unit>:
    doc : J.Json <- IO.try(J.Json, JsonIO.load(file_s))
    segs : Path.SegList = Path.parse(path_s)
    out : J.Json = Ops.get(doc, segs)
    IO.print(Ser.show(out))

def main_get(args: List<String>) -> IO(Unit):
  match args:
    case Con{path_s, Con{file_s, Nil{}}}:
      main_get_go(path_s, file_s)
    case _:
      main_die(usage())

def main_set_go(path_s: String, val_s: String, file_s: String) -> IO(Unit):
  do IO<Unit>:
    doc : J.Json <- IO.try(J.Json, JsonIO.load(file_s))
    segs : Path.SegList = Path.parse(path_s)
    out : J.Json = Ops.set(doc, segs, val_s)
    IO.print(Ser.show(out))

def main_set(args: List<String>) -> IO(Unit):
  match args:
    case Con{path_s, Con{val_s, Con{file_s, Nil{}}}}:
      main_set_go(path_s, val_s, file_s)
    case _:
      main_die(usage())

def main_del_go(path_s: String, file_s: String) -> IO(Unit):
  do IO<Unit>:
    doc : J.Json <- IO.try(J.Json, JsonIO.load(file_s))
    segs : Path.SegList = Path.parse(path_s)
    out : J.Json = Ops.del(doc, segs)
    IO.print(Ser.show(out))

def main_del(args: List<String>) -> IO(Unit):
  match args:
    case Con{path_s, Con{file_s, Nil{}}}:
      main_del_go(path_s, file_s)
    case _:
      main_die(usage())

def main_filter_go(path_s: String, pred_s: String, file_s: String) -> IO(Unit):
  do IO<Unit>:
    doc : J.Json <- IO.try(J.Json, JsonIO.load(file_s))
    segs : Path.SegList = Path.parse(path_s)
    pred : Path.Pred = Path.parse_pred(pred_s)
    out : J.Json = Ops.filter(doc, segs, pred)
    IO.print(Ser.show(out))

def main_filter(args: List<String>) -> IO(Unit):
  match args:
    case Con{path_s, Con{pred_s, Con{file_s, Nil{}}}}:
      main_filter_go(path_s, pred_s, file_s)
    case _:
      main_die(usage())

def drop_cmd(+cmd: String) -> Unit:
  Unit{}

def main_get_after_drop(_u: Unit, rest: List<String>) -> IO(Unit):
  main_get(rest)

def main_pick_filter(filt: Bool, rest: List<String>) -> IO(Unit):
  match filt:
    case True{}:
      main_filter(rest)
    case False{}:
      main_die(usage())

def main_pick_del(is_del: Bool, +cmd: String, rest: List<String>) -> IO(Unit):
  match is_del:
    case True{}:
      main_del(rest)
    case False{}:
      main_pick_filter(Cli.is_filter(cmd), rest)

def main_pick_set(is_set: Bool, +cmd: String, rest: List<String>) -> IO(Unit):
  match is_set:
    case True{}:
      main_set(rest)
    case False{}:
      main_pick_del(Cli.is_del(cmd), cmd, rest)

def main_pick_get(get: Bool, +cmd: String, rest: List<String>) -> IO(Unit):
  match get:
    case True{}:
      main_get_after_drop(drop_cmd(cmd), rest)
    case False{}:
      main_pick_set(Cli.is_set(cmd), cmd, rest)

def main_cmd(+cmd: String, rest: List<String>) -> IO(Unit):
  main_pick_get(Cli.is_get(cmd), cmd, rest)

def main_go(args: List<String>) -> IO(Unit):
  match args:
    case Nil{}:
      main_die(usage())
    case Con{cmd, rest}:
      main_cmd(cmd, rest)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    out : Unit <- main_go(args)
    IO.pure(Unit, out)
