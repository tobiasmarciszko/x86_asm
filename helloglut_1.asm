    ;;  Inspired by the example from Stino / former ByTeGeiZ
    ;;   
    ;;  compile with:
    ;;  nasm -g -f macho32 helloglut_1.asm
    ;;  gcc -framework GLUT -framework OpenGL -m32 -o helloglut_1 helloglut_1.o
    ;;
    ;; Initialization example from http://www.lighthouse3d.com/tutorials/glut-tutorial/initialization/
    ;;

    ;; DisplayMode
    %define GLUT_RGB                        0
    %define GLUT_RGBA                       GLUT_RGB
    %define GLUT_INDEX                      1
    %define GLUT_SINGLE                     0
    %define GLUT_DOUBLE                     2
    %define GLUT_ACCUM                      4
    %define GLUT_ALPHA                      8
    %define GLUT_DEPTH                      16
    %define GLUT_STENCIL                    32

    ;; BeginMode
    %define GL_POINTS                         0x0000
    %define GL_LINES                          0x0001
    %define GL_LINE_LOOP                      0x0002
    %define GL_LINE_STRIP                     0x0003
    %define GL_TRIANGLES                      0x0004
    %define GL_TRIANGLE_STRIP                 0x0005
    %define GL_TRIANGLE_FAN                   0x0006

    %define GL_POLYGON          9

    %define GL_DEPTH_BUFFER_BIT               0x00000100
    %define GL_STENCIL_BUFFER_BIT             0x00000400
    %define GL_COLOR_BUFFER_BIT               0x00004000

    ;;  GLUT stuff
    extern _glutCreateWindow, _glutInit, _glutInitDisplayMode, _glutDisplayFunc, _glutMainLoop, _glutInitWindowPosition, _glutInitWindowSize, _glutSwapBuffers, _glutIdleFunc
    
    ;;  OpenGL stuff
    extern _glClearColor, _glClear, _glBegin, _glEnd, _glFlush, _glVertex3f, _glColor3f, _glLoadIdentity, _gluLookAt, _glRotatef

    ;;  static data
    segment .data

window_name:    db "Hello GLUT!", 10, 0
fl_one:         dd 1.0
fl_two:         dd 2.0
fl_neg_one:     dd -1.0
fl_neg_two:     dd -2.0

fl_zero:        dd 0.0
fl_half:        dd 0.5
fl_neg_half:    dd -0.5

fl_angle         dd 0.0
fl_count_inc     dd 0.1

double_zero      dq 0.0
double_one       dq 1.0
double_ten       dq 10.0

    ;;  code
    segment .text

    global _main

    ;;  the main function that init OpenGL and install the gl draw function (_display_func)
_main:

    ;; TODO: Allocate stack space upfront and adress the stack directly
    ;; to avoid add/sub for alignment after and before every call
    
                                ; alignment = 0

    ;; void glutInit(int *argc, char **argv);
    ;;

    lea  ecx, [esp+4]           ; load adress of argc in stack to ecx
    lea  edx, [esp+8]           ; load adress of argv in stack to edx

    push ebp                    ; setup the frame   ;alignment => 4
    mov  ebp, esp

    push edx                    ; alignment => 8
    push ecx                    ; alignment => 12

    call _glutInit              ; alignment => 16 -> alignment <= 12 (after backjump with "ret")
    add  esp, 8                 ; alignment <= 4 (caller has to clean call paras (8 byte))

    ;; void glutInitDisplayMode(unsigned int mode)
    ;;
    sub esp, 4                  ; alignment => 8 (correction need to get to 16 at next call !)
    mov eax, GLUT_RGBA
    or  eax, GLUT_DOUBLE
    or  eax, GLUT_DEPTH
    push eax                    ; alignment => 12
    call _glutInitDisplayMode   ; alignment => 16 -> alignment <= 12
    add  esp, 4                 ; alignment <= 8 (caller has to clean call paras (4 byte))
    add  esp, 4                 ; alignment <= 4 (clean last the allignment correction)

    ;; void glutInitWindowPosition(int x, int y);
    ;;
    ;; -1 for values means that window manager will place the window
    push dword -1                ; alignment => 8 
    push dword -1                ; alignment => 12
    call _glutInitWindowPosition ; alignment => 16 -> alignment <= 12
    add  esp, 8                  ; alignment <= 4 (caller has to clean call paras (8 byte))

    ;; void glutInitWindowSize(int width, int height);
    ;;
    push dword 320              ; alignment => 8
    push dword 300              ; alignment => 12
    call _glutInitWindowSize    ; alignment => 16 -> alignment <= 12
    add  esp, 8                 ; alignment <= 4 (caller has to clean call paras (8 byte))

    ;; int glutCreateWindow(char *title);
    ;;
    sub esp, 4                  ; alignment => 8 (correction need to get to 16 at next call !)
    mov  eax, dword window_name
    push eax                    ; alignment => 12
    call _glutCreateWindow      ; alignment => 16 -> alignment <= 12
    add  esp, 4                 ; alignment <= 8 (caller has to clean call paras (4 byte))
    add  esp, 4                 ; alignment <= 4 (clean last the allignment correction)

    ;; void glutDisplayFunc(void (*funcName)(void));
    ;;
    sub esp, 4                  ; alignment => 8 (correction need to get to 16 at next call !)
    push dword _renderScene     ; alignment => 12
    call _glutDisplayFunc       ; alignment => 16 -> alignment <= 12
    add  esp, 4                 ; alignment <= 8 (caller has to clean call paras (4 byte))
    add  esp, 4                 ; alignment <= 4 (clean last the allignment correction)

    ;; void glutIdleFunc(void (*funcName)(void));
    ;;
    sub esp, 4                  ; alignment => 8 (correction need to get to 16 at next call !)
    push dword _renderScene     ; alignment => 12
    call _glutIdleFunc       ; alignment => 16 -> alignment <= 12
    add  esp, 4                 ; alignment <= 8 (caller has to clean call paras (4 byte))
    add  esp, 4                 ; alignment <= 4 (clean last the allignment correction)

    ;; void glutMainLoop(void)
    ;;
    sub esp, 8                  ; alignment => 12 (correction need to get to 16 at next call !)
    call _glutMainLoop          ; alignment => 16 -> alignment <= 12
    add  esp, 8                 ; alignment <= 4 (caller has to clean call paras (8 byte))

_pass_exit:
    pop  ebp                    ; alignment <= 0
    ret

_renderScene:

    sub     esp, 76 ; 9*8 = 72 + 4 bytes

    mov     eax, GL_COLOR_BUFFER_BIT
    or      eax, GL_DEPTH_BUFFER_BIT
    mov     [esp], dword eax
    call    _glClear
    call    _glLoadIdentity

    movsd   xmm0, [double_zero]
    movsd   xmm1, [double_one]

    movsd   [esp], xmm0
    movsd   [esp+0x8], xmm0
    movsd   [esp+0x10], xmm1
    movsd   [esp+0x18], xmm0
    movsd   [esp+0x20], xmm0
    movsd   [esp+0x28], xmm0
    movsd   [esp+0x30], xmm0
    movsd   [esp+0x38], xmm1
    movsd   [esp+0x40], xmm0
    call    _gluLookAt

    mov     eax, [fl_angle]
    mov     [esp], eax
    mov     eax, [fl_one]
    mov     [esp+0x4], eax
    mov     eax, [fl_one]
    mov     [esp+0x8], eax
    mov     eax, [fl_one]
    mov     [esp+0xc], eax
    call    _glRotatef

    mov     [esp], dword GL_TRIANGLES
    call    _glBegin

    mov     eax, [fl_neg_one]
    mov     [esp], eax
    mov     [esp+0x4], eax
    mov     eax, [fl_zero]
    mov     [esp+0x8], eax
    call    _glVertex3f

    mov     eax, [fl_one] 
    mov     [esp], eax
    mov     eax, [fl_zero] 
    mov     [esp+0x4], eax
    mov     [esp+0x8], eax
    call    _glVertex3f

    mov     eax, [fl_zero] 
    mov     [esp], eax
    mov     eax, [fl_one] 
    mov     [esp+0x4], eax
    mov     eax, [fl_zero] 
    mov     [esp+0x8], eax
    call    _glVertex3f

    call    _glEnd

    ;; increase angle counter
    movss   xmm2, [fl_angle]
    addss   xmm2, [fl_count_inc]
    movss   [fl_angle], xmm2

    call    _glutSwapBuffers

    add esp, 76 ; shrink stack
    ret

    
