using System;
namespace Digest.Serialize
{
	interface Serializable
	{
		public Result<void> Serialize(Serializer S);
	}
}
