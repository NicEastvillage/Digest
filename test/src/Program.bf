using System.Collections;
using System;
using Digest.Serialize;

namespace DigestTest
{
	public class SuperTestClass : Serialized
	{
		public int superint = 1001;
		//public float superfloat = 1002f;
		public List<List<int>> superlistlist = new List<List<int>>() {
			new List<int>() {123, 456, 678},
			new List<int>() {1, 22, 333, 4444, 55555},
			new List<int>() {0}
		} ~ DeleteContainerAndItems!(_);
	}

	public class TestClass : SuperTestClass, Serialized
	{
		public int i = 1;
		public int8 i8 = 2;
		//public int16 i16 = 3;
		public int32 i32 = 4;
		public int64 i64 = 5;
		public uint u = 6;
		public uint8 u8 = 7;
		public uint16 u16 = 8;
		public uint32 u32 = 9;
		public uint64 u64 = 10;
		public char8 c8 = 'a';
		public char16 c16 = 'b';
		//public float f = 11.0f;
		public double d = 12.0;
		public bool b = true;
		public List<int> list = new List<int>() {-1, -2, -3} ~ delete _;
		public Dictionary<int, char8> map = new Dictionary<int, char8>() {(1, 'a'), (2, 'b'), (3, 'c')} ~ delete _;
		public InnerTest inner;
		public TestClass child = null;
	}

	public struct InnerTest : Serialized
	{
		public String s = "123test";
	}

	class Program
	{
		public static void Main()
		{
			let data = scope TestClass();

			let prettyText = scope String();
			let printer = scope PrettyPrinter(prettyText);

			printer.Serialize(data);

			Console.WriteLine(prettyText);

			Console.Write("Done! Press ENTER to continue");
			Console.In.Read();
		}
	}
}
