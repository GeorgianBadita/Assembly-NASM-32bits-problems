;Badita Marin-Georgian, 211, 31-10-2017, tema lab 5, problema 8

;Se da un numar natural a (a: dword, definit in segmentul de date). Sa se citeasca un numar natural b si sa se calculeze: a + a\b. Sa se ;afiseze rezultatul operatiei. Valorile vor fi afisate in format decimal (baza 10) cu semn.

bits 32


global start        


extern exit, scanf, printf            
import exit msvcrt.dll
import scanf msvcrt.dll
import printf msvcrt.dll

segment data use32 class=data
    b dw 0
    a dd 12
    rez dd 0
    format_scan db "%d", 0 ;conventia folosita pentru citire
    format_printf db "%d", 10, 0 ;conventia folosita pentru afisare

; our code starts here
segment code use32 class=code
    start:
        
        mov AX, WORD [a] ;punem in AX partea low din dwordul a
        mov DX, WORD [a + 2] ;punem in DX partea high din dwordul a
        mov ECX, [a] ;copiem valoarea lui a
        PUSHAD ;salvam valoriile registriilor
        push DWORD b ;punem b pe stiva
        push DWORD format_scan ;punem formatul pe stiva
        
        call [scanf] ;citim b-ul
        add esp, 4*2 ;eliberam stiva
        POPAD ;restauram valorile registriilor
      
        
        idiv WORD [b] ;AX = DX:AX / b = a / b
        cwde ;AX -> EAX
       
        add EAX, ECX ;EAX = a + a/b
        
        mov [rez], EAX ;rez = a + a/b
        push DWORD [rez] ;punem rezultatul pe stiva
        push format_printf ;punem formatul de afisare pe stiva
        call [printf] ;apelam functia printf
        
        add ESP, 4*2 ;eliberam stiva
        
        
        push    dword 0      
        call    [exit]      
