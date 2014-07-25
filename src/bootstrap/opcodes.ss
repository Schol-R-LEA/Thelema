#!r6rs

(library 
 (thelema bootstrap opcodes)
 (export opcode opcode-format)
 (import
  (rnrs base (6))
  (rnrs enums (6))
  (rnrs hashtables (6))
  (rnrs lists (6))
  (rnrs records syntactic (6)))
 
 (define-record-type opcode
   (fields (mnemonic opcode-type)))

 
 (define-record-type opcode-format
   (fields (type size opcode-sub-field-map)))
