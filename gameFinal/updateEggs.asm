.386
	.model flat,stdcall
	option casemap:none
	include StructAndRule.inc
	include windows.inc
	include kernel32.inc
	include user32.inc


	GlobalFree PROTO:DWORD

	.code 
	
; ============== 刷新所有蛋的数据 =====================
; 描述： 随机生成数组，来更新蛋数组的坐标，并让Visible=1，srcColor不变
; 参数： eggsAddr 蛋数组的地址   snakeAddr 蛇地址
; 全局变量： eggCount
; 返回值： 无
	updateEggs proc,
		eggsAddr :dword,
		snakeAddr :dword

		invoke genRandPos,snakeAddr
		mov edi,eax
		xor ebx,ebx
reset:
		cmp ebx,eggCount
		jge resetFinish
		invoke setEgg,eggsAddr,ebx,dword ptr[edi+8*ebx],dword ptr[edi+8*ebx+4],-1,1
		inc ebx
		jmp reset
resetFinish:
		invoke GlobalFree,edi
		ret 
	updateEggs endp

	end