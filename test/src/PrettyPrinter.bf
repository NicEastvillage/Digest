using Digest.Serialize;
using System;

namespace DigestTest
{
	class PrettyPrinter : Serializer
	{
		private String indent = "    ";
		private String outString;
		private int currentIndentation = 0;

		public this(String outString)
		{
			this.outString = outString;
		}

		public override System.Result<void> SerializeInt(int value)
		{
			outString.AppendF("{}", value);
			return .Ok;
		}

		public override System.Result<void> SerializeInt8(int8 value)
		{
			outString.AppendF("{}", value);
			return .Ok;
		}

		public override System.Result<void> SerializeInt16(int16 value)
		{
			outString.AppendF("{}", value);
			return .Ok;
		}

		public override System.Result<void> SerializeInt32(int32 value)
		{
			outString.AppendF("{}", value);
			return .Ok;
		}

		public override System.Result<void> SerializeInt64(int64 value)
		{
			outString.AppendF("{}", value);
			return .Ok;
		}

		public override System.Result<void> SerializeUInt(uint value)
		{
			outString.AppendF("{}", value);
			return .Ok;
		}

		public override System.Result<void> SerializeUInt8(uint8 value)
		{
			outString.AppendF("{}", value);
			return .Ok;
		}

		public override System.Result<void> SerializeUInt16(uint16 value)
		{
			outString.AppendF("{}", value);
			return .Ok;
		}

		public override System.Result<void> SerializeUInt32(uint32 value)
		{
			outString.AppendF("{}", value);
			return .Ok;
		}

		public override System.Result<void> SerializeUInt64(uint64 value)
		{
			outString.AppendF("{}", value);
			return .Ok;
		}

		public override System.Result<void> SerializeChar8(char8 value)
		{
			outString.AppendF("'{}'", value);
			return .Ok;
		}

		public override System.Result<void> SerializeChar16(char16 value)
		{
			outString.AppendF("'{}'", value);
			return .Ok;
		}

		public override System.Result<void> SerializeFloat(float value)
		{
			outString.AppendF("{}", value);
			return .Ok;
		}

		public override System.Result<void> SerializeDouble(double value)
		{
			outString.AppendF("{}", value);
			return .Ok;
		}

		public override System.Result<void> SerializeBool(bool value)
		{
			outString.AppendF("{}", value);
			return .Ok;
		}

		public override System.Result<void> SerializeString(System.StringView str)
		{
			outString.AppendF("\"{}\"", str);
			return .Ok;
		}

		public System.Result<void> SerializeFieldName(System.StringView str)
		{
			outString.AppendF("{}", str);
			return .Ok;
		}

		public override System.Result<ListSerializer> SerializeList(int count)
		{
			return .Ok(new PrettyListPrinter(this));
		}

		public override System.Result<MapSerializer> SerializeDictionary(int count)
		{
			return .Ok(new PrettyMapPrinter(this));
		}

		public override System.Result<void> SerializeNull()
		{
			outString.AppendF("null");
			return .Ok;
		}

		protected override System.Result<ObjectSerializer> SerializeObject(System.String className)
		{
			return .Ok(new PrettyObjectPrinter(this));
		}

		private void IncreaseIdentation()
		{
			 currentIndentation++;
		}

		private void DecreaseIndentation()
		{
			currentIndentation--;
		}

		private void AddIndentation()
		{
			for (let i < currentIndentation)
			{
				outString.Append(indent);
			}
		}
	}

	class PrettyListPrinter : ListSerializer
	{
		private PrettyPrinter pp;
		private String outString => pp.[Friend]outString;
		private bool emptyList = true;

		public this(PrettyPrinter pp)
		{
			this.pp = pp;
			pp.[Friend]IncreaseIdentation();
			outString.Append("[");
		}

		public Result<void> SerializeElement(Serializable element)
		{
			if (!emptyList)
			{
				outString.Append(",");
			}
			emptyList = false;
			outString.Append("\n");
			pp.[Friend]AddIndentation();
			pp.Serialize(element);
			return .Ok;
		}

		public Result<void> End()
		{
			pp.[Friend]DecreaseIndentation();
			if (emptyList)
			{
				outString.Append("]");
			}
			else
			{
				outString.Append("\n");
				pp.[Friend]AddIndentation();
				outString.Append("]");
			}
			return .Ok;
		}
	}

	class PrettyMapPrinter : MapSerializer
	{
		private PrettyPrinter pp;
		private String outString => pp.[Friend]outString;
		private bool emptyMap = true;

		public this(PrettyPrinter pp)
		{
			this.pp = pp;
			pp.[Friend]IncreaseIdentation();
			outString.Append("{");
		}

		public Result<void> SerializeKeyValuePair(Serializable key, Serializable value)
		{
			if (!emptyMap)
			{
				outString.Append(",");
			}
			emptyMap = false;
			outString.Append("\n");
			pp.[Friend]AddIndentation();
			pp.Serialize(key);
			outString.Append(": ");
			pp.Serialize(value);
			return .Ok;
		}

		public Result<void> End()
		{
			pp.[Friend]DecreaseIndentation();
			if (emptyMap)
			{
				outString.Append("}");
			}
			else
			{
				outString.Append("\n");
				pp.[Friend]AddIndentation();
				outString.Append("}");
			}
			return .Ok;
		}
	}

	class PrettyObjectPrinter : ObjectSerializer
	{
		private PrettyPrinter pp;
		private String outString => pp.[Friend]outString;
		private bool emptyObject = true;

		public this(PrettyPrinter pp)
		{
			this.pp = pp;
			pp.[Friend]IncreaseIdentation();
			outString.Append("(");
		}

		public Result<void> SerializeField(StringView fieldName, Serializable value)
		{
			if (!emptyObject)
			{
				outString.Append(",");
			}
			emptyObject = false;
			outString.Append("\n");
			pp.[Friend]AddIndentation();
			pp.SerializeFieldName(fieldName);
			outString.Append(": ");
			pp.Serialize(value);
			return .Ok;
		}

		public Result<void> End()
		{
			pp.[Friend]DecreaseIndentation();
			if (emptyObject)
			{
				outString.Append(")");
			}
			else
			{
				outString.Append("\n");
				pp.[Friend]AddIndentation();
				outString.Append(")");
			}
			return .Ok;
		}
	}
}
