;NeuCon transfer 1.0
[TransferFunction]
; idname:  1st_order
; type:    TransferFunction
; label:   Звено 1-го порядка
; key_pos: K 0 d 4
product 2 ; K*(z/z-d)
polyfrac 0
1 / 1   ; K
polyfrac 0
 -1 0 / -1 0.5 ; d
