	;; RK - Evalbot (Cortex M3 de Texas Instrument)
; programme - Jeu de mémorisation reprenant le jeu SimonSays en ASM
; par Safi HANIFA et Yanis AIT TAOUIT



		AREA    |.text|, CODE, READONLY
		ENTRY
		EXPORT	DANSE
		;EXPORT WAIT
		
		; IMPORT 
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; déactiver le moteur droit
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arrière
		
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; déactiver le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant
			
; Durée danse
DUREE		EQU		0x20FFFFD
	
; ----------------------------------------------------------------------------------


DANSE
		MOV r2,	#0
		MOV r3, #500
		; Configure les PWM + GPIO
		BL	MOTEUR_INIT	   		   
		
		; Activer les deux moteurs droit et gauche
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
		
		; Rotation à droite de l'Evalbot
		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_AVANT
		BL WAIT
		
		
; Boucle Attente
WAIT	LDR r1,=DUREE 
wait1	SUBS r1, #1
        BNE wait1
; Arret des moteurs
		BL MOTEUR_DROIT_OFF
		BL MOTEUR_GAUCHE_OFF
		
		BX LR	

		END
		
		
		
		
		
		
		
		
		
		
		