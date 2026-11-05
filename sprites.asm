segment data public
    global sprite_p1, sprite_p2                                 ; Exporta os vetores base (para parado e andando)
    global sprite_p1_soco, sprite_p1_chute, sprite_p1_agachado  ; Exporta os vetores de ação do P1
    global sprite_p2_soco, sprite_p2_chute, sprite_p2_agachado  ; Exporta os vetores de ação do P2

    ; =========================================================================
    ; ESTRUTURA DO SPRITE (Lista de Retângulos)
    ; Cada bloco tem 9 bytes:
    ; dw offset_x      (Distância X do centro do personagem)
    ; dw offset_y_top  (Distância Y até o topo do bloco)
    ; dw largura
    ; dw altura
    ; db cor           (99 = Cor Dinâmica do Jogador)
    ; =========================================================================

; =========================================================
; SPRITES DO JOGADOR 1 (Virado para a direita)
; =========================================================
sprite_p1:
    ; Arte original do Karateka em Pé / Andando
    dw 4, 46, 20, 4, 0      ; Cabelo
    dw 3, 41, 22, 3, 99     ; Faixa Cabeca
    dw 4, 37, 20, 12, 6     ; Cabeca
    dw 18, 35, 3, 3, 0      ; Olho
    dw 0, 23, 26, 23, 15    ; Peito
    dw -2, -5, 11, 23, 15   ; Perna Esq
    dw 18, -5, 10, 23, 15   ; Perna Dir
    dw -1, -1, 28, 5, 99    ; Faixa Cintura
    dw -6, -27, 12, 6, 6    ; Pe Esq
    dw 22, -27, 10, 6, 6    ; Pe Dir
    dw 26, 18, 7, 7, 15     ; Braco
    dw -4, 10, 7, 6, 6      ; Mao Esq
    dw 30, 20, 8, 7, 6      ; Mao Dir (Recolhida)

sprite_p1_soco:
    ; Igual ao P1, mas com o braço direito e mão esticados para frente
    dw 4, 46, 20, 4, 0
    dw 3, 41, 22, 3, 99
    dw 4, 37, 20, 12, 6
    dw 18, 35, 3, 3, 0
    dw 0, 23, 26, 23, 15
    dw -2, -5, 11, 23, 15
    dw 18, -5, 10, 23, 15
    dw -1, -1, 28, 5, 99
    dw -6, -27, 12, 6, 6
    dw 22, -27, 10, 6, 6
    dw 26, 18, 30, 7, 15    ; Braço esticado (Largura: 30)
    dw -4, 10, 7, 6, 6
    dw 56, 20, 8, 7, 6      ; Mao Dir esticada na ponta (X: 56)

sprite_p1_chute:
    ; Igual ao P1, mas com a perna direita esticada
    dw 4, 46, 20, 4, 0
    dw 3, 41, 22, 3, 99
    dw 4, 37, 20, 12, 6
    dw 18, 35, 3, 3, 0
    dw 0, 23, 26, 23, 15
    dw -2, -5, 11, 23, 15
    dw 18, -5, 45, 10, 15   ; Perna Dir esticada (Largura: 45)
    dw -1, -1, 28, 5, 99
    dw -6, -27, 12, 6, 6
    dw 63, -13, 8, 8, 6     ; Pe Dir no ar (X: 63, Y: -13)
    dw 26, 18, 7, 7, 15
    dw -4, 10, 7, 6, 6
    dw 30, 20, 8, 7, 6

sprite_p1_agachado:
    ; Peito e cabeça rebaixados (Altura Y do Peito cortada, posições Y ajustadas)
    dw 4, 21, 20, 4, 0      ; Cabelo desce 25px
    dw 3, 16, 22, 3, 99     ; Faixa
    dw 4, 12, 20, 12, 6     ; Cabeca
    dw 18, 10, 3, 3, 0      ; Olho
    dw 0, -2, 26, 12, 15    ; Peito esmagado (Altura: 12)
    dw -2, -5, 11, 23, 15
    dw 18, -5, 10, 23, 15
    dw -1, -1, 28, 5, 99
    dw -6, -27, 12, 6, 6
    dw 22, -27, 10, 6, 6
    dw 26, -7, 7, 7, 15     ; Braco desce
    dw -4, -15, 7, 6, 6     ; Mao Esq
    dw 30, -5, 8, 7, 6      ; Mao Dir

; =========================================================
; SPRITES DO JOGADOR 2 (Virado para a esquerda)
; =========================================================
sprite_p2:
    dw 2, 46, 20, 4, 0
    dw 1, 41, 22, 3, 99
    dw 2, 37, 20, 12, 6
    dw 5, 35, 3, 3, 0
    dw 0, 23, 26, 23, 15
    dw 17, -5, 11, 23, 15
    dw -2, -5, 10, 23, 15
    dw -1, -1, 28, 5, 99
    dw 20, -27, 12, 6, 6
    dw -6, -27, 10, 6, 6
    dw -7, 18, 7, 7, 15
    dw 23, 10, 7, 6, 6
    dw -12, 20, 8, 7, 6

sprite_p2_soco:
    dw 2, 46, 20, 4, 0
    dw 1, 41, 22, 3, 99
    dw 2, 37, 20, 12, 6
    dw 5, 35, 3, 3, 0
    dw 0, 23, 26, 23, 15
    dw 17, -5, 11, 23, 15
    dw -2, -5, 10, 23, 15
    dw -1, -1, 28, 5, 99
    dw 20, -27, 12, 6, 6
    dw -6, -27, 10, 6, 6
    dw -30, 18, 30, 7, 15   ; Braco esticado p/ esq
    dw 23, 10, 7, 6, 6
    dw -38, 20, 8, 7, 6     ; Mao Dir na ponta esq

sprite_p2_chute:
    dw 2, 46, 20, 4, 0
    dw 1, 41, 22, 3, 99
    dw 2, 37, 20, 12, 6
    dw 5, 35, 3, 3, 0
    dw 0, 23, 26, 23, 15
    dw 17, -5, 11, 23, 15
    dw -37, -5, 45, 10, 15  ; Perna esticada p/ esq
    dw -1, -1, 28, 5, 99
    dw 20, -27, 12, 6, 6
    dw -45, -13, 8, 8, 6    ; Pe Dir
    dw -7, 18, 7, 7, 15
    dw 23, 10, 7, 6, 6
    dw -12, 20, 8, 7, 6

sprite_p2_agachado:
    dw 2, 21, 20, 4, 0
    dw 1, 16, 22, 3, 99
    dw 2, 12, 20, 12, 6
    dw 5, 10, 3, 3, 0
    dw 0, -2, 26, 12, 15
    dw 17, -5, 11, 23, 15
    dw -2, -5, 10, 23, 15
    dw -1, -1, 28, 5, 99
    dw 20, -27, 12, 6, 6
    dw -6, -27, 10, 6, 6
    dw -7, -7, 7, 7, 15
    dw 23, -15, 7, 6, 6
    dw -12, -5, 8, 7, 6