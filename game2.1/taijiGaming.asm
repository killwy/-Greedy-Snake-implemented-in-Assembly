	.386
	.model flat,stdcall
	option casemap:none
	include StructAndRule.inc

	.code 


	isMeetAnother proc,
		snake1Addr:dword,
		snake2Addr:dword
		
		mov edi,snake1Addr
		mov esi,snake2Addr
		
		mov ebx,dword ptr[edi] ;px1
		mov eax,dword ptr[ebx] ;x0

		mov ebx,dword ptr[esi] ;px2
		mov edx,dword ptr[ebx] ;x0

		cmp eax,edx
		je cmpY
		jmp noMeet
cmpY:
		mov ebx,dword ptr[edi+4]; py1
		mov eax,dword ptr[ebx]	; y0

		mov ebx,dword ptr[esi+4]; py2
		mov edx,dword ptr[ebx]	; y0
		
		cmp eax,edx
		je haveMeet
		jmp noMeet
noMeet:
		xor eax,eax
		jmp exit
haveMeet:
		mov eax,1
		jmp exit
exit:
		ret
	isMeetAnother endp


	taijiGaming proc,
		snake1Addr:dword,
		snake2Addr:dword,
		eggsAddr:dword

		local longer:dword
		local eggIndex:dword
		local many:dword ;已经检查了几条蛇

		mov longer,0
		mov eggIndex,0
		mov many,0		
playGame:
		invoke checkAllEgg,snake1Addr,eggsAddr
		cmp eax,-1
		je noEat
		cmp eax,0
		je rightEat
		jmp wrongEat
checkAnother:
		inc many
		cmp dword ptr many,1
		jg move
		invoke checkAllEgg,snake2Addr,eggsAddr
		cmp eax,-1
		je noEat
		cmp eax,0
		je rightEat
		jmp wrongEat
move:
		invoke moveSnake ,snake1Addr,longer
		invoke moveSnake ,snake2Addr,longer
		invoke isHeadMeetBody,snake1Addr
		cmp eax,1
		je selfKill
		invoke isMeetWall,snake1Addr
		cmp eax,1
		je selfKill
		invoke isMeetAnother,snake1Addr,snake2Addr
		cmp eax,0
		je selfKill
		jmp keepOn
wrongEat:
		mov eggIndex,eax
		invoke setEgg,eggsAddr,eggIndex,-1,-1,-1,0	;将该蛋的visible设置为0
		jmp checkAnother
noEat:
		
		jmp checkAnother
rightEat:
		inc dword ptr longer ; 吃到正确的蛋，则加长
		invoke updateEggs,eggsAddr,snake1Addr
		jmp checkAnother

resetFinish:
		jmp move

selfKill:
		xor eax,eax
		jmp exit
keepOn:
		mov eax,1
		jmp exit	
exit:
		ret
	taijiGaming endp

	end
