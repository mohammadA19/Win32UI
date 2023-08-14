namespace System;

extension Enum
{
	public static T Include<T>(T _base, T value)
		where T : Enum
		where T : operator T | T
		=> _base | value;
}
