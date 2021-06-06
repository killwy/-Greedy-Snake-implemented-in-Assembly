

	.386
	.model flat,stdcall
	option casemap:none
	include StructAndRule.inc

	.code 


; ====================== 设置蛋属性 ===========================================
; 参数，5个dword ：eggsAddr index   ,    newX  ,    newY  , newColor  , newVisible
;				 蛋数组地址 蛋数组下标，新的X坐标，新的Y坐标，新的颜色  ，是否显示
; 若为-1，表示该属性不变		全局变量：eggCount
;返回值：无
	setEgg proc ,
		 eggsAddr :dword,index :dword,newX :dword,newY :dword,newColor :dword,newVisible :dword
		pushad
		
		mov esi,eggsAddr

		mov edi,index
		cmp edi,dword ptr eggCount
		jge errIndex
		cmp edi,0
		jl errIndex
		shl edi,4   ;4取决于EGG结构的大小

		mov eax,dword ptr newX
		cmp eax,-1
		je tag1
		mov dword ptr[esi+edi],eax
tag1:		
		mov eax,dword ptr newY
		cmp eax,-1
		je tag2
		mov dword ptr[esi+edi+4],eax
tag2:
		mov eax,dword ptr newColor
		cmp eax,-1
		je tag3
		mov dword ptr[esi+edi+8],eax
tag3:
		mov eax,dword ptr newVisible
		cmp eax,-1
		je exit
		mov dword ptr[esi+edi+12],eax
errIndex:

exit:
		popad
		ret
	setEgg endp


	end
