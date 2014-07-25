#!r6rs

(library 
 (thelema bootstrap x86)
 (export x86-word-sizes x86-instruction-fields x86-opcode-fields x86-mnemonics)
 (import
  (rnrs base (6))
  (rnrs enums (6))
  (rnrs hashtables (6))
  (rnrs lists (6))
  (rnrs records syntactic (6))
  (rnrs exceptions (6))
  (rnrs conditions (6))
  (thelema bootstrap opcodes))
 
 (define x86-word-sizes (make-hashtable symbol-hash eq?)) 
 
 (define-enumeration x86-instruction-fields 
   (PREFIX
    SEGMENT
    OP-SIZE-OVERRIDE
    ADDRESS-SIZE-OVERRIDE
    OPCODE
    REG
    MOD-R/M
    SCALED/INDEXED
    DISPLACEMENT
    IMMEDIATE)
   x8-opcode-field-set)
 
 (define nilary '(OPCODE))
 
 (define unary-acc '(OPCODE))
 (define unary-reg '(OPCODE REG))
 (define unary-imm '(OPCODE IMMEDIATE))
 (define unary-indexed '(OPCODE SCALED/INDEXED IMMEDIATE))
 
 (define binary-acc-reg '(OPCODE REG))
 (define binary-reg-acc '(OPCODE REG))
 (define binary-acc-imm '(OPCODE REG IMMEDIATE))
 (define binary-reg-reg '(OPCODE REG))
 (define binary-reg-imm '(OPCODE REG IMMEDIATE))
 (define binary-r/m-reg '(OPCODE MOD-R/M))
 (define binary-reg-r/m '(OPCODE MOD-R/M))
 (define binary-r/m-imm '(OPCODE MOD-R/M IMMEDIATE))
 
 (define op-size-override #x66)
 (define addr-size-override #x67)
 
 (define x86-prefixes (make-hashtable symbol-hash eq?))
 (define x86-segment-overrides (make-hashtable symbol-hash eq?))
 (define x86-branch-pred-prefixes (make-hashtable symbol-hash eq?))
 
 (define-record-type x86-opcode-fields
   (parent opcode-fields)
   (fields opcode-bits sub-fields))
   
 (define-record-type x86-opcode-sub-fields
   (fields size index))
   
 (define x86-opcode-sub-field-set (make-hashtable symbol-hash eq?))
 
 (define-record-type x86-opcode
   (fields primary-offset zero-f-offset primary-opcode secondary-opcode r/o))
 
 (define-record-type x86-opcode-field-set
   (fields opcode field-signature arg-sizes))
 
 (define-record-type x86-instruction
   (parent instruction)
   (fields '()))
 
 (define i8086-mnemonics (make-hashtable symbol-hash eq?))
 (define i80186-mnemonics (make-hashtable symbol-hash eq?))
 (define i80286-mnemonics (make-hashtable symbol-hash eq?))
 (define i80287-mnemonics (make-hashtable symbol-hash eq?))
 (define i80386-mnemonics (make-hashtable symbol-hash eq?))
 (define i80387-mnemonics (make-hashtable symbol-hash eq?))
 (define i80486-mnemonics (make-hashtable symbol-hash eq?))
 (define pentium-mnemonics (make-hashtable symbol-hash eq?))
 (define ppro-mnemonics (make-hashtable symbol-hash eq?))
 (define MMX-mnemonics (make-hashtable symbol-hash eq?))
 (define pII-mnemonics (make-hashtable symbol-hash eq?))
 (define pIII-mnemonics (make-hashtable symbol-hash eq?))
 (define pIV-mnemonics (make-hashtable symbol-hash eq?))
 (define core-mnemonics (make-hashtable symbol-hash eq?))
 (define core2-mnemonics (make-hashtable symbol-hash eq?))
 (define SSE-mnemonics (make-hashtable symbol-hash eq?))
 (define SSE2-mnemonics (make-hashtable symbol-hash eq?))
 (define SSE3-mnemonics (make-hashtable symbol-hash eq?))
 (define SSSE3-mnemonics (make-hashtable symbol-hash eq?))
 (define SSE4-mnemonics (make-hashtable symbol-hash eq?))
 
 (define x86-mnemonics '(i8086-mnemonics i80186-mnemonics i80286-mnemonics i80287-mnemonics i80386-mnemonics i80387-mnemonics i80486-mnemonics
                                        pentium-mnemonics ppro-mnemonics MMX-mnemonics pII-mnemonics pIII-mnemonics pIV-mnemonics
                                        core-mnemonics core2-mnemonics
                                        SSE-mnemonics SSE2-mnemonics SSE3-mnemonics SSSE3-mnemonics SSE4-mnemonics))
 
 (hashtable-set! x86-opcode-sub-field-set 'R+ (x86-opcode-sub-fields 3 0))
 (hashtable-set! x86-opcode-sub-field-set 'W (x86-opcode-sub-fields 1 0))
 (hashtable-set! x86-opcode-sub-field-set 'S (x86-opcode-sub-fields 1 1))
 (hashtable-set! x86-opcode-sub-field-set 'D (x86-opcode-sub-fields 1 1))
 (hashtable-set! x86-opcode-sub-field-set 'TTTN (x86-opcode-sub-fields 1 3))
 (hashtable-set! x86-opcode-sub-field-set 'SR (x86-opcode-sub-fields 2 3))
 (hashtable-set! x86-opcode-sub-field-set 'SRE (x86-opcode-sub-fields 3 3))
 (hashtable-set! x86-opcode-sub-field-set 'MF (x86-opcode-sub-fields 2 1))
 
 
 (hashtable-set! x86-word-sizes 'NONE 0)
 (hashtable-set! x86-word-sizes 'BYTE 1)
 (hashtable-set! x86-word-sizes 'WORD 2)
 (hashtable-set! x86-word-sizes 'DOUBLE-WORD 4)
 (hashtable-set! x86-word-sizes 'QUAD-WORD 8)
 (hashtable-set! x86-word-sizes 'OCT-WORD 16)
 (hashtable-set! x86-word-sizes 'HEX-WORD 32)
 (hashtable-set! x86-word-sizes 'HALF-K 64) 
 (hashtable-set! x86-word-sizes 'SYSTEM-HALF-WORD '(8 16))
 (hashtable-set! x86-word-sizes 'SYSTEM-WORD '(16 32 64))
 (hashtable-set! x86-word-sizes 'FP-STATE '(94 108))
 (hashtable-set! x86-word-sizes 'FP80 10)
 (hashtable-set! x86-word-sizes 'FP96 12)
 
 (hashtable-set! x86-prefixes 'LOCK #xF0)
 (hashtable-set! x86-prefixes 'REPNE #xF2)
 (hashtable-set! x86-prefixes 'REPNZ #xF2)
 (hashtable-set! x86-prefixes 'REP #xF3)
 (hashtable-set! x86-prefixes 'REPE #xF3)
 (hashtable-set! x86-prefixes 'REPZ #xF3) 
 
 (hashtable-set! x86-branch-pred-prefixes 'BRT #x2E)  ; 'branch taken' strong hint
 (hashtable-set! x86-branch-pred-prefixes 'BRNT #x3E) ; 'branch not taken' weak hint
 
 (hashtable-set! x86-segment-overrides 'CS #x2E)
 (hashtable-set! x86-segment-overrides 'SS #x36)
 (hashtable-set! x86-segment-overrides 'DS #x3E)
 (hashtable-set! x86-segment-overrides 'ES #x26)
 (hashtable-set! x86-segment-overrides 'FS #x64)
 (hashtable-set! x86-segment-overrides 'GS #x65)
 
 
 (hashtable-set! i8086-mnemonics 'AAA (make-x86-instruction 
                                      "AAA" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x37 'NONE 'NONE) nilary '(NONE)))))
 (hashtable-set! i8086-mnemonics 'AAD (make-x86-instruction 
                                      "AAD" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #xD5 #x0A 'NONE) nilary '(NONE)))))
 (hashtable-set! i8086-mnemonics 'AAM (make-x86-instruction 
                                      "AAM" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #xD4 #x0A 'NONE) nilary '(NONE)))))
 (hashtable-set! i8086-mnemonics 'AAS (make-x86-instruction 
                                      "AAS" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #xEF 'NONE 'NONE) nilary '(NONE)))))
 (hashtable-set! i8086-mnemonics 'ADC (make-x86-instruction 
                                      "ADC" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x10 'NONE 'reg) binary-r/m-reg '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x11 'NONE 'reg) binary-r/m-reg '(SYSTEM-WORD SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x12 'NONE 'reg) binary-reg-r/m '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x13 'NONE 'reg) binary-reg-r/m '(SYSTEM-WORD SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x14 'NONE 'NONE) binary-acc-imm '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x15 'NONE 'NONE) binary-acc-imm '(SYSTEM-WORD SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x80 'NONE 2) binary-r/m-imm '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x81 'NONE 2) binary-r/m-imm '(SYSTEM-WORD SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x82 'NONE 2) binary-r/m-imm '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x83 'NONE 2) binary-r/m-imm '(SYSTEM-WORD BYTE)))))
 
 (hashtable-set! i8086-mnemonics 'ADD (make-x86-instruction 
                                      "ADD" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x00 'NONE 'reg) binary-r/m-reg '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x01 'NONE 'reg) binary-r/m-reg '(SYSTEM-WORD SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x02 'NONE 'reg) binary-reg-r/m '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x03 'NONE 'reg) binary-reg-r/m '(BYTE SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x04 'NONE  'NONE) binary-acc-imm '(BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x05 'NONE 'NONE) binary-acc-imm '(SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x80 'NONE 0) binary-r/m-imm '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x81 'NONE 0) binary-r/m-imm '(SYSTEM-WORD SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x82 'NONE 0) binary-r/m-imm '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x83 'NONE 0) binary-r/m-imm '(SYSTEM-WORD BYTE)))))
 (hashtable-set! i8086-mnemonics 'AND (make-x86-instruction 
                                      "AND" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x20 'NONE 'reg) binary-r/m-reg '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x21 'NONE 'reg) binary-r/m-reg '(SYSTEM-WORD SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x22 'NONE 'reg) binary-reg-r/m '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x23 'NONE 'reg) binary-reg-r/m '(BYTE SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x24 'NONE 'NONE) binary-acc-imm '(BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x25 'NONE 'NONE) binary-acc-imm '(SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE  #x80 'NONE 4) binary-r/m-imm '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x81 'NONE 4) binary-r/m-imm '(SYSTEM-WORD SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x82 'NONE 4) binary-r/m-imm '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE  'NONE #x83 'NONE 4) binary-r/m-imm '(SYSTEM-WORD BYTE)))))
 (hashtable-set! i8086-mnemonics 'CALL (make-x86-instruction 
                                       "CALL" 
                                       (list (make-x86-opcode-field-set 
                                              (make-x86-opcode 'NONE 'NONE #xE8 'NONE 'NONE) unary-imm '(SYSTEM-WORD))
                                             (make-x86-opcode-field-set 
                                              (make-x86-opcode 'NONE 'NONE #xFF 'NONE 2) unary-reg '(BYTE)))))
 (hashtable-set! i8086-mnemonics 'CALLF (make-x86-instruction 
                                        "CALLF" 
                                        (list (make-x86-opcode-field-set 
                                               (make-x86-opcode 'NONE 'NONE #x9A 'NONE 'NONE) unary-imm '(SYSTEM-WORD))
                                              (make-x86-opcode-field-set 
                                               (make-x86-opcode 'NONE 'NONE #xFF 'NONE 3) unary-reg '(BYTE)))))
 (hashtable-set! i8086-mnemonics 'CBW (make-x86-instruction 
                                      "CBW" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x98 'NONE 'NONE) nilary '(NONE)))))
 (hashtable-set! i8086-mnemonics 'CLC (make-x86-instruction 
                                      "CLC" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #xF8 'NONE 'NONE) nilary '(NONE)))))
 (hashtable-set! i8086-mnemonics 'CLD (make-x86-instruction 
                                      "CLD" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #xFC 'NONE 'NONE) nilary '(NONE)))))
 (hashtable-set! i8086-mnemonics 'CLI (make-x86-instruction 
                                      "CLI" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #xFA 'NONE 'NONE) nilary '(NONE)))))
 (hashtable-set! i8086-mnemonics 'CMC (make-x86-instruction 
                                      "CMC" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #xF5 'NONE 'NONE) nilary '(NONE)))))
 (hashtable-set! i8086-mnemonics 'CMP (make-x86-instruction 
                                      "CMP" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x38 'NONE 'reg) binary-r/m-reg '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x39 'NONE 'reg) binary-r/m-reg '(SYSTEM-WORD SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x3A 'NONE 'reg) binary-reg-r/m '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x3B 'NONE 'reg) binary-reg-r/m '(BYTE SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x3C 'NONE 'NONE) binary-acc-imm '(BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE  #x3D 'NONE 'NONE) binary-acc-imm '(SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x80 'NONE 7) binary-r/m-imm '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x81 'NONE 7) binary-r/m-imm '(SYSTEM-WORD SYSTEM-WORD))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x82 'NONE 7) binary-r/m-imm '(BYTE BYTE))
                                            (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #x83 'NONE 7) binary-r/m-imm '(SYSTEM-WORD BYTE)))))
 (hashtable-set! i8086-mnemonics 'CMPSB (make-x86-instruction 
                                      "CMPSB" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #xA6 'NONE 'NONE) binary-mem-mem '(BYTE BYTE)))))
 (hashtable-set! i8086-mnemonics 'CMPSW (make-x86-instruction 
                                      "CMPSW" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #xA7 'NONE 'NONE) binary-mem-mem '(SYSTEM-WORD SYSTEM-WORD)))))
 
 (hashtable-set! i8086-mnemonics 'CMPSW (make-x86-instruction 
                                      "CMPSW" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #xA7 'NONE 'NONE) binary-mem-mem '(SYSTEM-WORD SYSTEM-WORD)))))
 (hashtable-set! i8086-mnemonics 'CMPSW (make-x86-instruction 
                                      "CMPSW" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #xA7 'NONE 'NONE) binary-mem-mem '(SYSTEM-WORD SYSTEM-WORD)))))
 
 
 
 
 
 
 
 (hashtable-set! i80186-mnemonics 'BOUND (make-x86-instruction 
                                        "BOUND" 
                                        (list (make-x86-opcode-field-set 
                                               (make-x86-opcode 'NONE 'NONE #x62 'NONE 'reg) binary-reg-imm '(BYTE SYSTEM-WORD SYSTEM-WORD)))))
 
 
 (hashtable-set! i80386-mnemonics 'CMPSD (make-x86-instruction 
                                      "CMPSD" 
                                      (list (make-x86-opcode-field-set 
                                             (make-x86-opcode 'NONE 'NONE #xA7 'NONE 'NONE) binary-mem-mem '(SYSTEM-WORD SYSTEM-WORD)))))
