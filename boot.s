ORG 0
BITS 16
; oxd
_start:
	jmp short start
	nop

times 33 db 0

start:
	jmp 0x7c0:step2
step2:
	cli
	mov ax, 0x7c0
	mov ds, ax
	mov es, ax
	mov ax, 0x00
	mov ss, ax
	mov sp, 0x7c00
	sti

; Print disclaimer message only.
        mov si, message_1
	call print




;
; Global descriptor table definitions
;
gdt_start:
gdt_null:
	dd 0x0
	dd 0x0
; offset 0x8
gdt_code:            ; Code Segment
	dw 0xffff    ; Segment Limits
	dw 0         ; Base first 0-15 bits
	dw 0         ; Base 16-23 bits
	db 0x9a      ; Access Byte
	db 11001111b ; High 4 bits and the low 4 bits flags.
	db 0         ; base 24-31

; offset 0x10
gdt_data:            ; DS, SS, ES, FS, GS
        dw 0xffff    ; Segment Limits
        dw 0         ; Base first 0-15 bits
        dw 0         ; Base 16-23 bits
        db 0x92      ; Access Byte
        db 11001111b ; High 4 bits and the low 4 bits flags.
        db 0         ; base 24-31
gdt_end:
gdt_descriptor:
	dw gdt_end - gdt_start-1
	dd gdt_start



; Utils only for real mode.
print:
	mov bx, 0
.loop:
	lodsb
	cmp al,0
	je .done
	call print_char
	jmp .loop
.done:
	ret

print_char:
	mov ah, 0eh
	int 0x10
	ret




; required for OS entry in BIOS start point.

message_1: db 'Annette Kernel', 0

times 510- ($ - $$) db 0
dw 0xAA55




