bits 32


global start        


extern exit, printf, scanf           
import exit msvcrt.dll
import printf msvcrt.dll
import scanf msvcrt.dll

segment data use32 class=data
    ; ...
    format db "%c", 0
    format1 db "%c%c", 0
    chr resb 2
    tabHexa db "0123456789ABCDEF"
; our code starts here
segment code use32 class=code
    start:
        push DWORD chr
        push DWORD format
        call [scanf]
        add ESP, 4*2
        
        mov AL, [chr]
        
        mov AH, AL
        mov EBX, tabHexa
        shr AL, 4
        xlat
        mov [chr], AL
        mov AL, AH
        and AL, 0Fh
        xlat
        mov [chr + 1], AL
        
        push DWORD [chr + 1]
        push DWORD [chr]
        push DWORD format1
        call [printf]
        add ESP, 4*3
        
        push    dword 0      
        call    [exit]      
