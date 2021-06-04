	.386
	.model flat,stdcall
	option casemap:none
	include StructAndRule.inc

	.code 


	

; ========================== 是否撞墙 =========================
; 参数：snakeAddr :dword 蛇的地址    
; 全局变量：blockRow,blockCol
; 返回值：  eax: 0 没有碰到  1 碰到了
	isMeetWall proc ,
		snakeAddr :dword
		

		mov ebx,snakeAddr

		mov edi,dword ptr [ebx] ;px
		mov eax,dword ptr [edi]
		mov esi,dword ptr [ebx+4];py
		mov ecx,dword ptr [esi]
		
		cmp eax,0
		jl yesMeet
		cmp eax,blockCol
		jge yesMeet
		cmp ecx,0
		jl yesMeet
		cmp ecx,blockRow
		jge yesMeet
		jmp noMeet

yesMeet:
		mov eax,1
		jmp exit
noMeet:
		xor eax,eax
		jmp exit
exit:
		ret
	isMeetWall endp


	end