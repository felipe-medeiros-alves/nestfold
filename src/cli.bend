import Base

def eq(cmd: String, lit: String) -> Bool:
  String.eq(cmd, lit)

def is_get(cmd: String) -> Bool:
  eq(cmd, "get")

def is_set(cmd: String) -> Bool:
  eq(cmd, "set")

def is_del(cmd: String) -> Bool:
  eq(cmd, "del")

def is_filter(cmd: String) -> Bool:
  eq(cmd, "filter")
