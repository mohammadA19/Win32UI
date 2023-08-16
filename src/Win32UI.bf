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
	public this(int32 x = 0, int32 y = 0) => (X, Y) = (x, y);

	public int32 X { get; set mut; }
	public int32 Y { get; set mut; }

	public static explicit operator POINT(Self val) => .() { x = val.X, y = val.Y};
	public static explicit operator Self(POINT val) => .(val.x, val.y);
}

[CRepr]
public struct Size
{
	public this(i nt32 width = 0, int32 height = 0) => (Width, Height) = (width, height);

	public int32 Width { get; set mut; }
	public int32 Height { get; set mut; }

	public static explicit operator SIZE(Self val) => .() { cx = Width, cy = Height };
	public static explicit operator Self(SIZE val) => .(val.cx, val.cy);
}

public struct WindowHandle : Win32.HWND;
public struct MenuHandle : Win32.HMENU;
public struct ModuleHandle : Win32.HINSTANCE;

public struct WindowBuilder
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

public class EventLoop
{
	bool mRunning = true;

	public WPARAM Run()
	{
		Win32.MSG msg;
		while (mRunning)
		{
			if (Win32.GetMessageW(&msg, 0, 0, 0) == 0)
			{
				mRunning = false;
				break;
			}

			Win32.TranslateMessage(&msg);
			Win32.DispatchMessageW(&msg);
		}
		return msg.wParam;
	}

	public void Stop() => mRunning = false;
}
