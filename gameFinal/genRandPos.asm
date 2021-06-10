	.386
	.model flat,stdcall
	option casemap:none
	include StructAndRule.inc
	include windows.inc
	include kernel32.inc
	include user32.inc

	GetTickCount PROTO
	GlobalAlloc PROTO :DWORD,:DWORD
	.code 

	
; ======================  生成 随机坐标（多个） =================
; 参数：snakeAddr :dword 蛇的地址
; 全局变量：blockRow，blockCol,eggCount，blockSize
; 返回值：eax :记录随机数的数组首地址 
	genRandPos proc ,
		snakeAddr :dword


	;原理：Rand_Number = (Rand_Seed * X + Y) mod Z   x、y为素数
		local pos[eggCount*2] :dword
		local sLen:dword
		local num:dword

		
		mov dword ptr num,0
		;lea eax,pos
		;lea ebx, dword ptr [pos]
		;lea ecx, dword ptr [ebx]
		mov ebx,snakeAddr
		mov edi,dword ptr[ebx]
		mov esi,dword ptr[ebx+4]
		mov eax,dword ptr[ebx+8]
		mov dword ptr sLen ,eax
getRand:
		mov ebx,num
		cmp ebx,eggCount
		jge randFinish
		invoke GetTickCount
		mov ecx,23
		mul ecx
		add eax,13
		xor edx,edx
		mov ecx,blockCol
		div ecx	
		mov eax,edx
		mov ecx,blockSize
		mul ecx
		mov dword ptr [pos+8*ebx],eax ;x坐标
		invoke GetTickCount
		mov ecx,13
		mul ecx
		add eax,5
		xor edx,edx
		mov ecx,blockRow
		div ecx
		mov eax,edx
		mov ecx,blockSize
		mul ecx
		mov dword ptr [pos+8*ebx+4],eax ;y坐标

		xor ecx,ecx
cmpPos1:		;和蛇比较
		cmp ecx,sLen
		jge cmpPos1Finish
		mov eax,dword ptr[edi+4*ecx]
		add eax,xoffset
		mov edx,dword ptr[esi+4*ecx]
		inc ecx
		mov ebx,num
		cmp eax,dword ptr[pos+8*ebx];比较x
		jne cmpPos1
		cmp edx,dword ptr[pos+8*ebx+4];比较y
		jne cmpPos1
		jmp getRand ;相同则重新生成

cmpPos1Finish:

		lea ebx,pos
		mov ecx,num
		mov eax,dword ptr[ebx+8*ecx]
		mov edx,dword ptr[ebx+8*ecx+4]
		mov ecx,-1
cmpPos2:		;和随机数比较
		inc ecx
		cmp ecx,num
		jge cmpPos2Finish
		cmp eax,dword ptr[pos+8*ecx];比较x
		jne cmpPos2
		cmp edx,dword ptr[pos+8*ecx+4];比较y
		jne cmpPos2
		jmp getRand
cmpPos2Finish:
		inc dword ptr num
		jmp getRand
randFinish:
		invoke GlobalAlloc,GMEM_ZEROINIT,eggCount*2*4
		xor ebx,ebx
copy2mem:
		cmp ebx,eggCount*2
		jge exit
		mov edx,dword ptr[pos+ebx*4]
		mov dword ptr [eax+4*ebx],edx
		inc ebx
		jmp copy2mem
exit:
		ret
	genRandPos endp



	end
