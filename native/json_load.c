#include "yyjson/yyjson.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static Term build_json(Env e, yyjson_val* val);

static Term build_list(Env e, Term* items, size_t len) {
  Term xs = term_pak(CID_NIL, 0);
  for (size_t i = len; i > 0; i--) {
    xs = io_node(e, CID_CON, items[i - 1], xs);
  }
  return xs;
}

static Term build_array(Env e, yyjson_val* arr) {
  size_t len = yyjson_arr_size(arr);
  if (len == 0) {
    return term_pak(CID_NIL, 0);
  }
  Term* items = malloc(len * sizeof(Term));
  if (!items) {
    return term_pak(CID_NIL, 0);
  }
  for (size_t i = 0; i < len; i++) {
    items[i] = build_json(e, yyjson_arr_get(arr, i));
  }
  Term xs = build_list(e, items, len);
  free(items);
  return xs;
}

static Term build_object(Env e, yyjson_val* obj) {
  size_t len = yyjson_obj_size(obj);
  if (len == 0) {
    return term_pak(CID_NIL, 0);
  }
  Term* items = malloc(len * sizeof(Term));
  if (!items) {
    return term_pak(CID_NIL, 0);
  }
  yyjson_obj_iter iter;
  yyjson_obj_iter_init(obj, &iter);
  size_t i = 0;
  yyjson_val* key;
  while ((key = yyjson_obj_iter_next(&iter))) {
    yyjson_val* v = yyjson_obj_iter_get_val(key);
    const char* k = yyjson_get_str(key);
    size_t kn = yyjson_get_len(key);
    items[i++] = io_node(e, CID_JSON_PAIR, io_str(e, k, kn), build_json(e, v));
  }
  return build_list(e, items, len);
}

static Term build_json(Env e, yyjson_val* val) {
  if (yyjson_is_null(val)) {
    return term_pak(CID_J_NULL, 0);
  }
  if (yyjson_is_true(val)) {
    return io_node(e, CID_J_BOOL, term_pak(CID_TRUE, 0), 0);
  }
  if (yyjson_is_false(val)) {
    return io_node(e, CID_J_BOOL, term_pak(CID_FALSE, 0), 0);
  }
  if (yyjson_is_num(val)) {
    char buf[64];
    size_t n = (size_t)snprintf(buf, sizeof(buf), "%.17g", yyjson_get_num(val));
    return io_node(e, CID_J_NUM, io_str(e, buf, n), 0);
  }
  if (yyjson_is_str(val)) {
    return io_node(e, CID_J_STR, io_str(e, yyjson_get_str(val), yyjson_get_len(val)), 0);
  }
  if (yyjson_is_arr(val)) {
    return io_node(e, CID_J_ARR, build_array(e, val), 0);
  }
  if (yyjson_is_obj(val)) {
    return io_node(e, CID_J_OBJ, build_object(e, val), 0);
  }
  return term_pak(CID_J_NULL, 0);
}

Term json_load_run(Env e, Term* f, IoWork* w) {
  uint64_t mn = 0;
  char* path = io_cstr(e, f[0], &mn);
  if (io_nul(path, mn)) {
    free(path);
    return io_fail(e, EINVAL, "empty path");
  }
  FILE* fp = fopen(path, "rb");
  free(path);
  if (!fp) {
    return io_fail(e, errno, NULL);
  }
  fseek(fp, 0, SEEK_END);
  long sz = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  if (sz < 0) {
    fclose(fp);
    return io_fail(e, errno, NULL);
  }
  char* data = malloc((size_t)sz + 1);
  if (!data) {
    fclose(fp);
    return io_fail(e, ENOMEM, NULL);
  }
  size_t rd = fread(data, 1, (size_t)sz, fp);
  fclose(fp);
  data[rd] = '\0';
  yyjson_doc* doc = yyjson_read(data, rd, 0);
  free(data);
  if (!doc) {
    return io_fail(e, EINVAL, "invalid json");
  }
  Term root = build_json(e, yyjson_doc_get_root(doc));
  yyjson_doc_free(doc);
  return io_done(e, root);
}

static void __attribute__((constructor)) json_load_use(void) {
  io_eff(CID_JSON_LOAD, json_load_run, 0);
}
