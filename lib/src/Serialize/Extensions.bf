using Digest.Serialize;
using System.Diagnostics;

namespace System
{
	extension Int : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeInt((int)this);
		}
	}

	extension Int8 : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeInt8((int8)this);
		}
	}

	extension Int16 : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeInt16((int16)this);
		}
	}

	extension Int32 : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeInt32((int32)this);
		}
	}

	extension Int64 : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeInt64((int64)this);
		}
	}

	extension UInt : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeUInt((uint)this);
		}
	}

	extension UInt8 : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeUInt8((uint8)this);
		}
	}

	extension UInt16 : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeUInt16((uint16)this);
		}
	}

	extension UInt32 : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeUInt32((uint32)this);
		}
	}

	extension UInt64 : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeUInt64((uint64)this);
		}
	}

	extension Char8 : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeChar8((char8)this);
		}
	}

	extension Char16 : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeChar16((char16)this);
		}
	}

	extension Float : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeFloat((float)this);
		}
	}

	extension Double : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeDouble((double)this);
		}
	}

	extension Boolean : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeBool((bool)this);
		}
	}

	extension Object : Serializable
	{
		public virtual Result<void> Serialize(Serializer S)
		{
			return S.SerializeObject(this);
		}
	}

	extension String : Serializable
	{
		public override Result<void> Serialize(Serializer S)
		{
			return S.SerializeString(this);
		}
	}

	extension StringView : Serializable, Serialized
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeString(this);
		}
	}
}

namespace System.Collections
{
	extension List<T> : Serializable where T : Serializable
	{
		public override Result<void> Serialize(Serializer S)
		{
			let seq = Try!(S.SerializeList(Count));
			defer delete seq;

			for (T item in this)
			{
				Try!(seq.SerializeElement(item));
			}
			return seq.End();
		}
	}

	extension Dictionary<K, V> : Serializable
		where K : Serializable
		where V : Serializable
	{
		public override Result<void> Serialize(Serializer S)
		{
			let map = Try!(S.SerializeDictionary(Count));
			defer delete map;

			for (let (key, value) in this)
			{
				Try!(map.SerializeKeyValuePair(key, value));
			}
			return map.End();
		}
	}
}