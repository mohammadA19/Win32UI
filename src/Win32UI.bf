namespace Win32UI;
using System;
using System.Text;
using System.Interop;
using System.Diagnostics;

public class WindowClassBuilder
{
	Win32.WNDCLASSEXW mStruct;
	Span<char16>      mClassName ~ if (_.Ptr != null) delete _.Ptr;
	Span<char16>      mMenuName ~ if (_.Ptr != null) delete _.Ptr;

	static ModuleHandle sInstance = 0;
	public static ModuleHandle CurrentInstance
	{
		get
		{
			if (sInstance == 0)
				sInstance = (.)Win32.GetModuleHandleW(null);
			return sInstance;
		}
	}

	[AllowAppend]
	public this(String className)
	{
		if (className == null)
			return;

		int encodedLen = UTF16.GetEncodedLen(className);
		char16* _append1 = append char16[encodedLen+1]* (?);
		mClassName = .(_append1, encodedLen);
	
		UTF16.Encode(className, (.)mClassName.Ptr, encodedLen);
		mClassName[encodedLen] = 0;
	}

	static void SetVar(String value, ref Span<char16> dest)
	{
		if (dest.Ptr != null)
			delete dest.Ptr;

		int encodedLen = UTF16.GetEncodedLen(value);
		dest.Ptr = new char16[encodedLen+1]* (?);
		dest.Length = encodedLen;

		UTF16.Encode(value, dest.Ptr, encodedLen);
		dest[encodedLen] = 0;
	}

	public void FillMissingValues()
	{
		mStruct.cbSize = sizeof(Win32.WNDCLASSEXW);
		// mWndClassInfo.lpfnWndProc = ...;

		if (mStruct.hInstance == 0)
			mStruct.hInstance = (Win32.HINSTANCE)CurrentInstance;

		if (mStruct.hIcon == 0)
			mStruct.hIcon = Win32.LoadIconW(0, Win32.IDI_APPLICATION);

		if (mStruct.hCursor == 0)
			mStruct.hCursor = Win32.LoadCursorW(0, Win32.IDC_ARROW);

		if (mStruct.hbrBackground == 0)
			mStruct.hbrBackground = Win32.GetStockObject(.WHITE_BRUSH);

		if (mStruct.hIconSm == 0)
			mStruct.hIconSm = Win32.LoadImageW((Win32.HINSTANCE)CurrentInstance, (.)(void*)5, .IMAGE_ICON, Win32.GetSystemMetrics(.SM_CXSMICON), Win32.GetSystemMetrics(.SM_CYSMICON), .LR_DEFAULTCOLOR);
	}

	public void UseStyle(Win32.WNDCLASS_STYLES style)
	{
		mStruct.style = style;
	}

	public void UseWindowProc(Win32.WNDPROC proc)
	{
		mStruct.lpfnWndProc = proc;
	}

	public void UseStandardIcon()
	{
		mStruct.hIcon = Win32.LoadIconW(0, Win32.IDI_APPLICATION);
	}

	public void UseIcon(Win32.HICON icon)
	{
		mStruct.hIcon = icon;
	}

	public void UseStandardSmallIcon()
	{
		mStruct.hIconSm = // Win32.LoadIconW(0, Win32.IDI_APPLICATION);
			Win32.LoadImageW((Win32.HINSTANCE)CurrentInstance, (.)(void*)5, .IMAGE_ICON, Win32.GetSystemMetrics(.SM_CXSMICON), Win32.GetSystemMetrics(.SM_CYSMICON), .LR_DEFAULTCOLOR);
	}

	public void UseSmallIcon(Win32.HICON icon)
	{
		mStruct.hIconSm = icon;
	}

	public void UseStandardCursor()
	{
		mStruct.hCursor = Win32.LoadCursorW(0, Win32.IDC_ARROW);
	}

	public enum SystemCursor : int
	{
		Arrow,
		IBeam, Wait, Cross, UpArrow, Size, Icon,
		SizeNWSE, SizeNESW, SizeWE, SizeNS, SizeAll,
		No, Hand, AppStarting, Help, Pin, Person,
	}

	public void UseSystemCursor(SystemCursor cursor)
	{
		void* val;

		switch (cursor)
		{
		case .Arrow:       val = Win32.IDC_ARROW;
		case .IBeam:       val = Win32.IDC_IBEAM;
		case .Wait:        val = Win32.IDC_WAIT;
		case .Cross:       val = Win32.IDC_CROSS;
		case .UpArrow:     val = Win32.IDC_UPARROW;
		case .Size:        val = Win32.IDC_SIZE;
		case .Icon:        val = Win32.IDC_ICON;
		case .SizeNWSE:    val = Win32.IDC_SIZENWSE;
		case .SizeNESW:    val = Win32.IDC_SIZENESW;
		case .SizeWE:      val = Win32.IDC_SIZEWE;
		case .SizeNS:      val = Win32.IDC_SIZENS;
		case .SizeAll:     val = Win32.IDC_SIZEALL;
		case .No:          val = Win32.IDC_NO;
		case .Hand:        val = Win32.IDC_HAND;
		case .AppStarting: val = Win32.IDC_APPSTARTING;
		case .Help:        val = Win32.IDC_HELP;
		case .Pin:         val = Win32.IDC_PIN;
		case .Person:      val = Win32.IDC_PERSON;
		}

		mStruct.hCursor = Win32.LoadCursorW(0, (.)val);
	}

	public void SetClassName(String name)
	{
		SetVar(name, ref mClassName);
	}

	public void SetMenuName(String name)
	{
		SetVar(name, ref mMenuName);
	}

	public void IncludeStyle(Win32.WNDCLASS_STYLES style)
	{
		mStruct.style |= style;
	}

	public void ExcludeStyle(Win32.WNDCLASS_STYLES style)
	{
		mStruct.style &= ~style;
	}

	public enum SystemBrush
	{
		White,
		Black,
		DarkGray,
		Gray,
		LightGray,
		Hollow,
		Null,
	}

	public void UseStockBackground(SystemBrush brush = .Null)
	{
		Win32.GET_STOCK_OBJECT_FLAGS flag;

		switch (brush)
		{
		case .White: flag = .WHITE_BRUSH;
		case .Black: flag = .BLACK_BRUSH;
		case .DarkGray: flag = .DKGRAY_BRUSH;
		case .Gray: flag = .GRAY_BRUSH;
		case .LightGray: flag = .LTGRAY_BRUSH;
		case .Hollow: flag = .HOLLOW_BRUSH;
		case .Null: flag = .NULL_BRUSH;
		}
		mStruct.hbrBackground = Win32.GetStockObject(flag);
	}

	public Result<uint16> Register()
	{
		let r = Win32.RegisterClassExW(&mStruct);

		if (r == 0)
			return .Err;
		return r;
	}
}

[CRepr]
public struct Point
{
	Win32.POINT m;
	public this(int32 x = 0, int32 y = 0) => (m.x, m.y) = (x, y);

	public int32 X
	{
		get     => m.x;
		set mut => m.x = value;
	}

	public int32 Y
	{
		get     => m.y;
		set mut => m.y = value;
	}

	public static explicit operator POINT(Self val) => val.m;
	public static explicit operator Self(POINT val) => .(val.x, val.y);
}

[CRepr]
public struct Size : Win32.SIZE
{
	Win32.SIZE m;
	public this(int32 width = 0, int32 height = 0) => (m.cx, m.cy) = (width, height);

	public int32 Width
	{
		get     => m.cx;
		set mut => m.cx = value;
	}

	public int32 Height
	{
		get     => m.cy;
		set mut => m.cy = value;
	}

	public static explicit operator SIZE(Self val) => val.m;
	public static explicit operator Self(SIZE val) => .(val.cx, val.cy);
}

public struct WindowHandle : Win32.HWND;
public struct MenuHandle : Win32.HMENU;
public struct ModuleHandle : Win32.HINSTANCE;

static
{
	public static Result<WindowHandle> CreateWindow(char16* className, char16* windowName, Win32.WINDOW_STYLE style, Win32.WINDOW_EX_STYLE exStyle = 0, int32 x = Win32.CW_USEDEFAULT, int32 y = Win32.CW_USEDEFAULT, int32 width = Win32.CW_USEDEFAULT, int32 height = Win32.CW_USEDEFAULT, WindowHandle parentWindow = 0, MenuHandle menu = 0, ModuleHandle instance = 0, void* param = null)
	{
		Win32.HINSTANCE _instance = (.)instance;
		if (_instance == 0)
			_instance = (.)WindowClassBuilder.CurrentInstance;
		
		let r = Win32.CreateWindowExW(exStyle, className, windowName, style, x, y, width, height, (.)parentWindow, (.)menu, (.)instance, param);

		if (r == 0)
			return .Err;
		return (.)r;
	}

	public static Result<WindowHandle> CreateWindow(uint16 windowClass, char16* windowName, Win32.WINDOW_STYLE style, Win32.WINDOW_EX_STYLE exStyle = 0, int32 x = Win32.CW_USEDEFAULT, int32 y = Win32.CW_USEDEFAULT, int32 width = Win32.CW_USEDEFAULT, int32 height = Win32.CW_USEDEFAULT, WindowHandle parentWindow = 0, MenuHandle menu = 0, ModuleHandle instance = 0, void* param = null)
	{
		return CreateWindow(windowClass, windowName, style, exStyle, x, y, width, height, parentWindow, menu, instance, param);
	}

	const Point UseDefaultPosition = .(Win32.CW_USEDEFAULT, Win32.CW_USEDEFAULT);
	const Size UseDefaultSize = .(Win32.CW_USEDEFAULT, Win32.CW_USEDEFAULT);
	
	public static Result<WindowHandle> CreateWindow(char16* className, char16* windowName, Win32.WINDOW_STYLE style, Win32.WINDOW_EX_STYLE exStyle = 0, Point position = UseDefaultPosition, Size size = UseDefaultSize, WindowHandle parentWindow = 0, MenuHandle menu = 0, ModuleHandle instance = 0, void* param = null)
	{
		return CreateWindow(className, windowName, style, exStyle, position.X, position.Y, size.Width, size.Height, parentWindow, menu, instance, param);
	}

	public static Result<WindowHandle> CreateWindow(uint16 className, char16* windowName, Win32.WINDOW_STYLE style, Win32.WINDOW_EX_STYLE exStyle = 0, Point position = UseDefaultPosition, Size size = UseDefaultSize, WindowHandle parentWindow = 0, MenuHandle menu = 0, ModuleHandle instance = 0, void* param = null)
	{
		return CreateWindow(className, windowName, style, exStyle, position.X, position.Y, size.Width, size.Height, parentWindow, menu, instance, param);
	}
}

public class WindowBuilder
{
	char16* mClassName ~ DeleteVar(ref _, true); // if (_ != null && IsNotAtom(_)) delete _;
	// ^ this can be either a pointer to wchar or uint16 value (called atom). TAKE CARE: If it is atom, it must not be deleted.
	char16* mWindowName ~ DeleteVar(ref _); // ~ if (_ != null) delete _;
	Win32.WINDOW_STYLE mStyle;
	Win32.WINDOW_EX_STYLE mExStyle;
	Point mPos;
	Size mSize;
	WindowHandle mParent;
	MenuHandle mMenu;
	ModuleHandle mInstance;
	void* mParam;

	static bool IsAtom(char16* v)
	{
		let i = (int)(void*)v;
		return 0x0 < i && i < 0x10000;
	}

	static bool IsNotAtom(char16* v)
	{
		return !IsAtom(v);
	}

	static void DeleteVar(ref char16* dest, bool checkIfAtom = false)
	{
		if (dest != null)
		{
			if (!checkIfAtom || IsNotAtom(dest))
				delete dest;
		}
	}

	static void ConvertToUtf16(StringView str, out char16* newPtr)
	{
		int encodedLen = UTF16.GetEncodedLen(str);
		newPtr = new char16[encodedLen+1]* (?);

		UTF16.Encode(str, newPtr, encodedLen);
		newPtr[encodedLen] = 0;
	}

	public void OfClass(uint16 classAtom)
	{
		DeleteVar(ref mClassName, true);
		mClassName = (char16*)(void*)(int)classAtom;
	}

	public void OfClass(char16* classNamePtr)
	{
		DeleteVar(ref mClassName, true);
		mClassName = (.)classNamePtr;
	}

	public void OfClass(StringView value)
	{
		DeleteVar(ref mClassName, true);
		ConvertToUtf16(value, out mClassName);
	}

	public void WithTitle(char16* strPtr)
	{
		DeleteVar(ref mWindowName);
		mWindowName = strPtr;
	}

	public void WithTitle(StringView str)
	{
		DeleteVar(ref mWindowName);
		ConvertToUtf16(str, out mClassName);
	}

	public void SetStyle(Win32.WINDOW_STYLE style) => mStyle = style;
	public void AddStyle(Win32.WINDOW_STYLE style) => mStyle |= style;
	public void RemoveStyle(Win32.WINDOW_STYLE style) => mStyle = Enum.Exclude(mStyle, style);

	public void SetStyle(WindowStyle style) => mStyle = (.)style;
	public void AddStyle(WindowStyle style) => mStyle |= (.)style;
	public void RemoveStyle(WindowStyle style) => mStyle = Enum.Exclude(mStyle, (.)style);

	public void SetExStyle(Win32.WINDOW_EX_STYLE style) => mExStyle = style;
	public void AddExStyle(Win32.WINDOW_EX_STYLE style) => mExStyle |= style;
	public void RemoveExStyle(Win32.WINDOW_EX_STYLE style) => mExStyle = Enum.Exclude(mExStyle, style);

	public void UseDefaultPosition() => mPos = .(Win32.CW_USEDEFAULT, Win32.CW_USEDEFAULT);
	public void Position(Point pt) => mPos = pt;
	public void Position(Win32.POINT pt) => mPos = .(pt.x, pt.y);
	public void Position(int32 x, int32 y) => mPos = .(x, y);

	public void Size(Size size) => mSize = size;
	public void Size(Win32.SIZE size) => mPos = .(size.cx, size.cy);
	public void Size(int32 width, int32 height) => mPos = .(width, height);

	public void HasParent(Win32.HWND handle) => mParent = (.)handle;
	public void HasParent(WindowHandle handle) => mParent = handle;

	public void HasMenu(Win32.HMENU handle) => mMenu = (.)handle;
	public void HasMenu(MenuHandle handle) => mMenu = handle;

	public void ForCurrentModule() => mInstance = WindowClassBuilder.CurrentInstance;
	public void ForModule(Win32.HINSTANCE moduleHandle) => mInstance = (.)moduleHandle;
	public void ForModule(ModuleHandle moduleHandle) => mInstance = moduleHandle;

	// TODO: mParam

	public Result<WindowHandle> Create()
	{
		if (mInstance == 0)
			ForCurrentModule();

		let result = Win32.CreateWindowExW(mExStyle, (char16*)mClassName, mWindowName, mStyle, mPos.X, mPos.Y, mSize.Width, mSize.Height, (.)mParent, (.)mMenu, (.)mInstance, mParam);

		if (result == 0)
			return .Err;
		return (WindowHandle)result;
	}

	[AllowDuplicates]
	public enum WindowStyle : uint32
	{
		Overlapped = 0,
		Popup = 2147483648,
		Child = 1073741824,
		Minimize = 536870912,
		Visible = 268435456,
		Disabled = 134217728,
		ClipSiblings = 67108864,
		ClipChildren = 33554432,
		Maximize = 16777216,
		Caption = 12582912,
		Border = 8388608,
		DialogFrame = 4194304,
		VScroll = 2097152,
		HScroll = 1048576,
		SysMenu = 524288,
		ThickFrame = 262144,
		Group = 131072,
		TabStop = 65536,
		MinimizeBox = 131072,
		MaximizeBox = 65536,
		SizeBox = 262144,
		OverlappedWindow = 13565952,
		PopupWindow = 2156396544,
		ActiveCaption = 1,
	}
}

public struct SlimWindowBuilder
{
	char16* mClassName;
	// ^ this can be either a pointer to wchar or uint16 value (called atom).
	char16* mWindowName;
	WINDOW_STYLE mStyle;
	WINDOW_EX_STYLE mExStyle;
	Point mPos;
	Size mSize;
	WindowHandle mParent;
	MenuHandle mMenu;
	ModuleHandle mInstance;
	void* mParam;

	public void OfClass(uint16 classAtom) mut =>     mClassName = (char16*)(void*)(int)classAtom;
	public void OfClass(char16* classNamePtr) mut => mClassName = (.)classNamePtr;

	public void WithTitle(char16* strPtr) mut => mWindowName = strPtr;

	public void SetStyle(WINDOW_STYLE style) mut => mStyle = style;
	public void AddStyle(WINDOW_STYLE style) mut => mStyle |= style;
	public void RemoveStyle(WINDOW_STYLE style) mut => mStyle = Enum.Exclude(mStyle, style);

	public void SetExStyle(WINDOW_EX_STYLE style) mut => mExStyle = style;
	public void AddExStyle(WINDOW_EX_STYLE style) mut => mExStyle |= style;
	public void RemoveExStyle(WINDOW_EX_STYLE style) mut => mExStyle = Enum.Exclude(mExStyle, style);

	public void UseDefaultPosition() mut => mPos = .(Win32.CW_USEDEFAULT, Win32.CW_USEDEFAULT);
	public void Position(Point pt) mut => mPos = pt;
	public void Position(int32 x, int32 y) mut => mPos = .(x, y);

	public void Size(Size size) mut => mSize = size;
	public void Size(int32 width, int32 height) mut => mPos = .(width, height);

	public void HasParent(WindowHandle handle) mut => mParent = handle;

	public void HasMenu(MenuHandle handle) mut => mMenu = handle;

	public void ForCurrentModule() mut => mInstance = WindowClassBuilder.CurrentInstance;
	public void ForModule(ModuleHandle moduleHandle) mut => mInstance = moduleHandle;

	public void SetParam(void* param) mut => mParam = param;
	public void SetParam(Object obj) mut => mParam = Internal.UnsafeCastToPtr(obj);
	public void SetParam(int value) mut => mParam = (void*)value;

	public Result<WindowHandle> Create()
	{
		Win32.HINSTANCE instance = (.)mInstance;
		if (instance == 0)
			instance = (.)WindowClassBuilder.CurrentInstance;

		let result = Win32.CreateWindowExW((.)mExStyle, (char16*)mClassName, mWindowName, (.)mStyle, mPos.X, mPos.Y, mSize.Width, mSize.Height, (.)mParent, (.)mMenu, instance, mParam);

		if (result == 0)
			return .Err;
		return (WindowHandle)result;
	}

	[AllowDuplicates]
	public enum WINDOW_STYLE : uint32
	{
		OVERLAPPED = 0,
		POPUP = 2147483648,
		CHILD = 1073741824,
		MINIMIZE = 536870912,
		VISIBLE = 268435456,
		DISABLED = 134217728,
		CLIPSIBLINGS = 67108864,
		CLIPCHILDREN = 33554432,
		MAXIMIZE = 16777216,
		CAPTION = 12582912,
		BORDER = 8388608,
		DLGFRAME = 4194304,
		VSCROLL = 2097152,
		HSCROLL = 1048576,
		SYSMENU = 524288,
		THICKFRAME = 262144,
		GROUP = 131072,
		TABSTOP = 65536,
		MINIMIZEBOX = 131072,
		MAXIMIZEBOX = 65536,
		TILED = 0,
		ICONIC = 536870912,
		SIZEBOX = 262144,
		TILEDWINDOW = 13565952,
		OVERLAPPEDWINDOW = 13565952,
		POPUPWINDOW = 2156396544,
		CHILDWINDOW = 1073741824,
		ACTIVECAPTION = 1,
	}

	typealias WS = WINDOW_STYLE;

	[AllowDuplicates]
	public enum WINDOW_EX_STYLE : uint32
	{
		DLGMODALFRAME = 1,
		NOPARENTNOTIFY = 4,
		TOPMOST = 8,
		ACCEPTFILES = 16,
		TRANSPARENT = 32,
		MDICHILD = 64,
		TOOLWINDOW = 128,
		WINDOWEDGE = 256,
		CLIENTEDGE = 512,
		CONTEXTHELP = 1024,
		RIGHT = 4096,
		LEFT = 0,
		RTLREADING = 8192,
		LTRREADING = 0,
		LEFTSCROLLBAR = 16384,
		RIGHTSCROLLBAR = 0,
		CONTROLPARENT = 65536,
		STATICEDGE = 131072,
		APPWINDOW = 262144,
		OVERLAPPEDWINDOW = 768,
		PALETTEWINDOW = 392,
		LAYERED = 524288,
		NOINHERITLAYOUT = 1048576,
		NOREDIRECTIONBITMAP = 2097152,
		LAYOUTRTL = 4194304,
		COMPOSITED = 33554432,
		NOACTIVATE = 134217728,
	}

	typealias WS_EX = WINDOW_EX_STYLE;
}
