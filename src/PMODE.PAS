CODE     SEGMENT BYTE PUBLIC
         ASSUME CS:CODE
PMODE    PROC NEAR
         PUBLIC PMODE
.486p
           push ds
           push eax                       ; Alle benutzten Register sichern
           push edx
           xor eax,eax
           cli                            ; IRQ's sperren
           cdq                            ; eax=0 & edx =0
           mov ax,cs
           shl eax,4
           lea dx,GDT                     ; Lineare Adresse der GDT
           add eax,edx
           mov  dword ptr cs:GDTR+2,eax   ; In GDTR schreiben ..
           lgdt fword ptr cs:GDTR         ; und GDT laden

           mov eax,1
           mov cr0,eax                    ; PMode = ein

           mov ax,8                       ; 4GB-Deskriptor
           mov ds,ax
           mov es,ax                      ; 4GB-Segmente laden
           mov fs,ax
           mov gs,ax

           xor ax,ax                      ; PMode = aus
           mov cr0,eax
           pop edx                        ; alle Register wieder zurÅck
           pop eax
           pop ds
	   sti                            ; IRQ's zulassen
           ret
    GDT    dq    0,8f92000000ffffh        ; 0-Deskriptor & 4GB - Deskriptor
   GDTR    dw    16,0,0                   ; LÑnge der GDT,Lineare Adr.
PMODE ENDP
code ends
end