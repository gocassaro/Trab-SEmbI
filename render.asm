segment data public
    global desenha_cena, desenha_fundo, desenha_pause, apaga_pause, desenha_menu_quit, apaga_menu_quit, desenha_retangulo
    global index_p1, index_p2, cor_p1, cor_p2, color_map
    
    extern p1_x, p1_y, p1_hp, p1_x_antigo, p1_y_antigo, p1_estado, p1_estado_antigo
    extern p2_x, p2_y, p2_hp, p2_x_antigo, p2_y_antigo, p2_estado, p2_estado_antigo
    
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
    ;Limpa a tela/janela de texto usando a BIOS (Função 06h da INT 10h)
    MOV AX, 0600h       ;AH = 06h (Rolar/limpar janela para cima), AL = 00h (limpa toda a janela)
    MOV BH, 00h         ;Atributo de preenchimento (cor preta/sem atributos especiais)
    MOV CX, 0000h       ;CH = Linha inicial (0), CL = Coluna inicial (0)
    MOV DX, 1D4Fh       ;DH = Linha final (29 / 1Dh), DL = Coluna final (79 / 4Fh)
    INT 10h             ;Interrupção de vídeo do BIOS

    ;Desenha o fundo cinza da barra de vida do Jogador 1
    MOV CX, 20          ; Posição X inicial
    MOV DX, 20          ; Posição Y inicial
    MOV SI, 200         ; Largura do retângulo
    MOV DI, 15          ; Altura do retângulo
    MOV AL, 8           ; Cor 8 (Cinza - representa o espaço vazio da vida)
    CALL desenha_retangulo

    ;Desenha o fundo cinza da barra de vida do Jogador 2
    MOV CX, 420         
    MOV DX, 20          
    MOV SI, 200         
    MOV DI, 15          
    MOV AL, 8
    CALL desenha_retangulo

    ;Desenha o chão da arena na parte inferior da tela
    MOV CX, 0           
    MOV DX, 434         
    MOV SI, 640         
    MOV DI, 46          
    MOV AL, 10          
    CALL desenha_retangulo

    RET

desenha_cena:
    ;APAGA OS RASTROS ANTES DE DESENHAR A CENA ATUAL
    ;Depois prossegue para redesenhar os personagens apenas se houve uma mudança de posição ou de estado

    MOV AX, [p1_x]
    CMP AX, [p1_x_antigo]   ;Compara se a posição é a mesma que a antiga
    JNE apaga_p1            ;Pula para apaga_p1 se a posição recente for diferente da antiga

    MOV AX, [p1_y]          ;Faz o mesmo mas agora com a coordenada y
    CMP AX, [p1_y_antigo]
    JNE apaga_p1

    MOV AL, [p1_estado]
    CMP AL, [p1_estado_antigo] ;Compara o estado antigo com o estado atual 
    JE pula_apaga_p1         ;Caso o personagem mudou de estado mas permaneceu na mesma posição (agachou, deu soco, deu chute) continua para apaga_p1, caso contrário vai para pula_apaga_p1  

apaga_p1:
    ; Apaga o P1 redesenhando a exata arte antiga dele na posição antiga, mas na cor PRETA
    ; Verifica qual o estado anterior do personagem e faz um JUMP para cada função respectiva
    MOV AL, [p1_estado_antigo]
    CMP AL, 2
    JE apaga_p1_agachado
    CMP AL, 4
    JE apaga_p1_soco
    CMP AL, 5
    JE apaga_p1_chute
    
    MOV BX, sprite_p1
    JMP faz_apaga_p1

apaga_p1_agachado:
    MOV BX, sprite_p1_agachado ;Salva o sprite correspondente em BX
    JMP faz_apaga_p1
apaga_p1_soco:
    MOV BX, sprite_p1_soco ;Salva o sprite correspondente em BX
    JMP faz_apaga_p1
apaga_p1_chute:
    MOV BX, sprite_p1_chute ;Salva o sprite correspondente em BX

faz_apaga_p1:
    ;Passa as posições anteriores para CX e DX e chama desenha_sprite para desenhar o sprite (na cor preta do fundo) correspondente ao estado anterior 
    MOV CX, [p1_x_antigo]
    MOV DX, [p1_y_antigo]
    MOV AL, 0              ; Cor 0 = Preto (Apaga)
    CALL desenha_sprite

pula_apaga_p1:
    ; Verifica P2: Mudou X, Y ou Estado?
    ; Aqui faz a mesma coisa que o inicio de desenha_cena, mas agora para o player 2
    MOV AX, [p2_x]
    CMP AX, [p2_x_antigo]
    JNE apaga_p2

    MOV AX, [p2_y]
    CMP AX, [p2_y_antigo]
    JNE apaga_p2

    MOV AL, [p2_estado]
    CMP AL, [p2_estado_antigo]
    JE pula_apaga_p2
    
apaga_p2:
    ; Seleciona o sprite correspondente ao ESTADO ANTIGO de P2
    ; Faz a mesma coisa que apaga_p1 só que agora para P2
    MOV AL, [p2_estado_antigo]
    CMP AL, 2
    JE apaga_p2_agachado
    CMP AL, 4
    JE apaga_p2_soco
    CMP AL, 5
    JE apaga_p2_chute
    
    MOV BX, sprite_p2
    JMP faz_apaga_p2

apaga_p2_agachado:
    MOV BX, sprite_p2_agachado
    JMP faz_apaga_p2
apaga_p2_soco:
    MOV BX, sprite_p2_soco
    JMP faz_apaga_p2
apaga_p2_chute:
    MOV BX, sprite_p2_chute

faz_apaga_p2:
    MOV CX, [p2_x_antigo]
    MOV DX, [p2_y_antigo]
    MOV AL, 0              ; Cor 0 = Preto (Apaga)
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

;-------------------------------------------
; MOTOR DE SPRITES (Leitura de Vetores)
; Entrada: BX=Arte, CX=X_Base, DX=Y_Base, AL=Cor do Jogador (0=Apagar)
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

;------------------------------------
; FUNÇÃO DE RETÂNGULO OTIMIZADA
; Parametros:
;   CX = Coordenada X inicial (coluna)
;   DX = Coordenada Y inicial (linha)
;   SI = Largura do retângulo
;   DI = Altura do retângulo
;   AL = Cor do pixel
desenha_retangulo:
    ; Se a largura e a altura for 0, não há o que desenhar
    CMP SI, 0
    JE fim_retangulo
    CMP DI, 0
    JE fim_retangulo

    ; Salva os registradores modificados na pilha para preservar o estado anterior
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH BX
    
    MOV BX, DI ;BX armazena o contador de linhas (altura - DI)          
linha:
    PUSH CX  ;Salva o X inicial da linha atual           
    PUSH BX  ;Salva o contador de linhas atual         
    MOV BX, SI  ;BX armazena o contador de colunas (largura - SI)          
coluna:
    MOV AH, 0Ch ;Função 0Ch do BIOS: Escrever pixel gráfico        
    PUSH BX     ;Salva o contador de colunas        
    MOV BH, 0   ;Página de vídeo 0        
    INT 10h     ;Interrupção de vídeo (pinta o pixel em [CX, DX] com a cor AL)        
    POP BX      
    
    INC CX      ;Avança para o próximo pixel na horizontal (coluna seguinte)        
    DEC BX      ;Decrementa o contador de largura
    JNZ coluna  ;Repete até preencher toda a largura da linha        
    
    POP BX      ;Restaura o contador de linhas        
    POP CX      ;Restaura o X inicial da linha        
    INC DX      ;Desce para a próxima linha na vertical (Y + 1)        
    DEC BX      ;Decrementa o contador de altura
    JNZ linha   ;Repete até processar todas as linhas do retângulo        
    
    ;Restaura todos os registradores salvos
    POP BX
    POP DI
    POP SI
    POP DX
    POP CX
fim_retangulo:
    RET


;DESENHA_PAUSE / APAGA_PAUSE
;Desenham ou limpam o símbolo de pause (duas barras verticais) no centro da tela.
desenha_pause:

    ; Desenha a primeira barra vertical do pause
    MOV CX, 305         ; Posição X
    MOV DX, 220         ; Posição Y
    MOV SI, 10          ; Largura
    MOV DI, 40          ; Altura
    MOV AL, 15          ; Cor 15 (Branco intenso)
    CALL desenha_retangulo
    
    ; Desenha a segunda barra vertical do pause ao lado da primeira
    MOV CX, 325         
    MOV DX, 220
    MOV SI, 10
    MOV DI, 40
    MOV AL, 15          
    CALL desenha_retangulo
    RET

apaga_pause:

    ; Apaga a primeira barra preenchendo com a cor 0 (Preto)
    MOV CX, 305
    MOV DX, 220
    MOV SI, 10
    MOV DI, 40
    MOV AL, 0           
    CALL desenha_retangulo
    
    ; Apaga a segunda barra preenchendo com preto
    MOV CX, 325
    MOV DX, 220
    MOV SI, 10
    MOV DI, 40
    MOV AL, 0
    CALL desenha_retangulo
    RET

;---------------------------------
; DESENHA_MENU_QUIT
; Cria a caixa de diálogo de confirmação de saída ("QUIT? Y/N")
; desenhando um retângulo de fundo e escrevendo o texto via BIOS.
desenha_menu_quit:

    ; Desenha a borda/fundo externo do menu (Retângulo Branco)
    MOV CX, 220         
    MOV DX, 180         
    MOV SI, 200         
    MOV DI, 60          
    MOV AL, 15  

    ; Desenha o interior da caixa por cima, deixando apenas a borda aparente (Retângulo Preto)        
    CALL desenha_retangulo
    MOV CX, 225
    MOV DX, 185
    MOV SI, 190
    MOV DI, 50
    MOV AL, 0           
    CALL desenha_retangulo

    ; Posiciona o cursor de texto do BIOS (Função 02h)
    MOV AH, 02h
    MOV BH, 0           
    MOV DH, 13          
    MOV DL, 36          
    INT 10h

    ; Loop para imprimir caractere por caractere a string 'msg_sair'
    MOV BX, msg_sair
print_loop:
    MOV AL, [BX]        
    CMP AL, 0     ;Verifica se chegou ao fim da string (caractere nulo)      
    JE fim_menu_saida   
    
    MOV AH, 0Eh    ;Função 0Eh do BIOS (imprime caractere na tela)     
    PUSH BX             
    MOV BH, 0
    MOV BL, 14     ;Cor do texto: 14 (Amarelo)     
    INT 10h
    POP BX              
    
    INC BX         ;Avança para o próximo caractere     
    JMP print_loop
fim_menu_saida:
    RET

;Remove a caixa de diálogo de confirmação preenchendo a área com preto.
apaga_menu_quit:
    MOV CX, 220
    MOV DX, 180
    MOV SI, 200
    MOV DI, 60
    MOV AL, 0
    CALL desenha_retangulo
    RET