#!r6rs

(library 
 (thelema bootstrap opcodes)
 (export opcode-format)
 (import
  (rnrs base (6))
  (rnrs enums (6))
  (rnrs hashtables (6))
  (rnrs lists (6))
  (rnrs records syntactic (6)))
 
 (define-record-type opcode-format
   (fields (opcode-field-map)))