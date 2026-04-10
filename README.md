**Assembly addition**

Written in Intel syntax, it was originally just to practice for reverse engineering.
I finished a full version, with subtract, multiply and divide added but it was on
my machine back when I use to run kali(☠️) and is now lost(I think). Either way this has
the groundwork for what was later the calculator


**My favorite bites of code**

My beautiful safe print, clearly labelled useful
`
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
`


What I like about these two subroutines is, in the final calculator I was manually doing multiplication
and division because i thought it would be cooler. In that version I had the same method of converting
ascii values to int and back.

Then for some reason I still used `imul`, it would have been way better to use my own but whatever.

`
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

`
