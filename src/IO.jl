module IO

# DataTypes
abstract SqlDataType

# concrete types
typealias SmallIntType Int16
typealias IntType Int32
typealias BigIntType Int64
typealias FloatType Float32
typealias DoubleType Float64

# DataFields
abstract DataField

# number fields
type IntegerField{T<:Integer} <: DataField
  value::T
end

typealias SmallIntField IntegerField{SmallIntType}
typealias IntField IntegerField{IntType}
typealias BigIntField IntegerField{BigIntType}

# char fields
type VarCharField{T<:AbstractString} <: DataField
  value::T
end

type CharField{T<:AbstractString} <: DataField
  value::T
  length::Integer
end

# date/time fields


# Record Identifier (RID) Field
# the first 4 bytes represent the pageid, the last 4 bytes are the tupleid on the given page
immutable RID <: DataField
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

# Column Schemas
type ColumnSchema{T}
  name::AbstractString
  dataType::T
  nullable::Bool
  unique::Bool
end

ColumnSchema{T}(name::AbstractString, dtype::T, nullable, unique) = return ColumnSchema(name, dtype, nullable, unique)

ColumnSchema{T}(name::AbstractString, dtype::T) = ColumnSchema(name, dtype, false, false)

ColumnSchema{T}(name::AbstractString, dtype::T, nullable) = ColumnSchema(name, dtype, nullable, false)

# Table Schemas
type TableSchema
  size::Integer
  columns::Vector{ColumnSchema}
  columns_by_name::Dict{AbstractString, (ColumnSchema, Integer)}
end

TableSchema(pagesize::Integer) = return TableSchema(pagesize, Vector{ColumnSchema}(0), Dict{AbstractString, (ColumnSchema, Integer)}([]))

# add a column to the table-schema (append the new column)
function addColumn!{T}(tableschema::TableSchema, column::ColumnSchema{T})
  push!(tableschema.columns, column)
  setindex!(tableschema.columns_by_name, (column, length(tableschema.columns)), column.name)
end

getColumn(tableschema::TableSchema, pos::Integer) = return tableschema.columns[pos]
getColumn(tableschema::TableSchema, name::AbstractString) = return get(tableschema.columns_by_name, name, None)

function isequal(col1::ColumnSchema, col2::ColumnSchema)
  return isequal(col1.name, col2.name) && isequal(col1.dataType, col2.dataType)
end

# Tuples
type DataTuple
  fields::Vector{DataField}
  width::Integer
end

# constructors for datatuples
DataTuple(values::Vector{DataField}) = return DataTuple(copy(values), length(values))
DataTuple(numFields::Integer) = return DataTuple(Vector{DataField}(numFields), numFields)

# getters and setters for fields in a tuple
getField(tuple::DataTuple, pos::Integer) = return tuple.fields[pos]
setField!(tuple::DataTuple, field::DataField, pos::Integer) = tuple.fields[pos] = field


######################################################################################
# TablePage functionalities
######################################################################################
# constants
const HEADERSIZE = 32
const RECORD_HEADERSIZE = 4
# header
const MAGIC_NUMBER = 0xDEADBEEF
const PAGENUMBER_OFFSET = 4
const NR_RECORDS_OFFSET = 8
const RECORD_WIDTH_OFFSET = 12
const VAR_LENGTH_OFFSET = 16
# tombstones
const TOMBSTONE_DEAD = 0x0
const TOMBSTONE_ALIVE = 0x1

# Pages
abstract CacheableData

type TablePage <: CacheableData
  id::Integer
  size::Integer
  modified::Bool
  expired::Bool
  binaryPage::IOBuffer
  schema::TableSchema
end

# create a new page
function TablePage(binaryPage::Vector{UInt8}, schema::TableSchema, pageNumber::Int32)
  # wrap binary page
  buffer = IOBuffer(binaryPage, true, true, schema.size)
  # initialize header
  seekstart(buffer)
  # magic number to identify pages of the db
  write(buffer, MAGIC_NUMBER)
  # pagenumber
  write(buffer, pageNumber)
  # number of records on page
  write(buffer, Int32(0))
  # get width of a record
  width = mapfoldl(x -> sizeof(x.dataType), +, 0, schema.columns)
  write(buffer, width)
  # variable length offset
  write(buffer, buffer.maxsize)
end

# load an existing page from a buffer
function TablePage(binaryPage::Vector{UInt8}, schema::TableSchema)
end

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

