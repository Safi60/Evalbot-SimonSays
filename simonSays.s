	;; RK - Evalbot (Cortex M3 de Texas Instrument)
; programme - Jeu de mémorisation reprenant le jeu SimonSays en ASM
; par Safi HANIFA et Yanis AIT TAOUIT



		AREA    |.text|, CODE, READONLY

; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIOF	EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTE_BASE		EQU		0x40024000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; Pul_up
GPIO_PUR   		EQU 	0x510  ; GPIO Pull-Up (p432 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN			EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; PORT E : sélection du BUMPER GAUCHE, LIGNE 0 du port E
PORT0			EQU 	0x01

; PORT E : sélection du BUMPER GAUCHE, LIGNE 0 du port E
PORT1			EQU 	0x02
	
; Sélections des 2 BUMPERS
PORT01			EQU 	0x03

; Taille du tableau pour la séquence
TAILLE			EQU		0x5
	
		ENTRY
		EXPORT	__main
		
		IMPORT	CLIGNOTE2
		IMPORT	CLIGNOTE3
		IMPORT	CLIGNOTEG
		IMPORT	CLIGNOTED
		IMPORT	DANSE
		;IMPORT WAIT
		
		;; The IMPORT command specifies that a symbol is defined in a shared object at runtime.
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; déactiver le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arrière
		IMPORT  MOTEUR_DROIT_INVERSE		; inverse le sens de rotation du moteur droit
		
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; déactiver le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arrière
		IMPORT  MOTEUR_GAUCHE_INVERSE		; inverse le sens de rotation du moteur gauche
			
			
		;----------------------SWITCH-----------------;
		IMPORT CONFIG_SWITCH ; configure SW (configure pwms + GPIO)
		IMPORT READ_STATE_SW1 ; lit l'état de SW1
		IMPORT READ_STATE_SW2 ; lit l'état de SW2
		



__main	

	LDR r6, = SYSCTL_PERIPH_GPIOF
	MOV r0, #0x00000030
	STR r0, [r6]	

;Délai de 3 horloges systèmes
	NOP
	NOP
	NOP

; Activer fonction digitale - PORT E	
	LDR r7, = GPIO_PORTE_BASE+GPIO_O_DEN
	LDR r6, = PORT01
	STR r6, [r7]
	
	LDR r7, = GPIO_PORTE_BASE+GPIO_PUR
	LDR r6, = PORT01
	STR r6, [r7]
	

	; Clignote 2 fois pour lancer le jeu

	BL CLIGNOTE2

;Début du jeu
;Initialisation des variables utilisées

init
	MOV r0,#0
	LDR r1,=TAILLE
	LDR r2,=SEQUENCE
	MOV r4,#0
	LDRB r5,SEQUENCE
	B loop
	

; Boucle qui vérifie si on a atteint la fin de la séquence
loop
			CMP r1, r0  ; Comparaison entre l'index actuel et la longueur de la séquence
			BEQ win		; Victoire car toute la séquence a été reproduite sans erreur 
			ADD r0, #1	; Incrémentation de l'index
			MOV r4, #0
			B sequence
	
	
; On compte le nombre de case à lire dans la séquence
sequence	CMP r0, r4	; Comparaison nombre de LED à afficher
			MOV r12, #0	; 

			BEQ bumpers	; Si toute la séquence qui doit s'afficher a clignoté : on vérifie les bumpers
			; On choisit si on doit allumer la LED1 ou la LED2
			LDRB r5, [r2, r4]
			ADD r4, #1
			CMP r5, #0
			BEQ test1
			BNE test2	
	
; Allumage LED1
test1 		BL CLIGNOTEG
			B sequence
	
; Allumage LED2
test2		BL CLIGNOTED
			B sequence

; Vérification des bumpers
bumpers 	CMP r4,	r12
			BEQ loop		; Si tous les bumpers ont été activés sans erreur :on reprend l'affichage de la séquence
			MOV r5, r2
			B	lireEntrees	; Sinon  on lit les états des bumpers

			
			
lireEntrees 
			; Lecture de l'état du BUMPER DROIT
			LDR r7, = GPIO_PORTE_BASE + (PORT0<<2)
			LDR r9, [r7]
			CMP r9, #0x01
			BNE	save1	; Si le bumper droit a été activé
			
			; Lecture de l'état du BUMPER GAUCHE
			LDR r7, = GPIO_PORTE_BASE +(PORT1<<2)
			LDR r9, [r7]
			CMP r9, #0x02
			BNE	save0	; Si le bumper gauche a été activé
			
			; Si aucun n'a été activé on relit les états
			B lireEntrees
	
	
; On attend d'avoir l'entrée nécessaire à la vérification 
save1
			LDRB r5, [r2,r12]
			ADD r12, #1
			MOV r8, #0
			BL WAIT

	
; Si erreur on envoie vers le scénario de la défaite, sinon on reprend la vérification des bumpers
compared
			CMP	r5, #1
			BEQ bumpers
			B lose

; On attend d'avoir l'entrée nécessaire à la vérification
save0
			LDRB r5, [r2,r12]
			ADD r12, #1
			MOV r8, #0
			BL WAIT
			

; Si erreur on envoie vers le scénario de la défaite, sinon on reprend la vérification des bumpers
compareg	CMP r5, #0
			BEQ bumpers
			B lose
	
	; Scénario de défaite : on fait clignoter 3 fois les LEDS et on va à la fin du programme
lose
			BL CLIGNOTE3
			B fin
			;BL restart_sequence


restart_sequence
			PUSH { R0, R6, R10-R12, LR }
			BL CONFIG_SWITCH
			
			BL READ_STATE_SW2
			BNE restart_sequence
			B sequence
			POP { R0, R6, R10-R12, PC }	

	; Scénario de victoire : on fait clignoter 2 fois les LEDS
	; et le robot fait un tour sur lui même (danse de la joie), puis on va à la fin du programme
win 		BL CLIGNOTE2
			BL DANSE
			B fin

WAIT	LDR r1, =0x002FFFFF 						 
wait1	SUBS r1, #1
        BNE wait1
		BX LR

; Fin du programme
fin
; Initialisation de la séquence des LEDS (0 : LED gauche, 1 : LED droite)
	AREA constants, DATA, READONLY
SEQUENCE DCB 1,0,0,1,0


	END
	
	
	
	
	
	
	
	
	
	
	
	
	
	
