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
	
	