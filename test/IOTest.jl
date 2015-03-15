import IO
using Base.Test

# RID tests
pageIdx = Int32(10)
tupleIdx = Int32(4)

rid = IO.rid(pageIdx, tupleIdx)

@test IO.getPageIdx(rid) == pageIdx
@test IO.getTupleIdx(rid) == tupleIdx

# test field assignment of tuples
fields = [IO.BigIntField(10), IO.SmallIntField(3), IO.IntField(4)]
tuple1 = IO.datatuple(3)
IO.setField!(tuple1, fields[1], 2)

@test IO.getField(tuple1, 2).value == 10

# test creation of tuples from arrays
#tuple2 = IO.datatuple(fields) # doens't work! --TODO: fix!
#@test IO.getField(tuple2, 1).value == 10

fields = [IO.BigIntField(10), IO.SmallIntField(3), IO.IntField(4), IO.rid(Int32(10), Int32(2))]
tuple3 = IO.datatuple(fields) # this should work

@test IO.getField(tuple3, 1).value == 10



