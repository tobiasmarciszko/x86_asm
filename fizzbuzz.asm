;; this is 32 bit x86 assembly (Mach-O)
;;
;; build and link using:
;; nasm -f macho32 -o fizzbuzz.o fizzbuzz.asm
;; gcc -m32 -o fizzbuzz fizzbuzz.o
;;
;; author: tobias.marciszko@gmail.com

section .text

    global _main
    extern _printf              ; libc externals

_main:
    
    push ebp                    ; stack setup
    mov ebp, esp
    sub esp, 8                  ; allocate some space on the stack for parameters during the loop

    mov ecx, [count]            ; loop [count] times - this will automatically decrement on loop

_loop:

    inc dword [counter]
    mov byte [remainder], 0     ; keeps track of if we did print fizz and/or buzz to check if we need to print the number
                                ; we actually only need just one bit as a flag to check, we can probably improve this!
_checkfizz:
    mov eax, [counter]            
    mov bl, 3                   ; divide by 3 (fizz)
    div bl                      ; divide ax with bl -> result in al, remainder in ah

                                ; |31..16|15-8|7-0|
                                ;         |AH.|AL.|
                                ;         |AX.....|
                                ; |EAX............|
    cmp ah, 0
    je  _printfizz

_checkbuzz:
    mov eax, [counter]
    mov bl, 5                   ; divide by 5 (buzz)
    div bl                      ; divide ax with bl -> result in al, remainder in ah

                                ; |31..16|15-8|7-0|
                                ;         |AH.|AL.|
                                ;         |AX.....|
                                ; |EAX............|
    cmp ah, 0
    je  _printbuzz

_printnumber:

    cmp byte [remainder], 0     ; did we previously print fizz and/or buzz? then skip printing the number
    jne _endloop

    mov esi, ecx                ; printf clobbers eax , ecx (our counter!) and edx. So we store away ecx
    mov eax, [counter]
    mov dword [esp+4], eax       
    mov dword [esp], number     ; format string

    call _printf

    mov ecx, esi                ; restore ecx

_endloop:
    loop _loop                  ; loop de loop - auto decrements ecx

    mov dword [esp], newline
    call _printf

    add esp, 8                  ; clean up stack allocation
    
    pop ebp
    ret                         ; b-bye!

_printfizz:

    inc byte [remainder]        ; flag that we don't need to print the number later

    mov esi, ecx                ; save registers that printf clobbers
    
    mov dword [esp], fizz       
    call _printf

    mov ecx, esi                ; restore registers

    jmp _checkbuzz

_printbuzz:

    inc byte [remainder]

    mov esi, ecx
    
    mov dword [esp], buzz
    call _printf

    mov ecx, esi

    jmp _printnumber

section .data

    fizz dw "Fizz ", 0
    buzz dw "Buzz ", 0
    number dw "%d ", 0
    newline dw "", 0xa, 0xd, 0xa, 0xd
    
    count dw 100
    counter dw 0
    remainder db 0

segment .bss
