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
}

public struct WindowHandle : Win32.HWND;
public struct MenuHandle : Win32.HMENU;
public struct ModuleHandle : Win32.HINSTANCE;

static
{
	public static Result<int> CreateWindow(char16* className, char16* windowName, Win32.WINDOW_STYLE style, Win32.WINDOW_EX_STYLE exStyle = 0, int32 x = Win32.CW_USEDEFAULT, int32 y = Win32.CW_USEDEFAULT, int32 width = Win32.CW_USEDEFAULT, int32 height = Win32.CW_USEDEFAULT, WindowHandle parentWindow = 0, MenuHandle menu = 0, ModuleHandle instance = 0, void* param = null)
	{
		Win32.HINSTANCE _instance = (.)instance;
		if (_instance == 0)
			_instance = (.)WindowClassBuilder.CurrentInstance;
		
		let r = Win32.CreateWindowExW(exStyle, className, windowName, style, x, y, width, height, (.)parentWindow, (.)menu, (.)instance, param);

		if (r == 0)
			return .Err;
		return r;
	}

	public static Result<int> CreateWindow(uint16 windowClass, char16* windowName, Win32.WINDOW_STYLE style, Win32.WINDOW_EX_STYLE exStyle = 0, int32 x = Win32.CW_USEDEFAULT, int32 y = Win32.CW_USEDEFAULT, int32 width = Win32.CW_USEDEFAULT, int32 height = Win32.CW_USEDEFAULT, WindowHandle parentWindow = 0, MenuHandle menu = 0, ModuleHandle instance = 0, void* param = null)
	{
		return CreateWindow(windowClass, windowName, style, exStyle, x, y, width, height, parentWindow, menu, instance, param);
	}

	const Point UseDefaultPosition = .(Win32.CW_USEDEFAULT, Win32.CW_USEDEFAULT);
	const Size UseDefaultSize = .(Win32.CW_USEDEFAULT, Win32.CW_USEDEFAULT);
	
	public static Result<int> CreateWindow(char16* className, char16* windowName, Win32.WINDOW_STYLE style, Win32.WINDOW_EX_STYLE exStyle = 0, Point position = UseDefaultPosition, Size size = UseDefaultSize, WindowHandle parentWindow = 0, MenuHandle menu = 0, ModuleHandle instance = 0, void* param = null)
	{
		return CreateWindow(className, windowName, style, exStyle, position.X, position.Y, size.Width, size.Height, parentWindow, menu, instance, param);
	}

	public static Result<int> CreateWindow(uint16 className, char16* windowName, Win32.WINDOW_STYLE style, Win32.WINDOW_EX_STYLE exStyle = 0, Point position = UseDefaultPosition, Size size = UseDefaultSize, WindowHandle parentWindow = 0, MenuHandle menu = 0, ModuleHandle instance = 0, void* param = null)
	{
		return CreateWindow(className, windowName, style, exStyle, position.X, position.Y, size.Width, size.Height, parentWindow, menu, instance, param);
	}
}
