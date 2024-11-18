math = math
abs = math.abs

DELTA = 1e-10


sign = (x) ->
  if x > 0 then return 1
  if x == 0 then return 0
  return -1

nearest = (x, a, b) ->
  if abs(a - x) < abs(b - x) then return a else return b

assertType = (type, value, name) ->
  if type(value) ~= type
    error name ..' must be a ' .. type .. ' but was ' .. tostring(value) .. '(a ' .. type(value) .. ')'

assertIsPositiveNum = (value, name) ->
  if type(value) ~= 'number' or value <= 0
    error name .. ' must be a positive integer, but was ' .. tostring(value) .. '(' .. type(value) .. ')'

assertISRect = (x, y, w, h) ->
  assertType('number', x, 'x')
  assertType('number', y, 'y')
  assertIsPositiveNum(w, 'w')
  assertIsPositiveNum(h, 'h')

{
  :DELTA
  :sign
  :nearest
  :assertType
  :assertIsPositiveNum
  :assertISRect
}
