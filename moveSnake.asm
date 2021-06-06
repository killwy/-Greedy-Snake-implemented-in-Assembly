	.386
	.model flat,stdcall
	option casemap:none
	include StructAndRule.inc

	.code 


	
; ==================  蛇移动  ===============================================
; 参数：snakeAddr 蛇的地址  longer 长度是否要增加 1：是 0：否	
; 全局变量：blockSize
; 返回值： 无
	moveSnake proc,
		snakeAddr :dword,
		longer:dword
		
		push eax

		mov edx,snakeAddr

		cmp dword ptr [edx+8],1		;比较长度
		jle updateHead		
		cmp dword ptr longer,0 
		je noLonger
		inc dword ptr [edx+8]		;inc snake.len
noLonger:
		mov ebx,dword ptr [edx+8]	;len
		mov edi,dword ptr [edx]		;px
		mov esi,dword ptr [edx+4]	;py
updateBody:
		dec ebx
		mov eax,dword ptr [edi+4*ebx-4]
		mov ecx,dword ptr [esi+4*ebx-4]
		mov dword ptr[edi+4*ebx],eax
		mov dword ptr[esi+4*ebx],ecx
		cmp ebx,1
		jg updateBody
updateHead:
		mov edi,snakeAddr
		mov edx,dword ptr [edi+12]	;snake.direction
		cmp edx,UP
		je Up
		cmp edx,DOWN
		je Down
		cmp edx,LEFT
		je Left
		cmp edx,RIGHT
		je Right
		jmp errDirection
Up:
		mov ebx,dword ptr[edi+4]	;py
		sub dword ptr [ebx],blockSize
		jmp exit
Down:	
		mov ebx,dword ptr[edi+4]	;py
		add dword ptr[ebx],blockSize
		jmp exit
Left:
		mov ebx,dword ptr[edi]		;px
		sub dword ptr[ebx],blockSize
		jmp exit
Right:
		mov ebx,dword ptr[edi]		;px
		add dword ptr [ebx],blockSize
		jmp exit
errDirection:
		jmp exit

exit:  
		pop eax
	ret
	moveSnake endp


	end