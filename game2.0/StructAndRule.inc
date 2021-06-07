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
; 参数：snakeAddr :dword  蛇的地址  
;返回值：eax:0 初始化失败（内存分配失败） 1：成功
	initialSnake PROTO :DWORD
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
; 参数：snakeAddr 蛇的地址  longer 长度是否要增加 1：是 0：否	
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


ENDIF

.data 

	blockRow equ 20					;格子的行数
	blockCol equ 20					;格子的列数
	blockSize equ 25				;格子的大小（边长）
	MAX_LENGTH equ 120				;蛇的最大长度
	eggCount equ 5					;蛋的数量
	
	UP equ <'W'>
	DOWN equ <'S'>
	LEFT equ <'A'>
	RIGHT equ <'D'>
	xoffset equ 6
	
