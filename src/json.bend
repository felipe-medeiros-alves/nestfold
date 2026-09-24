import Base

type Json is Type:
  JNull{}
  JBool{b: Bool}
  JNum{s: String}
  JStr{s: String}
  JArr{xs: List<Json>}
  JObj{xs: List<JsonPair>}

type JsonPair is Type:
  JsonPair{key: String, val: Json}
