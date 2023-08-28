
using System;
namespace Win32UI;

[CRepr]
public struct Point
{
	public this(int32 x = 0, int32 y = 0) => (X, Y) = (x, y);

	public int32 X { get; set mut; }
	public int32 Y { get; set mut; }

	public static explicit operator Win32.POINT(Self val) => .() { x = val.X, y = val.Y};
	public static explicit operator Self(Win32.POINT val) => .(val.x, val.y);
}

[CRepr]
public struct Size
{
	public this(int32 width = 0, int32 height = 0) => (Width, Height) = (width, height);

	public int32 Width { get; set mut; }
	public int32 Height { get; set mut; }

	public static explicit operator Win32.SIZE(Self val) => .() { cx = val.Width, cy = val.Height };
	public static explicit operator Self(Win32.SIZE val) => .(val.cx, val.cy);
}

public struct WindowHandle : Win32.HWND;
public struct MenuHandle : Win32.HMENU;
public struct ModuleHandle : Win32.HINSTANCE;
public struct BrushHandle : Win32.HBRUSH;

public struct IconHandle : Win32.HICON
{
}

public struct CursorHandle : Win32.HCURSOR
{

}

public static class Module
{
    private static ModuleHandle sCurrentInstance = 0;
    public static ModuleHandle CurrentInstance 
    {
        get
        {
            if (sCurrentInstance == 0)
                sCurrentInstance = (.)Win32.GetModuleHandleW(null);
            return sCurrentInstance;
        }
    }
}

public static class Icon
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

    public static IconHandle LoadFromSystem(SystemIcons icon)
    {
        return Win32.LoadIconW(0, (.)icon);
    }

    public static Result<IconHandle> LoadFromModule(ModuleHandle module, String iconName)
    {
        Debug.Assert(iconName != null, nameof(iconName) + " parameter must not be null");
        return TRY!( Win32.LoadIconW(module, iconName.ToScopedNativeWChar!()) );
    }

    public static Result<IconHandle> LoadFromModule(ModuleHandle module, char16* iconName)
    {
        Debug.Assert(iconName != null, nameof(iconName) + " parameter must not be null");
        return TRY!( Win32.LoadIconW(module, iconName) );
    }

    public static Result<IconHandle> LoadFromModule(ModuleHandle module, uint16 iconOrdinal)
    {
        return TRY!( Win32.LoadIconW(module, (void*)(uint)iconOrdinal) );
    }
}

public static class Cursor
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

    public static CursorHandle LoadFromSystem(SystemCursors cursor)
    {
        return Win32.LoadCursorW(0, (.)cursor);
    }

    public static Result<CursorHandle> LoadFromModule(ModuleHandle module, String cursorName)
    {
        Debug.Assert(cursorName != null, nameof(cursorName) + " parameter must not be null");
        return TRY!( Win32.LoadCursorW(module, cursorName.ToScopedNativeWChar!()) );
    }

    public static Result<IconHandle> LoadFromModule(ModuleHandle module, char16* cursorName)
    {
        Debug.Assert(cursorName != null, nameof(cursorName) + " parameter must not be null");
        return TRY!( Win32.LoadCursorW(module, cursorName) );
    }

    public static Result<IconHandle> LoadFromModule(ModuleHandle module, uint16 cursorOrdinal)
    {
        return TRY!( Win32.LoadCursorW(module, (void*)(uint)cursorOrdinal) );
    }
}

public static class Brush
{
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

    public static BrushHandle GetStock(StockBrushes brush)
    {
        return Win32.GetStockObject((.)brush);
    }
}