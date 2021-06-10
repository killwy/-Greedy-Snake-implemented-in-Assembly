IFNDEF 

; ================== 蛇 的数据结构 =====================
	SNAKE STRUCT
		px dword ?					;X数组的首地址
		py dword ?					;Y数组的首地址
		len dword ? 				;长度
		direction dword ?			;方向 0:上  1：下  2：左   3：右
		srcHead dword ?				;存放头部图片的地址
		srcBody dword ?				;存放身体图片的地址
	SNAKE ENDS
; =================== 蛋 的数据结构 ====================
	EGG STRUCT
		x dword ?					;x坐标
		y dword ?					;y坐标
		srcColor dword ?			;该egg的图片地址
		visible dword ?				;蛋是否可见
	EGG ENDS

; =============== 初始化 蛇 ================================================
; 参数：snakeAddr ,x0,y0,y0,y1,headPathAddr
;返回值：eax:0 初始化失败（内存分配失败） 1：成功
	initialSnake PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
; ====================== 设置蛋属性 ========================================
; 参数，5个dword ：eggsAddr index   ,    newX  ,    newY  , newColor  , newVisible
;				 蛋数组地址 蛋数组下标，新的X坐标，新的Y坐标，新的颜色  ，是否显示
; 若为-1，表示该属性不变		全局变量：eggCount
;返回值：无
	setEgg PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
; ================== 判断蛇是否碰到了自己的身体 ============================
;参数：snakeAddr :dword 蛇的地址  
;返回值：eax 0：没有碰到  eax 1: 碰到了	
	isHeadMeetBody PROTO:DWORD
; ==================  蛇移动  ===============================================
; 参数：snakeAddr 蛇的地址  longer 长度是否要增加 0：否	其他：是
; 返回值： 无
	moveSnake PROTO :DWORD,:DWORD
; ================== 检查所有的蛋 ===========================================
; 参数：snakeAddr 蛇地址	eggsAddr 蛋结构数组地址		
; 全局变量：eggCount
; 返回值：eax  -1：吃到了错误的蛋   其他：吃到的蛋的编号
	checkAllEgg PROTO:DWORD,:DWORD
; ========================== 是否撞墙 =========================
; 参数：snakeAddr :dword 蛇的地址    
; 全局变量：blockRow,blockCol
; 返回值：  eax: 0 没有碰到  1 碰到了
	isMeetWall PROTO:DWORD
; ======================  生成 随机坐标（多个） =================
; 参数：snakeAddr :dword 蛇的地址
; 全局变量：blockRow，blockCol,eggCount
; 返回值：eax :记录随机数的数组首地址 
	genRandPos PROTO:DWORD
; ============== 刷新所有蛋的数据 =====================
; 参数： eggsAddr 蛋数组的地址   snakeAddr 蛇地址
; 全局变量： eggCount
; 返回值： 无
; 描述： 随机生成数组，来更新蛋数组的坐标，并让Visible=1，srcColor不变
	updateEggs PROTO:DWORD,:DWORD

; ============ 普通模式 ===========================
; 参数：蛇地址  蛋地址
; 返回值： eax=0 蛇死亡  eax=1 蛇正常
	normalGaming PROTO:DWORD,:DWORD

; ============ 太极模式 ===========================
; 参数：蛇1地址 蛇2地址 蛋地址
; 返回值： eax=0 蛇死亡  eax=1 蛇正常
	taijiGaming PROTO:DWORD,:DWORD,:DWORD
	
; ============ 反转模式 ===========================
; 参数：蛇地址 蛋地址
; 返回值： eax=0 蛇死亡  eax=1 蛇正常
	reverseGaming PROTO:DWORD,:DWORD
ENDIF

.data 

	blockRow equ 20					;格子的行数
	blockCol equ 20					;格子的列数
	blockSize equ 25				;格子的大小（边长）
	MAX_LENGTH equ 120				;蛇的最大长度
	eggCount equ 5					;蛋的数量
	xoffset equ 6
	UP equ <'W'>
	DOWN equ <'S'>
	LEFT equ <'A'>
	RIGHT equ <'D'>
	isPause dd 0
	isOver dd 0
	isBegin dd 1
	mode dd 0
	headrightpath db ".\resrc\headright.bmp",0
	headleftpath db ".\resrc\headleft.bmp",0
	headuppath db ".\resrc\headup.bmp",0
	headdownpath db ".\resrc\headdown.bmp",0
	headrightpath1 db ".\resrc\headright1.bmp",0
	headleftpath1 db ".\resrc\headleft1.bmp",0
	headuppath1 db ".\resrc\headup1.bmp",0
	headdownpath1 db ".\resrc\headdown1.bmp",0
	bodypath db ".\resrc\body.bmp",0
	bodypath1 db ".\resrc\body1.bmp",0
	egg1path db ".\resrc\egg1.bmp",0
	egg2path db ".\resrc\egg2.bmp",0
	egg3path db ".\resrc\egg3.bmp",0
	egg4path db ".\resrc\egg4.bmp",0
	egg5path db ".\resrc\egg5.bmp",0
	egg6path db ".\resrc\egg6.bmp",0
	egg7path db ".\resrc\egg7.bmp",0
	bckpath db ".\resrc\mybck.bmp",0
	stoppath db ".\resrc\stop.bmp",0
	endpath db ".\resrc\end.bmp",0
	beginpath db ".\resrc\begin.bmp",0
	pipepath db "\\.\pipe\mypipe",0
	
	mem1x dword ?
	mem1y dword ?
	mem2x dword ?
	mem2y dword ?
	memrand dword ?