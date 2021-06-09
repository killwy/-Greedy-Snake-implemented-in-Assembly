IFNDEF 

; ================== �� �����ݽṹ =====================
	SNAKE STRUCT
		px dword ?					;X������׵�ַ
		py dword ?					;Y������׵�ַ
		len dword ? 				;����
		direction dword ?			;���� 0:��  1����  2����   3����
		srcHead dword ?				;���ͷ��ͼƬ�ĵ�ַ
		srcBody dword ?				;�������ͼƬ�ĵ�ַ
	SNAKE ENDS
; =================== �� �����ݽṹ ====================
	EGG STRUCT
		x dword ?					;x����
		y dword ?					;y����
		srcColor dword ?			;��egg��ͼƬ��ַ
		visible dword ?				;���Ƿ�ɼ�
	EGG ENDS

; =============== ��ʼ�� �� ================================================
; ������snakeAddr :dword  �ߵĵ�ַ  
;����ֵ��eax:0 ��ʼ��ʧ�ܣ��ڴ����ʧ�ܣ� 1���ɹ�
	initialSnake PROTO :DWORD
; ====================== ���õ����� ========================================
; ������5��dword ��eggsAddr index   ,    newX  ,    newY  , newColor  , newVisible
;				 �������ַ �������±꣬�µ�X���꣬�µ�Y���꣬�µ���ɫ  ���Ƿ���ʾ
; ��Ϊ-1����ʾ�����Բ���		ȫ�ֱ�����eggCount
;����ֵ����
	setEgg PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
; ================== �ж����Ƿ��������Լ������� ============================
;������snakeAddr :dword �ߵĵ�ַ  
;����ֵ��eax 0��û������  eax 1: ������	
	isHeadMeetBody PROTO:DWORD
; ==================  ���ƶ�  ===============================================
; ������snakeAddr �ߵĵ�ַ  longer �����Ƿ�Ҫ���� 0����	��������
; ����ֵ�� ��
	moveSnake PROTO :DWORD,:DWORD
; ================== ������еĵ� ===========================================
; ������snakeAddr �ߵ�ַ	eggsAddr ���ṹ�����ַ		
; ȫ�ֱ�����eggCount
; ����ֵ��eax  -1���Ե��˴���ĵ�   �������Ե��ĵ��ı��
	checkAllEgg PROTO:DWORD,:DWORD
; ========================== �Ƿ�ײǽ =========================
; ������snakeAddr :dword �ߵĵ�ַ    
; ȫ�ֱ�����blockRow,blockCol
; ����ֵ��  eax: 0 û������  1 ������
	isMeetWall PROTO:DWORD
; ======================  ���� ������꣨����� =================
; ������snakeAddr :dword �ߵĵ�ַ
; ȫ�ֱ�����blockRow��blockCol,eggCount
; ����ֵ��eax :��¼������������׵�ַ 
	genRandPos PROTO:DWORD
; ============== ˢ�����е������� =====================
; ������ eggsAddr ������ĵ�ַ   snakeAddr �ߵ�ַ
; ȫ�ֱ����� eggCount
; ����ֵ�� ��
; ������ ����������飬�����µ���������꣬����Visible=1��srcColor����
	updateEggs PROTO:DWORD,:DWORD

; ============ ��ͨģʽ ===========================
; �������ߵ�ַ  ����ַ
; ����ֵ�� eax=0 ������  eax=1 ������
	normalGaming PROTO:DWORD,:DWORD

; ============ ̫��ģʽ ===========================
; ��������1��ַ ��2��ַ ����ַ
; ����ֵ�� eax=0 ������  eax=1 ������
	taijiGaming PROTO:DWORD,:DWORD,:DWORD
	
; ============ ��תģʽ ===========================
; �������ߵ�ַ ����ַ
; ����ֵ�� eax=0 ������  eax=1 ������
	reverseGaming PROTO:DWORD,:DWORD
ENDIF

.data 

	blockRow equ 20					;���ӵ�����
	blockCol equ 20					;���ӵ�����
	blockSize equ 25				;���ӵĴ�С���߳���
	MAX_LENGTH equ 120				;�ߵ���󳤶�
	eggCount equ 5					;��������
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
	bodypath db ".\resrc\body.bmp",0
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
	
	
	