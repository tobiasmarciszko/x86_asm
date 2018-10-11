    ;; based on http://peter.michaux.ca/articles/assembly-hello-world-for-os-x
    ;; this is 32 bit nasm assembly
    ;;
    ;; build and link using:
    ;; nasm -f macho helloworld_2.asm
    ;; ld -o helloworld_2 -e main helloworld_2.o
    ;;
    ;; In this example I make procedural calls to avoid padding the stack
    ;; before each system call (int 0x80)

    section .text

    global main

write:
    mov eax, 4
    int 0x80
    ret

exit:
    mov eax, 1
    int 0x80
    ret

main:
    
    push dword mylen    ; push message length on the stack
    push dword mymsg    ; push message to write on the stack
    push dword 1        ; push file descriptor value (stdout) on the stack

    call write

    add esp,12          ; we still need to clean up the stack, 3 args * 4 bytes = 12 bytes to clean up

    call exit
                        ; no need to clean up, already exited at this point

    section .data

    mymsg db "hello, world - again! :)", 0xa ; string with a carriage-return
    mylen equ $-mymsg                        ; string length in bytes
    
