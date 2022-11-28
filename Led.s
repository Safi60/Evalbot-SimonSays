
; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIOF EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Broches select
PORT45				EQU		0x30		; led1 & led2 sur broche 4 et 5
	
PORT4				EQU		0x10		; led1 sur broche 4

PORT5				EQU		0x20		; led2 sur broche 5

; blinking frequency
DUREE   			EQU     0x000DFFFF
	
	
		AREA    |.text|, CODE, READONLY
		ENTRY
		
		EXPORT	CLIGNOTE2
		EXPORT	CLIGNOTE3
		EXPORT	CLIGNOTEG
		EXPORT	CLIGNOTED
			
; ---------------------------------------------------------------
; Méthode pour faire clignoter 2 fois les 2 LEDS simultanément
CLIGNOTE2
; Activer l'horloge périphérique du port F en définissant le bit 5 (0x20 == 0b100000)

	LDR r3, = SYSCTL_PERIPH_GPIOF
	MOV r8, #0x00000020

;Délai de 3 horloges systèmes

	NOP
	NOP
	NOP

;Configuration LED

	LDR r3, = GPIO_PORTF_BASE+GPIO_O_DIR
	LDR r8, = PORT45
	STR r8, [r3]
	
	LDR r3, = GPIO_PORTF_BASE+GPIO_O_DEN
	LDR r8, = PORT45
	STR r8, [r3]
	
	LDR r3, = GPIO_PORTF_BASE+GPIO_O_DR2R
	LDR r8, = PORT45
	STR r8, [r3]
	MOV r10, #0x000
	
;Allumer les LEDS (PORTS45)

	MOV r11, #PORT45
	LDR r3, =GPIO_PORTF_BASE + (PORT45<<2)

; Fin configuration LED

; Boucle : 2 clignotements
	MOV r4, #0

loopC2	CMP	r4, #2
		BEQ finC2
		ADD r4, #1
		STR r10, [r3]
		LDR r9, = DUREE

wait1C2	SUBS r9, #1
		BNE wait1C2
		
		STR r11, [r3]
		LDR r9, = DUREE

wait2C2	SUBS r9, #1
		BNE wait2C2
		
		B loopC2
		
finC2		
		STR r10, [r3]
		BX LR	
	

; ---------------------------------------------------------------
; Méthode pour faire clignoter 3 fois les 2 LEDS simultanément
CLIGNOTE3
; Activer l'horloge périphérique du port F en définissant le bit 5 (0x20 == 0b100000)

	LDR r3, = SYSCTL_PERIPH_GPIOF
	MOV r8, #0x00000020

;Délai de 3 horloges systèmes

	NOP
	NOP
	NOP

;Configuration LED

	LDR r3, = GPIO_PORTF_BASE+GPIO_O_DIR
	LDR r8, = PORT45
	STR r8, [r3]
	
	LDR r3, = GPIO_PORTF_BASE+GPIO_O_DEN
	LDR r8, = PORT45
	STR r8, [r3]
	
	LDR r3, = GPIO_PORTF_BASE+GPIO_O_DR2R
	LDR r8, = PORT45
	STR r8, [r3]
	MOV r10, #0x000
	
;Allumer les LEDS (PORTS45)

	MOV r11, #PORT45
	LDR r3, =GPIO_PORTF_BASE + (PORT45<<2)

; Fin configuration LED

; Boucle : 3 clignotements
	MOV r4, #0

loopC3	CMP	r4, #3
		BEQ finC3
		ADD r4, #1
		STR r10, [r3]
		LDR r9, = DUREE

wait1C3	SUBS r9, #1
		BNE wait1C3
		
		STR r11, [r3]
		LDR r9, = DUREE

wait2C3	SUBS r9, #1
		BNE wait2C3
		
		B loopC3
		
finC3		
		STR r10, [r3]
		BX LR	



; ---------------------------------------------------------------
; Méthode pour faire clignoter LED droite 1 fois
CLIGNOTED
; Activer l'horloge périphérique du port F en définissant le bit 5 (0x20 == 0b100000)

	LDR r3, = SYSCTL_PERIPH_GPIOF
	MOV r8, #0x00000020

;Délai de 3 horloges systèmes

	NOP
	NOP
	NOP

;Configuration LED

	LDR r3, = GPIO_PORTF_BASE+GPIO_O_DIR
	LDR r8, = PORT4
	STR r8, [r3]
	
	LDR r3, = GPIO_PORTF_BASE+GPIO_O_DEN
	LDR r8, = PORT4
	STR r8, [r3]
	
	LDR r3, = GPIO_PORTF_BASE+GPIO_O_DR2R
	LDR r8, = PORT4
	STR r8, [r3]
	MOV r10, #0x000
	
;Allumer la LED (PORTS4)

	MOV r11, #PORT4
	LDR r3, =GPIO_PORTF_BASE + (PORT4<<2)

; Fin configuration LED

; clignotements LED
		STR r10, [r3]
		LDR r9, = DUREE

wait1CD	SUBS r9, #1
		BNE wait1CD
		
		STR r11, [r3]
		LDR r9, = DUREE

wait2CD	SUBS r9, #1
		BNE wait2CD
			
		STR r10, [r3]
		BX LR	



; ---------------------------------------------------------------
; ---------------------------------------------------------------
; Méthode pour faire clignoter LED droite 1 fois
CLIGNOTEG
; Activer l'horloge périphérique du port F en définissant le bit 5 (0x20 == 0b100000)

	LDR r3, = SYSCTL_PERIPH_GPIOF
	MOV r8, #0x00000020

;Délai de 3 horloges systèmes

	NOP
	NOP
	NOP

;Configuration LED

	LDR r3, = GPIO_PORTF_BASE+GPIO_O_DIR
	LDR r8, = PORT5
	STR r8, [r3]
	
	LDR r3, = GPIO_PORTF_BASE+GPIO_O_DEN
	LDR r8, = PORT5
	STR r8, [r3]
	
	LDR r3, = GPIO_PORTF_BASE+GPIO_O_DR2R
	LDR r8, = PORT5
	STR r8, [r3]
	MOV r10, #0x000
	
;Allumer la LED (PORT5)

	MOV r11, #PORT5
	LDR r3, =GPIO_PORTF_BASE + (PORT5<<2)

; Fin configuration LED

; clignotements LED
		STR r10, [r3]
		LDR r9, = DUREE

wait1CG	SUBS r9, #1
		BNE wait1CG
		
		STR r11, [r3]
		LDR r9, = DUREE

wait2CG	SUBS r9, #1
		BNE wait2CG
			
		STR r10, [r3]
		BX LR	

	END
 





















