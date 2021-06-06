.386
.model flat,stdcall
option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;include文件定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include       windows.inc
include       StructAndRule.inc
include       kernel32.inc
includelib    Msimg32.lib
include       gdi32.inc
includelib    gdi32.lib
include       gdiplus.inc
includelib    gdiplus.lib
include       user32.inc
includelib    user32.lib
include       kernel32.inc
includelib    kernel32.lib
include       msvcrt.inc
includelib msvcrt.lib
printf    PROTO C : dword,:vararg
IDI_ICON1 equ 101
BACK_HEIGHT EQU 500
BACK_WIDTH EQU 500
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.data
GpInput       GdiplusStartupInput<1,0,0,0>
x    dd 0
y    dd 0
snake SNAKE <> 
eggs EGG eggCount dup(<>)

szMsg byte 'x=%d , y=%d ',0ah,0
.data?
hInstance     dd        ?
hWinMain      dd        ?
hToken        dd        ?
hWindowHdc    HDC       ?
hIcon         dd        ?
hbmp_bg       DD        ?
hbmp_head     dd        ?
hbmp_body     dd        ?
hdcc          dd        ?


.const
szClassName   db       'MyClass',0
szCaptionMain db       '挑食蛇',0      ;标题名称
OutMessage db "按键%c",0ah,0
msg db "repaint!",10,0
headrightpath db ".\resrc\headright.bmp",0
	headleftpath db ".\resrc\headleft.bmp",0
	headuppath db ".\resrc\headup.bmp",0
	headdownpath db ".\resrc\headdown.bmp",0
	bodypath db ".\resrc\body.bmp",0
	egg1path db ".\resrc\egg1.bmp",0
	egg2path db ".\resrc\egg2.bmp",0
	egg3path db ".\resrc\egg3.bmp",0
	egg4path db ".\resrc\egg4.bmp",0
	egg5path db ".\resrc\egg5.bmp",0
	egg6path db ".\resrc\egg6.bmp",0
	egg7path db ".\resrc\egg7.bmp",0
	bckpath db ".\resrc\mybck.bmp",0


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                .code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;绘制界面
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
drawsnk proc uses ebx ecx edx esi edi

    local hdcMem:HDC
    local rect:RECT
    local cnt:dword
    mov esi,0
    mov edi,0
    invoke LoadImage,NULL,snake.srcHead,IMAGE_BITMAP,0,0,LR_LOADFROMFILE OR LR_CREATEDIBSECTION or LR_DEFAULTSIZE 
    mov hbmp_head,eax                                                   ;保存位图句柄
    invoke CreateCompatibleDC,hdcc                                      ;创建一个与指定设备兼容的内存设备上下文环境
    mov hdcMem,eax
    invoke SelectObject,hdcMem,hbmp_head                                ;把一个对象(位图、画笔、画刷等)选入指定的设备描述表。新的对象代替同一类型的老对象。
    invoke GetClientRect,hWinMain,addr rect                             ;获取客户端的矩形对象，保存在rect里
    mov ebx,snake.px
    mov edx,snake.py
    invoke BitBlt,hdcc,dword ptr [ebx],dword ptr [edx],rect.right,rect.bottom,hdcMem,0,0,SRCCOPY    ;在内存中将某页面上的一幅位图经过一定的变换转移到另一个页面上
    invoke DeleteDC,hdcMem
    invoke DeleteDC,hdcMem                                              ;删除设备描述表
    invoke DeleteObject,hbmp_head
    mov esi,1
    .while esi<snake.len
        
        invoke LoadImage,NULL,snake.srcBody,IMAGE_BITMAP,0,0,LR_LOADFROMFILE OR LR_CREATEDIBSECTION or LR_DEFAULTSIZE 
        mov hbmp_head,eax                                                   ;保存位图句柄
        invoke CreateCompatibleDC,hdcc                                      ;创建一个与指定设备兼容的内存设备上下文环境
        mov hdcMem,eax
        invoke SelectObject,hdcMem,hbmp_head                                ;把一个对象(位图、画笔、画刷等)选入指定的设备描述表。新的对象代替同一类型的老对象。
        invoke GetClientRect,hWinMain,addr rect                             ;获取客户端的矩形对象，保存在rect里
        mov ebx,snake.px
        mov edx,snake.py
        invoke BitBlt,hdcc,dword ptr [ebx+4*esi],dword ptr [edx+4*esi],rect.right,rect.bottom,hdcMem,0,0,SRCCOPY    ;在内存中将某页面上的一幅位图经过一定的变换转移到另一个页面上
        invoke DeleteDC,hdcMem
        invoke DeleteDC,hdcMem                                              ;删除设备描述表
        invoke DeleteObject,hbmp_head
        inc esi
    .endw
    ret
drawsnk endp

drawegg proc uses ebx ecx edx esi edi

    local hdcMem:HDC
    local rect:RECT
    mov esi,0
    mov edi,0
    mov esi,0
    .while esi<eggCount*16
        mov eax,(EGG ptr eggs[esi]).visible
        .if eax==1
        invoke LoadImage,NULL,(EGG ptr eggs[esi]).srcColor,IMAGE_BITMAP,0,0,LR_LOADFROMFILE OR LR_CREATEDIBSECTION or LR_DEFAULTSIZE 
        mov hbmp_head,eax                                                   ;保存位图句柄
        invoke CreateCompatibleDC,hdcc                                      ;创建一个与指定设备兼容的内存设备上下文环境
        mov hdcMem,eax
        invoke SelectObject,hdcMem,hbmp_head                                ;把一个对象(位图、画笔、画刷等)选入指定的设备描述表。新的对象代替同一类型的老对象。
        invoke GetClientRect,hWinMain,addr rect                             ;获取客户端的矩形对象，保存在rect里
        invoke BitBlt,hdcc,(EGG ptr eggs[esi]).x,(EGG ptr eggs[esi]).y,rect.right,rect.bottom,hdcMem,0,0,SRCCOPY    ;在内存中将某页面上的一幅位图经过一定的变换转移到另一个页面上
        invoke DeleteDC,hdcMem
        invoke DeleteObject,hbmp_head
        .endif
        add esi,16
        .endw
    ret
drawegg endp

draw proc 
    local hdcMem:HDC
    local rect:RECT
    ;加载图片
    invoke LoadImage,NULL,addr bckpath,IMAGE_BITMAP,0,0,LR_LOADFROMFILE OR LR_CREATEDIBSECTION or LR_DEFAULTSIZE 
    mov hbmp_bg,eax                                                     ;保存位图句柄
    invoke CreateCompatibleDC,hdcc                                      ;创建一个与指定设备兼容的内存设备上下文环境
    mov hdcMem,eax                                                      ;返回内存设备上下文环境的句柄
    invoke SelectObject,hdcMem,hbmp_bg                                  ;把一个对象(位图、画笔、画刷等)选入指定的设备描述表。新的对象代替同一类型的老对象。
    invoke GetClientRect,hWinMain,addr rect                                  ;获取客户端的矩形对象，保存在rect里
    invoke BitBlt,hdcc,0,0,rect.right,rect.bottom,hdcMem,0,0,SRCCOPY    ;在内存中将某页面上的一幅位图经过一定的变换转移到另一个页面上
    
    ;invoke LoadImage,NULL,addr headrightpath,IMAGE_BITMAP,0,0,LR_LOADFROMFILE OR LR_CREATEDIBSECTION or LR_DEFAULTSIZE 
    ;mov hbmp_head,eax                                                   ;保存位图句柄
    ;invoke CreateCompatibleDC,hdcc                                      ;创建一个与指定设备兼容的内存设备上下文环境
    ;mov hdcMem,eax
    ;invoke SelectObject,hdcMem,hbmp_head                                ;把一个对象(位图、画笔、画刷等)选入指定的设备描述表。新的对象代替同一类型的老对象。
    ;invoke GetClientRect,hWinMain,addr rect                             ;获取客户端的矩形对象，保存在rect里
    ;invoke BitBlt,hdcc,x,y,rect.right,rect.bottom,hdcMem,0,0,SRCCOPY    ;在内存中将某页面上的一幅位图经过一定的变换转移到另一个页面上
    ;每画一次图让它偏移10个像素单位，之后用来模拟蛇的移动
    call drawsnk
    call drawegg
    ;mov eax,x       
    ;add eax,1
    ;mov x,eax
    ;mov eax,y
    ;add eax,10
    ;mov y,eax
    ;invoke DeleteDC,hdcMem              ;删除设备描述表
    invoke DeleteObject,hbmp_bg            ;删除位图对象
    ;invoke DeleteObject,hbmp_head
    ret
draw endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;窗口过程
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcWinMain  proc     uses ebx edi esi,hWnd,uMsg,wParam,lParam
        local    @gdip
        local    @hBrush
        local hdcMem:HDC
        local rect:RECT
        LOCAL strRect:RECT
		LOCAL paint:dword
		LOCAL hdcmem:dword
	    LOCAL ps:PAINTSTRUCT
		LOCAL hdc:dword
          mov eax,uMsg
;*******************************************************************************************
              .if eax == WM_KEYDOWN
                   mov ebx, wParam
                   mov snake.direction,ebx
                  
                   invoke printf,addr OutMessage, ebx
                   ;.if snake.direction

              .endif

;*******************************************************************************************
              .if  eax ==  WM_PAINT
                   mov     ebx,hWnd
                   invoke BeginPaint,ebx,addr ps
                  .if  ebx == hWinMain
                       mov hdcc,eax  ;hdcc用来保存BeginPaint返回的hdc
                       call draw
                       invoke printf,addr msg   ;打印repaint
                   .endif
                   invoke EndPaint,ebx,addr ps
;********************************************************************************************
            .elseif  eax ==  WM_CLOSE
                invoke  DestroyWindow,hWinMain
                invoke  PostQuitMessage,NULL
;*******************************************************************************************
            .else    
                invoke DefWindowProc,hWnd,uMsg,wParam,lParam
            ret
            .endif
;********************************************************************************************
              xor      eax,eax
              ;call draw
          ret

_ProcWinMain  endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_WinMain      proc
              local longer:dword
              local eggIndex:dword
              local    @stWndClass:WNDCLASSEX                           ;定义局部变量窗口类
              local    @stMsg:MSG                                       ;定义局部变量消息

              mov longer,0
              invoke initialSnake,addr snake                             ;对蛇进行初始化
              invoke genRandPos,addr snake
              mov edi,eax
              invoke setEgg,addr eggs,0,dword ptr [edi],dword ptr [edi+4],addr egg1path,1
              invoke setEgg,addr eggs,1,dword ptr [edi+8],dword ptr [edi+12],addr egg2path,1
              invoke setEgg,addr eggs,2,dword ptr [edi+16],dword ptr [edi+20],addr egg3path,1
              invoke setEgg,addr eggs,3,dword ptr [edi+24],dword ptr [edi+28],addr egg4path,1
              invoke setEgg,addr eggs,4,dword ptr [edi+32],dword ptr [edi+36],addr egg5path,1


              invoke   GetModuleHandle,NULL                             ;返回主调进程(此进程)的可执行文件的基地址
              mov      hInstance,eax                                    ;得到的句柄存入hInstance
              invoke   RtlZeroMemory,addr @stWndClass,sizeof @stWndClass;用零填充窗口类
              invoke   LoadIcon,hInstance,IDI_ICON1
              mov      hIcon,eax
              
;*******************************************************************************************
;注册窗口类
;*******************************************************************************************
              invoke   LoadCursor,0,IDC_ARROW                           ;载入系统自带的光标 
              mov      @stWndClass.hCursor,eax                          ;光标句柄送入窗口对应光标字段
              push     hIcon                                            
              pop      @stWndClass.hIconSm                              ;图标句柄送入相应字段
              push     hInstance                
              pop      @stWndClass.hInstance                            ;实例的句柄送入相应字段
              mov      @stWndClass.cbSize,sizeof WNDCLASSEX             ;设置窗口类的大小
              mov      @stWndClass.style,CS_HREDRAW or CS_VREDRAW       ;设置窗口样式
              mov      @stWndClass.lpfnWndProc,offset _ProcWinMain      ;指定回调函数
              mov      @stWndClass.hbrBackground,COLOR_WINDOW+1         ;背景颜色
              mov      @stWndClass.lpszClassName,offset szClassName     ;设置窗口类名
              ;mov      @stWndClass.hIconSm,
              invoke   RegisterClassEx,addr @stWndClass                 ;注册窗口类
;*******************************************************************************************
;建立并显示窗口
;*******************************************************************************************
              invoke   CreateWindowEx,WS_EX_CLIENTEDGE,offset szClassName,\ 
                       offset szCaptionMain,WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,CW_USEDEFAULT\
                       ,BACK_WIDTH+20,BACK_HEIGHT+45,NULL,NULL,hInstance,NULL    ;创建window                         ;
              mov      hWinMain,eax                                      ;保存窗口的句柄
              invoke GetDC,eax                                           ;获取设备上下文
              mov  hWindowHdc,eax                                        ;保存设备上下文
              invoke   ShowWindow,hWinMain,SW_SHOWNORMAL                 ;显示窗口
              invoke   UpdateWindow,hWinMain                             ;更新窗口
;*******************************************************************************************
;消息循环
;*******************************************************************************************
              ;local snake:SNAKE
              
              
              .while      TRUE
              invoke     PeekMessage, addr @stMsg, NULL, 0, 0, PM_REMOVE
              .if           eax
                .break     .if @stMsg.message == WM_QUIT
                invoke     TranslateMessage, addr @stMsg
                invoke     DispatchMessage, addr @stMsg
              .else                                                          ;<做其他工作>
                invoke Sleep,200                                              ;休眠0.05秒
                ;判断
playGame:
		push ebx
		invoke checkAllEgg,addr snake,addr eggs
		cmp eax,-1
		je noEat
		cmp eax,0
		je rightEat
		jmp wrongEat
move:
		invoke moveSnake ,addr snake,longer
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
		invoke setEgg,addr eggs,eggIndex,-1,-1,-1,0	;将该蛋的visible设置为0
		jmp move
noEat:
		jmp move
rightEat:
		mov dword ptr longer,1 ; 吃到正确的蛋，则加长
		invoke updateEggs,addr eggs,addr snake
		jmp move
reset:
		cmp ebx,eggCount
		jge resetFinish
		;inc ebx
		jmp reset
resetFinish:
		jmp move

selfKill:
		
keepOn:



                invoke InvalidateRect,hWinMain,NULL,FALSE                    ;擦除原图使之失效，并重发WM_PAINT
                ;invoke UpdateWindow,hWinMain
                ;invoke PostMessage,hWinMain,WM_PAINT,0,0
              .endif
              .endw
              ret
_WinMain      endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
          invoke   GdiplusStartup,offset hToken,offset GpInput,NULL
          call     _WinMain
          invoke   GdiplusShutdown,hToken
          invoke   ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
end      start