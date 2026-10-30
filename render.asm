segment data public
    global desenha_cena
    global desenha_fundo
    extern p1_x, p1_y, p1_hp, p1_x_antigo, p1_y_antigo, p1_estado
    extern p2_x, p2_y, p2_hp, p2_x_antigo, p2_y_antigo, p2_estado

segment code

; =========================================================
; DESENHA FUNDO: EXECUTADO APENAS 1 VEZ AO INICIAR O JOGO
; =========================================================
desenha_fundo:
    ; 1. Limpa a tela inteira (Preenche de Preto)
    MOV AX, 0600h
    MOV BH, 00h
    MOV CX, 0000h
    MOV DX, 1D4Fh
    INT 10h

    ; 2. Desenha o Fundo da Barra P1 (Cinza escuro)
    MOV CX, 20          ; X inicial
    MOV DX, 20          ; Y inicial
    MOV SI, 200         ; Largura máxima
    MOV DI, 15          ; Altura
    MOV AL, 8           ; Cor: 8 (Cinza)
    CALL desenha_retangulo

    ; 3. Desenha o Fundo da Barra P2 (Cinza escuro)
    MOV CX, 420         ; X inicial (Termina no 620)
    MOV DX, 20
    MOV SI, 200
    MOV DI, 15
    MOV AL, 8
    CALL desenha_retangulo
    
    RET

; =========================================================
; DESENHA CENA: EXECUTADO A CADA FRAME (18.2 Hz)
; =========================================================
desenha_cena:
    ; --- 1. APAGA OS RASTROS ---
    ; Apagar sempre vai varrer o quadrado de 20x20 para garantir que 
    ; nada do frame anterior sobre na tela, mesmo se voltar de um pulo.
    MOV CX, [p1_x_antigo]
    MOV DX, [p1_y_antigo]
    MOV SI, 20
    MOV DI, 20
    MOV AL, 0           
    CALL desenha_retangulo

    MOV CX, [p2_x_antigo]
    MOV DX, [p2_y_antigo]
    MOV SI, 20
    MOV DI, 20
    MOV AL, 0
    CALL desenha_retangulo

    ; --- 2. DESENHA OS LUTADORES NAS POSIÇÕES NOVAS ---
    ; P1
    MOV CX, [p1_x]
    MOV DX, [p1_y]
    MOV SI, 20
    MOV DI, 20          ; Altura padrão
    CMP byte [p1_estado], 2 ; Checa se P1 está agachado
    JNE desenha_p1_cor
    MOV DI, 10          ; Se sim, altura vira 10
desenha_p1_cor:
    MOV AL, 9           ; Azul
    CALL desenha_retangulo
    
    ; P2
    MOV CX, [p2_x]
    MOV DX, [p2_y]
    MOV SI, 20
    MOV DI, 20          ; Altura padrão
    CMP byte [p2_estado], 2 ; Checa se P2 está agachado
    JNE desenha_p2_cor
    MOV DI, 10          ; Se sim, altura vira 10
desenha_p2_cor:
    MOV AL, 4           ; Vermelho
    CALL desenha_retangulo

    ; --- 3. ATUALIZA AS BARRAS DE VIDA (igual ao seu código anterior) ---
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
; FUNÇÃO AUXILIAR: DESENHA RETÂNGULO GENÉRICO
; Parâmetros de Entrada:
; CX = X Inicial | DX = Y Inicial
; SI = Largura   | DI = Altura
; AL = Cor (0 a 15)
; =========================================================
desenha_retangulo:
    CMP SI, 0
    JE fim_retangulo
    CMP DI, 0
    JE fim_retangulo

    ; Salva o contexto dos registradores para não corromper o chamador
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH BX
    
    MOV BX, DI          ; BX será o contador de linhas (Altura)
linha:
    PUSH CX             ; Salva a posição X original da linha
    PUSH BX             ; Salva a altura restante
    
    MOV BX, SI          ; BX será o contador de colunas (Largura)
coluna:
    MOV AH, 0Ch         ; Função de escrever pixel da INT 10h
    PUSH BX             ; Protege o contador de largura da INT 10h
    MOV BH, 0           ; Página de vídeo 0
    INT 10h             
    POP BX
    
    INC CX              ; X = X + 1 (Anda um pixel pra direita)
    DEC BX
    JNZ coluna          ; Repete até pintar toda a largura da linha atual
    
    POP BX              ; Recupera a altura restante
    POP CX              ; Volta o X para a esquerda
    INC DX              ; Y = Y + 1 (Desce uma linha)
    DEC BX
    JNZ linha           ; Repete até pintar todas as linhas (Altura)
    
    ; Restaura o contexto
    POP BX
    POP DI
    POP SI
    POP DX
    POP CX
fim_retangulo:
    RET