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

		public abstract Result<void> SerializeInt8(int8 value);

		public abstract Result<void> SerializeInt16(int16 value);

		public abstract Result<void> SerializeInt32(int32 value);

		public abstract Result<void> SerializeInt64(int64 value);

		public abstract Result<void> SerializeUInt(uint value);

		public abstract Result<void> SerializeUInt8(uint8 value);

		public abstract Result<void> SerializeUInt16(uint16 value);

		public abstract Result<void> SerializeUInt32(uint32 value);

		public abstract Result<void> SerializeUInt64(uint64 value);

		public abstract Result<void> SerializeChar8(char8 value);

		public abstract Result<void> SerializeChar16(char16 value);

		public abstract Result<void> SerializeFloat(float value);

		public abstract Result<void> SerializeDouble(double value);

		public abstract Result<void> SerializeBool(bool value);

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

			let objSerializer = Try!(SerializeObject(typeName));
			defer delete objSerializer;

			SerializeFieldsInHierarchy(objSerializer, type, obj);

			return objSerializer.End();
		}

		private Result<void> SerializeFieldsInHierarchy(ObjectSerializer objSerializer, Type type, Object obj)
		{
			let baze = type.BaseType;

			if (baze != typeof(Object) && baze != typeof(ValueType))
			{
				Try!(SerializeFieldsInHierarchy(objSerializer, baze, obj));
			}

			for (let field in type.GetFields())
			{
				let fieldType = field.FieldType;
				let fieldVariant = field.GetValue(obj).Get();
				let fieldName = scope String(field.Name);
				Debug.WriteLine(fieldName);

				Try!(SerializeField(objSerializer, fieldName, fieldType, fieldVariant));
			}

			return .Ok;
		}

		private Result<void> SerializeField(ObjectSerializer objSerializer, StringView fieldName, Type fieldType, Variant fieldVariant)
		{
			if (fieldType.IsValueType)
			{
				let boxed = fieldVariant.GetBoxed().Get();
				defer delete boxed;
				return objSerializer.SerializeField(fieldName, boxed);
			}
			else if (fieldType.IsObject)
			{
				if (!fieldVariant.HasValue)
				{
					return objSerializer.SerializeField(fieldName, null);
				}

				let fieldObjectValue = fieldVariant.Get<Object>();

				return objSerializer.SerializeField(fieldName, fieldObjectValue);
			}

			return .Err;
		}
	}
}
