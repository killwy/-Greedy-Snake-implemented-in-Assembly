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
TransparentBlt PROTO stdcall:HDC,:dword,:dword,:dword,:dword,:HDC,:dword,:dword,:dword,:dword,:UINT
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
snake1 SNAKE <>
eggs EGG eggCount dup(<>)
eggs1 EGG eggCount dup(<>)
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
h_pipe        dd        ?
buf_msg       db        1024 dup(0)
num_rcv       dw        ?
.const
szClassName   db       'MyClass',0
szCaptionMain db       '挑食蛇',0      ;标题名称
OutMessage db "按键%c",0ah,0
msg db "repaint!",10,0
pipe_error_msg db "pipe error!",10,0
cnct_msg db "connected successfully!",10,0

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                .code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;绘制界面
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
initEggs proc uses edi eax
    invoke genRandPos,addr snake
    mov edi,eax
    invoke setEgg,addr eggs,0,dword ptr [edi],dword ptr [edi+4],addr egg1path,1
    invoke setEgg,addr eggs,1,dword ptr [edi+8],dword ptr [edi+12],addr egg2path,1
    invoke setEgg,addr eggs,2,dword ptr [edi+16],dword ptr [edi+20],addr egg3path,1
    invoke setEgg,addr eggs,3,dword ptr [edi+24],dword ptr [edi+28],addr egg4path,1
    invoke setEgg,addr eggs,4,dword ptr [edi+32],dword ptr [edi+36],addr egg5path,1
    invoke GlobalFree,edi
    RET
initEggs endp
drawbegin proc uses ebx ecx edx esi edi
    local hdcMem:HDC
    local rect:RECT
    ;加载图片
    invoke LoadImage,NULL,addr beginpath,IMAGE_BITMAP,0,0,LR_LOADFROMFILE OR LR_CREATEDIBSECTION or LR_DEFAULTSIZE 
    mov hbmp_bg,eax                                                     ;保存位图句柄
    invoke CreateCompatibleDC,hdcc                                      ;创建一个与指定设备兼容的内存设备上下文环境
    mov hdcMem,eax                                                      ;返回内存设备上下文环境的句柄
    invoke SelectObject,hdcMem,hbmp_bg                                  ;把一个对象(位图、画笔、画刷等)选入指定的设备描述表。新的对象代替同一类型的老对象。
    invoke GetClientRect,hWinMain,addr rect                                  ;获取客户端的矩形对象，保存在rect里
    ;invoke BitBlt,hdcc,0,0,rect.right,rect.bottom,hdcMem,0,0,SRCCOPY    ;在内存中将某页面上的一幅位图经过一定的变换转移到另一个页面上
    invoke TransparentBlt,hdcc,0,0,500,500,hdcMem,0,0,500,500,0ffffffh
    invoke DeleteDC,hdcMem
    invoke DeleteObject,hbmp_bg
    ret
drawbegin endp
drawstop proc uses ebx ecx edx esi edi
    local hdcMem:HDC
    local rect:RECT
    ;加载图片
    invoke LoadImage,NULL,addr stoppath,IMAGE_BITMAP,0,0,LR_LOADFROMFILE OR LR_CREATEDIBSECTION or LR_DEFAULTSIZE 
    mov hbmp_bg,eax                                                     ;保存位图句柄
    invoke CreateCompatibleDC,hdcc                                      ;创建一个与指定设备兼容的内存设备上下文环境
    mov hdcMem,eax                                                      ;返回内存设备上下文环境的句柄
    invoke SelectObject,hdcMem,hbmp_bg                                  ;把一个对象(位图、画笔、画刷等)选入指定的设备描述表。新的对象代替同一类型的老对象。
    invoke GetClientRect,hWinMain,addr rect                                  ;获取客户端的矩形对象，保存在rect里
    ;invoke BitBlt,hdcc,0,0,rect.right,rect.bottom,hdcMem,0,0,SRCCOPY    ;在内存中将某页面上的一幅位图经过一定的变换转移到另一个页面上
    invoke TransparentBlt,hdcc,0,0,500,500,hdcMem,0,0,500,500,0ffffffh
    invoke DeleteDC,hdcMem
    invoke DeleteObject,hbmp_bg
    ret
drawstop endp

drawend proc uses ebx ecx edx esi edi
    local hdcMem:HDC
    local rect:RECT
    ;加载图片
    invoke LoadImage,NULL,addr endpath,IMAGE_BITMAP,0,0,LR_LOADFROMFILE OR LR_CREATEDIBSECTION or LR_DEFAULTSIZE 
    mov hbmp_bg,eax                                                     ;保存位图句柄
    invoke CreateCompatibleDC,hdcc                                      ;创建一个与指定设备兼容的内存设备上下文环境
    mov hdcMem,eax                                                      ;返回内存设备上下文环境的句柄
    invoke SelectObject,hdcMem,hbmp_bg                                  ;把一个对象(位图、画笔、画刷等)选入指定的设备描述表。新的对象代替同一类型的老对象。
    invoke GetClientRect,hWinMain,addr rect                                  ;获取客户端的矩形对象，保存在rect里
    ;invoke BitBlt,hdcc,0,0,rect.right,rect.bottom,hdcMem,0,0,SRCCOPY    ;在内存中将某页面上的一幅位图经过一定的变换转移到另一个页面上
    invoke TransparentBlt,hdcc,0,0,500,500,hdcMem,0,0,500,500,0ffffffh
    invoke DeleteDC,hdcMem
    invoke DeleteObject,hbmp_bg
    ret
drawend endp

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
    ;invoke BitBlt,hdcc,dword ptr [ebx],dword ptr [edx],rect.right,rect.bottom,hdcMem,0,0,SRCCOPY    ;在内存中将某页面上的一幅位图经过一定的变换转移到另一个页面上
    invoke TransparentBlt,hdcc,dword ptr [ebx],dword ptr [edx],25,25,hdcMem,0,0,25,25,0ffffffh
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
        ;invoke BitBlt,hdcc,dword ptr [ebx+4*esi],dword ptr [edx+4*esi],rect.right,rect.bottom,hdcMem,0,0,SRCCOPY    ;在内存中将某页面上的一幅位图经过一定的变换转移到另一个页面上
        invoke TransparentBlt,hdcc,dword ptr [ebx+4*esi],dword ptr [edx+4*esi],25,25,hdcMem,0,0,25,25,0ffffffh
        invoke DeleteDC,hdcMem
        invoke DeleteDC,hdcMem                                              ;删除设备描述表
        invoke DeleteObject,hbmp_head
        inc esi
    .endw
    ret
drawsnk endp

drawsnk1 proc uses ebx ecx edx esi edi

    local hdcMem:HDC
    local rect:RECT
    local cnt:dword
    mov esi,0
    mov edi,0
    invoke LoadImage,NULL,snake1.srcHead,IMAGE_BITMAP,0,0,LR_LOADFROMFILE OR LR_CREATEDIBSECTION or LR_DEFAULTSIZE 
    mov hbmp_head,eax                                                   ;保存位图句柄
    invoke CreateCompatibleDC,hdcc                                      ;创建一个与指定设备兼容的内存设备上下文环境
    mov hdcMem,eax
    invoke SelectObject,hdcMem,hbmp_head                                ;把一个对象(位图、画笔、画刷等)选入指定的设备描述表。新的对象代替同一类型的老对象。
    invoke GetClientRect,hWinMain,addr rect                             ;获取客户端的矩形对象，保存在rect里
    mov ebx,snake1.px
    mov edx,snake1.py
    ;invoke BitBlt,hdcc,dword ptr [ebx],dword ptr [edx],rect.right,rect.bottom,hdcMem,0,0,SRCCOPY    ;在内存中将某页面上的一幅位图经过一定的变换转移到另一个页面上
    invoke TransparentBlt,hdcc,dword ptr [ebx],dword ptr [edx],25,25,hdcMem,0,0,25,25,0ffffffh
    invoke DeleteDC,hdcMem
    invoke DeleteDC,hdcMem                                              ;删除设备描述表
    invoke DeleteObject,hbmp_head
    mov esi,1
    .while esi<snake1.len
        invoke LoadImage,NULL,snake1.srcBody,IMAGE_BITMAP,0,0,LR_LOADFROMFILE OR LR_CREATEDIBSECTION or LR_DEFAULTSIZE 
        mov hbmp_head,eax                                                   ;保存位图句柄
        invoke CreateCompatibleDC,hdcc                                      ;创建一个与指定设备兼容的内存设备上下文环境
        mov hdcMem,eax
        invoke SelectObject,hdcMem,hbmp_head                                ;把一个对象(位图、画笔、画刷等)选入指定的设备描述表。新的对象代替同一类型的老对象。
        invoke GetClientRect,hWinMain,addr rect                             ;获取客户端的矩形对象，保存在rect里
        mov ebx,snake1.px
        mov edx,snake1.py
        ;invoke BitBlt,hdcc,dword ptr [ebx+4*esi],dword ptr [edx+4*esi],rect.right,rect.bottom,hdcMem,0,0,SRCCOPY    ;在内存中将某页面上的一幅位图经过一定的变换转移到另一个页面上
        invoke TransparentBlt,hdcc,dword ptr [ebx+4*esi],dword ptr [edx+4*esi],25,25,hdcMem,0,0,25,25,0ffffffh
        invoke DeleteDC,hdcMem
        invoke DeleteDC,hdcMem                                              ;删除设备描述表
        invoke DeleteObject,hbmp_head
        inc esi
    .endw
    ret
drawsnk1 endp

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
        invoke TransparentBlt,hdcc,(EGG ptr eggs[esi]).x,(EGG ptr eggs[esi]).y,25,25,hdcMem,0,0,25,25,0ffffffh
        ;invoke BitBlt,hdcc,(EGG ptr eggs[esi]).x,(EGG ptr eggs[esi]).y,rect.right,rect.bottom,hdcMem,0,0,SRCCOPY    ;在内存中将某页面上的一幅位图经过一定的变换转移到另一个页面上
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
    call drawegg
    call drawsnk
    .if mode==2
        call drawsnk1
    .endif
    .if isPause!=0
        call drawstop
    .endif
    .if isOver==1
        call drawend
    .endif
    .if isBegin==1
        call drawbegin
    .endif
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
                   mov ecx,snake.direction
                   .if isBegin==1
                       .if ebx=="0"||ebx=="1"||ebx=="2"
                            sub ebx,'0'    
                            mov mode,ebx
                            mov isBegin,0
                       .endif
                   .endif 
                   .if ebx==" "
                        .if isOver==1       ;gameover界面
                            mov isBegin,1
                            ;invoke initialSnake,addr snake
                            ;invoke initEggs
                            ;mov isOver,0
                            ;.if mode==2
                                ;模式2的处理
                            ;.endif
                        .elseif isPause==0  ;未暂停状态
                            mov isPause,1
                        .else               ;暂停状态
                            mov isPause,0
                        .endif
                   .elseif ebx==RIGHT && ecx!=RIGHT && ecx!=LEFT
                   mov esi,offset headrightpath
                   mov snake.srcHead,esi
                   MOV snake.direction,ebx

                   .elseif ebx==UP && ecx!=UP && ecx!=DOWN
                   mov esi,offset headuppath
                   mov snake.srcHead,esi
                   MOV snake.direction,ebx
                   
                   .elseif ebx==DOWN && ecx!=UP && ecx!=DOWN
                   mov esi,offset headdownpath
                   mov snake.srcHead,esi
                   MOV snake.direction,ebx
                   
                   .elseif ebx==LEFT && ecx!=RIGHT && ecx!=LEFT
                   mov esi,offset headleftpath
                   mov snake.srcHead,esi
                   MOV snake.direction,ebx
                   .endif
                   invoke printf,addr OutMessage, ebx
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
          ret

_ProcWinMain  endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_WinMain      proc
              ;local longer:dword
              ;local eggIndex:dword
              local    @stWndClass:WNDCLASSEX                           ;定义局部变量窗口类
              local    @stMsg:MSG                                       ;定义局部变量消息

              ;mov longer,0
              invoke initialSnake,addr snake,4,9,3,9,offset headrightpath ;对蛇进行初始化
              invoke initialSnake,addr snake1,blockCol-5,9,blockCol-4,9,offset headleftpath
              call initEggs
              ;创建管道
              invoke CreateNamedPipe,addr pipepath,PIPE_ACCESS_INBOUND,PIPE_READMODE_BYTE or PIPE_NOWAIT, PIPE_UNLIMITED_INSTANCES, 1024, 1024, 0, NULL                                                     
              mov h_pipe,eax
              invoke ConnectNamedPipe,h_pipe, NULL                      ;等待操作端连接
              .if eax
                    invoke printf,addr cnct_msg                         ;打印成功连接消息
              .endif
              .if h_pipe==INVALID_HANDLE_VALUE
              invoke printf,addr pipe_error_msg                         ;打印连接失败消息
              .endif
              invoke   GetModuleHandle,NULL                             ;返回主调进程(此进程)的可执行文件的基地址
              mov      hInstance,eax                                    ;得到的句柄存入hInstance
              invoke   RtlZeroMemory,addr @stWndClass,sizeof @stWndClass;用零填充窗口类
              invoke   LoadIcon,hInstance,IDI_ICON1                     ;加载图标
              mov      hIcon,eax                                        ;保存图标句柄
              
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
              .while      TRUE
                  invoke     PeekMessage, addr @stMsg, NULL, 0, 0, PM_REMOVE    ;判断消息队列有无消息
                  .if           eax
                    .break     .if @stMsg.message == WM_QUIT
                    invoke     TranslateMessage, addr @stMsg
                    invoke     DispatchMessage, addr @stMsg
                  .else                                                          ;没有消息则做其他工作
                    invoke ReadFile,h_pipe,addr buf_msg,1024,addr num_rcv,NULL   ;针对手势模式读管道
                    .if eax                                                      ;如果有消息
                        invoke printf,addr OutMessage,buf_msg                    ;后台打印消息
                        ;更改方向
                        mov ecx,snake.direction                                  
                        xor ebx,ebx
                        mov bl,byte ptr buf_msg
                        .if ebx==RIGHT && ecx!=RIGHT && ecx!=LEFT
                           mov esi,offset headrightpath
                           mov snake.srcHead,esi
                           MOV snake.direction,ebx
                           .elseif ebx==UP && ecx!=UP && ecx!=DOWN
                           mov esi,offset headuppath
                           mov snake.srcHead,esi
                           MOV snake.direction,ebx
                           .elseif ebx==DOWN && ecx!=UP && ecx!=DOWN
                           mov esi,offset headdownpath
                           mov snake.srcHead,esi
                           MOV snake.direction,ebx
                           .elseif ebx==LEFT && ecx!=RIGHT && ecx!=LEFT
                           mov esi,offset headleftpath
                           mov snake.srcHead,esi
                           MOV snake.direction,ebx
                        .endif
                    .endif
                    invoke Sleep,500                                              ;休眠n秒
                    mov eax,0
                    .if isPause==0 && isOver==0 && isBegin==0                                 ;如果暂停了或游戏结束/开始状态则停止移动
                        .if mode==0
                        invoke normalGaming,addr snake,addr eggs
                        .endif
                        .if mode==1
                        invoke reverseGaming,addr snake,addr eggs
                        .endif
                        .if mode==2
                        
                        invoke taijiGaming,addr snake,addr snake1,addr eggs
                        .endif
                    .endif
                    .if eax==0 && isPause==0 && isBegin==0
                        mov isOver,1
                    .endif
                    invoke InvalidateRect,hWinMain,NULL,FALSE                    ;擦除原图使之失效，并重发WM_PAINT
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