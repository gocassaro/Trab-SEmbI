segment data public
    global desenha_cena, desenha_fundo, desenha_pause, apaga_pause, desenha_menu_quit, apaga_menu_quit
    global index_p1, index_p2, cor_p1, cor_p2, color_map
    
    extern p1_x, p1_y, p1_hp, p1_x_antigo, p1_y_antigo, p1_estado
    extern p2_x, p2_y, p2_hp, p2_x_antigo, p2_y_antigo, p2_estado
    
    extern sprite_p1, sprite_p1_soco, sprite_p1_chute, sprite_p1_agachado
    extern sprite_p2, sprite_p2_soco, sprite_p2_chute, sprite_p2_agachado

    msg_sair db 'QUIT? Y/N', 0
    
    ; Variaveis de apoio para o loop de sprites
    cor_temp    db 0
    base_x_temp dw 0
    base_y_temp dw 0

    preto           equ     0   
    azul            equ     1   
    verde           equ     2   
    cyan            equ     3   
    vermelho        equ     4   
    magenta         equ     5   
    marrom          equ     6   
    branco          equ     7   
    cinza           equ     8   
    azul_claro      equ     9   
    verde_claro     equ     10  
    cyan_claro      equ     11  
    rosa            equ     12  
    magenta_claro   equ     13  
    amarelo         equ     14  
    branco_intenso  equ     15  

    color_map       db      preto, azul, verde, cyan, vermelho, magenta, marrom, branco, cinza, azul_claro, verde_claro, cyan_claro, rosa, magenta_claro, amarelo, branco_intenso
    index_p1        db      1   
    index_p2        db      4   
    cor_p1          db      azul
    cor_p2          db      vermelho

segment code

; Desenha uma única vez as partes que não se movem
desenha_fundo:
    MOV AX, 0600h
    MOV BH, 00h
    MOV CX, 0000h
    MOV DX, 1D4Fh
    INT 10h

    MOV CX, 20
    MOV DX, 20
    MOV SI, 200
    MOV DI, 15
    MOV AL, 8
    CALL desenha_retangulo

    MOV CX, 420
    MOV DX, 20
    MOV SI, 200
    MOV DI, 15
    MOV AL, 8
    CALL desenha_retangulo

    ; Chão
    MOV CX, 0
    MOV DX, 434
    MOV SI, 640
    MOV DI, 46
    MOV AL, 10          ; Cor: 10 (verde_claro)
    CALL desenha_retangulo

    RET

desenha_cena:
    ; --- 1. APAGA OS RASTROS ---
    MOV AX, [p1_x]
    CMP AX, [p1_x_antigo]
    JNE apaga_p1
    MOV AX, [p1_y]
    CMP AX, [p1_y_antigo]
    JE pula_apaga_p1

apaga_p1:
    ; Apaga o P1 redesenhando a exata arte dele na posição antiga, mas na cor PRETA
    MOV BX, sprite_p1
    MOV CX, [p1_x_antigo]
    MOV DX, [p1_y_antigo]
    MOV AL, 0              ; Cor 0 = Preto
    CALL desenha_sprite

pula_apaga_p1:
    MOV AX, [p2_x]
    CMP AX, [p2_x_antigo]
    JNE apaga_p2
    MOV AX, [p2_y]
    CMP AX, [p2_y_antigo]
    JE pula_apaga_p2
    
apaga_p2:
    ; Apaga o P2
    MOV BX, sprite_p2
    MOV CX, [p2_x_antigo]
    MOV DX, [p2_y_antigo]
    MOV AL, 0              ; Cor 0 = Preto
    CALL desenha_sprite

pula_apaga_p2:    
    ; --- 2. DESENHA OS LUTADORES NAS POSIÇÕES NOVAS ---
    
    ; Jogador 1 (com a cor real)
    MOV CX, [p1_x]
    MOV DX, [p1_y]
    MOV AL, [cor_p1]

    CMP byte [p1_estado], 2     ; 2 = Agachado
    JE set_p1_agachado
    CMP byte [p1_estado], 4     ; 4 = Soco
    JE set_p1_soco
    CMP byte [p1_estado], 5     ; 5 = Chute
    JE set_p1_chute
    
    ; Padrão (Parado/Andando/Pulando)
    MOV BX, sprite_p1
    JMP draw_p1
    
set_p1_agachado:
    MOV BX, sprite_p1_agachado
    JMP draw_p1
set_p1_soco:
    MOV BX, sprite_p1_soco
    JMP draw_p1
set_p1_chute:
    MOV BX, sprite_p1_chute
    
draw_p1:
    CALL desenha_sprite

    ; Jogador 2 (com a cor real)
    MOV CX, [p2_x]
    MOV DX, [p2_y]
    MOV AL, [cor_p2]

    CMP byte [p2_estado], 2
    JE set_p2_agachado
    CMP byte [p2_estado], 4
    JE set_p2_soco
    CMP byte [p2_estado], 5
    JE set_p2_chute
    
    ; Padrão
    MOV BX, sprite_p2
    JMP draw_p2
    
set_p2_agachado:
    MOV BX, sprite_p2_agachado
    JMP draw_p2
set_p2_soco:
    MOV BX, sprite_p2_soco
    JMP draw_p2
set_p2_chute:
    MOV BX, sprite_p2_chute

draw_p2:
    CALL desenha_sprite

    ; --- 3. ATUALIZA AS BARRAS DE VIDA ---
    MOV CX, 20
    MOV DX, 20
    MOV SI, 200
    MOV DI, 15
    MOV AL, 8           
    CALL desenha_retangulo
    
    CMP byte [p1_hp], 0
    JE atualiza_hp2     
    MOV AL, [p1_hp]
    XOR AH, AH          
    MOV BX, 20
    MUL BX              
    MOV SI, AX          
    MOV CX, 20          
    MOV DX, 20          
    MOV DI, 15          
    MOV AL, 14          
    CALL desenha_retangulo

atualiza_hp2:
    MOV CX, 420
    MOV DX, 20
    MOV SI, 200
    MOV DI, 15
    MOV AL, 8           
    CALL desenha_retangulo

    CMP byte [p2_hp], 0
    JE fim_desenho      
    MOV AL, [p2_hp]
    XOR AH, AH
    MOV BX, 20
    MUL BX              
    MOV SI, AX          
    MOV CX, 620         
    SUB CX, AX          
    MOV DX, 20          
    MOV DI, 15          
    MOV AL, 14          
    CALL desenha_retangulo

fim_desenho:
    RET

; =========================================================
; NOVO MOTOR DE SPRITES (Leitura de Vetores)
; Entrada: BX=Arte, CX=X_Base, DX=Y_Base, AL=Cor do Jogador (0=Apagar)
; =========================================================
desenha_sprite:
    MOV byte [cor_temp], AL  
    MOV word [base_x_temp], CX
    MOV word [base_y_temp], DX
    MOV CX, 13               ; O sprite é composto por 13 retângulos

loop_sprite:
    PUSH CX                  ; Protege o contador do loop

    ; 1. Calcula o X Final
    MOV AX, [BX]
    ADD AX, [base_x_temp]
    MOV CX, AX               

    ; 2. Calcula o Y Final (Inverte o cartesiano pro VGA)
    MOV AX, 479
    SUB AX, [base_y_temp]
    SUB AX, [BX+2]
    MOV DX, AX               

    ; 3. Lê Largura e Altura
    MOV SI, [BX+4]           
    MOV DI, [BX+6]           

    ; 4. Define a Cor
    CMP byte [cor_temp], 0   ; Verifica se a intenção é APAGAR a tela (cor preta)
    JE forcar_preto

    MOV AL, [BX+8]           ; Lê a cor padrão do bloco
    CMP AL, 99               ; É parte da roupa colorida?
    JNE aplica_cor
    MOV AL, [cor_temp]       ; Se sim, usa a cor do jogador
    JMP aplica_cor

forcar_preto:
    MOV AL, 0                ; Força tudo a ficar preto

aplica_cor:
    ; 5. Chama o desenho nativo (rápido)
    PUSH BX
    CALL desenha_retangulo
    POP BX

    ADD BX, 10                ; Pula para o próximo bloco de dados (5 words)
    POP CX                   
    LOOP loop_sprite
    RET

; =========================================================
; FUNÇÃO DE RETÂNGULO OTIMIZADA (Original)
; =========================================================
desenha_retangulo:
    CMP SI, 0
    JE fim_retangulo
    CMP DI, 0
    JE fim_retangulo

    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH BX
    
    MOV BX, DI          
linha:
    PUSH CX             
    PUSH BX             
    MOV BX, SI          
coluna:
    MOV AH, 0Ch         
    PUSH BX             
    MOV BH, 0           
    INT 10h             
    POP BX
    
    INC CX              
    DEC BX
    JNZ coluna          
    
    POP BX              
    POP CX              
    INC DX              
    DEC BX
    JNZ linha           
    
    POP BX
    POP DI
    POP SI
    POP DX
    POP CX
fim_retangulo:
    RET

; (Mantenha as funções de Menu e Pause aqui embaixo exatamente como estavam)
desenha_pause:
    MOV CX, 305         
    MOV DX, 220         
    MOV SI, 10          
    MOV DI, 40          
    MOV AL, 15          
    CALL desenha_retangulo
    MOV CX, 325         
    MOV DX, 220
    MOV SI, 10
    MOV DI, 40
    MOV AL, 15          
    CALL desenha_retangulo
    RET

apaga_pause:
    MOV CX, 305
    MOV DX, 220
    MOV SI, 10
    MOV DI, 40
    MOV AL, 0           
    CALL desenha_retangulo
    MOV CX, 325
    MOV DX, 220
    MOV SI, 10
    MOV DI, 40
    MOV AL, 0
    CALL desenha_retangulo
    RET

desenha_menu_quit:
    MOV CX, 220         
    MOV DX, 180         
    MOV SI, 200         
    MOV DI, 60          
    MOV AL, 15          
    CALL desenha_retangulo
    MOV CX, 225
    MOV DX, 185
    MOV SI, 190
    MOV DI, 50
    MOV AL, 0           
    CALL desenha_retangulo

    MOV AH, 02h
    MOV BH, 0           
    MOV DH, 13          
    MOV DL, 36          
    INT 10h

    MOV BX, msg_sair
print_loop:
    MOV AL, [BX]        
    CMP AL, 0           
    JE fim_menu_saida   
    
    MOV AH, 0Eh         
    PUSH BX             
    MOV BH, 0
    MOV BL, 14          
    INT 10h
    POP BX              
    
    INC BX              
    JMP print_loop
fim_menu_saida:
    RET

apaga_menu_quit:
    MOV CX, 220
    MOV DX, 180
    MOV SI, 200
    MOV DI, 60
    MOV AL, 0
    CALL desenha_retangulo
    RET