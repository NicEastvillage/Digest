using System;
using System.Diagnostics;
using System.Reflection;

namespace Digest.Serialize
{
	interface ListSerializer
	{
		public Result<void> SerializeElement(Serializable element);

		public Result<void> End();
	}

	interface MapSerializer
	{
		public Result<void> SerializeKeyValuePair(Serializable key, Serializable value);

		public Result<void> End();
	}

	interface ObjectSerializer
	{
		public Result<void> SerializeField(String fieldName, Serializable value);

		public Result<void> End();
	}

	abstract class Serializer
	{
		public abstract Result<void> SerializeInt(int value);

		public abstract Result<void> SerializeInt64(int64 value);

		public abstract Result<void> SerializeFloat(float value);

		public abstract Result<void> SerializeString(StringView str);

		public abstract Result<ListSerializer> SerializeList(int count);

		public abstract Result<MapSerializer> SerializeDictionary(int count);

		public abstract Result<void> SerializeNull();

		protected abstract Result<ObjectSerializer> SerializeObject(String className);

		public Result<void> Serialize(Serializable item)
		{
			// Dynamic dispatching
			if (item == null)
				return SerializeNull();
			return item.Serialize(this);
		}

		public Result<void> SerializeObject(Object obj)
		{
			let type = obj.GetType();
			let typeName = scope String();
			type.GetName(typeName);

			let s = Try!(SerializeObject(typeName));
			defer delete s;

			let fields = type.GetFields();

			// TODO write fields of base type

			for (let field in fields)
			{
				let value = Try!(ExtractValueFromField(obj, field));
				defer delete value;
				let fieldName = scope String(field.Name);

				Try!(s.SerializeField(fieldName, value));
			}

			return s.End();
		}

		// NOTE: The returned value is boxed and the box should be deleted by caller
		private Result<Serializable> ExtractValueFromField(Object obj, FieldInfo field)
		{
			let fieldType = field.FieldType;
			let fieldVariant = field.GetValue(obj).Get();

			if (fieldType.IsPrimitive)
			{
				switch (fieldType)
				{
				case typeof(int):
					return .Ok(new box fieldVariant.Get<int>());
				case typeof(float):
					return .Ok(new box fieldVariant.Get<float>());
				// ...
				default:
					return .Err;
				}
			}
			else if (fieldType.IsObject)
			{
				if (!fieldVariant.HasValue)
				{
					return .Ok(new Box(null));
				}

				var fieldObjectValue = fieldVariant.Get<Object>();

				if (fieldObjectValue == null)
				{
					return .Ok(new Box(null));
				}

				return .Ok(new Box(fieldObjectValue));
			}

			return .Err;
		}

		private class Box : Serializable
		{
			Object value;
			public this(Object value)
			{
				this.value = value;
			}

			public new Result<void> Serialize(Serializer S)
			{
				if (value == null)
					return S.SerializeNull();

				return value.Serialize(S);
			}
		}
	}
}
