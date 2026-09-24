import Base
import ./json.bend as J

def load(path: String) ->
  IO(Result<&1, &1, U32 & String, J.Json>):
  import "../native/json_load.c"
  import "../native/json_load.js"

def dump(value: J.Json) -> IO(String):
  import "../native/json_dump.c"
  import "../native/json_dump.js"

def parse(text: String) ->
  IO(Result<&1, &1, U32 & String, J.Json>):
  import "../native/json_parse.c"
  import "../native/json_parse.js"
