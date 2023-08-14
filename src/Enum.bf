namespace System;

extension Enum
{
	public static T Include<T>(T _base, T value)
		where T : Enum
		where T : operator T | T
		=> _base | value;

	public static T Exclude<T>(T _base, T value)
		where T : Enum
		where T : operator T & T
		where T : operator ~T
		=> _base & ~value;

	public static bool Contains<T>(T _base, T value)
		where T : Enum
		where T : operator T & T
		//where bool: operator T != int
		=> (int)(_base & value) != 0;
}
