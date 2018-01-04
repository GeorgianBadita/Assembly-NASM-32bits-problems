bits 32


global start        


extern exit, fopen, fclose, fread, printf, fprintf      
import exit msvcrt.dll
import fopen msvcrt.dll
import fclose msvcrt.dll
import fread msvcrt.dll
import printf msvcrt.dll
import fprintf msvcrt.dll
segment data use32 class=data
    ; ...
    nume_fisier db "test.txt", 0            ;numele fiseireului care va fi deschis si din care se va citi
    mod_acces db "r", 0                     ;modul de acces, 'r' pentru citire
    mod_acces1 db "w", 0                    ;modul de acces, 'w' pentru scriere
    descripotr_fis dd -1                    ;descriptorul fisierului
    nr_car_citite dd 0                      ;numarul de caractere citite
    len equ 100                             ;numarul maxim de caractere citite intr-o etapa
    buffer times len db 0                   ;sirul in care se va citit textul
    rez times len db 0                      ;sirul in care se va pune rezultatul
    format db "%s", 0                       ;formatul de citire si afisare al input-ului/output-ului
    tabHexa db "0123456789ABCDEF"           ;o tabela cu toate cifrele Hexa
    vocale_mici db "aeiou"                  ;sir de caractere format din vocalele mici 
    vocale_mari db "AEIOU"                  ;sir de caractere format din vocalele mari
    been_voc db 0                           ;variabila de tip bool care ne va spune daca un caracter a fost sau nu vocala
; our code starts here
segment code use32 class=code
    start:
        
        ;apelam functia fopen pentru a deschide fisierul
        ;returneaza in EAX descriptorul sau 0 in caz de eraoare
        push DWORD mod_acces
        push DWORD nume_fisier
        call [fopen]
        add ESP, 4*2
        
        ;verifica daca functia a accesat cu succes fisierul
        cmp EAX, 0
        je final ;daca nu se acceseaza cu succes, sarim la final
        
        mov [descripotr_fis], EAX   ;salvam valoarea returnata de functia fopen in variabila descripotr_fis
        mov EDI, rez    ;setam sirul rezultat ca si sir destinatie
        repeta:
            push DWORD [descripotr_fis]
            push DWORD len
            push DWORD 1
            push DWORD buffer
            call [fread]
            add ESP, 4*4
            
            cmp EAX, 0
            je cleanup ;in cazul incare nu mai avem caractere de citit, sarim la cleanup (afisare si inchidere de fisier)
            
            mov [nr_car_citite], EAX ;salvam numarul de caractere citite
          
            
            mov ESI, buffer     ;initializam sirul sursa ca fiind bufferul citit
            mov ECX, [nr_car_citite]                ;punem in ECX numarul de caractere citite
            compare:
                push ECX                            ;salvam pe stiva valoarea lui ECX
                lodsb                               ;incarcam in AL, elementul curent din sir
                mov ECX, 0                          ;setam valoarea lui ECX la 0, pentru a-l folosi ca si contor
                mov [been_voc], BYTE 1              ;punem in variabila been_voc valoarea 1, insemnand ca presupunem ca nu e vocala
                vocala:
                    mov DL, [vocale_mici + ECX]     ;punem in DL, vocala mica curenta
                    mov DH, [vocale_mari + ECX]     ;punem in DH, vocala mare curenta
                    inc ECX                         ;incrementam valoarea lui ECX, pentru a trece la urmatoarea vocala
                    cmp AL, DL                      ;comparam elementul curent cu vocala mica curenta
                        je vocala_mica              ;in caz de egalitate, mergem la etiecheta vocala_mica
                        jmp try_voc_mare            ;altfel incercam sa vedem daca caracterul curent este o vocala mare
                        vocala_mica:
                          mov AH, AL                
                          mov EBX, tabHexa          ;mutam in EBX, tabHexa pentru a putea folosi functia xlat
                          shr AL, 4                 ;shiftam la dreapta cu 4 pentru a avea in AL, cifra hexa din stanga
                          xlat                      ;folosim xlat si vom avea in AL valoarea de la indexul ce era inainte in AL, din tabHexa
                          stosb                     ;punem prima cifra in sirul rezultat
                          mov AL, AH
                          and AL, 0Fh               ;salvam doar a 2-a cifra hexa, deoarece aceasta ne intereseaza
                          xlat                      ;aplicam din nou xlat si salvam in rezultat cifra
                          stosb
                          mov [been_voc], BYTE 0    ;setam been_voc la 0, inseamna ca am gasit vocala
                          jmp base_case             ;sarim la cazul de baza
                        try_voc_mare:
                            cmp AL, DH
                            je put_voc_mare        ;-----------------------------------------------------------
                            jmp base_case           ;aplicam acelasi rationament doar ca pentru vocalele mari  |
                            put_voc_mare:          ;-----------------------------------------------------------
                                mov AH, AL
                                mov EBX, tabHexa
                                shr AL, 4
                                xlat
                                stosb
                                mov AL, AH
                                and AL, 0Fh
                                xlat
                                stosb
                                mov [been_voc], BYTE 0
                                jmp base_case
                    base_case:
                        cmp ECX, 5      ;daca inca mai avem vocale
                        jnge vocala     ;comparam in continuare
                        jmp finished    ;reluam primul loop
            finished:
                mov DL, [been_voc]      ;punem in DL, valoarea lui been_voc
                mov DH, 1               
                cmp DL, DH              ;comparam DL, 1
                je store_cons           ;daca DL este 1, inseamna ca avem consoana, deci sarim la store_cons pentru a o pune in sir
                jmp reinit              ;sarim la reinitializarea primului loop
            store_cons:
                stosb
            reinit:
                pop ECX                 ;scoatem ECX de pe stiva
                loop compare            ;ne reintoarcem la primul loop
            jmp repeta  ;refacem bucla de citire
        
        cleanup:
            
              push DWORD mod_acces1       ;Deschidem fisierul pentru scriere
              push DWORD nume_fisier    
              call [fopen]
              add ESP, 4*2                ; eliberam parametrii de pe stiva
                
                
              cmp EAX, 0                  ; comparam din nou valoarea returnata de eax cu 0, pentru a nu exista erori
              je final
              
              mov [descripotr_fis], EAX   ;punem in descripotr_fis valoarea returnata de EAX
                
               push dword rez
               push dword [descripotr_fis]
               call [fprintf]             ;afisam rezultatul in fisier
               add esp, 4*2
            
            push DWORD [descripotr_fis]
            call [fclose]                 ;inchidem fisierul
            add ESP, 4
        final:
        push    dword 0      
        call    [exit]      
