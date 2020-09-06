using Digest.Serialize;

namespace System
{
	extension Int : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeInt((int)this);
		}
	}

	extension Float : Serializable
	{
		public Result<void> Serialize(Serializer S)
		{
			return S.SerializeFloat((float)this);
		}
	}
}

namespace System.Collections
{
	extension List<T> : Serializable where T : Serializable
	{
		public Result<void> Serialize(Serializer S)
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
		public Result<void> Serialize(Serializer S)
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