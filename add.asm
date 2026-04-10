%define sys_write 1
%define stdout 1
%define sys_read 0
%define stdin 0
%define sys_exit 60
%define n_line 10


section .data

        %define buffer_len 8
        buffer db buffer_len

        o_buffer db buffer_len

        prompt_one db `Enter first number: `, 0
        prompt_one_len equ $-prompt_one

        prompt_two db `Enter second number: `, 0
        prompt_two_len equ $-prompt_two

        answer db `Your number is: `, 0
        answer_len equ $-answer

        align 8
        num_1 dq 0
        num_2 dq 0

        debug_text db `DBUG`, n_line
        dtlen equ $-debug_text

        debug_convert db `DBUG CONV`, n_line
        dclen equ $-debug_convert

        debug_pop db `DATAPOP`, n_line
        dplen equ $-debug_pop

        debug_exp db `EXP LOOPED`, n_line
        delen equ $-debug_exp

section .text
global _start
_start:

        mov rax, sys_write
        mov rdi, stdout
        mov rsi, prompt_one
        mov rdx, prompt_one_len
        syscall

        mov rax, sys_read
        mov rdi, stdin
        mov rsi, buffer
        mov rdx, buffer_len
        syscall

        mov r8, buffer ; r8, r9 used for storing source and destination
        xor r9, r9
        call convert_str

        mov [num_1], r9

        mov rax, sys_write
        mov rdi, stdout
        mov rsi, prompt_two
        mov rdx, prompt_two_len
        syscall

        mov rax, sys_read
        mov rdi, stdin
        mov rsi, buffer
        mov rdx, buffer_len
        syscall

        mov r8, buffer
        xor r9, r9
        call convert_str

        mov [num_2], r9

        mov r11, [num_1]

        add r11, [num_2]

        ;mov r9, r11
        
        mov r8, r11
        xor r9, r9
        call convert_int

        mov [o_buffer], r9

        mov rax, sys_write
        mov rdi, stdout
        mov rsi, answer
        mov rdx, answer_len
        syscall
        
        mov rax, sys_write
        mov rdi, stdout
        mov rsi, o_buffer
        mov rdx, buffer_len
        syscall

        mov rax, sys_write
        mov rdi, stdout
        mov rsi, n_line
        mov rdx, 1
        syscall

        jmp exit

convert_str: ; result in r9
        movzx rdi, byte [r8]
        cmp rdi, n_line
        je done_convert
        sub rdi, `0`
        imul r9, r9, 10
        add r9, rdi
        inc r8
        jmp convert_str

convert_int: ; result in r9
        mov rax, r8
        cmp rax, 0
        je done_convert
        mov rdx, 0 ; esnures result of division location is empty
        mov rdi, 10
        div rdi ; rax = rdi / 10, rdx = rdi % 10
        mov r8, rax ; moves next number to be processed to r8
        add rdx, `0` ; turns single int to 256 bit char

        imul r9, r9, 256
        add r9, rdx

        jmp convert_int


old_convert_int: ; USELESS
        mov cx, 0
        call convert_int_loop
        ret

convert_int_loop: ; USELESS AND WRONG
        mov rax, r8
        cmp rax, 0
        je done_convert
        mov rdx, 0 ;ensures result of division location is empty
        mov rdi, 10
        div rdi ; rax = rdi / 10, rdx = rdi % 10
        add rdx, `0` ; turns single int to char

        mov rdi, 256
        movzx rsi, cx
        call exponents
        imul rdx, rdi
        add r9, rdx

        mov r8, rax

        mov r10, rdx
        call safe_print

        inc cx
        jmp convert_int_loop


safe_print: ; useful
        push rax
        push rcx
        push rdx
        push rsi
        push rdi
        push r8
        push r9
        push r11

        mov [o_buffer], r10
        mov rax, 1
        mov rdi, 1
        mov rsi, o_buffer
        mov rdx, buffer_len
        syscall
        
        pop r11
        pop r9
        pop r8
        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop rax
        ret
         
exponents: ; USELESS but maybe does work properly 
        ; Uses rdi for passing in base
        ; Uses rsi for exponent and counter(kinda)
        ; Uses r8 result, gets sent to rdi for return
        ; Uses r9 for storing base
        ; Uses division registers
        ; Pops on exit except rdi and rsi

        
        push r8
        push r9
        push rax
        
        ; division
        push rdx

        mov r8, 1; Needed for this type of exponent calculation
        mov r9, rdi
        
        jmp exponent_loop

        exponent_exit:
        mov r10, 10
        call safe_print

        mov rdi, r8

        ; division
        pop rdx

        pop rax
        pop r9
        pop r8

        ret
        
        exponent_loop:
        
        cmp rsi, 0
        je exponent_exit

        mov r10, rsi
        add r10, `0`
        call safe_print
        
        mov rax, rsi
        mov rdi, 2
        mov rdx, 0
        div rdi
        cmp rdx, 0
        
        je even
        ; if odd
        imul r8, r9
        dec rsi
        jmp exponent_loop
        
        even:
        ; if even
        imul r8, r8
        shr rsi, 1
        jmp exponent_loop


debug_print:
        mov rax, sys_write
        mov rdi, stdout
        syscall
        ret

done_convert:

        ret



exit:
        mov rax, sys_exit
        mov rdi, 0
        syscall
