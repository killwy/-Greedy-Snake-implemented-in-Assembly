.386
.model flat,stdcall
option casemap:none

	include DataStructure.inc
	scanf PROTO C :ptr sbyte ,:vararg
	printf PROTO C :dword ,:vararg

.data

	szEggInfo byte "egg[%d]:x=[%d],y=[%d],srcColor=[%d],visible=[%d]",0ah,0
	szSnakeInfo byte "snake:  direction=%d,len=%d",0ah,0
	szNodeInfo byte "x[%d]=%d , y[%d]=%d ",0ah,0
	szEnter byte " ",0ah,0
	
	eggCount equ 5					;蛋的数量
	snake SNAKE<>					;蛇
	eggs EGG eggCount dup(<>)		;egg数组

	array1 dword MAX_LENGTH dup(0)	;开辟一个内存，snake.px 指向该地址
	array2 dword MAX_LENGTH dup(0)	;开辟一个内存，snake.py 指向该地址


	.code

	
	; =============== 初始化 蛇 ========================
; 参数：  全局变量：snake,array1、array2
;返回值：无
	initialSnake proc 
	
		;初始长度
		mov dword ptr snake.len,2
		;初始节点位置
		mov dword ptr [array1],10
		mov dword ptr [array2],10
		mov dword ptr [array1+4],9
		mov dword ptr [array2+4],10
		lea eax,array1
		mov snake.px ,eax
		lea eax,array2
		mov snake.py,eax
		;初始方向
		mov dword ptr snake.direction,3
	ret
	initialSnake endp

; ================ 打印 蛋  相关信息（到控制台）========================
;参数：index:dword 数组下标   全局变量：eggs
;返回值：无
	printEgg proc ,
		index :dword
		
		local destEgg:EGG
		push edi
		push ebx
		push eax
		mov edi,index
		shl edi,4
		mov eax,dword ptr[eggs+edi]
		mov dword ptr destEgg.x,eax
		mov eax,dword ptr[eggs+edi+4]
		mov dword ptr destEgg.y,eax
		mov eax,dword ptr[eggs+edi+8]
		mov dword ptr destEgg.srcColor,eax
		mov eax,dword ptr[eggs+edi+12]
		mov dword ptr destEgg.visible,eax
		pop eax
		pop ebx
		pop edi
		invoke printf,offset szEggInfo,index,destEgg.x,destEgg.y,destEgg.srcColor,destEgg.visible
		ret 
	printEgg endp

; ====================== 设置蛋属性 ===========================================
; 参数，5个dword ： index   ,    newX  ,    newY  , newColor  , newVisible
;				 蛋数组下标，新的X坐标，新的Y坐标，新的颜色  ，是否显示
; 若为-1，表示该属性不变		全局变量：eggs、eggCount
;返回值：无
	setEgg proc ,
		 index :dword,newX :dword,newY :dword,newColor :dword,newVisible :dword
		
		mov edi,index
		cmp edi,dword ptr eggCount
		jge tag4
		cmp edi,0
		jl tag4
		shl edi,4   ;4取决于EGG结构的大小

		mov eax,dword ptr newX
		cmp eax,-1
		je tag1
		mov dword ptr[eggs+edi],eax
tag1:		
		mov eax,dword ptr newY
		cmp eax,-1
		je tag2
		mov dword ptr[eggs+edi+4],eax
tag2:
		mov eax,dword ptr newColor
		cmp eax,-1
		je tag3
		mov dword ptr[eggs+edi+8],eax
tag3:
		mov eax,dword ptr newVisible
		cmp eax,-1
		je tag4
		mov dword ptr[eggs+edi+12],eax
tag4:

		ret
	setEgg endp

; =================== 打印 蛇 相关信息（到控制台）===========================
; 全局变量  snake
	printSnake proc 
		
		invoke printf,offset szEnter
		invoke printf,offset szSnakeInfo,snake.direction,snake.len
		xor ebx,ebx
		mov esi,dword ptr [snake.px] 
		mov edi,dword ptr [snake.py]	
keepOn:
		
		mov eax,dword ptr [esi+4*ebx]
		
		mov edx,dword ptr [edi+4*ebx]
		invoke printf,offset szNodeInfo,ebx,eax,ebx,edx
		inc ebx
		cmp ebx,dword ptr snake.len
		jl keepOn
		
	ret
	 printSnake endp					

; ================== 判断蛇是否碰到了自己的身体 =============================
;参数：无   返回值：eax 0：没有碰到  eax 1: 碰到了	 全局变量：snake
		isHeadMeetBody proc 
		
		local headX:dword
		local headY:dword

		mov edi,dword ptr [snake.px]
		mov esi,dword ptr [snake.py]

		mov eax,dword ptr [edi]
		mov dword ptr headX,eax
		mov eax,dword ptr [esi]
		mov dword ptr headY,eax
		mov ecx,dword ptr snake.len
		dec ecx
		xor ebx,ebx
		xor eax,eax
check:	
		inc ebx
		mov eax,dword ptr [edi+4*ebx]
		mov ecx,dword ptr [esi+4*ebx]
		cmp eax,dword ptr headX
		jne isLoop
		cmp ecx,dword ptr headY
		jne isLoop
		jmp haveMeet
isLoop:	
		cmp ebx,ecx
		jl check

		mov eax,0	;没有碰到
		jmp exit
haveMeet:
		mov eax,1   ;碰到了
		jmp exit

exit:
	ret
	isHeadMeetBody endp

; ==================  蛇移动  ===============================================
; 参数：无   longer:dword 长度是否要增加 1：是 0：否	全局变量：snake
; 返回值： 无
	moveSnake proc ,
		longer : dword
		

		cmp dword ptr snake.len,1
		jle updateHead		
		cmp dword ptr longer,0 
		je noLonger
		inc snake.len
noLonger:
		mov ebx,snake.len
		mov edi,snake.px 
		mov esi,snake.py   
updateBody:
		dec ebx
		mov eax,dword ptr [edi+4*ebx-4]
		mov ecx,dword ptr [esi+4*ebx-4]
		mov dword ptr[edi+4*ebx],eax
		mov dword ptr[esi+4*ebx],ecx
		cmp ebx,1
		jg updateBody
updateHead:
		mov edx,dword ptr snake.direction
		cmp edx,0
		je Up
		cmp edx,1
		je Down
		cmp edx,2
		je Left
		cmp edx,3
		je Right
		jmp errDirection
Up:
		mov ebx,snake.py
		dec dword ptr [ebx]
		jmp exit
Down:	
		mov ebx,snake.py
		inc dword ptr[ebx]
		jmp exit
Left:
		mov ebx,snake.px
		dec dword ptr[ebx]
		jmp exit
Right:
		mov ebx,snake.px
		inc dword ptr [ebx]
		jmp exit
errDirection:
		jmp exit

exit:  

	ret
	moveSnake endp

; ================== 检查所有的蛋 ===========================================
; 参数：无			全局变量：snack，eggs，eggCount
; 返回值：eax  1:吃到了正确的蛋   0：没有吃到蛋   -1：吃到了错误的蛋
	CheckAllEgg proc 
		
		
		local headX:dword
		local headY:dword
	
		mov edi, snake.px
		mov eax, dword ptr[edi]
		mov headX,eax
		mov edi, snake.py
		mov eax, dword ptr[edi]
		mov headY,eax
		

		xor ebx,ebx
searchEgg:
		cmp ebx,eggCount
		jge searchFinish
		shl ebx,4   ;4取决于EGG结构的大小
		mov eax,dword ptr[eggs+ebx] 
		mov edx,dword ptr[eggs+ebx+4]
		inc ebx

		cmp eax,dword ptr headX
		jne searchEgg
		cmp edx,dword ptr headY
		jne searchEgg

		dec ebx
		cmp ebx,0
		je rightOne
		mov eax,-1		;吃到了错误的蛋	
		jmp exit

rightOne:
		mov eax,1		;吃到了正确的蛋
		jmp exit	

searchFinish:
		mov eax,0		;没有吃到
		jmp exit
exit:
		ret
	CheckAllEgg endp


