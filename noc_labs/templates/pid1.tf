; idname:  pid1
; type:    TransferFunction
; label:   ПИД регулятор (Kp Ki Kd)
; key_pos: Kp 0 Ki 0 Kd 0
sum 3 ; Kp + Ki*(z/z-1) + Kd*(z2-2z+1/z(z-1))
polyfrac 0 ; <=== Proportional term
 111.0 / 1   ; Kp
product 2  ; <=== Integral term
polyfrac 0
 222.0 / 1   ; Ki
polyfrac 0
 1 0 / 1 -1
product 2  ; <=== Differential term
polyfrac 0
 333.0 / 1   ; Kd
polyfrac 0
 1 -2 1 / 1 -1 0
