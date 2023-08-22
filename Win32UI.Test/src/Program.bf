namespace Win32UI.Test;

class Program
{
	static void Main()
	{
		/*var wcbuilder = scope WindowClassBuilder("Win32UI.Test");
		let r = wcbuilder
			..UseStandardIcon()
			..UseStandardCursor()
			..UseStandardSmallIcon()
			..UseStockBackground()
			..Register();

		if (let wcAtom = r)
		{
			Win32.MessageBoxW(0, scope $"wcAtom = {wcAtom}".ToScopedNativeWChar!(), "Success".ToScopedNativeWChar!(), .MB_OK);
		}
		else
			Win32.MessageBoxW(0, scope $"LastError = {Win32.GetLastError()}".ToScopedNativeWChar!(), "Failure".ToScopedNativeWChar!(), .MB_OK); */

		var res = RegisterWindowClass("Win32UI.Test");
		var window = CreateWindow(OverlappedWindow, "Win32UI.Test");
	}
}