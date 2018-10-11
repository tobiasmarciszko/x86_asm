 ;; based on http://peter.michaux.ca/articles/assembly-hello-world-for-os-x
    ;; this is 32 bit nasm assembly
    ;;
    ;; build and link using:
    ;; nasm -f macho32 -o helloworld_1.o helloworld_1.asm
    ;; gcc -m32 -o helloworld_1 helloworld_1.o
    ;;

    section .text

    global mymain   ; make the main function externally visible

mymain:
    
    push dword mylen    ; push message length on the stack
    push dword mymsg    ; push message to write on the stack
    push dword 1        ; push file descriptor value (stdout) on the stack

    mov eax, 4          ; system call for write
    sub esp, 4          ; OS X stack needs padding for system calls, note that stack goes down, not up
    int 0x80            ; interrupt for system calls

    add esp,16          ; clean up stack: (3 args * 4 bytes/arg + 4 bytes extra space = 16 bytes)

                        ; stack should be fine now
    mov eax, 1          ; system call number for exit
    sub esp, 4          ; remember to pad the stack
    int 0x80            ; interrupt for system calls

                        ; no need to clean up, already exited at this point

    section .data

    mymsg db "hello, world", 0xa ; string with a carriage-return
    mylen equ $-mymsg            ; string length in bytes
    
