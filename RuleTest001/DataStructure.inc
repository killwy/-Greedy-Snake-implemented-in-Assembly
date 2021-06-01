

.386
.model flat,stdcall
option casemap:none

;externdef blockRow:ABS,blockCol:ABS,blockSize:ABS,MAX_LENGTH:ABS

; ================== 蛇 的数据结构 =====================
	SNAKE STRUCT
		px dword ?					;X数组的首地址
		py dword ?					;Y数组的首地址
		srcHead dword ?				;存放头部图片的地址
		srcBody dword ?				;存放身体图片的地址
		len dword ? 				;长度
		direction dword ?			;方向 0:上  1：下  2：左   3：右
	SNAKE ENDS
; =================== 蛋 的数据结构 ====================
	EGG STRUCT
		x dword ?					;x坐标
		y dword ?					;y坐标
		srcColor dword ?			;该egg的图片地址
		visible dword ?				;蛋是否可见
	EGG ENDS


	

	.data 
	
	; =================  界面参数  ========================
	blockRow equ 20					;格子的行数
	blockCol equ 20					;格子的列数
	blockSize equ 10				;格子的大小（边长）

	MAX_LENGTH equ 120				;蛇的最大长度
	

	.code

