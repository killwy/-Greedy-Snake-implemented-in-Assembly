	.386
	.model flat,stdcall
	option casemap:none
		
	include StructAndRule.inc

	.code 

	normalGaming proc,
		snakeAddr:dword,
		eggsAddr:dword

		local longer:dword
		local eggIndex:dword

		mov longer,0
		mov eggIndex,0
		
playGame:
		invoke checkAllEgg,snakeAddr,eggsAddr
		cmp eax,-1
		je noEat
		cmp eax,0
		je rightEat
		jmp wrongEat
move:
		invoke moveSnake ,snakeAddr,longer
		mov dword ptr longer,0
		invoke isHeadMeetBody,snakeAddr
		cmp eax,1
		je selfKill
		invoke isMeetWall,snakeAddr
		cmp eax,1
		je selfKill
		jmp keepOn
wrongEat:
		mov eggIndex,eax
		invoke setEgg,eggsAddr,eggIndex,-1,-1,-1,0	;将该蛋的visible设置为0
		jmp move
noEat:
		jmp move
rightEat:
		mov dword ptr longer,1 ; 吃到正确的蛋，则加长
		invoke updateEggs,eggsAddr,snakeAddr
		jmp move
reset:
		cmp ebx,eggCount
		jge resetFinish
		;inc ebx
		jmp reset
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
	normalGaming endp

	end
