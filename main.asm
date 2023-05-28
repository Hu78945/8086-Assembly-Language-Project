.model small
.data       
    new_line db 13, 10, "$"
    
    game_draw db "_|_|_", 13, 10
              db "_|_|_", 13, 10
              db "_|_|_", 13, 10, "$" 
              
;The first line, game_pointer db 9 DUP(?), declares the variable game_pointer
;in the data segment of the assembly code. The db directive is used to allocate
;memory for byte-sized data, and DUP(?) specifies that the memory should be duplicated
;nine times with uninitialized values represented by the ? symbol.   
     
    ;it will hold the address of the game_board postions             
    game_pointer db 9 DUP(?)  
    
    win_flag db 0 
    player db "0$" 
    
    game_over_message db "Behzad", 13, 10, "$"    
    game_start_message db "Everyone except Behzad", 13, 10, "$"
    player_message db "PLAYER $"   
    win_message db " WIN!$"   
    type_message db "TYPE A POSITION: $"

.stack
    dw   128  dup(?)         



code segment
start:
    ; set data registers  
    
    mov     ax, @data
    mov     ds, ax

    ; game start   
    call    set_game_pointer    
            
main_loop:

    ;Calls differnet subroutines 
    call    clear_screen   
    
    lea     dx, game_start_message 
    call    print
    
    lea     dx, new_line
    call    print                      
    
    lea     dx, player_message
    call    print
    lea     dx, player
    call    print  
    
    lea     dx, new_line
    call    print    
    
    lea     dx, game_draw
    call    print    
    
    lea     dx, new_line
    call    print    
    
    lea     dx, type_message    
    call    print            
                        
    ; read draw position                   
    call    read_keyboard
                       
    ; calculate draw position                   
    sub     al, 49               
    mov     bh, 0
    mov     bl, al                                  
                                  
    call    update_draw                                    
                                                          
    call    check  
                       
    ; check if game ends                   
    cmp     win_flag, 1  
    je      game_over  
    
    call    change_player 
            
    jmp     main_loop   


change_player:   
    lea     si, player
    
    ;The XOR operation flips the bit value of the current player.
    ;If the current player is "0", the XOR operation with "1"
    ;will result in "1", and if the current player is "1",
    ;the XOR operation with "1" will result in "0".    
    xor     ds:[si], 1 
    
    ret
      
 
update_draw:
    mov     bl, game_pointer[bx]
    mov     bh, 0
    
    lea     si, player
    
    cmp     ds:[si], "0"
    je      draw_x     
                  
    cmp     ds:[si], "1"
    je      draw_o              
                  
    draw_x:
    mov     cl, "x"
    jmp     update

    draw_o:          
    mov     cl, "o"  
    jmp     update    
          
    update:         
    mov     ds:[bx], cl
      
    ret 
       
       
check:
    call    check_line
    ret     
       
       
check_line:
    mov     cx, 0
    
    check_line_loop:
    
    ;These instructions compare the value in the cx register with 0.
    ;If they are equal (the first line), the program jumps to the first_line
    ;label to perform the check for that line.     
    cmp     cx, 0
    je      first_line
    
    ;These instructions compare the value in the cx register with 1.
    ;If they are equal (the second line), the program jumps to the second_line
    ;label to perform the check for that line.
    cmp     cx, 1
    je      second_line
    
    ;These instructions compare the value in the cx register with 2.
    ;If they are equal (the third line), the program jumps to the third_line
    ;label to perform the check for that line.
    cmp     cx, 2
    je      third_line  
    
    ;If none of the above conditions are met, it means that all lines have
    ;been checked, so the program calls the check_column subroutine to proceed
    ;with checking the columns and diagonals.
    call    check_column
    ret    
        
    first_line:
    
    ;These instructions set the si register to the appropriate index in
    ;the game_pointer array. The game_pointer array stores the memory addresses
    ;of each position in the game board.    
    mov     si, 0   
    jmp     do_check_line   

    second_line:    
    mov     si, 3
    jmp     do_check_line
    
    third_line:    
    mov     si, 6
    jmp     do_check_line        

    do_check_line:
    ;This instruction increments the cx register, which keeps track of the
    ;current line being checked.
    inc     cx
    
    ;This instruction clears the bh register, which will be used as
    ;the high byte of the memory address to access the game board positions.
    mov     bh, 0
    
    ;This instruction loads the memory address of the current position in the
    ;game board into the bl register. The game_pointer array holds the memory
    ;addresses of each position
    mov     bl, game_pointer[si]
    
    ;This instruction loads the value stored at the memory address pointed
    ;to by bx (the current game board position) into the al register.
    ;al will contain the symbol ("x", "o", or "_") stored at that position.
    mov     al, ds:[bx]
    
    ;This instruction compares the value in al with the symbol "_" (underscore),
    ;which represents an empty position in the game board.
    cmp     al, "_"
    je      check_line_loop
    
    
    ;This instruction increments the si register to move to the next position
    ;in the line.
    inc     si 
    
    ;This instruction loads the memory address of the next position in the
    ;game board into the bl register.
    mov     bl, game_pointer[si] 
    
    ;This instruction compares the value in al (the current symbol)
    ;with the value at the memory address pointed to by bx
    ;(the next position in the line).   
    cmp     al, ds:[bx]
    
    ; If the symbols are not equal, it means the line is not filled with
    ;the same symbol, so the program jumps back to the check_line_loop label
    ;to continue checking the rest of the line.
    jne     check_line_loop 
      
    inc     si
    mov     bl, game_pointer[si]  
    cmp     al, ds:[bx]
    jne     check_line_loop
                 
    
    ;If the program reaches this point, it means that all positions in the
    ;line have the same symbol, and the line is filled. The following instructions
    ;are executed:                    
    mov     win_flag, 1
    ret         
       
       
       
check_column:
    mov     cx, 0
    
    check_column_loop:     
    cmp     cx, 0
    je      first_column
    
    cmp     cx, 1
    je      second_column
    
    cmp     cx, 2
    je      third_column  
    
    call    check_diagonal
    ret    
        
    first_column:    
    mov     si, 0   
    jmp     do_check_column   

    second_column:    
    mov     si, 1
    jmp     do_check_column
    
    third_column:    
    mov     si, 2
    jmp     do_check_column        

    do_check_column:
    inc     cx
  
    mov     bh, 0
    mov     bl, game_pointer[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      check_column_loop
    
    add     si, 3
    mov     bl, game_pointer[si]    
    cmp     al, ds:[bx]
    jne     check_column_loop 
      
    add     si, 3
    mov     bl, game_pointer[si]  
    cmp     al, ds:[bx]
    jne     check_column_loop
                 
                         
    mov     win_flag, 1
    ret        


check_diagonal:
    mov     cx, 0
    
    check_diagonal_loop:     
    cmp     cx, 0
    je      first_diagonal
    
    cmp     cx, 1
    je      second_diagonal                         
    
    ret    
        
    first_diagonal:    
    mov     si, 0                
    mov     dx, 4 ;fasiulhaq
    jmp     do_check_diagonal   

    second_diagonal:    
    mov     si, 2
    mov     dx, 2
    jmp     do_check_diagonal       

    do_check_diagonal:
    inc     cx
  
    mov     bh, 0
    mov     bl, game_pointer[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      check_diagonal_loop
    
    add     si, dx
    mov     bl, game_pointer[si]    
    cmp     al, ds:[bx]
    jne     check_diagonal_loop 
      
    add     si, dx
    mov     bl, game_pointer[si]  
    cmp     al, ds:[bx]
    jne     check_diagonal_loop
                 
                         
    mov     win_flag, 1
    ret  
           

game_over:        
    call    clear_screen   
    
    lea     dx, game_start_message 
    call    print
    
    lea     dx, new_line
    call    print                          
    
    lea     dx, game_draw
    call    print    
    
    lea     dx, new_line
    call    print

    lea     dx, game_over_message
    call    print  
    
    lea     dx, player_message
    call    print
    
    lea     dx, player
    call    print
    
    lea     dx, win_message
    call    print 

    jmp     fim    
  
     
set_game_pointer:
;After loading the address of game_draw into si,the program likely uses a loop
;to iterate over each character in the array,and then calls the print function to
;display the character stored at the memory location pointed by si.The print function
;likely uses the ah register set to 9 to invoke the DOS print string function.

    lea     si, game_draw
    
;The second line, lea bx, game_pointer, uses the lea (Load Effective Address) instruction
;to load the memory address of game_pointer into the bx (base index) register.
;By doing so, the program can access and manipulate the elements of the game_pointer array
;by using the bx register as a pointer to its memory location.
;This instruction allows the program to perform operations on the game_pointer array,
;such as reading or writing values to specific positions, iterating over the array, or using
;it as a reference to access other related data in memory. 


    lea     bx, game_pointer 
    
    
    ;Represent the number of psotion on the board                  
    mov     cx, 9   
    
    loop_1:
    
    ;This condition is checking if the loop has reached the positions at 
    ;indices 6 and 7,which correspond to the second row of the game board.
    cmp     cx, 6
    je      add_1
    
                    
    ;This condition is checking if the loop has reached the 
    ;positions at indices 3 and 4, which correspond to the
    ;first row of the game board.
    cmp     cx, 3
    je      add_1
    
    
    ;If none of the previous conditions are met, it jumps to the add_2 label.
    ;This condition covers the positions at indices 0, 1, 2, 5, and 8, which
    ;correspond to the third row and both diagonals of the game board.
    jmp     add_2 
    
    
    ;this block of instructions is executed when the loop has reached
    ;the second or first row. It increments the si register by 1 to skip
    ;the newline characters in the game_draw string and jumps to the add_2 label.
    add_1:
    add     si, 1
    jmp     add_2
         
    ;This block of instructions is executed for all positions on the game board.
    ;It stores the current value of the si register, which holds the address of
    ;the respective position in the game_draw string, into the memory location
    ;pointed to by bx (i.e., the game_pointer array). It then increments the si
    ;register by 2 to skip the position and the newline character in the game_draw string.  
    add_2:                                
    mov     ds:[bx], si 
    add     si, 2
    
    ;This increments the bx register to point to the next memory location
    ;in the game_pointer array.                    
    inc     bx 
    
    ;This decrements the cx register and jumps back to the loop_1 label as
    ;long as cx is not zero. This iterates the loop until all positions on
    ;the game board have been processed.              
    loop    loop_1 
    
    ;This is a subroutine return instruction that returns control to the caller.
    ret  
         
       
print:      ; print dx content  
    mov     ah, 9
    int     21h   
    
    ret 
    

clear_screen:       ; get and set video mode

    ;This instruction moves the value 0Fh (15 in decimal) into the ah register.
    ;The value 0Fh represents the video function for retrieving the current video
    ;mode and the current color palette.
    mov     ah, 0fh
    
    ;This interrupts the program and transfers control to the BIOS video services.
    ;The specific video function to be executed is determined by the value in
    ;the ah register. In this case, the interrupt is triggered to retrieve the
    ;current video mode and color palette.
    int     10h   
    
    ;This instruction moves the value 0 into the ah register.
    ;The value 0 represents the video function for setting the video mode.
    mov     ah, 0 
    
    ;This interrupts the program again to invoke the BIOS video services.
    ;The interrupt is triggered to set the video mode based on the value
    ;in the ah register, which is now 0. This effectively clears the screen
    ;by resetting the display to the default mode.
    int     10h
    
    ret
       
    
read_keyboard:  ; read keybord and return content in ah
    mov     ah, 1       
    int     21h  
    
    ret      
      
 
;to end the program     
fim:
    mov ah,4ch
    int 21h         
      
code ends

end start