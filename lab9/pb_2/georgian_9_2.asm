;Badita Marin-Georgian, gr. 211, 28.11.2017, tema lab 9, problema 2

;Se da un fisier text. Sa se citeasca continutul fisierului, sa se contorizeze numarul de consoane si sa se afiseze aceasta valoare. 
;Numele fisierului text este definit in segmentul de date.



bits 32


global start        


extern exit, fopen, fread, fclose, printf     
import exit msvcrt.dll
import fopen msvcrt.dll
import fread msvcrt.dll
import fclose msvcrt.dll
import printf msvcrt.dll

segment data use32 class=data
    ; ...
    nume_fisier db "input.txt", 0 ;numele fisierului care ca fi creat
    mod_acces db "r", 0           ;modul de deschidere a fisierului
    len equ 100                   ;numarul maxim de elemente cititie din fisier
    buffer times (len + 1) db 0     ;sirul in care se va citit textul din fisier de dimensiune (len + 1)
    descrptor_fis dd -1           ;variabila in care vom salva descriptorul fisierului - necesar pentru a putea face referire la fisier
    format db "Numarul de consoane din text este %d", 0 ;formatul - utilizat pentru afisarea numarului de consoane din textul cititi
; our code starts here
    nr_car_citite dd 0 ;variabila in care vom salva numarul de caractere
    numar_cons db 0   ;variabila care numara cate consoane avem
segment code use32 class=code
    start:
        ;apelam fopen pentru a deschide fisierului
        ;functia va returna in EAX descriptorul fisierului sau 0 in caz de eroare
        ;EAX = fopen(nume_fisier, mod_acces)
        
        push DWORD mod_acces
        push DWORD nume_fisier
        call [fopen]
        add ESP, 4*2    ;eliberam parametrii de pe stiva
       
        mov [descrptor_fis], EAX ;salvam valoarea returnata de fopen in variabila descrptor_fis
        
        ;verificam daca functia fopen a accesat cu succes fisierul (daca EAX != 0)
        
        cmp EAX, 0
        je final
        ;citim textul din fisierul deschis folosind functia fread
        ;EAX = fread(text, 1, len, descrptor_fis)
        
        bucla:
            ;citim o parte(100 de caractere) din textul in fisierul deschis folosind fread
            ;EAX = fread(buffer, 1, len, descrptor_fis)
            push DWORD [descrptor_fis]
            push DWORD len
            push DWORD 1
            push DWORD buffer
            call [fread]
            add ESP, 4*4
            
            ;EAX = numar de caractere /bytes citite
            cmp EAX, 0  ;daca numarul de caractere citite este  0, am terminat de parcurs fisierul
            je clean_up
            
            mov [nr_car_citite], EAX ;salvam numarul de caractere citite
            mov EDX, 0      ;punem 0 in EDX, deoarece il vom folosi ca si contor
            mov ECX, [nr_car_citite] ;punem in ECX nr_car_citite ca sa iteram 
            cld ;setam directia de parcurgere de la stanga la dreapta
            jecxz final
            num_cons:   
                
                mov BL, [buffer + EDX] ;punem in BL pozitia curenta din sir
                inc EDX ;incrementam EDX pentru a trece la pozitia urmatoare
                cmp BL, 'a' ;comparam valoarea curenta cu a
                jne comp_e ;daca nu este egala cu a, trecem la e
                je not_cons ;daca este egala cu a, sarim la eticheta not_cons
                comp_e: 
                    cmp BL, 'e' ;comparam valoarea curenta cu e
                    jne comp_i ;daca nu este egala trecem la compararea cu i
                    je not_cons ;daca caracterul este egal cu i trecem la eticheta not_cons
                    comp_i: 
                        cmp BL, 'i' ;comparam caracterul curent cu i
                        jne comp_o ;daca nu este egal cu i, trecem la compararea cu o
                        je not_cons ;daca este egal cu i atunci sarim la eticheta not_cons
                        comp_o:
                            cmp BL, 'o' ;comparam caracterul curent cu o
                            jne comp_u ;daca nu este egal cu o, trecem la compararea cu u
                            je not_cons ;daca este egal cu o atunci trecem la eticheta not_cons
                            comp_u:
                                cmp BL, 'u' ;acelasi rationament ca si mai sus
                                jne count_cons ;daca programul a ajuns cu executia la aceasta instructiune
                                ;si caracterul curent nu este egal cu u atunci el este consoana si sarim la eticheta count_cons
                                je not_cons ;daca caracterul curent este egaul cu u sarim la eticheta not_cons
                
                count_cons:
                    cmp BL, ' ' ;mai avem o ultima comparatie de facut, anume daca caracterul curent este spatuu
                    jne count ;daca nu este spatiu, sarim la eticheta count
                    je not_cons ;daca este spatiu sarim la eticheta not_cons
                    count:
                        mov BL, [numar_cons] ;punem numarul de consoane curente in BL
                        inc BL ;incrementam BL
                        mov [numar_cons], BL ;updatam numarul de consoane
                        loop num_cons ;mergem inapoi la eticheta num_cons pentru a verifica urmatoarele caractere
                not_cons:
                    loop num_cons ;daca caracterul nu este consoana, revenim la eticheta num_cons pentru a verifica celelalte caractere ramase
            jmp bucla ;refacem citirea
            
        clean_up:
           
            ;cand am terminat de prelucrat sirul, afisam numarul de consoane
            
            push DWORD [numar_cons]
            push DWORD format
            call [printf]
            add ESP, 4*2
            
            ;apelam functia fclose pentru a inchide fisierul
            ;fclose(descrptor_fis)
            push DWORD descrptor_fis
            call [fclose]
            add ESP, 4
            
            
        final:
        push    dword 0      
        call    [exit]      
