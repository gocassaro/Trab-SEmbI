segment data public
    global desenha_cena
    extern p1_x, p1_y, p1_estado, p1_hp
    extern p2_x, p2_y, p2_estado, p2_hp

segment code

desenha_cena:
    ; ==========================================
    ; AGUARDA O VSYNC (Sincronização Vertical)
    ; ==========================================
    MOV DX, 03DAh               ; Porta de status do monitor VGA
espera_vblank_fim:
    IN AL, DX
    TEST AL, 8                  ; Testa o bit 3 (Vertical Retrace)
    JNZ espera_vblank_fim       ; Espera terminar o VSync anterior (se estiver ocorrendo)
espera_vblank_inicio:
    IN AL, DX
    TEST AL, 8
    JZ espera_vblank_inicio     ; Espera o monitor iniciar o período de VSync
    
    ; 1. Limpa a tela (preenche com preto)
    MOV AX, 0600h
    MOV BH, 00h
    MOV CX, 0000h
    MOV DX, 1D4Fh
    INT 10h

    ; ==========================================
    ; INTERFACE: BARRAS DE ENERGIA (FUNDO CINZA)
    ; ==========================================
    
    ; Fundo Barra P1 (Canto Superior Esquerdo)
    MOV CX, 20          ; X = 20
    MOV DX, 20          ; Y = 20
    MOV SI, 200         ; Largura = 200 (10 HP * 20 pixels)
    MOV DI, 15          ; Altura = 15
    MOV AL, 8           ; Cor: Cinza (Código 8)
    CALL desenha_retangulo

    ; Fundo Barra P2 (Canto Superior Direito)
    MOV CX, 420         ; X = 420 (Termina no X=620)
    MOV DX, 20          ; Y = 20
    MOV SI, 200         ; Largura = 200
    MOV DI, 15          ; Altura = 15
    MOV AL, 8           ; Cor: Cinza
    CALL desenha_retangulo

    ; ==========================================
    ; INTERFACE: ENERGIA ATUAL (BARRAS AMARELAS)
    ; ==========================================
    
    ; Vida Atual P1
    CMP byte [p1_hp], 0
    JE hp2_check        ; Se HP for 0, não desenha a barra amarela
    
    MOV AL, [p1_hp]
    XOR AH, AH          ; Limpa AH, deixando apenas p1_hp em AX
    MOV BX, 20
    MUL BX              ; AX = HP * 20 (Calcula a largura atual)
    MOV SI, AX          ; Largura
    MOV CX, 20          ; X = 20
    MOV DX, 20          ; Y = 20
    MOV DI, 15          ; Altura
    MOV AL, 14          ; Cor: Amarelo
    CALL desenha_retangulo

hp2_check:
    ; Vida Atual P2
    CMP byte [p2_hp], 0
    JE draw_players     ; Se HP for 0, pula
    
    MOV AL, [p2_hp]
    XOR AH, AH
    MOV BX, 20
    MUL BX              ; AX = HP * 20
    MOV SI, AX          ; Largura
    MOV CX, 620         ; Borda direita máxima da barra
    SUB CX, AX          ; Subtrai a largura para a barra "encolher" para a direita
    MOV DX, 20          ; Y = 20
    MOV DI, 15          ; Altura
    MOV AL, 14          ; Cor: Amarelo
    CALL desenha_retangulo

draw_players:
    ; ==========================================
    ; DESENHA OS LUTADORES
    ; ==========================================
    
    ; Desenha P1
    MOV CX, [p1_x]
    MOV DX, [p1_y]
    MOV SI, 20          ; Largura 20
    MOV DI, 20          ; Altura 20
    MOV AL, 9           ; Cor: Azul
    CALL desenha_retangulo
    
    ; Desenha P2
    MOV CX, [p2_x]
    MOV DX, [p2_y]
    MOV SI, 20          ; Largura 20
    MOV DI, 20          ; Altura 20
    MOV AL, 4           ; Cor: Vermelho
    CALL desenha_retangulo
    
    RET

; ==========================================
; FUNÇÃO: DESENHA RETÂNGULO GENÉRICO
; Parâmetros:
; CX = Posição X Inicial
; DX = Posição Y Inicial
; SI = Largura
; DI = Altura
; AL = Cor (0 a 15)
; ==========================================
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
    
    MOV BX, DI          ; Passa a altura para o contador BX
linha:
    PUSH CX             ; Salva X inicial da linha
    PUSH BX             ; Salva a altura restante
    
    MOV BX, SI          ; Passa a largura para o contador BX
coluna:
    MOV AH, 0Ch         ; INT 10h, 0Ch: Escrever pixel gráfico
    PUSH BX             
    MOV BH, 0           
    INT 10h             
    POP BX
    
    INC CX              ; Avança 1 pixel para a direita
    DEC BX
    JNZ coluna          ; Continua até terminar a largura
    
    POP BX              ; Recupera a altura restante
    POP CX              ; Volta o X para o começo da linha
    INC DX              ; Desce 1 pixel (Y = Y + 1)
    DEC BX
    JNZ linha           ; Continua até terminar a altura
    
    POP BX
    POP DI
    POP SI
    POP DX
    POP CX
fim_retangulo:
    RET

; segment data public
;     global desenha_cena
;     extern p1_x, p1_y, p1_estado
;     extern p2_x, p2_y, p2_estado

; segment code
; desenha_cena:
;     ; 1. Limpa a tela pintando o fundo de preto
;     ; (Usamos a rolagem da BIOS, que é muito mais rápida que pintar pixel por pixel)
;     MOV AX, 0600h       ; Função de rolar a janela (AL=0 limpa a tela)
;     MOV BH, 00h         ; Cor do fundo (Preto)
;     MOV CX, 0000h       ; Canto superior esquerdo (X=0, Y=0)
;     MOV DX, 1D4Fh       ; Canto inferior direito (VGA 640x480)
;     INT 10h

;     ; 2. Desenha o Jogador 1 (Azul = 9)
;     MOV CX, [p1_x]
;     MOV DX, [p1_y]
;     MOV AL, 9
;     CALL desenha_quadrado
    
;     ; 3. Desenha o Jogador 2 (Vermelho = 4)
;     MOV CX, [p2_x]
;     MOV DX, [p2_y]
;     MOV AL, 4
;     CALL desenha_quadrado
    
;     RET

; ; Função que desenha um bloco 20x20
; desenha_quadrado:
;     PUSH CX
;     PUSH DX
;     PUSH BX
    
;     MOV BX, 20          ; Altura = 20 pixels
; linha:
;     PUSH CX             ; Salva a coordenada X do início da linha
;     PUSH BX             ; Salva a altura restante
    
;     MOV BX, 20          ; Largura = 20 pixels
; coluna:
;     MOV AH, 0Ch         ; Função da BIOS de desenhar pixel
;     PUSH BX             ; Salva a largura restante
;     MOV BH, 0           ; Página de vídeo
;     INT 10h             ; Pinta o pixel nas coordenadas CX, DX
;     POP BX
    
;     INC CX              ; Anda 1 pixel para a direita
;     DEC BX
;     JNZ coluna          ; Repete até terminar a largura
    
;     POP BX              ; Recupera a altura restante
;     POP CX              ; Volta a coordenada X para o início da coluna
;     INC DX              ; Desce 1 pixel (próxima linha)
;     DEC BX
;     JNZ linha           ; Repete até terminar a altura
    
;     POP BX
;     POP DX
;     POP CX
;     RET

;; =========================================== ;;

; segment data public
;     global desenha_cena
;     extern p1_x, p1_y, p1_estado
;     extern p2_x, p2_y, p2_estado

; segment code
; desenha_cena:
;     ; (Aqui você pode incluir uma macro para limpar a tela desenhando um retângulo preto de 640x480)
    
;     ; Desenha P1
;     MOV CX, [p1_x]
;     MOV DX, [p1_y]
;     MOV AL, 9           ; Cor Azul para P1
;     CALL desenha_lutador_placeholder
    
;     ; Desenha P2
;     MOV CX, [p2_x]
;     MOV DX, [p2_y]
;     MOV AL, 4           ; Cor Vermelha para P2
;     CALL desenha_lutador_placeholder
    
;     RET

; desenha_lutador_placeholder:
;     ; CX = X, DX = Y, AL = Cor
;     ; Essa função desenharia um retângulo base.
;     ; Se p1_estado == 2 (Agachado), desenha retângulo menor.
;     ; Se p1_estado == 4 (Soco), desenha um braço estendido (uma linha reta).
    
;     ; Exemplo de Ponto (Use plot_xy do lab05 na versão final[cite: 6])
;     MOV AH, 0Ch
;     MOV BH, 0
;     INT 10h
;     RET