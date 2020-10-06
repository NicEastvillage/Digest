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
		public Result<void> SerializeField(StringView fieldName, Serializable value);

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

			// TODO write fields of base type

			for (let field in type.GetFields())
			{
				let fieldType = field.FieldType;
				let fieldVariant = field.GetValue(obj).Get();
				let fieldName = scope String(field.Name);

				Try!(SerializeField(s, fieldName, fieldType, fieldVariant));
			}

			return s.End();
		}

		private Result<void> SerializeField(ObjectSerializer os, StringView fieldName, Type fieldType, Variant fieldVariant)
		{
			if (fieldType.IsPrimitive)
			{
				switch (fieldType)
				{
				case typeof(int):
					return Try!(os.SerializeField(fieldName, fieldVariant.Get<int>()));
				case typeof(float):
					return Try!(os.SerializeField(fieldName, fieldVariant.Get<float>()));
				// ...
				default:
					return .Err;
				}
			}
			else if (fieldType.IsObject)
			{
				if (!fieldVariant.HasValue)
				{
					return os.SerializeField(fieldName, null);
				}

				let fieldObjectValue = fieldVariant.Get<Object>();

				if (fieldObjectValue == null)
				{
					return os.SerializeField(fieldName, null);
				}

				return os.SerializeField(fieldName, fieldObjectValue);
			}
			else if (fieldType.IsStruct)
			{
				let st = fieldVariant.GetBoxed().Get();
				defer delete st;
				return os.SerializeField(fieldName, st);
			}

			return .Err;
		}
	}
}
