	.386
	.model flat,stdcall
	option casemap:none
	include StructAndRule.inc

	
	

	.code 


	;1是否撞到2
	isMeetAnother proc,
		snake1Addr:dword,
		snake2Addr:dword

		local headX:dword
		local headY:dword
		local len:dword
		
		mov edi,snake1Addr
		mov esi,snake2Addr
		
		mov eax,dword ptr[esi+8]
		mov len,eax
		mov ebx,dword ptr[edi] ;px1
		mov eax,dword ptr[ebx] ;x0
		mov headX,eax
		mov ebx,dword ptr[edi+4]; py1
		mov eax,dword ptr[ebx]	; y0
		mov headY,eax

		xor ecx,ecx
keepCmp:		
		cmp ecx,len
		jge noMeet
		mov ebx,dword ptr[esi] ;px2
		mov edx,dword ptr[ebx+ecx*4] ;x
		cmp dword ptr headX,edx
		je cmpY
		inc ecx
		jmp keepCmp
cmpY:
		mov ebx,dword ptr[esi+4]; py2
		mov edx,dword ptr[ebx+ecx*4]	; y
		cmp dword ptr headY,edx
		je haveMeet
		inc ecx
		jmp keepCmp
noMeet:
		xor eax,eax
		jmp exit
haveMeet:
		mov eax,1
		jmp exit
exit:
		ret
	isMeetAnother endp
	;让镜像与原蛇反向
	changeDirection proc uses edi esi ebx,
				snake1Addr :dword,
				snake2Addr :dword
		
		mov edi,snake1Addr
		mov esi,snake2Addr
		mov ebx,dword ptr[edi+12]
		cmp ebx,UP
		je nowUp
		cmp ebx,DOWN
		je nowDown
		cmp ebx,LEFT
		je nowLeft
		cmp ebx,RIGHT
		je nowRight
		jmp exit
nowUp:
		mov dword ptr[esi+12],DOWN
		mov dword ptr[esi+16],offset headdownpath1
		jmp exit
nowDown:
		mov dword ptr[esi+12],UP
		mov dword ptr[esi+16],offset headuppath1
		jmp exit
nowLeft:
		mov dword ptr[esi+12],RIGHT
		mov dword ptr[esi+16],offset headrightpath1
		jmp exit
nowRight:
		mov dword ptr[esi+12],LEFT
		mov dword ptr[esi+16],offset headleftpath1
		jmp exit
	exit:
		ret
	changeDirection endp

	taijiGaming proc,
		snake1Addr:dword,
		snake2Addr:dword,
		eggsAddr:dword

		local longer:dword
		local eggIndex:dword
		local many:dword ;已经检查了几条蛇

		invoke changeDirection,snake1Addr,snake2Addr

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
		invoke isHeadMeetBody,snake1Addr
		cmp eax,1
		je selfKill
		invoke isMeetWall,snake1Addr
		cmp eax,1
		je selfKill
		invoke isMeetAnother,snake1Addr,snake2Addr
		cmp eax,1
		je selfKill

		invoke moveSnake ,snake2Addr,longer
		invoke isHeadMeetBody,snake2Addr
		cmp eax,1
		je selfKill
		invoke isMeetWall,snake2Addr
		cmp eax,1
		je selfKill
		invoke isMeetAnother,snake2Addr,snake1Addr
		cmp eax,1
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