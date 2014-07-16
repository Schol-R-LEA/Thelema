#!r6rs

(library 
 (thelema bootstrap elf)
 (export ELF-File-Types ELF-Operating-Systems ELF-Architectures elf-file-header write-elf-file-header read-elf-file-header)
 (import
  (rnrs base (6))
  (rnrs enums (6))
  (rnrs hashtables (6))
  (rnrs unicode (6))
  (rnrs bytevectors (6))
  (rnrs lists (6))
  (rnrs records syntactic (6))
  (rnrs io ports (6))
  (rnrs exceptions (6))
  (rnrs control (6)))
 
 (define MAGIC-COOKIE (list->string '(#\x7F #\E #\L #\F)))
 (define padding-size 7)
 
 (define-enumeration ELF-File-Types (RELOCATABLE EXECUTABLE SHARED CORE) file-type-set) 
 
 (define-record-type section-record
   (fields name (mutable symbol-table))
   (sealed #t))
 
 (define-record-type program-header
   (fields type offset virtual-address physical-address size-in-file size-in-memory flags align)
   (sealed #t))
 
 (define-record-type section-header
   (fields name-position type flags base-address offset size link info align entry-size)
   (sealed #t))
 
 (define-record-type elf-symbol-table-entry
   (fields name-position value size type binding other section-number)
   (sealed #t))
 
 
 (define-record-type elf-header-identifier
   (fields                                   ; all fields are immutable
    magic                                    ; 'magic number' indicating file type
    bit-width                                ; bit width - 1 is 32 bits, 2 is 64 bits
    endianness                               ; endianness - 1 for little, 2 for big
    version                                  ; ELF format version, always set to 1
    OS-ABI                                   ; Operating System interface type
    ABI-version                              ; ABI version, usually ignored
    padding)                                 ; seven byte reserved area
   (protocol
    (lambda (ctor)
      (lambda (class byte-order system system-version)
        (ctor 
         (string->bytevector MAGIC-COOKIE)   ; magic
         (make-bytevector 1 class)           ; bit-width
         (make-bytevector 1 byte-order)      ; endianness
         (make-bytevector 1 1)               ; version
         (make-bytevector 1 system)          ; operating system 
         (make-bytevector 1 system-version)  ; OS ABI version
         (make-bytevector padding-size 0))))); padding
   (sealed #t))
 
 (define-record-type elf-file-header
   (fields
    (immutable identifier)
    (mutable file-type)                      ; file type - 1=relocatable, 2=executable, 3=shared object, 4=core image
    (mutable arch-type)                      ; CPU architecture type - 2=SPARC, 3=x86, 4=68K, etc.
    (immutable file-version)                 ; file version, always 1
    (mutable entry-point)                    ; entry point if executable 
    (mutable program-header-position)        ; file position of program header or 0
    (mutable section-header-position)        ; file position of section header or 0
    (immutable flags)                        ; architecture specific flags, usually 0
    (mutable size)                           ; size of this ELF header 
    (mutable program-header-size)            ; size of an entry in program header
    (mutable program-header-entries)         ; number of entries in program header or 0
    (mutable section-header-size)            ; size of an entry in section header 
    (mutable section-header-entries)         ; number of entries in section header or 0 
    (mutable section-id-string-area))        ; section number that contains section name strings
   (protocol 
    (lambda (ctor)
      (lambda (identifier type arch entry-point ph-pos sh-pos flags ph-size ph-entries sh-size sh-entries string-pos)
        (let* ((bits (elf-header-identifier-bit-width identifier))
               (address-size (if (= 1 bits) 4 8))
               (offset-size address-size)
               (header-size (+ 38 address-size (* 2 offset-size))))
          (ctor
           identifier                         ; ELF header identifier
           #vu8(1 0)                          ; file-type
           (make-bytevector 1 arch)           ; arch-type
           #vu8(1 0 0 0)                      ; file-version
           (make-bytevector address-size 0)   ; entry-point
           (make-bytevector offset-size 0)    ; program-header-position
           (make-bytevector offset-size 0)    ; section-header-position
           (make-bytevector 4 0)              ; flags
           (make-bytevector 2 header-size)    ; size
           (make-bytevector 2 ph-size)        ; program-header-size
           (make-bytevector 2 ph-entries)     ; program-header-entries
           (make-bytevector 2 sh-size)        ; section-header-size
           (make-bytevector 2 sh-entries)     ; section-header-entries     
           (make-bytevector 2 string-pos)))))); section-id-string-area
   (sealed #t))
 
 
 (define (write-elf-identifier dest id)
   (put-bytevector dest (elf-header-identifier-magic id))
   (put-bytevector dest (elf-header-identifier-bit-width id))
   (put-bytevector dest (elf-header-identifier-endianness id))
   (put-bytevector dest (elf-header-identifier-version id))
   (put-bytevector dest (elf-header-identifier-OS-ABI id))
   (put-bytevector dest (elf-header-identifier-ABI-version id))
   (put-bytevector dest (elf-header-identifier-padding id)))
 
 (define (write-elf-file-header dest h)
   (write-elf-identifier dest (elf-file-header-identifier h))
   (put-bytevector dest (elf-file-header-file-type h))
   (put-bytevector dest (elf-file-header-arch-type h))
   (put-bytevector dest (elf-file-header-file-version h))
   (put-bytevector dest (elf-file-header-entry-point h))
   (put-bytevector dest (elf-file-header-program-header-position h))
   (put-bytevector dest (elf-file-header-section-header-position h))
   (put-bytevector dest (elf-file-header-flags h))
   (put-bytevector dest (elf-file-header-size h))         
   (put-bytevector dest (elf-file-header-program-header-size h))     
   (put-bytevector dest (elf-file-header-program-header-entries h))  
   (put-bytevector dest (elf-file-header-section-header-size h))     
   (put-bytevector dest (elf-file-header-section-header-entries h))  
   (put-bytevector dest (elf-file-header-section-id-string-area h)))
 
 (define (read-elf-file-header src)
   '())
 
 
 
 (define ELF-Architectures (make-hashtable symbol-hash eqv?))
 (define ELF-Operating-Systems (make-hashtable symbol-hash eqv?))
 
 (hashtable-set! ELF-Architectures 'None 0)
 (hashtable-set! ELF-Architectures 'M32 1)
 (hashtable-set! ELF-Architectures 'SPARC 2)
 (hashtable-set! ELF-Architectures 'x86-32 3)
 (hashtable-set! ELF-Architectures 'M68K 4)
 (hashtable-set! ELF-Architectures 'M88K 5)
 (hashtable-set! ELF-Architectures 'i860 7)
 (hashtable-set! ELF-Architectures 'MIPS-I 8)
 (hashtable-set! ELF-Architectures 'S370 9)
 (hashtable-set! ELF-Architectures 'MIPS-RS3K-LE #xA)
 (hashtable-set! ELF-Architectures 'PA-RISC #xF)
 (hashtable-set! ELF-Architectures 'SPARC32-Plus #x12)
 (hashtable-set! ELF-Architectures 'i960 #x13)
 (hashtable-set! ELF-Architectures 'Power-PC #x14)
 (hashtable-set! ELF-Architectures 'Power-PC-64 #x15)
 (hashtable-set! ELF-Architectures 'S390 #x16)
 (hashtable-set! ELF-Architectures 'ARM-32 #x28)
 (hashtable-set! ELF-Architectures 'Alpha #x29)
 (hashtable-set! ELF-Architectures 'Super-H #x2A)
 (hashtable-set! ELF-Architectures 'SPARC-V9 #x2B)
 (hashtable-set! ELF-Architectures 'Itanium #x32)
 (hashtable-set! ELF-Architectures 'x86-64 #x3E)
 (hashtable-set! ELF-Architectures 'MMIX #x50)
 (hashtable-set! ELF-Architectures 'Open-RISC #x5C)
 (hashtable-set! ELF-Architectures 'ARM-64 #xB7)
 (hashtable-set! ELF-Architectures 'Tilera-64 #xBB)
 (hashtable-set! ELF-Architectures 'Tilera-Pro #xBC)
 (hashtable-set! ELF-Architectures 'MicroBlaze #xBD)
 (hashtable-set! ELF-Architectures 'CUDA #xBE)
 
 (hashtable-set! ELF-Operating-Systems 'SYS-V 0)
 (hashtable-set! ELF-Operating-Systems 'HP-UX 1)
 (hashtable-set! ELF-Operating-Systems 'NetBSD 2)
 (hashtable-set! ELF-Operating-Systems 'GNU/Linux 3)
 (hashtable-set! ELF-Operating-Systems 'Solaris 6)
 (hashtable-set! ELF-Operating-Systems 'AIX 7)
 (hashtable-set! ELF-Operating-Systems 'IRIX 8)
 (hashtable-set! ELF-Operating-Systems 'FreeBSD 9)
 (hashtable-set! ELF-Operating-Systems 'Tru64 #xA)
 (hashtable-set! ELF-Operating-Systems 'Modesto #xB)
 (hashtable-set! ELF-Operating-Systems 'OpenBSD #xC)
 (hashtable-set! ELF-Operating-Systems 'OpenVMS #xD)
 (hashtable-set! ELF-Operating-Systems 'HP-NSK #xE)
 (hashtable-set! ELF-Operating-Systems 'AROS #xF)
 (hashtable-set! ELF-Operating-Systems 'Fenix #x10)
 (hashtable-set! ELF-Operating-Systems 'Embedded #xFF))
