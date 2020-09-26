using System;
using Digest.xposure;
using System.Diagnostics;

namespace DigestTest
{
	class Program
	{
		[Reflect]
		public class TestClass
		{
			public int integer = 5;
			public InnerStruct inner = DerivingStruct();
		}

		[Reflect]
		public struct InnerStruct
		{
			public int number = 42;
		}

		[Reflect]
		public struct DerivingStruct : InnerStruct
		{
			public int wow = -1;
		}

		public static void Main()
		{
			Console.WriteLine("Hello World");

			let tc = scope TestClass();
			let s = scope Serializer();

			let str = InnerStruct();
			let o = (Object)str;

			s.Serialize(tc);

			Console.Write("Done! Press ENTER to continue");
			Console.In.Read();
		}
	}
}
