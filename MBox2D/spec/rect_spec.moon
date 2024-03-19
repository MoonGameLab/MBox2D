rect = assert require "rect"
m = assert require "moon"
dump = m.p

describe 'rect', ->
  rectGetDiff = rect.rectGetDiff
  rectDetectCollision =  rect.rectDetectCollision

  print rectGetDiff(2,3,4,5 ,5,4,4,2 )

  dump rectDetectCollision(2,3,4,5 ,5,4,4,2, 0,0)  

