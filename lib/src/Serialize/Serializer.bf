using System;
using System.Diagnostics;

namespace Digest.Serialize
{
	interface Serializer
	{
		public Result<void> SerializeInt(int value);

		public Result<void> SerializeFloat(float value);

		public Result<SerializeSequence> SerializeList(int count);

		public Result<SerializeMap> SerializeDictionary(int count);

		public Result<void> Serialize(Serializable item);
	}

	interface SerializeSequence
	{
		public Result<void> SerializeElement(Serializable element);

		public Result<void> End();
	}

	interface SerializeMap
	{
		public Result<void> SerializeKeyValuePair(Serializable key, Serializable value);

		public Result<void> End();
	}
}
