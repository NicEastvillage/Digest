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

		protected abstract Result<ObjectSerializer> SerializeObject(String className);

		public Result<void> Serialize(Serializable item)
		{
			// Dynamic dispatching
			return item.Serialize(this);
		}

		public Result<void> SerializeObject(Object obj)
		{
			/*if (obj is Serializable)
				return Serialize(obj as Serializable);*/

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
				let fieldName = scope String(field.Name);

				Try!(s.SerializeField(fieldName, value));
			}

			return s.End();
		}

		private Result<Serializable> ExtractValueFromField(Object obj, FieldInfo field)
		{
			let fieldType = field.FieldType;
			let fieldVariant = field.GetValue(obj).Get();

			if (fieldType.IsPrimitive)
			{
				switch (fieldType)
				{
				case typeof(int):
					return .Ok(fieldVariant.Get<int>());
				case typeof(float):
					return .Ok(fieldVariant.Get<float>());
				// ...
				default:
					return .Err;
				}
			}
			else if (fieldType.IsObject)
			{
				if (!fieldVariant.HasValue)
				{
					return .Ok(null);
				}

				var fieldObjectValue = fieldVariant.Get<Object>();

				if (fieldObjectValue == null)
				{
					return .Ok(null);
				}

				if (fieldObjectValue is Serializable)
				{
					return .Ok(fieldObjectValue as Serializable);
				}
				else
				{
					return .Ok(Try!(Serialize(fieldObjectValue)));
				}
			}

			return .Err;
		}
	}
}
