
using System;
using System.Diagnostics;
namespace Win32UI;

[CRepr]
public struct Point : this(int32 X, int32 Y)
{
	public static explicit operator Win32.POINT(Self val) => .() { x = val.X, y = val.Y};
	public static explicit operator Self(Win32.POINT val) => .(val.x, val.y);
}

[CRepr]
public struct Size : this(int32 Width, int32 Height)
{
	public static explicit operator Win32.SIZE(Self val) => .() { cx = val.Width, cy = val.Height };
	public static explicit operator Self(Win32.SIZE val) => .(val.cx, val.cy);
}

[Union]
public struct Rect
{
	public using RectAsBounds Bounds;
	public using RectAsPoints Points;
	public       int32[4] Values;

	[Packed]
	public struct RectAsBounds : this(int32 Left, int32 Top, int32 Right, int32 Bottom);

	[Packed]
	public struct RectAsPoints : this(Point TopLeft, Point BottomRight);
}

public struct Window;
public struct Menu;

public static struct Module
{
	private static Module* sCurrentInstance = default;
	public static Module* CurrentInstance
	{
	    get
	    {
	        if (sCurrentInstance == default)
	            sCurrentInstance = (.)Win32.GetModuleHandleW(null);
	        return sCurrentInstance;
	    }
	}
}

public static struct Icon
{
	public enum SystemIcons : uint
	{
	    APPLICATION = 32512,
	    QUESTION = 32514,
	    WINLOGO = 32517,
	    SHIELD = 32518,
	    WARNING = 32515,
	    ERROR = 32513,
	    INFORMATION = 32516,
	}

	public typealias IDI = SystemIcons;

	public static Icon* LoadFromSystem(SystemIcons icon)
	{
	    return Win32.LoadIconW(default, (.)(void*)(int)icon);
	}

	public static Icon* LoadFromModule(Module* module, String iconName)
	{
	    Debug.Assert(iconName != null, nameof(iconName) + " parameter must not be null");
	    return Win32.LoadIconW(module, iconName.ToScopedNativeWChar!());
	}

	public static Icon* LoadFromModule(Module* module, char16* iconName)
	{
	    Debug.Assert(iconName != null, nameof(iconName) + " parameter must not be null");
	    return Win32.LoadIconW(module, iconName);
	}

	public static Icon* LoadFromModule(Module* module, uint16 iconOrdinal)
	{
	    return Win32.LoadIconW(module, (char16*)(void*)(uint)iconOrdinal);
	}
}

public static struct Cursor
{
	public enum SystemCursors : uint
	{
	    ARROW = 32512,
	    IBEAM = 32513,
	    WAIT = 32514,
	    CROSS = 32515,
	    UPARROW = 32516,
	    SIZE = 32640,
	    ICON = 32641,
	    SIZENWSE = 32642,
	    SIZENESW = 32643,
	    SIZEWE = 32644,
	    SIZENS = 32645,
	    SIZEALL = 32646,
	    NO = 32648,
	    HAND = 32649,
	    APPSTARTING = 32650,
	    HELP = 32651,
	    PIN = 32671,
	    PERSON = 32672,
	}

	public typealias IDC = SystemCursors;

	public static Cursor* LoadFromSystem(SystemCursors cursor)
	{
	    return Win32.LoadCursorW(default, (.)(void*)(int)cursor);
	}

	public static Cursor* LoadFromModule(Module* module, String cursorName)
	{
	    Debug.Assert(cursorName != null, nameof(cursorName) + " parameter must not be null");
	    return Win32.LoadCursorW(module, cursorName.ToScopedNativeWChar!());
	}

	public static Cursor* LoadFromModule(Module* module, char16* cursorName)
	{
	    Debug.Assert(cursorName != null, nameof(cursorName) + " parameter must not be null");
	    return Win32.LoadCursorW(module, cursorName);
	}

	public static Cursor* LoadFromModule(Module* module, uint16 cursorOrdinal)
	{
	    return Win32.LoadCursorW(module, (.)(void*)(uint)cursorOrdinal);
	}
}

public static struct Brush
{
	[AllowDuplicates]
    public enum StockBrushes : uint32
    {
        BLACK_BRUSH = 4,
		DKGRAY_BRUSH = 3,
		DC_BRUSH = 18,
		GRAY_BRUSH = 2,
		HOLLOW_BRUSH = 5,
		LTGRAY_BRUSH = 1,
		NULL_BRUSH = 5,
		WHITE_BRUSH = 0,
    }

    public static Brush* GetStock(StockBrushes brush)
    {
        return (.)(void*)Win32.GetStockObject((.)brush);
    }
}

public static struct DC;
public static struct Bitmap;
public static struct Region;
public static struct Pen;
public static struct Font;
public static struct Palette;
public static struct Monitor;
