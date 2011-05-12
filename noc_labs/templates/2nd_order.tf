;NeuCon transfer 1.0
[TransferFunction]
; idname:  2nd_order
; type:    TransferFunction
; label:   Звено 2-го порядка
; key_pos: K 0 d1 5 d2 6
product 2 ; K*z^2/(z^2+d1*z+d2)
polyfrac 0
1 / 1   ; K
polyfrac 0
 1 0 0 / 1 -2 2 ; d1 d2
