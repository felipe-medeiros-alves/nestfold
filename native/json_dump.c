Term json_dump_run(Env e, Term* f, IoWork* w) {
  (void)f;
  return io_done(e, io_str(e, "null", 4));
}

static void __attribute__((constructor)) json_dump_use(void) {
  io_eff(CID_JSON_DUMP, json_dump_run, 0);
}
