using System;
namespace Digest.Serialize
{
	interface Serializable
	{
		public Result<void> Serialize(Serializer S);
	}

	/* Marker. Every serialized custom class must implement this to generate the needed reflection data */
	[Reflect(.None, ReflectImplementer=.DynamicBoxing | .All)]
	interface Serialized { }
}
