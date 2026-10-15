segment data public
    global desenha_cena
    extern p1_x, p1_y, p1_estado
    extern p2_x, p2_y, p2_estado

segment code
desenha_cena:
    ; 1. Limpa a tela pintando o fundo de preto
    ; (Usamos a rolagem da BIOS, que é muito mais rápida que pintar pixel por pixel)
    MOV AX, 0600h       ; Função de rolar a janela (AL=0 limpa a tela)
    MOV BH, 00h         ; Cor do fundo (Preto)
    MOV CX, 0000h       ; Canto superior esquerdo (X=0, Y=0)
    MOV DX, 1D4Fh       ; Canto inferior direito (VGA 640x480)
    INT 10h

    ; 2. Desenha o Jogador 1 (Azul = 9)
    MOV CX, [p1_x]
    MOV DX, [p1_y]
    MOV AL, 9
    CALL desenha_quadrado
    
    ; 3. Desenha o Jogador 2 (Vermelho = 4)
    MOV CX, [p2_x]
    MOV DX, [p2_y]
    MOV AL, 4
    CALL desenha_quadrado
    
    RET

; Função que desenha um bloco 20x20
desenha_quadrado:
    PUSH CX
    PUSH DX
    PUSH BX
    
    MOV BX, 20          ; Altura = 20 pixels
linha:
    PUSH CX             ; Salva a coordenada X do início da linha
    PUSH BX             ; Salva a altura restante
    
    MOV BX, 20          ; Largura = 20 pixels
coluna:
    MOV AH, 0Ch         ; Função da BIOS de desenhar pixel
    PUSH BX             ; Salva a largura restante
    MOV BH, 0           ; Página de vídeo
    INT 10h             ; Pinta o pixel nas coordenadas CX, DX
    POP BX
    
    INC CX              ; Anda 1 pixel para a direita
    DEC BX
    JNZ coluna          ; Repete até terminar a largura
    
    POP BX              ; Recupera a altura restante
    POP CX              ; Volta a coordenada X para o início da coluna
    INC DX              ; Desce 1 pixel (próxima linha)
    DEC BX
    JNZ linha           ; Repete até terminar a altura
    
    POP BX
    POP DX
    POP CX
    RET

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