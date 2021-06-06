	.386
	.model flat,stdcall
	option casemap:none,
			proc:private

	includelib msvcrt.lib
	include StructAndRule.inc
	include msvcrt.inc
	include \masm32\include\kernel32.inc

	printf PROTO C: DWORD ,:VARARG
	scanf PROTO C:PTR SBYTE,:VARARG
	Sleep PROTO :DWORD

	

	
	.data
		
		szEggInfo byte "egg[%d]:x=[%d],y=[%d],srcColor=[%d],visible=[%d]",0ah,0
		szSnakeInfo byte "snake:  direction=%c,len=%d",0ah,0
		szNodeInfo byte "x[%d]=%d , y[%d]=%d ",0ah,0
		szEnter byte " ",0ah,0
		szWrongEat byte '吃错了',0ah,0
		szNoEat byte '没吃到',0ah,0
		szRightEat byte '吃对了',0ah,0
		szSelfKill byte '自杀了',0ah,0

		szTestRand byte 'x=%d , y=%d',0ah,0
		
	; =================  界面参数  ========================


	.code

	; ================ 打印 蛋  相关信息（到控制台）========================
;参数：eggsAddr 蛋结构数组地址 index:dword 数组下标   
;返回值：无
	printEgg proc,
		eggsAddr :dword,
		index :dword

		local destEgg:EGG

		pushad

		mov esi,eggsAddr

		mov edi,index
		shl edi,4
		mov eax,dword ptr[esi+edi]
		mov dword ptr destEgg.x,eax
		mov eax,dword ptr[esi+edi+4]
		mov dword ptr destEgg.y,eax
		mov eax,dword ptr[esi+edi+8]
		mov dword ptr destEgg.srcColor,eax
		mov eax,dword ptr[esi+edi+12]
		mov dword ptr destEgg.visible,eax
		invoke printf,offset szEggInfo,index,destEgg.x,destEgg.y,destEgg.srcColor,destEgg.visible
		popad
		ret 
	printEgg endp

	; =================== 打印 蛇 相关信息（到控制台）===========================
; 全局变量  snake
	printSnake proc ,
		snake:SNAKE
		push eax
		push ecx
		;invoke printf,offset szEnter
		invoke printf,offset szSnakeInfo,snake.direction,snake.len
		xor ebx,ebx
		mov esi,snake.px
		mov edi,snake.py
keepOn:
		
		mov eax,dword ptr [esi+4*ebx]
		
		mov edx,dword ptr [edi+4*ebx]
		invoke printf,offset szNodeInfo,ebx,eax,ebx,edx
		inc ebx
		cmp ebx,dword ptr snake.len
		jl keepOn
		
		pop ecx
		pop eax
	ret
	 printSnake endp					


	tryGame proc PUBLIC

		local snake:SNAKE
		local eggs[eggCount]:EGG
		local longer:dword	;是否变长标志位
		local eggIndex:dword ;用来帮助输出


		mov dword ptr longer,0
		
		;模拟实验

		;初始化蛇头坐标为（10，10），方向为右（x逐渐增大）
		invoke initialSnake,addr snake
		invoke printSnake,snake
        invoke genRandPos,addr snake
        mov edi,eax
        invoke setEgg,addr eggs,0,dword ptr [edi],dword ptr [edi+4],1111,1
        invoke setEgg,addr eggs,1,dword ptr [edi+8],dword ptr [edi+12],2222,1
        invoke setEgg,addr eggs,2,dword ptr [edi+16],dword ptr [edi+20],3333,1
        invoke setEgg,addr eggs,3,dword ptr [edi+24],dword ptr [edi+28],4444,1
        invoke setEgg,addr eggs,4,dword ptr [edi+32],dword ptr [edi+36],5555,1
		
		invoke printEgg,addr eggs,0
		invoke printEgg,addr eggs,1
		invoke printEgg,addr eggs,2
		invoke printEgg,addr eggs,3
		invoke printEgg,addr eggs,4
		invoke printf,offset szEnter

		;设置0号蛋的坐标为（20，10）
		invoke setEgg,addr eggs,0,20*blockSize,10*blockSize,999,1
		invoke printEgg,addr eggs,0
		;1号蛋的坐标为（16，10）
		invoke setEgg,addr eggs,1,16*blockSize,10*blockSize,999,1
		invoke printEgg,addr eggs,1
		
		
		mov ebx,100
playGame:
		invoke Sleep,1000
		invoke printf,offset szEnter
		push ebx
		invoke checkAllEgg,addr snake,addr eggs
		cmp eax,-1
		je noEat
		cmp eax,0
		je rightEat
		jmp wrongEat
move:
		invoke moveSnake ,addr snake,longer
		invoke printSnake, snake
		mov dword ptr longer,0
		invoke isHeadMeetBody,addr snake
		cmp eax,1
		je selfKill
		invoke isMeetWall,addr snake
		cmp eax,1
		je selfKill
		jmp keepOn
wrongEat:
		mov eggIndex,eax
		invoke printf,offset szWrongEat
		invoke printEgg,addr eggs,eggIndex
		invoke setEgg,addr eggs,eggIndex,-1,-1,-1,0	;将该蛋的visible设置为0
		invoke printEgg,addr eggs,eggIndex
		jmp move
noEat:
		invoke printf,offset szNoEat
		jmp move
rightEat:
		invoke printf,offset szRightEat
		mov dword ptr longer,1 ; 吃到正确的蛋，则加长
		invoke updateEggs,addr eggs,addr snake
		xor ebx,ebx
reset:
		cmp ebx,eggCount
		jge resetFinish
		invoke printEgg,addr eggs,ebx
		inc ebx
		jmp reset
resetFinish:
		jmp move
keepOn: 
		pop ebx
		dec ebx
		cmp ebx,0
		jg playGame
		jmp exit
selfKill:
		invoke printf,offset szSelfKill
exit:

		invoke ExitProcess,0
		
	
	tryGame endp
	end tryGame