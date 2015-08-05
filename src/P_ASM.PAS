DATA     SEGMENT WORD PUBLIC
	 ASSUME DS:DATA

;------------------------------;Interne Variablen;

o        dd 320 dup (0)
u        dd 320 dup (64000)
of       dd 0
H        DD 0                  ;Zwischenspeicher fr Vektoren
W1       DD 0                  ;1.Teil des X-Vektors (x-Teil)
W2       DD 0                  ;2.Teil des X-Vektors (y-Teil)
F        DD 0                  ;1.Teil des Y-Vektors (x-Teil)
G        DD 0                  ;2.Teil des Y-Vektors (y-Teil)
SEGADD   DD 0                  ;Lineare Adr. des Datensegmets
P        DW 0                  ;Zwischenspeicher fr das SP-Reg
UP       DW 640 DUP (0)        ;Obere  Offsetmap
DN       DW 640 DUP (0)        ;Untere Offsetmap
XV       DD 0                  ;Zwischenspeicher fr die X-Koord.
YV       DD 0                  ;Zwischenspeicher fr die Y-Koord.
XXADD    DD 0                  ;Additionswert i X-Richtung
YYADD    DD 0                  ;Additionswert i Y-Richtung
XN       DD 0                  ;2.Zwischenspeicher fr die X-Koord.
YN       DD 0                  ;2.Zwischenspeicher fr die Y-Koord.
XT       Dw 0                  ;2.Zwischenspeicher fr die X-Koord.
YT       Dw 0                  ;2.Zwischenspeicher fr die Y-Koord.
XSS      DW 0
YSS      DW 0
YS       DW 0                  ;1.Teil des Y-Werts des Beobachters

;------------------------------;Externe Variablen;


	 EXTRN SOCK  :WORD
	 EXTRN xsp   :DWORD
	 EXTRN ysp   :DWORD
	 EXTRN zsp   :DWORD
	 EXTRN CT    :DWORD
	 EXTRN CT2   :DWORD    ;Variablen fr dir Timerroutine
	 EXTRN CT3   :DWORD
	 EXTRN Y1    :DWORD    ;Sin. vom Winkl / 1.Teil vom Vektor
	 EXTRN Y2    :DWORD    ;Cos. vom Winkl / 2.Teil vom Vektor
	 EXTRN XXX   :DWORD    ;X-Koord. des Beobachters
	 EXTRN YYY   :DWORD    ;Y-Koord. des Beobachters
	 EXTRN SEGM  :WORD     ;64K-Bl”ckchen im unteren Meg(abyte)
	 EXTRN SEGM2 :WORD     ;64K-Bl”ckchen im unteren Meg
	 EXTRN YO    :DWORD    ;2.Teil des Y-Werts des Beobachters
	 EXTRN YO2   :DWORD    ;3.Teil des Y-Werts des Beobachters
	 EXTRN D     :WORD     ;DIV-Tabelle
	 EXTRN D2    :WORD     ;DIV-Tabelle
	 EXTRN COL   :BYTE     ;Farb-Tabelle
	 EXTRN KEYTAB:BYTE     ;Scancode-Tabelle
	 EXTRN END1  :WORD     ;Grenzwerte zwischen den Detail-
	 EXTRN END2  :WORD     ;berg„nngen
	 EXTRN BEG   :WORD     ;Anz. der Z-Zeilen
	 EXTRN T2    :WORD     ;Tabelle fr den Hintergrund
	 EXTRN S2    :BYTE
	 EXTRN S3    :BYTE     ;Sinustabellen fr das Wasser
	 EXTRN S4    :BYTE

	 EXTRN XMS   :DWORD    ;ermittelte Gr”áe des XMS-Speicher
	 EXTRN S     :BYTE     ;Sinustabelle (ohne Vorzeichen )
	 EXTRN T     :BYTE     ;Sinustabelle (mit  Vorzeichen )
	 EXTRN C     :WORD     ;Z„hler
	 EXTRN WINKL :WORD     ;Winkel des Beobachters
	 EXTRN CN2   :WORD     ;weitere Variablen fr dir Timerroutine
	 EXTRN CN3   :WORD
	 EXTRN CN4   :WORD
	 EXTRN CNT   :WORD
	 EXTRN ROT2  :WORD     ;1.Additionswert fr den Winkel
	 EXTRN PICS  :WORD     ;Anz. der Bilder pro Sekunde
	 EXTRN YADD2 :DWORD    ;Additionswert in X fr den Beobachter
	 EXTRN XADD2 :DWORD    ;Additionswert in Y fr den Beobachter
	 EXTRN DTO   :WORD     ;Y-Differenzwert zwischen 2 X/Z-Werte
	 EXTRN YA    :DWORD    ;Y-Varialen des Beobachters
	 EXTRN YY    :DWORD    ;Y-Varialen des Beobachters
	 EXTRN ROT   :DWORD    ;2.Additionswert fr den Winkel
	 EXTRN DOOR  :BYTE     ;Tr-Varialen
	 EXTRN DOOR_OFS:WORD

	 EXTRN ED_MODE:BYTE    ;Editor-Modus (0=Ein/1=Aus)

;------------------------------;NETZTABELLE-----------------


;------------------------------;Speicherorganisation;
			       ;    ( ab 1 Meg )
TEXTURES EQU 600000H           ;dazgeh”riges File:MS.PCX
MULTAB   EQU 500800H           ;wird vom PRG berechnet
Z_BUF    EQU 4C0000H           ;dazgeh”riges File:Blockmap
O_MAP_UP EQU 4A0000H           ;dazgeh”riges File:Blockmap
O_MAP_DN EQU 480000H           ;dazgeh”riges File:Blockmap
COL_TAB  EQU 470000H           ;wird vom PRG berechnet
DOOR_MAP EQU 460000H           ;dazgeh”riges File:Blockmap
Sprites  EQU 400000H           ;Sprites
WAV      EQU 200000H           ;dazgeh”riges File:MUSIC.WAV


DATA     ENDS

;------------------------------;
;------------------------------;
;------------------------------;

CODE     SEGMENT BYTE PUBLIC
	 ASSUME CS:CODE,DS:DATA
.486P


;------------------------------;
;---------  SPRITE  -----------;
;------------------------------;


set_o1:
	 push bx
	 push di
	 push eax
	 push ecx

	 mov bx,0
	 mov di,0
    c_sp1:
	 movzx eax,up[bx]
	 movzx ecx,dn[bx]

	 mov o[di],eax
	 mov u[di],ecx
	 add di,4
	 mov o[di],eax
	 mov u[di],ecx
	 add di,4
	 mov o[di],eax
	 mov u[di],ecx
	 add di,4
	 mov o[di],eax
	 mov u[di],ecx
	 add di,4

	 inc bx
	 inc bx
	 cmp di,320*4
	 jne c_sp1

	 pop ecx
	 pop eax
	 pop di
	 pop bx
	 ret

;------------------------------;
set_o2:
	 push bx
	 push di
	 push eax
	 push ecx
	 mov bx,0
	 mov di,0
    c_sp2:

	 movzx eax,up[bx]
	 movzx ecx,dn[bx]

	 mov o[di],eax
	 mov u[di],ecx
	 add di,4
	 mov o[di],eax
	 mov u[di],ecx
	 add di,4

	 inc bx
	 inc bx
	 cmp di,320*4
	 jne c_sp2
	 pop ecx
	 pop eax
	 pop di
	 pop bx
	 ret

;------------------------------;
set_o3:
	 push bx
	 push di
	 push eax
	 push ecx

	 mov bx,0
	 mov di,0
    c_sp3:
	 movzx eax,up[bx]
	 mov o[di],eax
	 movzx eax,dn[bx]
	 mov u[di],eax
	 add di,4

	 inc bx
	 inc bx
	 cmp di,320*4
	 jne c_sp3
	 pop ecx
	 pop eax
	 pop di
	 pop bx
	 ret

;------------------------------;

SPR      PROC NEAR
	 PUBLIC SPR

	 pusha
	 push es
	 push bp

	 mov es,segm
	 mov ds,cs:dat

	 mov ebx,Zsp
	 cmp ebx,3
	 jl wsp0


; shl ebx,1
	 mov eax,Xsp
;	 shl eax,8
; sar eax,1
	 cdq
	 idiv ebx
	 add eax,160
	 mov xss,ax

       jl wsp0

	 mov eax,Ysp
;	 shl eax,8
	 cdq
	 idiv ebx
	 add eax,120
	 mov yss,ax

       jl wsp0

	 lea eax,[eax*4+eax]
	 shl eax,6

	 mov of,eax
	 movsx eax,xss
	 add of,eax

	 mov bp,word ptr zsp
   sar bp,1
	 mov xt,0
	 xor ebx,ebx
xx_sp:
	 cmp xss,319
	 ja  xxx_s

	 mov dx,0
	 mov edi,of
	 mov si,xss
	 shl si,2
	 mov bl,byte ptr xt+1
	 mov ecx,o[si]
	 mov esi,u[si]
yy_sp:
	 cmp edi,ecx
	 jl  xxx_s
	 cmp edi,esi
	 jg  xspw

	 mov bh,dh
	 mov al,ds:Sprites[ebx]
SP_O:Test al,al
     jz xxx_s
     mov es:[di],al
     xxx_s:
	 add edi,320
	 add dx,bp
	 test dh,40h
	 jz yy_sp
xspw:
	 inc of
	 inc xss
	 add  xt,bp
	 test xt+1,40h
	 jz  xx_sp

wsp0:
	 pop bp
	 pop es
	 popa

	 ret

SPR      ENDP




;------------------------------;
;------------------------------;







;------------------------------;
;------------------------------;
;------------------------------;
;----=>  Haupt-Prozedur <=-----;
;------------------------------;
;------------------------------;
;------------------------------;

SHOW     PROC NEAR
	 PUBLIC SHOW

	 PUSH DS                                ;FS=DS
	 POP FS
	 XOR AX,AX                              ;GS=0
	 MOV GS,AX                              ;( als 4GB Segment )



;------------------------------;

	 test c,12                   ;Kleiner Effekt (Flackerlicht)
	 jnz flacker
	 xor dword ptr gs:z_buf[62473*4],4000h;immer 2 Bl”ckchen vertauschen
flacker:

;------------------------------;
;----=>  Door open/close <=----;
;------------------------------;


	 XOR BX,BX
	 XOR DI,DI
DOOR1:
	 MOVZX SI,BYTE PTR DOOR[BX]             ;Tr zu ?
	 OR  SI,SI
	 JZ  DOOR2                              ;ja ? ,dann weiter
	 SHR SI,1
	 MOVZX AX,BYTE PTR S[SI+64]
	 SHR AL,1                               ;Tr-Offset berechnen
	 NEG AX                                 ;( mit der Sin-Tab )
	 SUB AX,14
	 MOVZX ESI,WORD PTR DOOR_OFS[DI]
	 ADD AX,GS:O_MAP_DN[ESI*2]
	 MOV WORD PTR  GS:O_MAP_UP[ESI*2],AX
	 INC BYTE PTR DOOR[BX]                  ;solang weiter bis die
						;Tr wieder zu ist
DOOR2:   INC DI
	 INC DI
	 INC BL                                 ;alle Tren prfen (255max.)
	 JNZ DOOR1

;------------------------------;

	 CMP KEYTAB[57],0                       ;SPACE gedrckt ?
	 JNE DOOR5                              ;wenn nicht,dann weiter

	 MOV ESI,XADD2
	 MOV EDI,YADD2
	 SHL ESI,1
	 SHL EDI,1
	 MOV EAX,XXX
	 ADD EAX,ESI                            ;Steht man vor einer Tr ?
	 MOV XN,EAX
	 MOV EBX,YYY
	 ADD EBX,EDI
	 BSWAP EBX
	 MOV BL,BYTE PTR XN+2
	 MOVZX EBX,BX

	 CMP BYTE PTR GS:DOOR_MAP[EBX],1
	 JNE DOOR5                              ;wenn nicht,dann weiter

	 MOV SI,510
DOOR3:
	 CMP DOOR_OFS[SI],BX
	 JE  DOOR4
	 DEC SI                                 ;Tr suchen,vor der man steht
	 DEC SI
	 JNZ DOOR3
DOOR4:
	 SHR SI,1
	 CMP DOOR[SI],0                         ;... und aktivieren
	 JNZ DOOR5
	 INC BYTE PTR DOOR[SI]

DOOR5:


;------------------------------;
;----=>    Herumlaufen   <=----;
;------------------------------;


	 MOVZX  BX,BYTE PTR WINKL
	 MOVSX EAX,BYTE PTR T[BX]
	 MOV    Y1,EAX                          ;Y1=Sin vom Winkl
	 ADD    BL,64                           ;( 1.Vektor )
	 MOVSX EAX,BYTE PTR T[BX]
	 MOV    Y2,EAX                          ;Y2=Cos vom Winkl
						;( 2.Vektor )
	 MOV XXADD,0                            ; Add-Wert in X-Richtung = 0
	 MOV YYADD,0                            ;Add-Wert in Y-Richtung = 0
	 MOV   ROT,0                            ;Add-Wert vom Winkl     = 0
	 MOV   ECX,1

	 MOV EBX,Y1
	 MOV EDX,Y2
	 LEA EBX,[EBX+EBX*2]
	 LEA EDX,[EDX+EDX*2]
	 SHL EBX,1                              ;Y1=Y1*6
	 SHL EDX,1                              ;Y2=Y2*6

	 CMP KEYTAB[54],0
	 JNE KEY1                               ;wenn Shift gedrckt ist,
	 SHL EBX,1                              ;dann rennen
	 SHL EDX,1
	 INC CX
KEY1:
	 CMP KEYTAB[56],0                       ;Strafe ON ? (Alt-Taste)
	 JNE KEY2                               ;wenn nicht,dann zu Key2

	 CMP KEYTAB[75],0
	 JNE KEY3
	 ADD XXADD,EDX
	 ADD YYADD,EBX                          ;ansonsten nach rechts
   KEY3: CMP KEYTAB[77],0                       ;bzw. links laufen
	 JNE KEY4
	 SUB XXADD,EDX
	 SUB YYADD,EBX
   KEY4: JMP KEY6

KEY2:
	 CMP KEYTAB[75],0
	 JNE KEY5
	 ADD ROT,ECX                            ;rechts bzw links drehen
   KEY5: CMP KEYTAB[77],0
	 JNE KEY6
	 SUB ROT,ECX
   KEY6:

	 CMP KEYTAB[72],0
	 JNE KEY7
	 ADD XXADD,EBX
	 SUB YYADD,EDX                          ;vor- bzw rckw„rts laufen
   KEY7: CMP KEYTAB[80],0
	 JNE KEY8
	 SUB XXADD,EBX
	 ADD YYADD,EDX
   KEY8:

	 MOV EAX,XXADD                          ;Add-Werte fr die Timer-
	 MOV XADD2,EAX                          ;routine setzen
	 MOV EAX,YYADD
	 MOV YADD2,EAX
	 MOV EAX,ROT
	 MOV ROT2,AX


;------------------------------;
;----=>   Hintergrund    <=----;
;------------------------------;


	 MOVZX DX,BYTE PTR WINKL
	 NEG DL

	 MOV BX,DX                              ;Winkel*2.5 um
	 SHL DX,1                               ;256 auf 640ø umzurechenen
	 SHR BX,1                               ;(640 Pixel = Breite des
	 ADD DX,BX                              ; Hintergrundbilds)

	 PUSH DS
	 MOV AX,SEGM
	 ADD AX,20*27+200
	 MOV ES,AX                              ;Segmente sichern & setzen
	 MOV AX,FS:SEGM2
	 ADD AX,20*27*4
	 MOV DS,AX
	 CLD
	 MOV BP,AX
	 BSWAP EBP
	 MOV BP,ES
	 MOV BX,0

	 MOV CX,1280

X_BG:    MOV SI,BX
	 SHL SI,1
	 MOV SI,FS:T2[SI]                       ;X-Wert aus der Tabelle
	 ADD SI,DX
	 ADD SI,64000                           ;Start-Offsets berechnen
	 MOV DI,BX
	 ADD DI,16000

	 PUSH SI
	 PUSH BX
	 MOV BX,320
	 STC
 Y_BG1:  MOV AL,[SI]                            ;1. Teil des Hintergrundbilds
	 MOV ES:[DI],AL
	 SUB SI,CX
	 SBB DI,BX                              ;Vertikale Linie zeichnen
	 JNC Y_BG1
	 POP BX
	 POP SI

	 MOV DI,BX
	 ADD DI,9*320
	 ADD SI,9*320*4-64000
	 BSWAP EBP
	 MOV AX,BP
	 ADD AX,4000
	 MOV DS,AX
	 BSWAP EBP
	 MOV AX,BP
	 ADD AX,1000
	 MOV ES,AX
	 STC
	 PUSH BX
	 MOV BX,320                             ;1. Teil des Hintergrundbilds
 Y_BG2:
	 MOV AL,[SI]
	 MOV ES:[DI],AL
	 SUB SI,CX                              ;Vertikale Linie zeichnen
	 SBB DI,BX
	 JNC Y_BG2
	 POP BX

	 MOV ES,BP
	 BSWAP EBP
	 MOV DS,BP
	 BSWAP EBP
	 INC BX
	 CMP BX,320                              ;schon 320 Linien ?
	 JNE X_BG                                ;wenn nicht,dann zurck




	 MOV DS,FS:SEGM2                         ;Segmente setzen
	 MOV ES,FS:SEGM

	 XOR EAX,EAX                             ;1.& 2. Zeile schhwarz
	 XOR DI,DI
	 MOV CX,160
	 REP STOSD

	 MOV DX,35
	 XOR SI,SI
	 MOV DI,640
 R_BARS: MOV EAX,2020202H
	 CMP DX,25                               ;Zeile 3-13 blau
	 JAE WR
	 MOV EAX,[SI]                            ;restliche Farben
	 ADD SI,1280-4                           ;aus dem Bild
	 LODSD
 WR:     MOV CX,80                               ;Zeile fllen
	 REP STOSD
	 DEC DX
	 JNE R_BARS

	 XOR EAX,EAX
	 MOV DI,320*96
	 MOV CX,80*104                           ;untere Bilschirmh„lfte
	 REP STOSD                               ;schwarz fllen
	 POP DS


;------------------------------;
;------------------------------;
;----=>   Hauptroutine   <=----;
;------------------------------;
;----=>   Voxel-Engine   <=----;
;------------------------------;
;------------------------------;


	 PUSH EBP
	 CLD
	 XOR EDI,EDI
	 MOV AX,320
	 MOV CX,320
    UPL: MOV UP[DI],AX                           ;obere Screen Offsets
	 ADD DI,2
	 LOOP UPL

	 XOR DI,DI
	 MOV AX,64000-640
	 MOV CX,320
    DNL: MOV DN[DI],AX
	 ADD DI,2                                ;untere Screen Offsets
	 LOOP DNL
	 MOV ES,SEGM
	 XOR EBX,EBX
	 XOR EBP,EBP

	 PUSH BEG
	 POP  YS
;------------------------------;
ZZ0:;   -LOW-DETAIL-                              ;-=> 1. Z-Schleife <=-
;------------------------------;
      MOV BX,YS
      MOVZX EAX,BX
      SHL EAX,12
      ADD EAX,MULTAB
      SUB EAX,SEGADD                              ;Z-Offset fr jede Zeile
      MOV ECX,YO                                  ;neu in Code patchen
      SHL ECX,2
      ADD ECX,EAX
      MOV DWORD PTR CS:OFS2-4,ECX
      MOV DWORD PTR CS:OFS6-4,ECX

	 MOV SI,158                               ;Wert fr die Screen Offs.

	 MOV AL,COL[BX]
	 MOV BYTE PTR CS:YSO1-1,AL                ;Farbwert aus der Col-Tab
	 MOV BYTE PTR CS:YSO2-1,AL                ;(abh„ngig von der Y-Koord.)
						  ;in den Code patchen
	 SHL BX,1
	 MOVZX EBX,D2[BX]
	 SHL BX,1
	 MOVZX EAX,D[BX]  ;  H =-Y2/ Z

mov edx,dword ptr zsp
;:shl edx,1
cmp ax,dx
ja  sspp1
cmp D[BX-2],dx
jb  sspp1
call set_o1
sspp1:

	 IMUL Y2          ;  W1=-Y2/(Z*32)
	 MOV H,EAX                                ;1.Richtungsvektor
	 NEG H                                    ;berechnen (W1)
	 SAR EAX,5        ;  G = Y1/ Z
	 MOV W1,EAX       ;  W2= Y1/(Z*32)
	 CLI                                      ;IRQ's sperren
	 MOV P,SP                                 ;SP sichern,da zu
						  ;wenig Register da sind
	 MOV ESP,EAX                              ;ESP=W1=1.Vektor
	 MOVZX EAX,D[BX]
	 IMUL Y1                                  ;2.Richtungsvektor
	 MOV G,EAX                                ;berechnen (W2)
	 SAR EAX,5
	 MOV W2,EAX
	 MOV DWORD PTR CS:W2OF-4,EAX              ;W2 in Code patchen

	 IMUL EAX,W1,40                           ;Startwert in die Mitte
	 NEG EAX          ;  G=G+XXX-40*W1        ;versch.
	 ADD EAX,XXX      ;  H=H+YYY-40*W2        ;X-Koordinate dazu
	 ADD G,EAX
	 IMUL EAX,W2,40                           ;Startwert in die Mitte
	 NEG EAX                                  ;versch.
	 ADD EAX,YYY                              ;Y-Koordinate dazu
         ADD EAX,H
         MOV F,EAX
	 XOR EAX,EAX
	 XOR EDX,EDX

;------------------------------;
XX:                                               ;-=> 1. X-Schleife <=-
;------------------------------;
	 MOV DX,DN[SI]
	 MOV BP,UP[SI]                            ;šberschneiden sich
	 CMP DX,BP                                ;die Offsets ?
	 JBE WWX                                  ;wenn nicht,dann weiter

	 MOV  AX,  WORD PTR DS:F+1
	 AND  AL,0FCH                             ;beide Richtungs-
	 MOVZX EBX,WORD PTR DS:G+1                ;vektoren laden
	 XCHG BH,AL
	 SHR EBX,2
	 OR  EBX,DS:Z_BUF[EAX*4]                  ;Offs.vom Bl”ckchen
OFS0:    LEA ECX,DS:O_MAP_DN[EAX*2]

OFS3:    MOVZX AX,BYTE PTR DS:TEXTURES[EBX+128]   ;unterer H”henwert
OFS1:    ADD AX,DS:[ECX]                          ;mit Y-Offset verrechnen
	 MOV EDI,DS:MULTAB[EAX*4]                 ;Wert aus der Mul-Tabelle
OFS2:    CMP EDI,EDX
	 JGE WW                                   ;Linie zeichnen ?
	 CMP EDI,EBP                              ;wenn nicht,dann weiter
	 JGE WW3
	 MOV DI,BP
    WW3: MOV DN[SI],DI                            ;Off-Tab updaten
	 ADD DI,SI
	 MOV AL,DS:TEXTURES[EBX];GS:[BX]          ;untere Textur laden
OF0:
	 MOV AH,123                               ;Helligkeit (wird in Code)
YSO1:                                             ;           (gepatcht    )
	 ADD DI,SI
	 MOV AL,BYTE PTR DS:COL_TAB[EAX]          ;Wert aus der Farbtabelle
OFS4:    MOV AH,AL
YYYYY:   STOSW                                    ;4 Pixel-Linie ziehen
	 STOSW
	 ADD DI,316
	 CMP DI,DX
	 JB  YYYYY
WW:      MOVZX AX,BYTE PTR DS:TEXTURES[EBX+192]   ;oberer H”henwert
OFS5:    ADD AX,DS:[ECX+20000H]                   ;Y-Offset oben
	 MOV EDI,DS:MULTAB[EAX*4]                 ;Wert auus der Mul-Tab
OFS6:    CMP EDI,EBP
	 JLE WWX                                  ;Linie zeichnen ?
	 CMP EDI,EDX                              ;wenn nicht,dann weiter
	 JLE WW3X
	 MOV DI,DX
    WW3X:MOV DS:UP[SI],DI                         ;Off-Tab updaten
	 MOV AL,DS:TEXTURES[EBX+64]               ;obere Textur laden
OF1:
	 OR AL,AL
	 JZ WWX                                   ;Hintergrund freilassen ?
						  ;wenn ja,dann keine Linie
	 ADD BP,SI
	 MOV AH,123                               ;Helligkeit
YSO2:    MOV AL,DS:COL_TAB[EAX]                   ;Wert aus der Farbtabelle
OFS8:
	 ADD DI,SI
	 ADD DI,SI                                ;Screen-Ofs berechnen
	 MOV AH,AL
    YZX: STOSW                                    ;4 Pixel-Linie ziehen
	 STOSW
	 SUB DI,324
	 CMP DI,BP
	 JA  YZX
WWX:;--------------------------------

	 ADD DWORD PTR G,ESP                      ;Add fr 1.Vektor
W1OF:    ADD DWORD PTR F,12345H                   ;Add fr 2.Vektor(gepatcht)
W2OF:    SUB SI,2                                 ;N„chste X-Koord.
	 JNS XX
;------------------------------------
	 MOV SP,P                                 ;SP wieder zurckschreiben
	 STI                                      ;IRQ's wieder zulassen
	 MOV AX,END1                              ;Low-Detail fertig ?
	 DEC YS
	 CMP YS,AX                                ;wenn nicht,dann von vorne
	 JNZ ZZ0
EN:
      MOV DI,158
      MOV SI,318
      MOV CX,80
CON1: MOV AX,DN[DI]
      MOV BX,UP[DI]
      DEC DI
      DEC DI
      MOV DN[SI],AX                               ;Screen-Ofs auf
      MOV UP[SI],BX                               ;160 Spalten umrechnen
      DEC SI
      DEC SI
      MOV DN[SI],AX
      MOV UP[SI],BX
      DEC SI
      DEC SI
      LOOP CON1

;------------------------------;
ZZ2:; -MIDDLE-DETAIL-                             ;-=> 2. Z-Schleife <=-
;------------------------------;
      MOV BX,YS
      MOVZX EAX,BX
      SHL EAX,12
      ADD EAX,MULTAB                              ;Fast gleich wie
      SUB EAX,SEGADD                              ;die Low Detail Routine,
      MOV ECX,YO                                  ;deswegen wird hier
      SHL ECX,2                                   ;fast nichts mehr
      ADD ECX,EAX                                 ;dokumentiert
      MOV DWORD PTR CS:OFS22-4,ECX
      MOV DWORD PTR CS:OFS62-4,ECX
	 MOV SI,318
	 MOV AL,COL[BX]
	 MOV BYTE PTR CS:YSO12-1,AL
	 MOV BYTE PTR CS:YSO22-1,AL
	 SHL BX,1
	 MOVZX EBX,D2[BX]
	 SHL BX,1
	 MOVZX EAX,D[BX]


mov edx,dword ptr zsp
;shl edx,1
cmp eax,edx
ja  sspp2
cmp D[BX-2],dx
jb  sspp2
call set_o2
sspp2:



	 IMUL Y2
	 MOV H,EAX
	 NEG H
	 SAR EAX,6
	 MOV W1,EAX
	 CLI
	 MOV P,SP
	 MOV ESP,EAX
	 MOVZX EAX,D[BX]
	 IMUL Y1
	 MOV G,EAX
	 SAR EAX,6
	 MOV W2,EAX
	 MOV DWORD PTR CS:W2OF2-4,EAX
	 IMUL EAX,W1,80
	 NEG EAX
	 ADD EAX,XXX
	 ADD G,EAX
	 IMUL EAX,W2,80
	 NEG EAX
	 ADD EAX,YYY
	 ADD EAX,H
	 MOV F,EAX
	 XOR EAX,EAX
	 XOR EDX,EDX
;------------------------------;
XX2:                                              ;-=> 2. X-Schleife <=-
;------------------------------;
	 MOV DX,DN[SI]
         MOV BP,UP[SI]
	 CMP DX,BP
	 JBE WWX2


	  MOV  AX,  WORD PTR DS:F+1
	  AND  AL,0FCH
          MOVZX EBX,WORD PTR DS:G+1
	  XCHG BH,AL
	  SHR EBX,2
	  OR  EBX,DS:Z_BUF[EAX*4]
 OFS02:   LEA ECX,DS:O_MAP_DN[EAX*2]


OFS32:   MOVZX AX,BYTE PTR DS:TEXTURES[EBX+128]
OFS12:   ADD AX,DS:[ECX]
         MOV EDI,DS:MULTAB[EAX*4]
OFS22:   CMP EDI,EDX
	 JGE WW22
	 CMP EDI,EBP
	 JGE WW32
         MOV DI,BP
    WW32:MOV DN[SI],DI
	 ADD DI,SI
	 MOV AL,DS:TEXTURES[EBX]
OF2:
	 MOV AH,123
YSO12:   MOV AL,BYTE PTR DS:COL_TAB[EAX]
OFS42:
	 MOV AH,AL
YXYYY:   MOV ES:[DI],AX
	 ADD DI,320
	 CMP DI,DX
         JB  YXYYY
WW22:    MOVZX AX,BYTE PTR DS:TEXTURES[EBX+192]
OFS52:   ADD AX,DS:[ECX+20000H]
	 MOV EDI,DS:MULTAB[EAX*4]
OFS62:   CMP EDI,EBP
	 JLE WWX2
	 CMP EDI,EDX
	 JLE WW3X2
	 MOV DI,DX
   WW3X2:MOV DS:UP[SI],DI
         MOV AL,DS:TEXTURES[EBX+64]
OF3:
	 OR AL,AL
	 JZ WWX2

	 ADD BP,SI
         MOV AH,123
YSO22:   MOV AL,DS:COL_TAB[EAX]
OFS82:
         ADD DI,SI
	 MOV AH,AL
    YZX2:MOV ES:[DI],AX                           ;2 Pixel breite Linie
	 SUB DI,320                               ;zeichnen
	 CMP DI,BP
	 JA  YZX2
WWX2:;--------------------------
	 ADD DWORD PTR G,ESP
W1OF2:   ADD DWORD PTR F,12345H
W2OF2:   DEC SI
	 DEC SI
	 JNS XX2
;-------------------------------
	 MOV SP,P
         STI
         MOV AX,END2
	 DEC YS
	 CMP YS,AX
	 JNZ ZZ2
EN2:
      MOV DI,318
      MOV SI,638
      MOV CX,160
CON2: MOV AX,DN[DI]
      MOV BX,UP[DI]
      DEC DI
      DEC DI
      MOV DN[SI],AX                               ;Screen-Ofs auf
      MOV UP[SI],BX                               ;320 Spalten umrechnen
      DEC SI                                      ;(Tabelle wird
      DEC SI                                      ; doppelt so groá )
      MOV DN[SI],AX
      MOV UP[SI],BX
      DEC SI
      DEC SI
      LOOP CON2

;------------------------------;
ZZ3:; - HIGH-DETAIL -                              ;-=> 3. Z-Schleife <=-
;------------------------------;
      MOV BX,YS
      MOVZX EAX,BX
      SHL EAX,12
      ADD EAX,MULTAB
      SUB EAX,SEGADD
      MOV ECX,YO
      SHL ECX,2
      ADD ECX,EAX
      MOV DWORD PTR CS:OFS23-4,ECX
      MOV DWORD PTR CS:OFS63-4,ECX
	 MOV SI,638
	 MOV AL,COL[BX]
	 MOV BYTE PTR CS:YSO13-1,AL
	 MOV BYTE PTR CS:YSO23-1,AL
	 SHL BX,1
	 MOVZX EBX,D2[BX]
	 SHL BX,1
	 MOVZX EAX,D[BX]





mov edx,dword ptr zsp
;shl edx,1
cmp eax,edx
ja  sspp3
cmp D[BX-2],dx
jb  sspp3
call set_o3
sspp3:



	 IMUL Y2
	 MOV H,EAX
	 NEG H
	 SAR EAX,7
	 MOV W1,EAX
	 MOV DWORD PTR CS:W1OF3-4,EAX
	 MOVZX EAX,D[BX]
	 IMUL Y1
	 MOV G,EAX
	 SAR EAX,7
	 MOV W2,EAX
	 MOV DWORD PTR CS:W2OF3-4,EAX
	 IMUL EAX,W1,160
	 NEG EAX
	 ADD EAX,XXX
	 ADD G,EAX
	 IMUL EAX,W2,160
	 NEG EAX
	 ADD EAX,YYY
	 ADD EAX,H
	 MOV F,EAX
	 XOR EAX,EAX
	 XOR EDX,EDX
	 CLI
	 MOV P,SP
	 MOV SP,319
;------------------------------;
XX3:                                              ;-=> 3. X-Schleife <=-
;------------------------------;
	 MOV DX,DN[SI]
	 MOV BP,UP[SI]
	 CMP DX,BP
	 JBE WWX3

	  MOV  AX,  WORD PTR DS:F+1
	  AND  AL,0FCH
	  MOVZX EBX,WORD PTR DS:G+1
	  XCHG BH,AL
	  SHR EBX,2
	  OR  EBX,DS:Z_BUF[EAX*4]
 OFS03:   LEA ECX,DS:O_MAP_DN[EAX*2]

OFS33:   MOVZX AX,BYTE PTR DS:TEXTURES[EBX+128]
OFS13:   ADD AX,DS:[ECX]
	 MOV EDI,DS:MULTAB[EAX*4]
OFS23:   CMP EDI,EDX
	 JGE WW23
	 CMP EDI,EBP
	 JGE WW33
	 MOV DI,BP
    WW33:MOV DN[SI],DI
	 ADD DI,SP
	 MOV AL,DS:TEXTURES[EBX]
OF4:
	 MOV AH,123
YSO13:   MOV AL,BYTE PTR DS:COL_TAB[EAX]
OFS43:
Y03:
	 MOV ES:[DI],AL
	 ADD DI,320
	 CMP DI,DX
	 JB  Y03
WW23:    MOVZX AX,BYTE PTR DS:TEXTURES[EBX+192]
OFS53:   ADD AX,DS:[ECX+20000H]
	 MOV EDI,DS:MULTAB[EAX*4]
OFS63:   CMP EDI,EBP
	 JLE WWX3
	 CMP EDI,EDX
	 JLE WW3X3
	 MOV DI,DX
   WW3X3:
	 MOV DS:UP[SI],DI
	 MOV AL,DS:TEXTURES[EBX+64]
OF5:
	 OR AL,AL
	 JZ WWX3

	 MOV AH,123
YSO23:
	 ADD BP,SP
	 MOV AL,DS:COL_TAB[EAX]
OFS83:
	 ADD DI,SP
    YZX3:MOV ES:[DI],AL                           ;1 Pixel breite Linie
	 SUB DI,320                               ;zeichnen
	 CMP DI,BP
	 JA  YZX3
WWX3:;-------------------------------;
	 ADD DWORD PTR G,12345H
W1OF3:   ADD DWORD PTR F,12345H
W2OF3:   DEC SI
	 DEC SI
	 DEC SP
	 JNS XX3
;------------------------------------;
	 MOV SP,P
	 STI
	 DEC YS
	 CMP YS,5
	 JNZ ZZ3
EN3:
	 PUSH DS




;------------------------------------;

			;          ### #### ####
	; mov xsp,0           ;     #    # #  # #
	 mov ysp,-50*128           ;     ###  ###  # #
	; mov zsp,250         ;       #  #    ##
			     ;  ###  #    # #


	  call spr
			;          ### #### ####
;	 mov xsp,0           ;     #    # #  # #
;	 mov ysp,0           ;     ###  ###  # #
;	 mov zsp,-30         ;       #  #    ##
			     ;  ###  #    # #
;	  call spr


;------------------------------------;
;------------------------------------;
;---------- Equalizer ---------------;
;------------------------------------;
;------------------------------------;

	 XOR EBX,EBX
	 IN AL,131
	 MOV BH,AL
	 SHL EBX,8
	 MOV AL,0
	 OUT 12,AL                   ;DMA-Register auslesen,
	 IN AL,2                     ;und ins EBX-Reg. die
	 MOV BL,AL                   ;Lineare Adresse schreiben
	 IN AL,2
	 MOV BH,AL

	 MOV AL,GS:[EBX]
	 MOV AH,GS:[EBX+5]           ;Maximalwert aus mehreren
	 MOV CL,GS:[EBX+10]          ;Adressen. ermitteln,um eine bessere
	 MOV CH,GS:[EBX+15]          ;Anzeige zu erhalten

	 CMP AL,AH
	 JB  V1W
	 MOV AL,AH
V1W:     CMP AL,CL
	 JB  V2W
	 MOV AL,CL
V2W:     CMP AL,CH
	 JB  V3W
	 MOV AL,CH
V3W:
	 NEG AL

	 MOV DI,320*199+4
	 XOR AH,AH                   ;Start-Offset
	 MOV BX,AX
	 XOR EAX,EAX                 ;Startfarbe
VOLUME1:
	 CMP BL,BH                   ;ausgelesener Wert erreicht?
	 JB VOLUME2
	 PUSH DI
	 STOSD
	 STOSD
	 STOSD
	 STOSD                       ;wenn nicht,dann 2 Balken zeichnen
	 ADD DI,320-40               ;(rechts und links)
	 STOSD
	 STOSD
	 STOSD
	 STOSD
	 POP DI
VOLUME2:
	 ADD EAX,01010101H           ;n„chste Farbe

	 SUB DI,640                  ;n„chste Reihe
	 ADD BH,16
	 JNZ VOLUME1


;------------------------------------;
;------------------------------------;
;-----------  WASSER  ---------------;
;------------------------------------;
;------------------------------------;

	 XOR EDX,EDX
	 MOV DH,40H                  ;Y=64
	 MOV SI,WORD PTR C
         SHL SI,1
	 AND SI,255
Y_ANIM:
	 MOV DL,40H                  ;X=64
         XOR BX,BX
         MOV AH,S2[SI]
         MOV DI,WORD PTR C
         SHL DI,1                    ;Plasma auf das
         ADD DI,BX                   ;Wasserbl”ckchen
X_ANIM:                              ;berechnen
	 AND DI,255                  ;(berlagerug von 3 Sinus-)
	 MOV AL,S3[BX]               ;(wellen;X-Richtung,Y-Richtung und)
	 ADD AL,S4[DI]               ;(diagonal)
         ADD AL,AH
	 MOV DS:TEXTURES[80080H+EDX-257],AL ;Werte direkt in die
AN_OF:   ADD DI,4                           ;Bl”ckchenmap schreiben
	 ADD BL,8
	 DEC DL
	 JNZ X_ANIM

	 ADD SI,4
	 AND SI,255
	 DEC DH
	 JNZ Y_ANIM

;------------------------------------;
;------------------------------------;
;-- Copy from Memory to Video-RAM ---;
;------------------------------------;
;------------------------------------;

	 MOV DS,SEGM                 ;Quellsegment
	 MOV AX,0A000H               ;Video-Segment
	 MOV ES,AX
	 XOR SI,SI                   ;Offs. auf 0
	 XOR DI,DI
	 MOV CX,16000
	 CLD
	 REP MOVSD                   ;..und Kopieren

	 POP DS
	 POP EBP

	 CMP KEYTAB[66],0            ;F8 gedrckt ?
	 JNE ED_W1
				     ;wenn ja,dann zwischen
	 XOR ED_MODE,1               ;Edit-Mode und Full-ASSEM.-Mode
	 AND ED_MODE,1               ;hin- und herschalten
   ED_W2:
	 CMP KEYTAB[66],0            ;warten,bis F8 wieder losgelassen
	 JE  ED_W2                   ;wird
ED_W1:
	 CMP KEYTAB[1],0             ;ESC gedrckt ?
	 JZ BACK_TP                  ;wenn ja,dann raus

	 CMP BYTE PTR ED_MODE,0      ;Edit-Mode ? ; wenn nicht,dann
	 JNE SHOW                    ;erneut die Sow Routine aufrufen
BACK_TP:
	 RET                         ;... UND ZURšCK zu TP

SHOW     ENDP






;------------------------------------;
;------------------------------------;
;-- Init-Routine fr den Assm.Teil --;
;------------------------------------;
;------------------------------------;

SHOW_I   PROC NEAR
	 PUBLIC SHOW_I

	 PUSH DS

	; mov xsp,0           ;     #    # #  # #
	; mov ysp,0           ;     ###  ###  # #
	; mov zsp,30         ;       #  #    ##

	 PUSH FS
	 CALL SOUNDBLASTER           ;Soundkarte Initialisieren
	 POP FS
	 POP DS

;------------------------------------;

	 XOR EAX,EAX
	 MOV AX,DS
	 MOV CS:DAT,AX               ;Datensegment jederzeit erreichbar
	 SHL EAX,4                   ;machen
	 MOV SEGADD,EAX

;------------------------------------;

	 SUB DWORD PTR CS:OFS0-4,EAX
	 SUB DWORD PTR CS:OFS1-4,EAX
	 SUB DWORD PTR CS:OFS2-4,EAX
	 SUB DWORD PTR CS:OFS3-4,EAX
	 SUB DWORD PTR CS:OFS4-4,EAX
	 SUB DWORD PTR CS:OFS5-4,EAX
	 SUB DWORD PTR CS:OFS6-4,EAX
	 SUB DWORD PTR CS:OFS8-4,EAX
	 SUB DWORD PTR CS:OFS02-4,EAX
	 SUB DWORD PTR CS:OFS12-4,EAX
	 SUB DWORD PTR CS:OFS22-4,EAX
	 SUB DWORD PTR CS:OFS32-4,EAX
	 SUB DWORD PTR CS:OFS42-4,EAX
	 SUB DWORD PTR CS:OFS52-4,EAX; Alle 32BIT-Offsets im
	 SUB DWORD PTR CS:OFS62-4,EAX; Code zurechtpatchen
	 SUB DWORD PTR CS:OFS82-4,EAX

	 SUB DWORD PTR CS:OFS03-4,EAX
	 SUB DWORD PTR CS:OFS13-4,EAX
	 SUB DWORD PTR CS:OFS23-4,EAX
	 SUB DWORD PTR CS:OFS33-4,EAX
	 SUB DWORD PTR CS:OFS43-4,EAX
	 SUB DWORD PTR CS:OFS53-4,EAX
	 SUB DWORD PTR CS:OFS63-4,EAX
	 SUB DWORD PTR CS:OFS83-4,EAX

	 SUB DWORD PTR CS:OF0  -4,EAX
	 SUB DWORD PTR CS:OF1  -4,EAX
	 SUB DWORD PTR CS:OF2  -4,EAX
	 SUB DWORD PTR CS:OF3  -4,EAX
	 SUB DWORD PTR CS:OF4  -4,EAX
	 SUB DWORD PTR CS:OF5  -4,EAX

	 SUB DWORD PTR CS:AN_OF-4,EAX

	 SUB DWORD PTR CS: SP_O-4,EAX

	 ex:
	 RET

SHOW_I   ENDP


;------------------------------------;
;------------------------------------;
;--- Logoff-Routine fr dir INT's ---;
;------------------------------------;
;------------------------------------;


BACK     PROC NEAR
	 PUBLIC BACK
  CLI
  PUSH DS

XOR AX,AX                            ;Alle Interrupts wieder
    MOV ES,AX                        ;auf die Ursprnglichen
    XOR DI,DI                        ;Werte setzen
    LEA SI,ZAK
    MOV AX,CS
    MOV DS,AX
    MOV CX,256
    REP MOVSD

  POP DS
  STI
  RET

BACK    ENDP


;------------------------------------;
;------------------------------------;
;-------- Keyboard-Abfrage ----------;
;------------------------------------;
;------------------------------------;


KEY      PROC NEAR
	 PUBLIC KEY

	 PUSH DS
         PUSH AX
	 PUSH BX

	 MOV DS,CS:DAT               ;momentanes DS laden
	 IN AL,96                    ;Scanncode lesen
	 MOV BL,AL
	 AND AL,128                  ;Make/Breakcode
	 AND BX,127                    ;Scancode als Offset nehmen,
	 MOV DS:BYTE PTR KEYTAB[BX],AL ;und in die KeyTab schreiben
	 MOV AL,20H
	 OUT 20H,AL                  ;IRQ-Kontroller best„tigen

	 POP BX
	 POP AX
         POP DS

	 IRET

KEY      ENDP


;------------------------------------;
;------------------------------------;
;--------- TIMER + Clipping ---------;
;------------------------------------;
;------------------------------------;


TIMER    PROC NEAR
	 PUBLIC TIMER

	 PUSH EAX
	 PUSH EBX
	 PUSH ECX
	 PUSH EDX
	 PUSH ESI
	 PUSH EDI
	 PUSH DS
	 PUSH GS


	 XOR AX,AX
	 MOV GS,AX

	 MOV AX,CS:DAT
	 MOV DS,AX

	 DEC CN3
	 JNZ NIXSEND
	 mov ax,10
	 MOV CN3,ax

	 call SEND_PACKET
	 NIXSEND:

	 call GET_PACKET

;------------------------------------;
	 INC CN2
	 CMP CN2,100                 ;schon 100mal den Timer
	 JNE TM                      ;aufgerufen ?
	 MOV AX,CNT
	 MOV PICS,AX                 ;wenn ja,dann die Anz. der
	 XOR AX,AX                   ;Bilder pro Sekunde lesen
	 MOV CN2,AX
	 MOV CNT,AX
TM:
;------------------------------------;

	 INC C                       ;Allgemeiner Z„hler

;------------------------------------;

	 MOV EAX,XXX
	 MOV XV,EAX
	 MOV EAX,YYY
	 MOV YV,EAX                  ;X zwischenspeicheren
	 MOV EAX,XADD2
	 ADD XXX,EAX
	 MOV EAX,YADD2               ;X zwischenspeicheren
	 ADD YYY,EAX
	 MOV AX,ROT2
	 ADD WINKL,AX                ;Beobachter weiterdrehen

;------------------------------------;

	 CMP BYTE PTR ED_MODE,0      ;Edit-Mode ? ; wenn ja,dann
	 JE  OS4                     ;das Clipping berspringen

;------------------------------------;
;------------- Clipping -------------;
;------------------------------------;

         MOV ESI,XADD2
	 MOV EDI,YADD2
	 SHL ESI,3
	 SHL EDI,3

;---------Geradeaus-CLipping---------;

	 MOV EAX,XXX
	 ADD EAX,ESI
         MOV XN,EAX
	 MOV EAX,YYY
         ADD EAX,EDI
	 MOV YN,EAX                  ;H”henkoordinate in Laufrichtung
	 CALL GET_Z                  ;auslesen
	 PUSH DX                     ;H”henkoordinate zwischenspeichern
         CMP BX,45                   ;kleiner als man selbst ?
         JG  OS1
	 PUSH XV
	 POP  XXX                    ;wenn ja,dann stehenbleiben
	 PUSH YV
	 POP  YYY
OS1:
;------------------------------------;
         MOV EAX,XXX
         MOV XN,EAX
	 MOV EAX,YYY
         MOV YN,EAX                  ;momentane H”henkoordinate
	 CALL GET_Z                  ;auslesen
	 POP AX                      ;und mit der H”henkoordinate in
         SUB DX,AX                   ;Laufrichtung vergleichen
         CMP DX,30                   ;differenz>30 (Stufe) ?
	 JL  OS11
	 PUSH XV
	 POP  XXX                    ;wenn ja,dannn stehenbleiben
	 PUSH YV
         POP  YYY
OS11:
;---------Rechts-Clipping------------;

	 MOV EAX,XXX
	 ADD EAX,ESI
	 ADD EAX,EDI
         MOV XN,EAX
         MOV EAX,YYY
	 ADD EAX,EDI                 ;rechte H”henkoordinate
         SUB EAX,ESI                 ;auslesen
	 MOV YN,EAX
	 CALL GET_Z
         CMP BX,45                   ; >45 ? ; wenn nicht,dann
	 JL  OS2
	 MOV EAX,YADD2               ;nach rechts laufen
         ADD XXX,EAX
	 MOV EAX,XADD2
	 SUB YYY,EAX
OS2:
	 PUSH DX                     ;H”henkoordinate zwischenspeichern
;------------------------------------;
	 MOV EAX,XXX
	 ADD EAX,ESI
	 MOV XN,EAX
	 MOV EAX,YYY
         ADD EAX,EDI
	 MOV YN,EAX
	 CALL GET_Z
	 POP AX                      ;ist rechts eine Stufe
	 SUB DX,AX                   ;oder Wand ? (H”hendifferenz >30 ?)
	 CMP DX,30
         JG  OS21
         MOV EAX,YADD2
	 ADD XXX,EAX                 ;wenn nicht,dann nach rechts laufen
	 MOV EAX,XADD2
         SUB YYY,EAX
OS21:
;---------Links-Clipping-------------;

         MOV EAX,XXX
	 ADD EAX,ESI
	 SUB EAX,EDI
	 MOV XN,EAX
	 MOV EAX,YYY
         ADD EAX,EDI
	 ADD EAX,ESI                 ;geprft wird
	 MOV YN,EAX                  ;Genau gleich wie Rechts-Clipping,
	 CALL GET_Z                  ;nur daá die andere Richtung
	 CMP BX,45
	 JL  OS3
	 MOV EAX,YADD2
         SUB XXX,EAX
         MOV EAX,XADD2
	 ADD YYY,EAX
OS3:
         PUSH DX
;------------------------------------;
         MOV EAX,XXX
	 ADD EAX,ESI
         MOV XN,EAX
         MOV EAX,YYY
	 ADD EAX,EDI
	 MOV YN,EAX
         CALL GET_Z
	 POP AX
         SUB DX,AX
	 CMP DX,30
	 JG  OS31
	 MOV EAX,YADD2
         SUB XXX,EAX
         MOV EAX,XADD2
	 ADD YYY,EAX
OS31:
;------------------------------------;
	 CMP SI,5
	 jne OS4

	 MOV EAX,YADD2
         MOV EBX,XADD2
	 SAR EAX,1
         SAR EBX,1

	 MOV EAX,YADD2               ;nach rechts laufen
         ADD XXX,EAX
         MOV EAX,XADD2
	 SUB YYY,EBX
	 MOV EAX,YADD2
	 SUB XXX,EAX
	 MOV EAX,XADD2
	 ADD YYY,EBX

OS4:

;------------------------------;
;----=>    Runterfallen  <=----;
;------------------------------;


	 MOVZX BX,BYTE PTR C
         SHL   BL,1
         MOVZX EAX,BYTE PTR S[BX]
	 SHR   AL,5                             ;Sinus-Schwanken
         SUB   EAX,YO2                          ;Y-Offset vom
	 SUB   EAX,YY                           ;Spieler
         MOV   YO,EAX



         MOV EAX,XXX
	 MOV XN,EAX
	 MOV EAX,YYY
	 MOV YN,EAX
	 CALL GET_Z                             ;momentane Boden-H”hen
	 MOV AX,DX
         SUB AX,WORD PTR YO2                    ;mit eigener H”he verrechnen
         MOV DTO,AX

	 CMP DX,WORD PTR YO2                    ;schon auf dem Boden ?
     JL  FALL
	 MOVZX EAX,WORD PTR YA
	 SHR AX,4
	 ADD YO2,EAX                            ;.. wenn nicht,dann nach unten
         INC YA                                 ;   beschleunigen
     JMP FALL2

FALL :   ADD EDX,3
	 MOVSX EDX,DX
	 MOV  YO2,EDX
         MOV YA,0
FALL2:


;------------------------------;

         POP GS
	 POP DS
         POP EDI
	 POP ESI
	 POP EDX
	 POP ECX
	 POP EBX
         MOV AL,20H                  ;IRQ-Controller noch best„tigen
         OUT 20H,AL
	 POP EAX
         IRET

TIMER    ENDP

;------------------------------------;

GET_Z:
	 MOVZX EBX,BYTE PTR XN+2
	 MOV    BH,BYTE PTR YN+2
	 MOVZX EAX,BYTE PTR XN+1     ;H”henkoordinate fr gegebenes
	 MOV AH   ,BYTE PTR YN+1     ;XN,YN ermitteln
         SHR AX,2                    ;obere   16 Bits fr das Bl”ckchen,
	 AND AX,3F3FH                ;Bits    10-15 als Offset im Bl”ckchen
	 OR  EAX,GS:Z_BUF[EBX*4]     ;und Bits 0-9 als Nachkommastellen

         MOVZX DX,BYTE PTR GS:[128+TEXTURES+EAX]
         ADD   DX,GS:O_MAP_DN[EBX*2]
	 MOVZX CX,BYTE PTR GS:[192+TEXTURES+EAX]
	 ADD   CX,GS:O_MAP_UP[EBX*2]
	 ADD   CX,DTO                ;Offset des Beobachters

	 MOV BX,DX
         SUB BX,CX

         RET
;------------------------------------;

DAT      DW 0                        ;Datesegment des Pascal und ASSM.Teil

;====== SOUNDBLASTER DETECTION ==========================
;----------------------------- DSP WAIT FOR READ --------
WW_DSP:
   PUSH ECX
   MOV ECX,0FFFFFFH   ; TIMEOUT-WERT.
   MOV DX,DS:SBPORT
   ADD DX,0CH
  @1:
   IN AL,DX
   DEC ECX
   JZ RAUS2
   AND AL,80H
   JNZ @1
RAUS2:
   POP ECX
RET
;--------------------------------------------------------
SOUNDBLASTER:         ; PORT DETECT 220H,240H,260H,280H

   PUSH CS
   POP DS

   STI

   MOV DX,226H
LOOPS1:
   MOV AL,1           ; 1 ZUM RESET PORT SCHREIBEN.
   OUT DX,AL          ; SCHREIBE NACH 2X6H.
   XOR AL,AL          ; 0 ZUM RESET PORT SCHREIBEN.
   OUT DX,AL          ; SCHREIBE NACH 2X6H.

   ADD DX,8           ; WARTEN AUF LESEOK.
   MOV ECX,0FFFFFFH   ; TIMEOUT-WERT.
WAIT_40:
   IN AL,DX           ; LESE VON 2XEH
   DEC ECX
   JZ TIMEOUT
   AND AL,80H
   JZ WAIT_40

   SUB DX,4
   IN AL,DX           ; LESE VON 2XAH
   SUB DX,4
   CMP AL,0AAH        ; SOUNDBLASTER INIT CODE ? (0AAH)
   JE GOT_THE_SB      ; SOUNDBLASTER GEFUNDEN !
TIMEOUT:
   ADD DX,20H         ; SOUNDBLASTER DETECTION VON 220H BIS 280H IN 20H STEPZ
   CMP DX,306H
   JNE LOOPS1
   SUB DX,20H

   LEA DX,SB1         ;( KEIN SOUNDBLASTER GEFUNDEN.
   MOV AH,9
   INT 21H
   JMP END_SB

GOT_THE_SB:           ;) SOUNDBLASTER GEFUNDEN.
   SUB DX,6
   MOV DS:SBPORT,DX   ;  PORT IN VARIABLE SCHREIBEN.

   CALL WW_DSP        ;  LAUTSPRECHER AUS.
   MOV AL,0D3H
   OUT DX,AL          ;  SCHREIBE NACH 2XCH.

   ;----------------------------------------------------------------------
    CALL DA         ; DMA DETECT
   ;-------------- DEN TEXT AUF DEN BILDSCHIRM AUSGEBEN -(PORT+DMA+IRQ)---
    LEA DX,SB2
    MOV AH,9
    INT 21H

    MOV AH,9
    CMP WORD PTR DS:SBPORT,220H
    JNE @W1
    LEA DX,SB21
  @W1:
    CMP WORD PTR DS:SBPORT,240H
    JNE @W2
    LEA DX,SB22
  @W2:
    CMP WORD PTR DS:SBPORT,260H
    JNE @W3
    LEA DX,SB23
  @W3:
    CMP WORD PTR DS:SBPORT,280H
    JNE @W4
    LEA DX,SB24
  @W4:
    INT 21H           ; TEXT AUF DEN BILDSCHIRM.

    MOV AH,9
    CMP BYTE PTR DS:SBDMA,1
    JNE @W11
    LEA DX,SB25
  @W11:
    CMP BYTE PTR DS:SBDMA,2
    JNE @W22
    LEA DX,SB26
  @W22:
    CMP BYTE PTR DS:SBDMA,4
    JNE @W33
    LEA DX,SB27
  @W33:
    CMP BYTE PTR DS:SBDMA,8
    JNE @W44
    LEA DX,SB28
  @W44:
    CMP BYTE PTR DS:SBDMA,0
    JNE @W55
    LEA DX,SB30
  @W55:
    INT 21H

    MOV AH,9                      ;TEXTSCHEN AUSGEBEN  (IRQ....)
    CMP BYTE PTR DS:SBIRQ,0
    JNE @W000X
    LEA DX,SB29
  @W000X:
    CMP BYTE PTR DS:SBIRQ,2
    JNE @W111X
    LEA DX,SB31
  @W111X:
    CMP BYTE PTR DS:SBIRQ,5
    JNE @W222X
    LEA DX,SB32
  @W222X:
    CMP BYTE PTR DS:SBIRQ,7
    JNE @W333X
    LEA DX,SB33
  @W333X:
    INT 21H
END_SB:
RET

;============= DT I+D ==================================
DA:
  MOV AL,255
  OUT 13,AL
  XOR AL,AL
  OUT 14,AL
  OUT 8,AL

  MOV AL,255
  OUT 15,AL

  XOR AL,AL
  OUT 12,AL     ;FLIP FLOP RESET
  OUT 0,AL      ;ADDRESS DMA 0 CHANNEL 0
  OUT 0,AL      ;ADDRESS DMA 0 CHANNEL 0
  OUT 1,AL      ;COUNTER DMA 0 CHANNEL 0
  OUT 1,AL      ;COUNTER DMA 0 CHANNEL 0
  OUT 2,AL      ;ADDRESS DMA 0 CHANNEL 1
  OUT 2,AL      ;ADDRESS DMA 0 CHANNEL 1
  OUT 3,AL      ;COUNTER DMA 0 CHANNEL 1
  OUT 3,AL      ;COUNTER DMA 0 CHANNEL 1
  OUT 4,AL      ;ADDRESS DMA 0 CHANNEL 2
  OUT 4,AL      ;ADDRESS DMA 0 CHANNEL 2
  OUT 5,AL      ;COUNTER DMA 0 CHANNEL 2
  OUT 5,AL      ;COUNTER DMA 0 CHANNEL 2
  OUT 6,AL      ;ADDRESS DMA 0 CHANNEL 3
  OUT 6,AL      ;ADDRESS DMA 0 CHANNEL 3
  OUT 7,AL      ;COUNTER DMA 0 CHANNEL 3
  OUT 7,AL      ;COUNTER DMA 0 CHANNEL 3

  MOV AL,0+8+64
  OUT 11,AL     ;MODE REGISTER DMA 0 CHANNEL 0
  MOV AL,1+8+64
  OUT 11,AL     ;MODE REGISTER DMA 0 CHANNEL 1
  MOV AL,2+8+64
  OUT 11,AL     ;MODE REGISTER DMA 0 CHANNEL 2
  MOV AL,1+2+8+64;
  OUT 11,AL     ;MODE REGISTER DMA 0 CHANNEL 3

  CALL WW_DSP   ;KOMMANDO SCHREIBE SAMPLING RATE
  MOV AL,40H
  OUT DX,AL
  CALL WW_DSP   ;SAMPLING RATE AUF 255
  MOV AL,255
  OUT DX,AL

  MOV WORD PTR FS:[10*4+2],CS
  MOV WORD PTR FS:[10*4],OFFSET IRQ2
  MOV WORD PTR FS:[13*4+2],CS
  MOV WORD PTR FS:[13*4],OFFSET IRQ5
  MOV WORD PTR FS:[15*4+2],CS
  MOV WORD PTR FS:[15*4],OFFSET IRQ7

  XOR AL,AL     ;ALLE INTERRUPTZ [ON]
  OUT 15,AL

  CALL WW_DSP   ;KOMMANDO SPIELE SAMPLE
  MOV AL,14H
  OUT DX,AL
  CALL WW_DSP   ;LO BYTE SAMPLE LENGTH
  XOR AL,AL
  OUT DX,AL
  CALL WW_DSP   ;HI BYTE SAMPLE LENGTH
  XOR AL,AL
  OUT DX,AL

  STI
  XOR AL,AL
  OUT  21H,AL
  OUT 0A1H,AL

  MOV ECX,0FFFFFFFH              ;AUF DEN IRQ WARTEN
WAIT_IRQ:
  DEC ECX
  JNZ WAIT_IRQ

  MOV BYTE PTR DS:SBDMA,0

  IN AL,1
  IN AL,1
  CMP AL,0
  JE NOCHANNEL0
   OR BYTE PTR DS:SBDMA,1
   JMP OUTX
NOCHANNEL0:
  IN AL,3
  IN AL,3
  CMP AL,0
  JE NOCHANNEL1
   OR BYTE PTR DS:SBDMA,2
   JMP OUTX
NOCHANNEL1:
  IN AL,5
  IN AL,5
  CMP AL,0
  JE NOCHANNEL2
   OR BYTE PTR DS:SBDMA,4
   JMP OUTX
NOCHANNEL2:
  IN AL,7
  IN AL,7
  CMP AL,0
  JE NOCHANNEL3
   OR BYTE PTR DS:SBDMA,8
NOCHANNEL3:
OUTX:
RET
;============================= IRQ DETECT ==============
IRQ2:
 PUSH EAX
 MOV BYTE PTR DS:SBIRQ,2      ;IRQ NUMMER SCHREIBEN
 MOV DX,022EH                 ;UNBEDINGT EINLESEN (AHHHHHHHHHHHH)
 IN AL,DX
 MOV WORD PTR DS:SBIRQOFF,80  ;OFFSET IN INT TAB. FUER IRQ2
 MOV AL,20H                   ;QUITIEREN
 OUT 020H,AL
 OUT 0A0H,AL
 POP EAX
 MOV ECX,1                    ;LOOP SCHLEIFE BEENDEN (ECX=0)
IRET

IRQ5:
 PUSH EAX
 MOV BYTE PTR DS:SBIRQ,5
 MOV DX,022EH
 IN AL,DX
 MOV WORD PTR DS:SBIRQOFF,104  ; OFFSET IN INT TAB. FUER IRQ5
 MOV AL,20H
 OUT 020H,AL
 OUT 0A0H,AL
 POP EAX
 MOV ECX,1
IRET

IRQ7:
 PUSH EAX
 MOV BYTE PTR DS:SBIRQ,7
 MOV DX,022EH
 IN AL,DX
 MOV WORD PTR DS:SBIRQOFF,120  ; OFFSET IN INT TAB. FUER IRQ7
 MOV AL,20H
 OUT 020H,AL
 OUT 0A0H,AL
 POP EAX
 MOV ECX,1
IRET

;================== SB - Varialen  =====================

   SB1       DB '     SOUNDOUTPUT - NONE',13,10,'$'
   SB2       DB '     SOUNDOUTPUT - BLASTER  $'
   SB21      DB '( PORT 22OH -$'
   SB22      DB '( PORT 24OH -$'
   SB23      DB '( PORT 26OH -$'
   SB24      DB '( PORT 28OH -$'
   SB25      DB ' DMA 0 -$'
   SB26      DB ' DMA 1 -$'
   SB27      DB ' DMA 2 -$'
   SB28      DB ' DMA 3 -$'
   SB30      DB ' DMA ? -$'
   SB29      DB ' IRQ ? ).',13,10,'$'
   SB31      DB ' IRQ 2 ).',13,10,'$'
   SB32      DB ' IRQ 5 ).',13,10,'$'
   SB33      DB ' IRQ 7 ).',13,10,'$'
   MEMORY    DD 0
   SBPORT    DW 0
   SBDMA     DB 0
   SBIRQ     DB 0
   SBIRQOFF  DD 0     ;OFFSET FUER DEN IRQ IN DIE INTERRUPT TABELLE

   ZAK       DD 256 DUP(0)   ;Zwischenspeicher fr alle INTs

;================ DMA INIT ROUTINE =====================

PLAY     PROC NEAR
         PUBLIC PLAY


  CMP CS:SBIRQ,0         ;SB installiert ?
  JE  NoSound            ;Wenn nicht,dann zum Ende

  PUSH EBP
  PUSH DS
  PUSH FS

  PUSH CS
  POP  DS

  CLI                    ;SETZE INT
  XOR AX,AX
  MOV FS,AX
  MOV EBP,DS:SBIRQOFF
  SHR EBP,1
  MOV AX,OFFSET IRQPLAY
  MOV FS:[EBP],AX
  MOV AX,CS
  MOV FS:[EBP+2],AX


  CALL WW_DSP            ;SAMPLING RATE (KOMMANDO)
  MOV AL,64
  OUT DX,AL
  CALL WW_DSP            ;SAMPLING RATE (WERT)
  MOV AL,166
  OUT DX,AL
  MOV AL,5
  OUT 10,AL              ;EINZELMASKIERUNG
  MOV AL,89
  OUT 11,AL              ;MODE REGISTER  1+8+16+64
  XOR AL,AL
  OUT 12,AL              ;FLIPFLOPRESET
  OUT 2,AL               ;ADRESSE LOW  0
  OUT 2,AL               ;ADRESSE HIGH 0
  MOV AL,0FFH
  OUT 3,AL               ;SAMPLE LENGTH 64K
  OUT 3,AL               ;SAMPLE LENGTH 64K
  MOV AL,21H
  OUT 131,AL             ;SEGMENT REG AUF 2MEG EINSTELLEN.
  MOV AL,1
  OUT 10,AL              ;MASKIERUNG AUS.
  XOR AL,AL
  OUT 33,AL              ;ALLE INTERRUPTS ERLAUBEN
  STI
  CALL WW_DSP            ;DSP COMMAND - PLAY SAMPLE
  MOV AL,20
  OUT DX,AL
  CALL WW_DSP            ;SAMPLE LENGTH 64K
  MOV AL,255
  OUT DX,AL
  CALL WW_DSP            ;SAMPLE LENGTH 64K
  MOV AL,255
  OUT DX,AL
  CALL WW_DSP            ;SPEAKER ON
  MOV AL,0D1H
  OUT DX,AL
  XOR AL,AL
  OUT 0EH,AL
  OUT 21H,AL

  POP FS
  POP DS
  POP EBP

NoSound:

RET




;================ DMA IRQ ROUTINE ======================
IRQPLAY:
	  PUSH EAX
          PUSH EDX
	  PUSH DS
	  MOV AX,CS
	  MOV DS,AX

          MOV DX,DS:SBPORT   ;LESEN DER BASIS ADRESSE DER SOUNDB.
	  ADD DX,0EH
	  IN AL,DX           ;LESE 2XEH (FUER ALTE KARTEN ?)

	  IN AL,131          ;SEGMENT REGISTER HOCHZAEHLEN
	  INC AL
	  CMP AL,40H
          JB NORESET
          MOV AL,21H
NORESET:  OUT 131,AL

	  SUB DX,2
ROUND1:   IN AL,DX           ;LESE 2XCH
          AND AL,80H
          JNZ ROUND1
	  MOV AL,14H
	  OUT DX,AL
ROUND2:   IN AL,DX           ;LENGTH 65536 (65535) LOW BYTE
	  AND AL,80H
          JNZ ROUND2
	  MOV AL,0FFH
	  OUT DX,AL
ROUND3:   IN AL,DX           ;UND NUN DAS HIGH BYTE
	  AND AL,80H
	  JNZ ROUND3
	  MOV AL,0FFH
          OUT DX,AL


          MOV AL,20H         ;QUITTIEREN
          OUT 020H,AL
	  POP DS
          POP EDX
	  POP EAX
          IRET

PLAY ENDP


CHECK_MEM PROC NEAR
          PUBLIC CHECK_MEM

   PUSH DS
   XOR AX,AX
   MOV DS,AX  ;ALLE INTERRUPTS SICHERN
   XOR SI,SI
   LEA DI,ZAK
   MOV AX,CS
   MOV ES,AX
   MOV CX,256
   REP MOVSD
   POP DS

    MOV ESI,0F0000H        ;Anfangsaddresse
    MOV EDI,10000H         ;Schrittweite
    XOR AX,AX
    MOV FS,AX
 MEMORYLOOP:
    ADD ESI,EDI            ;Schrittweite addieren
    MOV BL,FS:[ESI]        ;Addresse sichern
    MOV AL,0AAH            ;Mit dem Wert AAh beschreiben
    MOV FS:[ESI],AL
    MOV AL,FS:[ESI]
    MOV FS:[ESI],BL
    CMP AL,0AAH            ;Ausgelesener wert noch AAh ?
    JE MEMORYLOOP          ;Wenn ja weiter oben
    SHR EDI,1              ;Schrittweite teilen
    OR  EDI,EDI            ;Prfen ob Schrittweite =0
    JZ MEMORYLOOP

    MOV XMS,ESI


    RET

CHECK_MEM ENDP

SEND_PACKET PROC NEAR
	    PUBLIC SEND_PACKET
	   RET
SEND_PACKET ENDP



GET_PACKET PROC NEAR
	   PUBLIC GET_PACKET

	   RET

GET_PACKET ENDP



CODE     ENDS
	 END