Term json_parse_run(Env e, Term* f, IoWork* w) {
  (void)f;
  return io_fail(e, EINVAL, "json_parse not implemented");
}

static void __attribute__((constructor)) json_parse_use(void) {
  io_eff(CID_JSON_PARSE, json_parse_run, 0);
}
