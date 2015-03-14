        START   = $0000
        LOAD12  = $190F
        LOADT9  = $1929

        .ORG    $17EC

VEB:     cmp    a:START
         bne    failed
         jmp    LOAD12
failed:  jmp    LOADT9
