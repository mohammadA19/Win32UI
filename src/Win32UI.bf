
namespace Win32UI;
using System;
using System.Text;
using System.Interop;
using System.Diagnostics;

static
{
	static T NotZero<T>(T value, T valueIfZero)
	{
		return value != default ? value : valueIfZero;
	}

	static Win32.WNDCLASSEXW PrepareWndClassExW(
		BrushHandle backgroundBrush = 0,
		CursorHandle cursor = 0,
		IconHandle smallIcon = 0,
		IconHandle icon = 0,
		ModuleHandle module = 0,
		Win32.WNDPROC windowProc = null,
		Win32.WNDCLASS_STYLES style = 0,
		int32 extraClassBytes = 0,
		int32 extraWindowBytes = 0
		)
	{
		return Win32.WNDCLASSEXW() {
			cbSize        = sizeof(Win32.WNDCLASSEXW),
			cbClsExtra    = extraClassBytes,
			cbWndExtra    = extraWindowBytes,
			hbrBackground = NotZero(backgroundBrush, Brush.GetStock(.WHITE_BRUSH)),
			hCursor       = NotZero(cursor, Cursor.LoadFromSystem(.ARROW)),
			hIconSm       = NotZero(smallIcon, Win32.LoadImageW(Module.CurrentInstance, (.)(void*)5, .IMAGE_ICON, SystemMetrics.SmallIcon.Width, SystemMetrics.SmallIcon.Height, .LR_DEFAULTCOLOR)),
			hIcon         = NotZero(icon, Icon.LoadFromSystem(IDI.APPLICATION)),
			hInstance     = NotZero(module, Module.CurrentInstance),
			lpfnWndProc   = windowProc ?? => WindowProc,
			// lpszClassName = ... ,
			// lpszMenuName  = ... ,
			style         = NotZero(style, 0) // TODO
		};
	}

	public static Result<WindowClass> RegisterWindowClass(
		String windowClassName,
		String menuName = null,
		BrushHandle backgroundBrush = 0,
		CursorHandle cursor = 0,
		IconHandle smallIcon = 0,
		IconHandle icon = 0,
		ModuleHandle module = 0,
		Win32.WNDPROC windowProc = null,
		Win32.WNDCLASS_STYLES style = 0,
		int32 extraClassBytes = 0,
		int32 extraWindowBytes = 0
		)
	{
		Debug.Assert(windowClassName != null);
		var wc = PrepareWndClassExW(backgroundBrush, cursor, smallIcon, icon, module, windowProc, style, extraClassBytes, extraWindowBytes);

		wc.lpszClassName = windowClassName.ToScopedNativeWChar!();
		wc.lpszMenuName = menuName?.ToScopedNativeWChar!();

		let atom = Win32.RegisterClassExW(&wc);
		return atom != 0 ? WindowClass(atom) : .Err;
	}
}

public static class SystemMetrics
{
	public static Size SmallIcon => .(Win32.GetSystemMetrics(.SM_CXSMICON), Win32.GetSystemMetrics(.SM_CYSMICON));
}

// TODO: extend this struct
public struct WindowClass
{
	char16* mClassName;

	public this(char16* classNamePtr)
	{
		mClassName = classNamePtr;
	}

	public this(uint16 atom)
	{
		mClassName = (char16*)(void*)(int)atom;
	}

	/*[AllowAppend]
	public this(String className)
	{
		// if (className == null)
			// return;
		Debug.Assert(className != null, "class name must not be null");

		int encodedLen = UTF16.GetEncodedLen(className);
		char16* appendPtr = append char16[encodedLen+1]* (?);
		mClassName = appendPtr;

		UTF16.Encode(className, (.)mClassName, encodedLen);
		mClassName[encodedLen] = 0;
	}*/

	static bool IsAtom(char16* v)
	{
		let i = (int)(void*)v;
		return 0x0 < i && i < 0x10000;
	}

	static bool IsNotAtom(char16* v)
	{
		return !IsAtom(v);
	}
}

public class EventLoop
{
	bool mRunning = true;

	public Win32.WPARAM Run()
	{
		Win32.MSG msg = default;
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

static
{
	[CallingConvention(.Stdcall)]
	public static Win32.LRESULT WindowProc(Win32.HWND param0, uint32 param1, Win32.WPARAM param2, Win32.LPARAM param3)
	{
		switch (param1)
		{
		case Win32.WM_CLOSE:
			Win32.PostQuitMessage(0);
		default:
			// Do nothing
		}

		return Win32.DefWindowProcW(param0, param1, param2, param3);
	}
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

public typealias WS = WINDOW_STYLE;

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

public typealias WS_EX = WINDOW_EX_STYLE;

public struct ConstructionParams : this(
	WindowClass? WindowClass,
	String WindowName,
	WINDOW_STYLE Style,
	WINDOW_EX_STYLE ExStyle,
	Point Position,
	Size Size,
	WindowHandle Parent = 0,
	MenuHandle Menu = 0);

static
{
	const Point DefaultPosition = .(Win32.CW_USEDEFAULT, Win32.CW_USEDEFAULT);

	static char16[?] ButtonClassName = "BUTTON".ToConstNativeW();
	public static WindowClass Button = .(&ButtonClassName);

	public const ConstructionParams OverlappedWindowParams = .(null, "Window", WS.OVERLAPPEDWINDOW, 0, DefaultPosition, .(500, 400));
	public const ConstructionParams ButtonParams = .(Button, "Button", WS.VISIBLE | WS.CHILD, 0, DefaultPosition, .(300, 25));

	public static Result<WindowHandle> CreateWindow(ConstructionParams cParams, String className = null, String windowName = null, WINDOW_STYLE? style = null,
		WINDOW_EX_STYLE? exStyle = null, Point? position = null, Size? size = null, WindowHandle? parent = null, MenuHandle? menu = null)
	{
		// Debug.Assert(cParams != null, scope $"Argument '{nameof(cParams)}' must not be null");
		Debug.Assert(className != null || cParams.WindowClass != null, "window class name is not provided by arguments nor by ConstructionParams instance");
		let pos = position ?? cParams.Position;
		let sz = size ?? cParams.Size;

		let result = Win32.CreateWindowExW(exStyle ?? cParams.ExStyle, className?.ToScopedNativeWChar!() ?? cParams.WindowClass, 
			(windowName ?? cParams.WindowName).ToScopedNativeWChar!(),  style ?? cParams.Style, 
			pos.X, pos.Y, sz.Width, sz.Height, parent ?? cParams.Parent, menu ?? cParams.Menu, Module.CurrentInstance, null);

		return result != 0 ? (.)result : .Err;
	}
}
