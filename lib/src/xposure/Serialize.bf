using System;
using System.Reflection;
using System.Collections;

namespace Digest.xposure
{
	public abstract class TypeSerializer
	{
	    public abstract void Serialize(Serializer sw, ref Object o, FieldInfo fi);

	    public abstract void Deserialize(Serializer sw, ref Object o, FieldInfo fi);

	}

	public class IntSerializer : TypeSerializer
	{
	    public override void Serialize(Serializer sw, ref Object o, FieldInfo fi)
	    {
	        var result = (int)fi.GetValue(o).Get().[Friend]mData;
	    }

	    public override void Deserialize(Serializer sw, ref Object o, FieldInfo fi)
	    {

	    }
	}

	public class Serializer
	{
	    private Dictionary<Type, TypeSerializer> _serializers = new Dictionary<Type, TypeSerializer>();

	    public this()
	    {
	        _serializers.Add(typeof(int), new IntSerializer());
	    }

	    public void Serialize<T>(T t)
	    {
			var k = (Object)t;
	        Serialize(this, typeof(T), ref k);
	    }

	    private void Serialize(Serializer sw, Type type, ref Object o)
	    {
	        var fields = type.GetFields();
	        for (var it in fields)
	        {
				TypeSerializer serializer;
	            if (_serializers.TryGetValue(it.FieldType, out serializer))
	            {
	                serializer.Serialize(sw, ref o, it);
	            }
	            else
	            {
					if (it.FieldType.IsStruct)
					{
						var b = (Object)it.GetValue(o).Get();
						Serialize(sw, it.FieldType, ref b);
					}
	            }
	        }
	    }

	    public T Deserialize<T>(Serializer sw)
	    {
	        var t = default(T);
			var k = (Object)t;
	        var type = typeof(T);
	        var fields = type.GetFields();
	        for (var it in fields)
	        {
				TypeSerializer serializer;
	            if (_serializers.TryGetValue(it.FieldType, out  serializer))
	            {
	                serializer.Deserialize(sw, ref k, it);
	            }
	            else
	            {
	                //check if struct and recurse
	            }
	        }
	        return t;
	    }
	}

}
