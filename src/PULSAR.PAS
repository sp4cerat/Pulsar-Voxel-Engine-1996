USES DOs;            (* .. *)

CONST                    (*ADDRESSEN WO DIE  EINZELNEN SPEICHERBEREICHE SIND*)

Textures =  $600000 ;    (*TEXTURES*)
MULTAB   =  $500000 ;    (*MULTIPLIKATIONSTABELLE*)
Z_BUF    =  $4C0000 ;    (*ZBUFFERTABELLE*)
O_MAP_UP =  $4A0000 ;    (*OFFSETTABELLE FUER BLOECKE OBEN*)
O_MAP_DN =  $480000 ;    (*OFFSETTABELLE FUER BLOECKE UNTEN*)
COL_TAB  =  $470000 ;    (*FARBTABELLE FUER Z-SHADING*)
DOOR_MAP =  $460000 ;    (*TABELLE FUER TUERFRAGS*)
SPRITES  =  $400000 ;    (*SPRITES          *)
WAV      =  $200000 ;    (*SOUNDFILE (.WAV) *)

{$l PMODE }              (*INCLUDE FILE UM SEGMENTGRENZE VON 64K AUFZUHEBEN*)
{$l P_ASM }              (*ASSEMBLER MAIN LOOP*)

VAR pics,cn2,cnt,segm,segm2,segm3,a,c,n,winkl,gamma,gamma2,x,y,z,o,
    detail,end1,end2,beg,rot,rot2,DTO,x0,xs,ed_mode:integer;
    xadd,yadd,xadd2,yadd2,xn,ct2,ct3,y2,y1,YO,YO2,
    xsp,ysp,zsp,ct,doors,yy,ya,xxx,yyy,w1,w2,e,f,yn,xms:longint;
    s2,s3,s4,s,Keytab:ARRAY[0..255] OF byte    ;
    t,col,door       :ARRAY[0..255] OF shortint;
    t2,door_ofs      :ARRAY[0..319] OF word    ;
    d                :ARRAY[0..9999]OF integer ;
    d0,d1,d2,d3      :ARRAY[0..499] OF integer ;
    SegP,SegP2,SegP3,SegP4:pointer;
    ff,ff2:FILE;
    msw:word;
    CN3,CN4,sock:word;

PROCEDURE Play;     EXTERNAL;   (*ABSPIELEN STARTEN*)
PROCEDURE Back;     EXTERNAL;   (*ALLE INTERRUPTS ZURšCKSCHREIBEN*)
PROCEDURE show;     EXTERNAL;   (*MAIN ASM LOOP*)
PROCEDURE show_i;   EXTERNAL;   (*MAIN INIT FOR ASM LOOP*)
PROCEDURE Timer ;   EXTERNAL;   (*TIMER INTERRUPT*)
PROCEDURE Key;      EXTERNAL;   (*KEYBOARD INTERRUPT*)
PROCEDURE pmode;    EXTERNAL;   (*MACHT SEGMENTE GROESSER (INCLUDE DATEI -PMODE- *)
PROCEDURE check_mem;EXTERNAL;   (*ERMITTELT SYSTEMSPEICHER + ALLE INTERRUPTS SICHERN*)
PROCEDURE send_packet;EXTERNAL;
{_______________________________________________________________________}
{                                                                       }
(*MEMORY WRITE BYTE*)
PROCEDURE MW (addr:longint;byt:byte);ASSEMBLER;ASM push es;xOR ax,ax
mov es,ax;mov al,byt;db 66h;mov di,wORd ptr addr;dd 7882667h;pop es;END;

(*MEMORY WRITE WORD*)
PROCEDURE MWW(addr:longint;wOR:wORd);ASSEMBLER;ASM push es;xOR ax,ax
mov es,ax;mov ax,wOR;db 66h;mov di,wORd ptr addr;dd 7892667h;pop es;END;

(*MEMORY WRITE DWORD*)
PROCEDURE MWD(addr:longint;dwOR:longint);ASSEMBLER;ASM push es;xOR ax,ax
mov es,ax;db 66h;mov ax,wORd ptr dwOR;db 66h;mov di,wORd ptr addr;
db 67h,66h,26h,89h,7;pop es;END;

(*MEMORY READ BYTE*)
FUNCTION  MR (addr:longint):byte;VAR a:byte;BEGIN;ASM push es;xOR ax,ax
mov es,ax;db 66h;mov di,wORd ptr addr;dd 78A2667h;mov a,al;pop es;END;mr:=a;END;

(*MEMORY READ WORD*)
FUNCTION  MRW(addr:longint):wORd;VAR a:wORd;BEGIN;ASM push es;xOR ax,ax
mov es,ax;db 66h;mov di,wORd ptr addr;dd 78B2667h;mov a,ax;pop es;END;mrw:=a;END;
{_______________________________________________________________________}
{                                                                       }
(*PCX BILD LADEN*)
PROCEDURE LoadPCX(F:String;S:LongInt;XS:Longint;pf:byte);
VAR Q:FILE;
    B:ARRAY[0..2047]OF byte;
    Anz,Pos,W,H,E,Pack,D,X,C:wORd;
    I:Byte;
    Adr,Y:LongInt;
BEGIN
  X:=0;
  Y:=0;
  Assign(Q,F);
  Reset(Q,1);
  {------PALETTE LOAD ?------}
IF pf=1 THEN BEGIN
  Seek(Q,FILESize(Q)-3*256-1);
  BlockRead(Q,B,3*256+1);
  IF B[0]=12 THEN BEGIN
     FOR I:=0 TO 255 DO BEGIN
	 PORt[$3C8]:=I;
	 PORt[$3C9]:=B[I*3+1]SHR 2;
	 PORt[$3C9]:=B[I*3+2]SHR 2;
	 PORt[$3C9]:=B[I*3+3]SHR 2;
     END;
  END;
END;
  {------PICTURE LOAD--------}
  Seek (Q,0);
  BlockRead (Q,B,128,Anz);
  IF (B[0]<>10) OR (B[3]<>8) THEN BEGIN
     close (Q);
     exit;
  END;
  W:=(B[9] -B[5])*256+B[8] -B[4]+1;
  H:=(B[11]-B[7])*256+B[10]-B[6]+1;
  Pack:=0;
  C:=0;
  E:=Y+H;

  REPEAT
    BlockRead(Q,B,2048,Anz);
    Pos:=0;
    while (Pos<Anz) AND (Y<E) DO BEGIN
          IF Pack <> 0 THEN BEGIN
             Adr:=X+C+Y* XS;
	     FOR D:=0 TO Pack DO BEGIN
                 MW(S+Adr,B[Pos]);
		 Inc(Adr);
	     END;
	     Inc(C,Pack);
	     Pack := 0;
	  END else IF (B[Pos] AND $C0)=$C0 THEN Pack:=B[Pos] AND $3F else BEGIN
	      Adr:=X+C+Y* XS;
	      MW(S+Adr,B[Pos]);
	      Inc(C)
	  END;
	  Inc(Pos);
          IF C=W THEN BEGIN
	     C:=0;
	     Inc(Y);
	  END;
    END;
  UNTIL(Anz=0) OR (Y=E);
  close (Q);
END;

{_______________________________________________________________________}
{                                                                       }

PROCEDURE Test_Door;
BEGIN
 IF mr(DOOR_map+xn shr 1)=1 then
 BEGIN
  DOORS:=0;
   REPEAT inc(DOORs);
   UNTIL(mr(DOOR_MAP+mrw(door_ofs[doors*2]))<>1)or(DOORS>255);
   DOOR_OFs[lo(DOORs)]:=xn shr 1;
 END;
REPEAT UNTIL keytab[61]>127;
END;

{_______________________________________________________________________}
{                                                                       }
			   {  START o CODE  }
{_______________________________________________________________________}
{                                                                       }
BEGIN
{-------------EMM drin ?------------------------------------}
 ASM
  mov ax,3     (*CLRSCR*)
  int 10h

  xor al,al    (*DMA EINZELMASKIERUNGSREGISTER ALLE KANAELE*)
  out 10,al
  inc al
  out 10,al
  inc al
  out 10,al
  inc al
  out 10,al

  smsw msw     (*LOW WORD VON CR0 SICHERN*)
 END;
 IF msw AND 1=1 THEN BEGIN writeln('     Prozessor in Protected-Mode!');exit;END;
{-------------HIMEM drin ?----------------------------------}
 ASM
  mov ax,4300h
  int 2fh
  mov msw,ax
 END;
 IF msw AND 128=128 THEN BEGIN writeln('     Himem installiert!');exit;END;
{-------------GATE A20 einschalten !------------------------
 ASM
  mov ax,7a00h
  mov bx,12
  int 2fh
  mov msw,ax
 END;
 if msw and 255<>255 then BEGIN
    writeln('     Netzwerk nicht installiert!');exit;
 END ELSE BEGIN
   asm
    xor ax,ax
    xor bx,bx
    mov dx,5000h
    int 7ah
    xor ax,ax
    xor bx,bx
    mov dx,5001h
    int 7ah
   end;}
   sock:=1;
   cn3:=100;
   cn4:=20;
{   writeln('     USiNG SOCKET 5oooHEX n 5oo1HEX.');
 END;}

pORt[$64]:=$d1;{delay(1);}
pORt[$60]:=$df;{delay(1);}
{_______________________________________________________________________}
{                                                                       }
pmode;
{_______________________________________________________________________}
{                                                                       }
check_mem;
writeln('     MEMORY FOUND - ',XMS shr 10 shr 10,' MB');
IF xms<$800000 THEN BEGIN writeln('     Not enough Memory installed!');exit;END;
{_______________________________________________________________________}
{                                                                       }
{directvideo:=false;
textcolor(7);
{_______________________________________________________________________}
{                                                                       }
IF MaxAvail < (65530*3)THEN BEGIN Writeln('     Not enough DOS Memory - only ',maxavail,' Bytes MEM');exit;END;

getmem(SegP ,65530);Segm :=memw[seg(segp) :OFs(segp) +2];
getmem(SegP2,65530);Segm2:=memw[seg(segp2):OFs(segp2)+2];
getmem(SegP3,65530);Segm3:=memw[seg(segp3):OFs(segp3)+2];

Show_I;                          (*VORBEREITEN AUF DAS HAUPTPROGRAMM*)

SetIntVec(9,@Key);


  PORt[$43] := $34;                        (*TIMER 0 FREQ. AUF 100Hz*)
  PORt[$40] :=($1234DD DIV 100)mod 256;
  PORt[$40] :=($1234DD DIV 100)DIV 256;

FOR a:=0 TO 100 DO BEGIN                 (*KLEINES DELAY*)
    REPEAT UNTIL port[$3da] AND 8=8;     (*WAIT FOR RETRACE*)
   { delay(5);}
END;

FOR e:=0 TO 63 DO BEGIN                  (*WEGDIMMEN*)
    FOR a:=0 TO 255 DO BEGIN
	port[$3c7]:=a;
	c:=port[$3c9];IF c>0 THEN dec(c);
	n:=port[$3c9];IF n>0 THEN dec(n);
	o:=port[$3c9];IF o>0 THEN dec(o);
	port[$3c8]:=a;
	port[$3c9]:=c;
	port[$3c9]:=n;
	port[$3c9]:=o;
    END;
    REPEAT UNTIL port[$3da] AND 8=8;     (*WAIT FOR RETRACE*)
END;

ASM mov ax,13h;int 10h;END;              (*GFX MODE 13h*)

loadpcx('loadtes2.pcx',$a0000,320,1);    (*LOAD STARTUP IMAGE*)

assign(ff,'music.wav');                  (*LOAD SOUNDFILE*)
reset(ff,1);
f:=FILEsize(ff) shr 16-1;IF f>31 THEN f:=31;
FOR e:=0 TO f DO BEGIN
    blockread(ff,mem[segm3:0],65535);
    FOR yn:=0 TO 65535 DO mw(Wav+yn+e SHL 16,mem[segm3:yn]);
    IF e=1 THEN play;
END;
close(ff);

FOR f:=e SHL 16 TO $6F0000 shr 2 DO mwd(f SHL 2+$110000,0); (*KILL LOOP*)
{_______________________________________________________________________}
{                                                                       }
x0:=0;                   (*TABELLE UM DEN HINTERGRUND RUND ZU MAPPEN*)
FOR a:=0 TO 1279 DO BEGIN
    z:=round(sin(-2*pi*a/1279)*256);
    IF z>0 THEN BEGIN
       xs:=round(cos(2*pi*a/1279)*32768) DIV z;
       IF abs(xs)<160 THEN BEGIN
	  inc(xs,160);
	  FOR x:=x0 TO xs  DO t2[x AND 511]:=a shr 1;
	  x0:=xs;
       END;
       IF (xs>160) AND (x0<160) THEN BEGIN
	  inc(xs,160);
	  FOR x:=x0 TO 319 DO t2[x AND 511]:=a shr 1;x0:=xs;
       END;
    END;
END;

loadpcx('ms.pcx',textures,256,0);  (*LOAD TEXTURES*)

FOR f:=0 TO 65535 DO mww(o_map_up+f*2,0 );     (*TABELLEN LOESCHEN*)
FOR f:=0 TO 65535 DO mww(o_map_dn+f*2,88);
FOR f:=0 TO 65535 DO mwd(z_buf   +f*4,0);
FOR f:=0 TO 65535 DO mw(DOOR_map+f,0);
FOR a:=0 TO 255   DO DOOR[a]:=0;
FOR a:=0 TO 255   DO DOOR_OFs[a]:=0;
DOORs:=0;
					       (*LOAD BLOCKMAP*)
assign(ff,'blockmap');reset(ff,1);
blockread(ff,mem[segm3:0],65535);
FOR f:=0 TO 65535 DO mw(z_buf+f        ,mem[segm3:f]);
blockread(ff,mem[segm3:0],65535);
FOR f:=0 TO 65535 DO mw(z_buf+f+  65536,mem[segm3:f]);
blockread(ff,mem[segm3:0],65535);
FOR f:=0 TO 65535 DO mw(z_buf+f+2*65536,mem[segm3:f]);
blockread(ff,mem[segm3:0],65535);
FOR f:=0 TO 65535 DO mw(z_buf+f+3*65536,mem[segm3:f]);

blockread(ff,mem[segm3:0],65535);
FOR f:=0 TO 65535 DO mw(o_map_up+f     ,mem[segm3:f]);
blockread(ff,mem[segm3:0],65535);
FOR f:=0 TO 65535 DO mw(o_map_up+f+65536,mem[segm3:f]);

blockread(ff,mem[segm3:0],65535);
FOR f:=0 TO 65535 DO mw(o_map_dn+f      ,mem[segm3:f]);
blockread(ff,mem[segm3:0],65535);
FOR f:=0 TO 65535 DO mw(o_map_dn+f+65536,mem[segm3:f]);
blockread(ff,mem[segm3:0],65535);
FOR f:=0 TO 65535 DO mw(DOOR_map+f      ,mem[segm3:f]);
blockread(ff,DOOR[0]    ,256);
blockread(ff,DOOR_OFs[0],512);
blockread(ff,DOORS      ,2  );
close(ff);

FOR a:=0 TO 127    DO keytab[a]:=128;      (*TABELLEN BERECHNEN*)
FOR a:=0 TO 255    DO s [a]:=round(128-cos(pi*a/128)*127);
FOR a:=0 TO 255    DO t [a]:=round(sin(pi*a/128)*127);
FOR a:=0 TO 255    DO s2[a]:=round(sin(pi*a/128)*3+3);
FOR a:=0 TO 255    DO s3[a]:=round(sin(pi*a/128)*4+4);
FOR a:=0 TO 255    DO s4[a]:=round(sin(pi*a/128)*2+2);

FOR a:=0 TO 9999   DO d[a]:=128 shl 10 DIV (a+1);
FOR a:=0 TO 255    DO d1[a]:=a+1;
FOR a:=0 TO 90     DO d1[a+85]:= (a*2+85);
FOR a:=2 TO 150    DO d1[a+170]:=(a*a DIV 2+170+85+1);

FOR a:=0 TO 255    DO d3[a]   :=a+1;
FOR a:=0 TO 50     DO d3[a+40]:=(a*2+40);
FOR a:=1 TO 127-90 DO d3[a+90]:=(a*a DIV 2+40+100+1);

FOR a:=0 TO 255    DO d0[a]    :=a+1;
FOR a:=0 TO 80     DO d0[a+64] :=a*2+64+1;
FOR a:=1 TO 64     DO d0[a+64+80]:=a*a DIV 3+160+64+1;

FOR a:=0 TO 255    DO d2[a]:=d3[a]*4;
{_________________________________________________________}
{                                                         }

FOR x:=0 TO 255 DO
    FOR y:=0 TO 255 DO BEGIN
	a:=x AND 15+y-20;
	IF a<(x AND 15)  THEN a:=(x AND 15);
	IF a>15 THEN a:=15;
	mw(col_tab+x+y*256,x AND 240+a AND 15);
END;

{-------------------------------------------------}

gamma :=15;            { mit High-Detail starten }
gamma2:=184;
FOR a:=0 TO 255 DO col[a]:=d[a+41] DIV gamma2+31-gamma;
FOR a:=0 TO 255 DO d2[a] :=d1[a];
BEG :=255;
END1:=230;
END2:=150;
FOR e:=0 TO 1023 DO
    FOR f:=0 TO 255 DO mwd(
	multab+e SHL 2+f SHL 12,(((e-512)*d2[f])DIV 256)*320+32000+320*20);
{_______________________________________________________________________}
{                                                                       }

pORt[$60]:=$ed;{delay(5);}pORt[$60]:=2; { Num-Lock=ON }

{__________________________BLOCKBERECHNUNG______________________________}
{                                                                       }

{====================== BLOCK 1 =====================}
FOR x:=0 TO 63 DO
FOR y:=0 TO 63 DO
    mw(textures+x+y*256+$80,
       s[lo(x SHL 2)]DIV 42+
       s[lo(y SHL 2)]DIV 64+
       s[lo(y SHL 2+x SHL 2)]DIV 52+130);

FOR x:=0 TO 63 DO
FOR y:=0 TO 63 DO
    mw(textures+x+y*256+$C0,120);

FOR x:=0 TO 63 DO
FOR y:=0 TO 63 DO
    mw(textures+x+y*256+64,0);  {6}


{====================== BLOCK 2 =====================}
FOR x:=0 TO 15 DO
FOR y:=0 TO 63 DO BEGIN
    mw(textures+15-x+y*256+$40C0,150+x*5);
    mw(textures+48+x+y*256+$40C0,150+x*5);
    mw(textures+31-x+y*256+$40C0,150+x*x shr 4-15);
    mw(textures+32+x+y*256+$40C0,150+x*x shr 4-15);
    mw(textures+15-x+y*256+$4080,128-x);
    mw(textures+48+x+y*256+$4080,128-x);
    mw(textures+31-x+y*256+$4080,128  );
    mw(textures+32+x+y*256+$4080,128  );
END;


{====================== BLOCK 3 =====================}
FOR x:=0 TO 63 DO
FOR y:=0 TO 63 DO BEGIN
    mw(textures+x+y*256+$8080,mr(textures+y+x*256+$4080));
    mw(textures+x+y*256+$80C0,mr(textures+y+x*256+$40C0));
END;


{====================== BLOCK 4 =====================}
FOR x:=0 TO 63 DO
FOR y:=0 TO 63 DO BEGIN
    a:=mr(textures+x+y*256+$4080);
    c:=mr(textures+x+y*256+$8080);
    IF c>a THEN a:=c;
    mw(textures+x+y*256+$C080,a);
    a:=mr(textures+x+y*256+$40C0);
    c:=mr(textures+x+y*256+$80C0);
    IF c<a THEN a:=c;
    mw(textures+x+y*256+$C0C0,a);
END;

{====================== BLOCK 5 =====================}
FOR x:=0 TO 63 DO
FOR y:=0 TO 63 DO BEGIN
    mw(textures+x+y*256+$10080,mr(textures+x+y*256+$4080)+y shr 1);
    mw(textures+x+y*256+$100C0,mr(textures+x+y*256+$40C0)+y shr 1);
END;
{====================== BLOCK 6 =====================}
FOR x:=0 TO 63 DO
FOR y:=0 TO 63 DO BEGIN
    mw(textures+x+y*256+$14080,mr(textures+x+y*256+$4080)-y shr 1);
    mw(textures+x+y*256+$140C0,mr(textures+x+y*256+$40C0)-y shr 1);
END;
                  {Block 7}
FOR x:=0 TO 31 DO FOR y:=0 TO 63 DO BEGIN
    mw(textures+x+y*256+$18080+32,128);
    mw(textures+x+y*256+$18080,mr(textures+x+y*256+$c080));
    mw(textures+x+y*256+$180C0+32,134);
    mw(textures+x+y*256+$180C0,mr(textures+x+y*256+$c0C0));
                  {Block 8}
    mw(textures+x+y*256+$1c080,128);
    mw(textures+x+y*256+$1c080+32,mr(textures+x+y*256+$c080+32));
    mw(textures+x+y*256+$1c0C0,134);
    mw(textures+x+y*256+$1c0C0+32,mr(textures+x+y*256+$c0C0+32));
END;

{====================== BLOCK 9 =====================}
FOR x:=0 TO 63 DO {Block 9}
FOR y:=0 TO 63 DO BEGIN
    mw(textures+x+y*256+$20080,mr(textures+y+x*256+$18080));
    mw(textures+x+y*256+$200C0,mr(textures+y+x*256+$180C0));
                  {Block 10}
    mw(textures+x+y*256+$24080,mr(textures+y+x*256+$1c080));
    mw(textures+x+y*256+$240C0,mr(textures+y+x*256+$1c0C0));
                  {Block 11}
    mw(textures+x+y*256+$28080,128);
    mw(textures+x+y*256+$280C0,134);
END;

FOR x:=0 TO 31 DO FOR y:=0 TO 31 DO BEGIN
    mw(textures+x+y*256+$28080,mr(textures+x+y*256+$c080));
    mw(textures+x+y*256+$280C0,mr(textures+x+y*256+$c0C0));
END;

{====================== BLOCK 12-14 ==================}
FOR x:=0 TO 63 DO {Block 12}
FOR y:=0 TO 63 DO BEGIN
    mw(textures+x+y*256+$2c080,mr(textures+63-x+y*256+$28080));
    mw(textures+x+y*256+$2c0C0,mr(textures+63-x+y*256+$280C0));
		  {Block 13}
    mw(textures+63-x+y*256+$30080,mr(textures+63-y+x*256+$28080));
    mw(textures+63-x+y*256+$300C0,mr(textures+63-y+x*256+$280C0));
                  {Block 14}
    mw(textures+x+y*256+$34080,mr(textures+63-y+x*256+$28080));
    mw(textures+x+y*256+$340C0,mr(textures+63-y+x*256+$280C0));
END;

{====================== BLOCK 15 =====================}
FOR x:=0 TO 31 DO
    FOR y:=0 TO 63 DO BEGIN            {Block 15}
        mw(textures+x+y*256+$38080,mr(textures+x+y*256+$4080));
        mw(textures+x+y*256+$380C0,mr(textures+x+y*256+$40C0));
        mw(textures+x+y*256+$38080+32,mr(textures+32+x+y*256+$c080));
        mw(textures+x+y*256+$380C0+32,mr(textures+32+x+y*256+$c0C0));
    END;

{====================== BLOCK 16-18 ==================}
FOR x:=0 TO 63 DO {Block 16}
    FOR y:=0 TO 63 DO BEGIN
        mw(textures+x+y*256+$3c080,mr(textures+63-x+y*256+$38080));
        mw(textures+x+y*256+$3c0C0,mr(textures+63-x+y*256+$380C0));
                  {Block 17}
        mw(textures+63-x+y*256+$40080,mr(textures+63-y+x*256+$38080));
        mw(textures+63-x+y*256+$400C0,mr(textures+63-y+x*256+$380C0));
                  {Block 18}
        mw(textures+x+y*256+$44080,mr(textures+y+x*256+$38080));
        mw(textures+x+y*256+$440C0,mr(textures+y+x*256+$380C0));
    END;

{====================== BLOCK 19 =====================}
FOR x:=0 TO 63 DO
    FOR y:=0 TO 63 DO BEGIN
        a:=mr(textures+x+y*256+$38080);
        c:=mr(textures+x+y*256+$40080);
        IF c<a THEN a:=c;
        mw(textures+x+y*256+$48080,a);
	a:=mr(textures+x+y*256+$380C0);
        c:=mr(textures+x+y*256+$400C0);
        IF c>a THEN a:=c;
        mw(textures+x+y*256+$480C0,a);
    END;

{====================== BLOCK 20/21/22 ===============}
FOR x:=0 TO 63 DO
    FOR y:=0 TO 63 DO BEGIN
        mw(textures+x+y*256   +$4c080,mr(textures+63-x+y*256+$48080));
        mw(textures+x+y*256   +$4c0C0,mr(textures+63-x+y*256+$480C0));

        mw(textures+   x+y*256+$50080,mr(textures+   y+x*256+$48080));
        mw(textures+   x+y*256+$500C0,mr(textures+   y+x*256+$480C0));

        mw(textures+63-x+y*256+$54080,mr(textures+y+   x*256+$48080));
	mw(textures+63-x+y*256+$540C0,mr(textures+y+   x*256+$480C0));
    END;


{====================== BLOCK 22/23/24/25 ============}
FOR x:=0 TO 127 DO
    FOR y:=0 TO 63 DO BEGIN
        mw(textures+x+y*256+$58080,mr(textures+x+y*256+$c080));
        mw(textures+x+y*256+$5c080,mr(textures+x+y*256+$c080));
	mw(textures+x+y*256+$60080,mr(textures+x+y*256+$c080));
        mw(textures+x+y*256+$64080,mr(textures+x+y*256+$c080));
    END;

FOR x:=0 TO 31 DO
    FOR y:=0 TO 31 DO BEGIN
        mw(textures+x+y*256+$58080+32      ,128);
        mw(textures+x+y*256+$580C0+32      ,134);
        mw(textures+x+y*256+$5c080         ,128);
        mw(textures+x+y*256+$5c0C0         ,134);
        mw(textures+x+y*256+$60080   +$2000,128);
        mw(textures+x+y*256+$600C0   +$2000,134);
        mw(textures+x+y*256+$64080   +$2020,128);
        mw(textures+x+y*256+$640C0   +$2020,134);
    END;

{====================== BLOCK 26 =====================}
FOR x:=0 TO 63 DO
    FOR y:=0 TO 63 DO BEGIN
        mw(textures+x+y*256+$68040,0);         {6}
	mw(textures+x+y*256+$68080,128);
        mw(textures+x+y*256+$680C0,134);
    END;

{====================== BLOCK 27/28 ==================}
FOR x:=0 TO 63 DO
    FOR y:=0 TO 63 DO BEGIN
        mw(textures+y+x*256+$6c080,mr(textures+x+y*256+$4080)+y shr 1);
	mw(textures+y+x*256+$6c0C0,mr(textures+x+y*256+$40C0)+y shr 1);
        mw(textures+y+x*256+$70080,mr(textures+x+y*256+$4080)-y shr 1);
        mw(textures+y+x*256+$700C0,mr(textures+x+y*256+$40C0)-y shr 1);
    END;


{====================== BLOCK 30 =====================}
FOR x:=0 TO 63 DO
    FOR y:=0 TO 63 DO BEGIN
        mw(textures+y+x*256+$78000,31);
        mw(textures+y+x*256+$78040,0);
    END;


{====================== BLOCK 31 =====================}
FOR x:=0 TO 63 DO
    FOR y:=0 TO 63 DO BEGIN
	a:=s[lo(x*4)]DIV 60+
        s[lo(y*4-x*8)]DIV 40+
        s[lo(y*12+x*4)]DIV 50+
        s[lo(y*4+x*8)]DIV 60+3;
        IF a>15 THEN a:=31-a;
        mw(textures+y+x*256+$80000,a+46);
        mw(textures+y+x*256+$80040,0);
        mw(textures+y+x*256+$80080,mr(textures+x+y*256+$80));
        mw(textures+y+x*256+$800C0,mr(textures+x+y*256+$C0));
    END;


{_______________________________________________________________________}
{                                                                       }
yy:=-30;              (*START KOORDINATEN SETZEN*)
xxx:=611352;
yyy:=-683870;
winkl:=90;

loadpcx('bgg.pcx',longint(segm2)*16,1280,0);  (*LOAD BACKGROUND*)


loadpcx('dm.pcx',sprites,256,1);  (**)

yo2:=mrw(o_map_dn+xn)+mr(Textures+128+xxx shr 10 AND 63+yyy shr 10 AND 63 SHL 8+
     longint(mrw(z_buf+xn SHL 1+1))SHL 8);

ed_mode:=1;

port[$21]:=0;         (*ALLE INTERRUPTS ERLAUBEN*)

doors:=0;
xsp:=xxx;
zsp:=yyy;
{_______________________________________________________________________}
{                                                                       }
SetIntVec(8,@Timer);
REPEAT          (*MAIN PASCAL REPEAT SCHLEIFE (EDITOR MODE)*)
{_______________________________________________________________________}
{                                                                       }
y1:=t[lo(winkl)];
y2:=t[lo(winkl+64)];
IF keytab[73]=0 THEN inc(yy,-9) else IF keytab[81]=0 THEN inc(yy, 9);

xn:=((((xxx+y1 SHL 9)shr 16)and 255+((yyy-y2 SHL 9)shr 16)and 255 SHL 8)SHL 1)AND $1ffff;

IF keytab[87]=0 THEN BEGIN gamma:=(gamma+1)AND 31;FOR a:=0 TO 255 DO
		     col[a]:=d[a+41]DIV (gamma2+10)+31-gamma;END;
IF keytab[88]=0 THEN BEGIN gamma2:=(gamma2+5)AND 511;FOR a:=0 TO 255 DO
	 col[a]:=d[a+41]DIV (gamma2+10)+20-gamma;END;
IF keytab[82]=0 THEN mww(o_map_up+xn,mrw(o_map_up+xn)+4);
IF keytab[83]=0 THEN mww(o_map_up+xn,mrw(o_map_up+xn)-4);
IF keytab[71]=0 THEN mww(o_map_dn+xn,mrw(o_map_DN+xn)+4);
IF keytab[79]=0 THEN mww(o_map_dn+xn,mrw(o_map_DN+xn)-4);
IF KEYTAB[59]=0 THEN BEGIN MWW(Z_BUF+XN SHL 1+1,(MRW(Z_BUF+XN SHL 1+1)+$40)AND $1FC0);
   Repeat Until Port[$3da]and 8=8;{Delay(100);}END;
IF KEYTAB[60]=0 THEN BEGIN MWW(Z_BUF+XN SHL 1+1,(MRW(Z_BUF+XN SHL 1+1)-$40)AND $1FC0);
   Repeat Until Port[$3da]and 8=8;{Delay(100);}END;
IF keytab[61]=0 THEN BEGIN mw(DOOR_map+xn shr 1,mr(DOOR_map+xn shr 1)-1);Test_Door;END;
IF keytab[62]=0 THEN BEGIN mw(DOOR_map+xn shr 1,mr(DOOR_map+xn shr 1)+1);Test_Door;END;
IF keytab[63]=0 THEN BEGIN gamma :=15;gamma2:=184;FOR a:=0 TO 255 DO
   col[a]:=d[a+41]DIV gamma2+31-gamma;FOR a:=0 TO 255 DO d2[a] :=d1[a];
   beg:=255;END1:=230;END2:=150;FOR e:=0 TO 1023 DO FOR f:=0 TO 255 DO mwd(
   multab+e SHL 2+f SHL 12,(((e-512)*d2[f])DIV 256)*320+32000+320*20);END;
IF keytab[64]=0 THEN BEGIN gamma :=19;gamma2:=184;FOR a:=0 TO 255 DO
   col[a]:=d[a+41]DIV gamma2+31-gamma;FOR a:=0 TO 255 DO d2[a] :=d0[a]*2;
   beg:=191;END1:=160;END2:=70;FOR e:=0 TO 1023 DO FOR f:=0 TO 255 DO mwd(
   multab+e SHL 2+f SHL 12,(((e-512)*d2[f])DIV 256)*320+32000+320*20);END;
IF keytab[65]=0 THEN BEGIN gamma :=22;gamma2:=184;FOR a:=0 TO 255 DO
   col[a]:=d[a+41]DIV gamma2+31-gamma;FOR a:=0 TO 255 DO d2[a] :=d3[a]*4;
   END1:=70;END2:=10;beg:=127;FOR e:=0 TO 1023 DO FOR f:=0 TO 255 DO mwd(
   multab+e SHL 2+f SHL 12,(((e-512)*d2[f])DIV 256)*320+32000+320*20);END;

{gotoxy(1,1);writeln(Pics);
writeln('O:',xn shr 1);
writeln('D:',mr(DOOR_map+xn shr 1));
writeln('D:',DOORS);
writeln('x:',xsp);
writeln('y:',ysp);
writeln('z:',zsp);}
if keytab[55]=0 then begin assign(ff2,'shot.raw');rewrite(ff2,1);
blockwrite(ff2,mem[$a000:0],64000);for a:=0 to 255 do begin
port[967]:=a;x:=port[969]shl 2;y:=port[969]shl 2;z:=port[969]shl 2;
blockwrite(ff2,x,1);
blockwrite(ff2,y,1);
blockwrite(ff2,z,1);
end;
close(ff2);
end;
inc(cnt);
SHOW;                 (*ASM MAIN*)
SEND_PACKET;
{_______________________________________________________________________}
{                                                                       }
UNTIL keytab[1]=0;    (*END MAIN PASCAL LOOP*)
{_______________________________________________________________________}
{                                                                       }

ASM mov ax,3;int 10h;END;

pORt[$60]:=$ed;{delay(1);}pORt[$60]:=0; (*NUMLOCK AUS*)
pORt[$21]:=0;                         (*ALLE INTERRUPTS ERLAUBEN*)


  PORt[$43] :=$34;                    (*TIMER 0 - ALTE FREQUENZ (18.2/s)*)
  PORt[$40] :=255;
  PORt[$40] :=255;
Back;            (*ALLE INTERRUPTS ZURUECKSCHREIBEN*)

assign(ff,'blockmap');rewrite(ff,1);  (*BLOCKMAP SICHERN*)

writeln;write('     SAVING.');

FOR f:=0 TO 65535 DO mem[segm3:f]:=mr(z_buf+f);
blockwrite(ff,mem[segm3:0],65535);write('.');
FOR f:=0 TO 65535 DO mem[segm3:f]:=mr(z_buf+f+65536);
blockwrite(ff,mem[segm3:0],65535);write('.');
FOR f:=0 TO 65535 DO mem[segm3:f]:=mr(z_buf+f+65536*2);
blockwrite(ff,mem[segm3:0],65535);write('.');
FOR f:=0 TO 65535 DO mem[segm3:f]:=mr(z_buf+f+65536*3);
blockwrite(ff,mem[segm3:0],65535);write('.');

FOR f:=0 TO 65535 DO mem[segm3:f]:=mr(o_map_up+f);
blockwrite(ff,mem[segm3:0],65535);write('.');
FOR f:=0 TO 65535 DO mem[segm3:f]:=mr(o_map_up+f+65536);
blockwrite(ff,mem[segm3:0],65535);write('.');

FOR f:=0 TO 65535 DO mem[segm3:f]:=mr(o_map_dn+f);
blockwrite(ff,mem[segm3:0],65535);write('.');
FOR f:=0 TO 65535 DO mem[segm3:f]:=mr(o_map_dn+f+65536);
blockwrite(ff,mem[segm3:0],65535);write('.');

FOR f:=0 TO 65535 DO mem[segm3:f]:=mr(DOOR_map+f);
blockwrite(ff,mem[segm3:0],65535);write('.');
blockwrite(ff,DOOR[0]    ,256);write('.');
blockwrite(ff,DOOR_ofs[0],512);write('.');
blockwrite(ff,DOORS      ,2  );write('.');
close(ff);

writeln;
freemem(SegP ,51200);
freemem(SegP2,65500);
freemem(SegP3,65500);
END.