	.386
	.model flat,stdcall
	option casemap:none
	include StructAndRule.inc

	.code 


	
; ================== 检查所有的蛋 ===========================================
; 参数：snakeAddr 蛇地址	eggsAddr 蛋结构数组地址		
; 全局变量：eggCount
; 返回值：eax  -1：吃到了错误的蛋   其他：吃到的蛋的编号
	checkAllEgg proc ,
		snakeAddr :dword,
		eggsAddr :dword
		
		local headX:dword
		local headY:dword
			
		mov edi,snakeAddr
		mov esi,eggsAddr


		mov eax, dword ptr[edi]
		mov headX,eax
		mov eax, dword ptr[edi+4]
		mov headY,eax

		xor ebx,ebx
searchEgg:
		cmp ebx,eggCount
		jge searchFinish
		shl ebx,4   ;4取决于EGG结构的大小

		cmp dword ptr[esi+ebx+12],1 ;判断visible == 1 ？
		jne noVisible

		mov eax,dword ptr[esi+ebx] 
		mov edx,dword ptr[esi+ebx+4]
		shr ebx,4
		inc ebx
		
		mov ecx,headX
		cmp eax,dword ptr [ecx]
		jne searchEgg
		mov ecx,headY
		cmp edx,dword ptr [ecx]
		jne searchEgg

		dec ebx
		mov eax,ebx  ;返回吃到的蛋编号
		jmp exit

noVisible:
		shr ebx,4
		inc ebx
		jmp searchEgg

searchFinish:
		mov eax,-1		;没有吃到
		jmp exit
exit:
		ret
	checkAllEgg endp

	end
