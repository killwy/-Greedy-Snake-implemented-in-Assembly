        .386
        .model flat,stdcall
        option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;include文件定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include       windows.inc
include       gdi32.inc
includelib    gdi32.lib
include       gdiplus.inc
includelib    gdiplus.lib
include       user32.inc
includelib    user32.lib
include       kernel32.inc
includelib    kernel32.lib
include  msvcrt.inc
includelib msvcrt.lib
printf    PROTO C : dword,:vararg

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                .data
GpInput       GdiplusStartupInput<1,0,0,0>
                .data?
hInstance     dd       ?
hWinMain      dd       ?
hToken        dd       ?
hWindowHdc HDC ?
                .const
szClassName   db       'MyClass',0
szCaptionMain db       'GDI+!',0
hBitmap HBITMAP ?
OutMessage db "按键%c",0ah,0
IMAGE_PATH byte "C:\\Users\\12272\\Desktop\\1.bmp",0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                .code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;窗口过程
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcWinMain  proc     uses ebx edi esi,hWnd,uMsg,wParam,lParam
          local    @gdip
          local    @hBrush

		    LOCAL hbitmap:dword
            LOCAL strRect:RECT
		LOCAL paint:dword
		LOCAL hdcmem:dword
	
		LOCAL hdc:dword
          mov eax,uMsg
;*******************************************************************************************
              .if eax == WM_KEYDOWN
                   mov ebx, wParam
                   invoke printf,addr OutMessage, ebx
              .endif

              .if  eax ==  WM_PAINT
                   mov     ebx,hWnd
             

              .if  ebx == hWinMain
                   invoke  GdipCreateFromHWND,hWnd,addr @gdip
                   invoke  GdipCreateSolidFill,ColorsBlack,addr @hBrush
                   invoke  GdipFillRectangleI,@gdip,@hBrush,0,0,300,300
                   ;invoke  GdipCreateSolidFill,ColorsWhite,addr @hBrush
                   ;invoke  GdipFillRectangleI,@gdip,@hBrush,10,10,280,280
                   
				 	;invoke SelectObject,hdcmem,hbitmap
				 	;invoke BitBlt,hWindowHdc,0,0,500,500,hdcmem,0,0,SRCCOPY
					;invoke printf,addr OutFmt,hbitmap

                   ;mov hBitmap, ebx
                   ;invoke DrawBmpRect, hWnd, 0, 0, 255, 255, TEXT("C:\\Users\\12272\\Desktop\\1.bmp"));
                   invoke  GdipDeleteBrush,@hBrush
                   invoke  GdipDeleteGraphics,@gdip
               .endif
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
              local    @stWndClass:WNDCLASSEX
              local    @stMsg:MSG

              invoke   GetModuleHandle,NULL
              mov      hInstance,eax
              invoke   RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
;*******************************************************************************************
;注册窗口类
;*******************************************************************************************
              invoke   LoadCursor,0,IDC_ARROW
              mov      @stWndClass.hCursor,eax
              push     hInstance
              pop      @stWndClass.hInstance
              mov       @stWndClass.cbSize,sizeof WNDCLASSEX
              mov      @stWndClass.style,CS_HREDRAW or CS_VREDRAW
              mov      @stWndClass.lpfnWndProc,offset _ProcWinMain
              mov      @stWndClass.hbrBackground,COLOR_WINDOW+1
              mov      @stWndClass.lpszClassName,offset szClassName
              invoke   RegisterClassEx,addr @stWndClass
;*******************************************************************************************
;建立并显示窗口
;*******************************************************************************************
              invoke   CreateWindowEx,WS_EX_CLIENTEDGE,offset szClassName,\
                       offset szCaptionMain,WS_OVERLAPPEDWINDOW,100,100,320,320,\
                       NULL,NULL,hInstance,NULL
              mov      hWinMain,eax
              invoke GetDC,eax
                mov  hWindowHdc,eax
              invoke   ShowWindow,hWinMain,SW_SHOWNORMAL
              invoke   UpdateWindow,hWinMain
;*******************************************************************************************
;消息循环
;*******************************************************************************************
              .while   TRUE
                   invoke  GetMessage,addr @stMsg,NULL,0,0
                   .break  .if eax ==  0
                   invoke  TranslateMessage,addr @stMsg
                   invoke  DispatchMessage,addr @stMsg
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