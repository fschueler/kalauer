module IO

# DataTypes
abstract DataType
abstract BasicType <: DataType
abstract ArithmeticType <: DataType
abstract FixedLengthType <: DataType
abstract ArrayType <: DataType

# concrete types
typealias SmallIntType Int16
typealias IntType Int32
typealias BigIntType Int64
typealias FloatType Float32
typealias DoubleType Float64

# DataFields
abstract DataField

type IntegerField{T<:Integer} <: DataField
  value::T
end

typealias SmallIntField IntegerField{SmallIntType}
typealias IntField IntegerField{IntType}
typealias BigIntField IntegerField{BigIntType}

# Record Identifier (RID)
# the first 4 bytes represent the pageid, the last 4 bytes are the tupleid on the given page
type RID <: DataField
  value::Int64
end

function rid(page_idx::Int32, tuple_idx::Int32)
  if page_idx < 0 || tuple_idx < 0
    error("RIDs must be non-negative!")
  end

  new_rid = Int64((Int64(page_idx) << 32) | tuple_idx)
  return RID(new_rid)
end

getPageIdx(rid::RID) = return Int32(rid.value >>> 32)
getTupleIdx(rid::RID) = return Int32(rid.value & 0x0f)

# check for define arithmetic types
arithmetic{T<:DataField}(x::T) = return x.value <: Number

# Schemas
type ColumnSchema{T}
  name::String
  dataType::T
  nullable::Bool
  unique::Bool
end

type TableSchema
  size::Integer
  columns::Vector{ColumnSchema}
  columns_by_name::Dict{String, (ColumnSchema, Integer)}
end

# Pages
abstract CacheableData

type TablePage <: CacheableData
  id::Integer
  size::Integer
  modified::Bool
  expired::Bool
  buffer::IOBuffer
end

# Tuples
type DataTuple
  fields::Vector{DataField}
  width::Integer
end

# constructors for datatuples
datatuple(values::Vector{DataField}) = return DataTuple(copy(values), length(values))
datatuple(numFields::Integer) = return DataTuple(Vector{DataField}(numFields), numFields)

# getters and setters for fields in a tuple
getField(tuple::DataTuple, pos::Integer) = return tuple.fields[pos]
setField!(tuple::DataTuple, field::DataField, pos::Integer) = tuple.fields[pos] = field


######################################################################################
# TablePage functionalities
######################################################################################

# insert a tuple
function insertTuple(page::TablePage, tuple::DataTuple)

end

# delete a tuple (mark tombstone bit as deleted)
function deleteTuple(page::TablePage, position::Integer)

end


######################################################################################
# Serialization
######################################################################################

function encodeAsBinary{T}(buffer::IOBuffer, value::T, offset::Integer)
  write(buffer, value)
end

encodeAsBinary{T}(buffer::IOBuffer, value::T) = encodeAsBinary(buffer, value, 0)

######################################################################################
# Deserialization
######################################################################################

# extract a field from the first n bytes after the offset from the buffer
function getFieldFromBinary{T<:Integer}(buffer::IOBuffer, offset::Integer)

end

end # module

