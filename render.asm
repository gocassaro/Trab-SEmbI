segment data public
    global desenha_cena
    global desenha_fundo
    extern p1_x, p1_y, p1_hp, p1_x_antigo, p1_y_antigo
    extern p2_x, p2_y, p2_hp, p2_x_antigo, p2_y_antigo

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
    
    ; --- 1. APAGA OS RASTROS (Dirty Rectangles) ---
    ; Pinta um quadrado PRETO (cor 0) exatamente na posição ANTIGA do P1
    MOV CX, [p1_x_antigo]
    MOV DX, [p1_y_antigo]
    MOV SI, 20
    MOV DI, 20
    MOV AL, 0           
    CALL desenha_retangulo

    ; Pinta um quadrado PRETO na posição ANTIGA do P2
    MOV CX, [p2_x_antigo]
    MOV DX, [p2_y_antigo]
    MOV SI, 20
    MOV DI, 20
    MOV AL, 0
    CALL desenha_retangulo

    ; --- 2. DESENHA OS LUTADORES NAS POSIÇÕES NOVAS ---
    ; Desenha P1 na posição atual
    MOV CX, [p1_x]
    MOV DX, [p1_y]
    MOV SI, 20
    MOV DI, 20
    MOV AL, 9           ; Cor: 9 (Azul)
    CALL desenha_retangulo
    
    ; Desenha P2 na posição atual
    MOV CX, [p2_x]
    MOV DX, [p2_y]
    MOV SI, 20
    MOV DI, 20
    MOV AL, 4           ; Cor: 4 (Vermelho)
    CALL desenha_retangulo

    ; --- 3. ATUALIZA AS BARRAS DE VIDA DINAMICAMENTE ---
    
    ; > Repinta todo o Fundo Cinza do P1
    MOV CX, 20
    MOV DX, 20
    MOV SI, 200
    MOV DI, 15
    MOV AL, 8           
    CALL desenha_retangulo
    
    ; > Desenha a Energia Amarela do P1 por cima
    CMP byte [p1_hp], 0
    JE atualiza_hp2     ; Se a vida for 0, pula e deixa só o cinza
    
    MOV AL, [p1_hp]
    XOR AH, AH          ; Limpa AH (AX agora tem o valor de HP)
    MOV BX, 20
    MUL BX              ; Multiplica AX por BX (Resultado vai para DX:AX)
    MOV SI, AX          ; SI recebe a nova largura calculada (HP * 20)
    
    ; Como a instrução MUL afeta o DX, precisamos restaurar as coordenadas Y e Altura
    MOV CX, 20          ; X
    MOV DX, 20          ; Y
    MOV DI, 15          ; Altura
    MOV AL, 14          ; Cor: 14 (Amarelo)
    CALL desenha_retangulo

atualiza_hp2:
    ; > Repinta todo o Fundo Cinza do P2
    MOV CX, 420
    MOV DX, 20
    MOV SI, 200
    MOV DI, 15
    MOV AL, 8           
    CALL desenha_retangulo

    ; > Desenha a Energia Amarela do P2 por cima
    CMP byte [p2_hp], 0
    JE fim_desenho      ; Se a vida for 0, termina a renderização
    
    MOV AL, [p2_hp]
    XOR AH, AH
    MOV BX, 20
    MUL BX              ; DX:AX = HP * 20
    MOV SI, AX          ; SI = Largura
    
    MOV CX, 620         ; Borda máxima direita da barra
    SUB CX, AX          ; Subtrai a largura para "encolher" da esquerda para a direita
    
    ; Restaura coordenadas após o MUL
    MOV DX, 20          ; Y
    MOV DI, 15          ; Altura
    MOV AL, 14          ; Cor: Amarelo
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