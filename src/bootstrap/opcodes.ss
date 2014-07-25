#!r6rs

(library 
 (thelema bootstrap opcodes)
 (export instruction opcode-format)
 (import
  (rnrs base (6))
  (rnrs enums (6))
  (rnrs hashtables (6))
  (rnrs lists (6))
  (rnrs records syntactic (6)))
 
 (define-record-type instruction
   (fields mnemonic opcode-format-list))
 
 (define-record-type opcode-sub-fields
   (fields size index))
 
 (define-record-type opcode-format
   (fields size opcode opcode-sub-field-map))
