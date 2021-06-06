	.386
	.model flat,stdcall
	option casemap:none
	include StructAndRule.inc
	include windows.inc
	include kernel32.inc
	include user32.inc

	GlobalAlloc PROTO :DWORD,:DWORD
	.data
	headrightpath db ".\resrc\headright.bmp",0
	headleftpath db ".\resrc\headleft.bmp",0
	headuppath db ".\resrc\headup.bmp",0
	headdownpath db ".\resrc\headdown.bmp",0
	bodypath db ".\resrc\body.bmp",0
	eggpath db ".\resrc\egg.bmp",0
	bckpath db ".\resrc\mybck.bmp",0
	
	.code 

		
; =============== 初始化 蛇 ========================
; 参数：snakeAddr :dword  蛇的地址  
; 全局变量：blockSize，MAX_LENGTH
;返回值：eax:0 初始化失败（内存分配失败） 1：成功
	initialSnake proc,
		snakeAddr :dword
	
		mov edi,snakeAddr
		mov dword ptr [edi+8],2						;初始化len
		;分配数组 初始化节点位置 (10,10) (9,10)
		invoke GlobalAlloc,GMEM_ZEROINIT,MAX_LENGTH*4
		cmp eax,0
		jz iniErro
		mov dword ptr [edi] ,eax						;初始化px
		mov dword ptr [eax],10*blockSize-xoffset
		mov dword ptr [eax+4],9*blockSize-xoffset
		invoke GlobalAlloc,GMEM_ZEROINIT,MAX_LENGTH*4
		cmp eax,0
		jz iniErro
		mov dword ptr [edi+4],eax						;初始化py
		mov dword ptr [eax],10*blockSize
		mov dword ptr [eax+4],10*blockSize

		mov dword ptr [edi+12],RIGHT				;初始化direction

		mov dword ptr [edi+16],offset headrightpath			;初始化srcHead
		mov dword ptr [edi+20],offset bodypath					;初始化srcBody
		jmp exit
	iniErro:
		xor eax,eax
		jmp exit
	exit:
		mov eax,1
		 
		ret
	initialSnake endp

	end