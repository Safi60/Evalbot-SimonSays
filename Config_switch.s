; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIO EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; The GPIODATA register is the data register
GPIO_PORTD_BASE		EQU		0x40007000		; GPIO Port D (APB) base: 0x4000.7000 (p416 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)
	
; Pul_up
GPIO_I_PUR   		EQU 	0x00000510  ; GPIO Pull-Up (p432 datasheet de lm3s9B92.pdf)
	
	
BROCHE_D_6				EQU 	0x40		; SW1

BROCHE_D_7				EQU 	0x80		; SW2

BROCHE_D_6_7			EQU 	0xC0		; SW1_2



		AREA    |.text|, CODE, READONLY
		ENTRY
		
		EXPORT CONFIG_SWITCH
		EXPORT READ_STATE_SW1
		EXPORT READ_STATE_SW2


; Configuration des SWITCH 1 et SWITCH 2
CONFIG_SWITCH
		; ;; Enable the Port D peripheral clock 		(p291 datasheet de lm3s9B96.pdf)
		; ;;
		LDR R6, = SYSCTL_PERIPH_GPIO  			;; RCGC2
		LDR R0, [R6]
		ORR R0, R0, #0x08	;; Enable clock on GPIO D (0x08 == 0b0000 1000) where SWITCH were connected on (0xC0 == 0b1100 0000)
		; ;;										   (GPIO::HGFE DCBA)
		STR R0, [R6]

		; ;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet in lm3s9B92.pdf)
		NOP
		NOP
		NOP

		LDR R6, = GPIO_PORTD_BASE + GPIO_I_PUR	;; Pull_up
		LDR R0, = BROCHE_D_6_7
		STR R0, [R6]

		LDR R6, = GPIO_PORTD_BASE + GPIO_O_DEN	;; Enable Digital Function
		LDR R0, [R6]
		ORR R0, R0, #BROCHE_D_6_7
		STR R0, [R6]
		

		BX LR
; FIN de Configuration des SWITCH 1 et SWITCH 2		


; Lit l'état du SWITCH 1
READ_STATE_SW1
		PUSH { R10, R11, LR }							
		LDR R11, = GPIO_PORTD_BASE + (BROCHE_D_6<<2)  ;; @data Register = @base + (mask<<2) ==> SW1
		LDR R10, [R11]
		CMP R10, #0x00
		POP { R10, R11, PC }
	
	

; Lit l'état du SWITCH 2
READ_STATE_SW2
		PUSH { R10, R12, LR }							
		LDR R12, = GPIO_PORTD_BASE + (BROCHE_D_7<<2)  ;; @data Register = @base + (mask<<2) ==> SW2
		LDR R10, [R12]
		CMP R10, #0x00	
		POP { R10, R12, PC }

		END
	

	