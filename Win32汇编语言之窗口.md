# Win32汇编语言之窗口

###### 参考资料：

https://blog.csdn.net/weixin_39768541/article/details/85490980

###### http://www.cppblog.com/luqingfei/archive/2010/08/17/123678.aspx

https://blog.csdn.net/liu_yude/article/details/44736555

https://zhidao.baidu.com/question/134666987508967925.html

https://www.cnblogs.com/dzqdzq/p/3235914.html

https://blog.csdn.net/silyvin/article/details/7540333

https://blog.csdn.net/yongyu211/article/details/7722477

https://blog.csdn.net/feidegengao/article/details/14146215

在文章《Windows消息机制的逆向分析》中详细分析了Windows的消息机制以及窗体的创建过程，文章中表述Windows窗体的创建分为三步：声明WNDCLASS实例、窗体注册、创建窗体。如果继续细分可以分为四步：**声明WNDCLASS实例、窗体注册、创建窗体、显示窗体**。

其中窗体注册函数是RegisterClass()或RegisterClassEx()，创建窗体则是CreateWindow()或CreatewindowEx()函数，显示窗体则是利用ShowWindow()函数。

#### 一、窗口类结构体WNDCLASSEX（EX是extend是在WNDCLASS基础上的拓展）

typedef struct
{
  UINT cbSize;
  UINT style;
  WNDPROC lpfnWndProc;
  int cbClsExtra;
  int cbWndExtra;
  HINSTANCE hInstance;
  HICON hIcon;
  HCURSOR hCursor;
  HBRUSH hbrBackground;
  LPCTSTR lpszMenuName;
  LPCTSTR lpszClassName;
  HICON hIconSm;
} WNDCLASSEX, *PWNDCLASSEX;

1. **cbSize**  WNDCLASSEX 的大小。在调用GetClassInfoEx前必须要先设置它值。我们可以用sizeof（WNDCLASSEX）来获得准确的值。

2. **style**  窗口类的样式，它的值可以是窗口样式值的任意组合。

3. **lpfnWndProc**  指向窗口处理函数（回调函数）。处理窗口事件，像单击鼠标会怎样，右击鼠标会怎样，都是由此函数控制的。

4. **cbClsExtra**  用于在窗口类结构中保留一定空间，用于存在自己需要的某些信息。初始化为0.

5. **cbWndExtra** 记录窗口实例的额外信息，系统初始为0.如果程序使用WNDCLASSEX注册一个从资源文件里创建的对话框，则此参数必须设置为DLGWINDOWEXTRA。

6. **hInstance**：本模块的事例句柄。

7.  **hIcon**  窗口类的图标，为资源句柄，如果设置为NULL，系统将为窗口提供一个默认的图标。

8.  **hCursor** 窗口类的鼠标样式，为鼠标样式资源的句柄，如果设置为NULL，系统提供一个默认的鼠标样式。

9. **hbrBackground** 窗口类的背景刷，为背景刷句柄，也可以为系统颜色值，如果颜色值已给出，则必须转化为以下的HBRUSH的值

   ·  COLOR_ACTIVEBORDER
   ·  COLOR_ACTIVECAPTION
   ·  COLOR_APPWORKSPACE
   ·  COLOR_BACKGROUND
   ·  COLOR_BTNFACE
   ·  COLOR_BTNSHADOW
   ·  COLOR_BTNTEXT
   ·  COLOR_CAPTIONTEXT
   ·  COLOR_GRAYTEXT
   ·  COLOR_HIGHLIGHT
   ·  COLOR_HIGHLIGHTTEXT
   ·  COLOR_INACTIVEBORDER
   ·  COLOR_INACTIVECAPTION
   ·  COLOR_MENU
   ·  COLOR_MENUTEXT
   ·  COLOR_SCROLLBAR
   ·  COLOR_WINDOW
   ·  COLOR_WINDOWFRAME
   ·  COLOR_WINDOWTEXT

10. **lpszMenuName**  指向一个以NULL结尾的字符串，同目录资源的名字一样。如果使用整型id表示菜单，可以用MAKEINTRESOURCE定义一个宏。如果它的值为NULL,那么该类创建的窗口将都没有默认的菜单。

11. **lpszClassName**  指向窗口类的指针，LPSTR类型。

12. **hIconSm**  小图标的句柄，在任务栏显示的图标，可以和上面的那个一样。

#### 二、什么是窗口类？为什么要注册窗口类？

1. 在Windows中运行的程序，大多数都有一个或几个可以看得见的窗口，而在这些窗口被创建起来之前，操作系统怎么知道该怎样创建该窗口，以及用户操作该窗口的各种消息交给谁处理呢？所以VC在调用Windows的API（CreateWindow或者CreateWindowEx）创建窗口之前，要求程序员必须定义一个窗口类（不是传统C++意义上的类）来规定所创建该窗口所需要的各种信息，主要包括：窗口的**消息处理函数**、窗口的**风格**、**图标**、 **鼠标**、**菜单**等。其定义见上述内容。

2. 自己注册窗口类，类名自己设定。自己注册窗口类可以自定义窗口的基本设置（图标等）以及消息响应函数（这个很重要，要不然你的窗口什么都干不了）
   当然系统也有一些已经给你注册好的窗口类，比如最基础的：

   "Button"=WC_BUTTON(按钮)
   "Static"=WC_STATIC(静态文本)
   "Edit"=WC_EDIT(文本框)

3. 注册窗口类的目的是自定义一类窗口的共性，相当于告诉Windows系统我定义了这样一个类。将WNDCLASSEX实例的地址传给RegisterClassEx函数调用之后，系统就知道你有这么一个类，方便于之后的窗口创建。

#### 三、创建窗口

1. 窗口类只定义了窗口的“共性”，建立窗口时肯定还要指定窗口的很多“个性化”的参数，如WNDCLASSEX结构中没有定义的外观、标题、位置、大小和边框类型等属性，这些属性是在建立窗口时才指定的。

2. 函数原型：

   ```c
   HWND CreateWindowEx(
   	DWORD dwExStyle,
       LPCTSTR lpClassName,
       LPCTSTR lpWindowName,
       DWORD dwStyle,
       int x,
       int y,
       int nWidth,
       int nHeight,
       HWND hWndParent,
       HMENU hMenu,
       HINSTANCE hInstance,
       LPVOID lpParam
   );
   ```

   **dwExStyle**：指定窗口的扩展风格。

   **lpClassName**:使用需要建立窗口的类名，由于之前我们已经注册了类，因此只需要提供类名就可以将窗口进程和我们自定义的窗口类关联起来。

   **lpWindowName**：窗口的名称，显示在左上角标题栏上。

   **dwStyle**：指定创建窗口的风格。

   **x，y**   ：指定窗口左上角位置，单位是像素。默认时可指定为CW_USEDEFAULT，这样Windows会自动为窗口指定最合适的位置，当建立子窗口时，位置是以父窗口的左上角为基准的，否则，以屏幕左上角为基准。

   **nWidth，hHeight**：窗口的宽度和高度，也就是窗口的大小，同样是以像素为单位的。默认时可指定为CW_USEDEFAULT，这样Windows会自动为窗口指定最合适的大小。

   **hWndParent**：窗口所属的父窗口，对于普通窗口（相对于子窗口），这里的“父子”关系只是从属关系，主要用来在父窗口销毁时一同将其“子”窗口销毁，并不会把窗口位置限制在父窗口的客户区范围内，但如果要建立的是真正的子窗口（dwStyle中指定了WS_CHILD的时候），这时窗口位置会被限制在父窗口的客户区范围内，同时窗口的坐标（x，y）也是以父窗口的左上角为基准的。

   **hMenu**：窗口上要出现的菜单的句柄。在注册窗口类的时候也定义了一个菜单，那是窗口的默认菜单，意思是如果这里没有定义菜单（用参数NULL）而注册窗口类时定义了菜单，则使用窗口类中定义的菜单；如果这里指定了菜单句柄，则不管窗口类中有没有定义都将使用这里定义的菜单；两个地方都没有定义菜单句柄，则窗口上没有菜单。另外，当建立的窗口是子窗口时（dwStyle中指定了WS_CHILD），这个参数是另一个含义，这时hMenu参数指定的是子窗口的ID号，这样可以节省一个参数的位置，因为反正子窗口不会有菜单。

    **hInstance**：模块句柄，和注册窗口类时一样，指定了窗口所属的程序模块。

    **lpParam**:指向一个值的指针，该值传递给窗口 WM_CREATE消息。该值通过在IParam参数中的CREATESTRUCT结构传递。如果应用程序调用CreateWindow创建一个MDI客户窗口，则lpParam必须指向一个CLIENTCREATESTRUCT结构。

    **返回值**：如果函数成功，返回值为新窗口的句柄：如果函数失败，返回值为NULL。若想获得更多错误信息，请调用GetLastError函数。

   **函数过程**：在返回前，CreateWindowEx给**窗口过程**发送一个WM_CREATE消息。对于层叠，弹出式和子窗口，CreateWindowEx给窗口发送WM_CREATE，WM_GETMINMAXINFO和WM_NCCREATE消息。消息WM_CREATE的IParam参数包含一个指向CREATESTRUCT结构的指针。如果指定了WS_VISIBLE风格，CreateWindow向窗口发送所有需要激活和显示窗口的消息。

   #### 四、getDC()函数

   1. **函数功能**：该函数检索一指定窗口的客户区域或整个屏幕的显示[设备上下文](http://baike.baidu.com/view/1923644.htm)环境的句柄，以后可以在GDI函数中使用该句柄来在设备上下文环境中绘图。

   2. **参数**：

      hWnd：设备上下文环境被检索的窗口的句柄，如果该值为NULL，GetDC则检索整个屏幕的设备上下文环境。

   3. **返回值**：如果成功，返回指定窗口客户区的设备上下文环境；如果失败，返回值为Null。

   4. **注意**：在使用普通设备上下文环境绘图之后，必须调用ReleaseDc函数释放该设备上下文环境，典型和特有设备上下文环境不需要释放，设备上下文环境的个数仅受有效内存的限制。

   #### 五、显示窗体

   1.  **函数原型：BOOL \*ShowWindow\*（HWND \*hWnd\*, int \*nCmdShow\*）**
   2.  其中***hWnd***指窗口句柄；***nCmdShow***指定窗口如何显示。
   3. **UpdateWindow函数**：如果窗口的更新区域不为空，此函数通过向窗口发送 WM_PAINT 消息来更新指定窗口的客户区。

   #### 六、消息循环

   1. 在创建窗口、显示窗口、更新窗口后，我们需要编写一个消息循环，不断地从消息队列中取出消息，并进行响应。要从消息队列中取出消息，我们需要调用GetMessage()函数，该函数的原型声明如下：在创建窗口、显示窗口、更新窗口后，我们需要编写一个消息循环，不断地从消息队列中取出消息，并进行响应。要从消息队列中取出消息，我们需要调用GetMessage()函数，该函数的原型声明如下：

   ```c
   BOOL GetMessage(
             LPMSG lpMsg,              // address of structure with message
             HWND hWnd,                 // handle of window
             UINT wMsgFilterMin,       // first message
             UINT wMsgFilterMax        // last message
   );
   ```

   ​	**lpMsg**指向一个消息（MSG）结构体，GetMessage从线程的消息队列中取出的消息信息将保存在该结构体对象中。

   ​	**hWnd**指定接收属于哪一个窗口的消息。通常我们将其设置为NULL，用于接收属于调用线程(当前进程)的所有窗口的窗口消息。

   ​	**wMsgFilterMin**指定要获取的消息的最小值，通常设置为0。

   ​	**wMsgFilterMax**指定要获取的消息的最大值。如果wMsgFilterMin和wMsgFilter Max都设置为0，则接收所有消息。

    2. **TranslateMessage**函数用于将虚拟键消息转换为字符消息。字符消息被投递到调用线程的消息队列中，当下一次调用GetMessage函数时被取出。当我们敲击键盘上的某个字符键时，系统将产生WM_KEYDOWN和WM_KEYUP消息。这两个消息的附加参数（wParam和lParam）包含的是虚拟键代码和扫描码等信息，而我们在程序中往往需要得到某个字符的ASCII码，TranslateMessage这个函数就可以将WM_KEYDOWN和WM_ KEYUP消息的组合转换为一条WM_CHAR消息（该消息的wParam附加参数包含了字符的ASCII码），并将转换后的新消息投递到调用线程的消息队列中。注意，TranslateMessage函数并不会修改原有的消息，它只是产生新的消息并投递到消息队列中。

    3. **DispatchMessage**函数分派一个消息到窗口过程，由窗口过程函数对消息进行处理。DispachMessage实际上是将消息回传给操作系统，由操作系统调用窗口过程函数对消息进行处理（响应）。

    4. **总体流程：**

       （1）操作系统接收到应用程序的窗口消息（按键、点击等），将消息投递到该应用程序的消息队列中。

       （2）应用程序在消息循环中调用GetMessage函数从消息队列中取出一条一条的消息。取出消息后，应用程序可以对消息进行一些预处理，例如，放弃对某些消息的响应，或者调用TranslateMessage产生新的消息。

       （3）应用程序调用DispatchMessage，将消息回传给操作系统。消息是由MSG结构体对象来表示的，其中就包含了接收消息的窗口的句柄。因此，DispatchMessage函数总能进行正确的传递。

       （4）系统利用WNDCLASS结构体的lpfnWndProc成员保存的窗口过程函数的指针调用窗口过程，对消息进行处理（即“系统给应用程序发送了消息”）。

       以上就是Windows应用程序的消息处理过程。

 ![IMG_0797(20210605-143423)](C:\Users\zjx\Documents\Tencent Files\1243691477\FileRecv\MobileFile\IMG_0797(20210605-143423).PNG)