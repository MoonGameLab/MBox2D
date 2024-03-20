floor = math.floor


gridToWorld = (cellSize, cx, cy) ->
  return (cx - 1)*cellSize, (cy - 1)*cellSize

gridToCell = (cellSize, x, y) ->
  return floor(x / cellSize) + 1, floor(y / cellSize) + 1

gridTraverseInitStep = (cellSize, ct, t1, t2) ->
  v = t2 - t1
  if v > 0
    return 1, cellSize / v, ((ct + v) * cellSize - t1) / v
  elseif v < 0
    return -1, -cellSize / v, ((ct + v - 1) * cellSize - t1) / v
  else
    return 0, math.huge, math.huge

-- http://www.cse.yorku.ca/~amana/research/grid.pdf
gridTraverse = (cellSize, x1,y1,x2,y2, f) ->
  cx1,cy1        = gridToCell cellSize, x1,y1
  cx2,cy2        = gridToCell cellSize, x2,y2
  stepX, dx, tx = gridTraverseInitStep cellSize, cx1, x1, x2
  stepY, dy, ty = gridTraverseInitStep cellSize, cy1, y1, y2
  cx, cy = cx1, cy1

  f cx, cy

  while abs(cx - cx2) + abs(cy - cy2) > 1
    if tx < ty
      tx, cx = tx + dx, cx + stepX
      f cx, cy
    else
      if tx == ty then f cx + stepX, cy
      ty, cy = ty + dy, cy + stepY
      f cx, cy

  if cx ~= cx2 or cy ~= cy2 then f(cx2, cy2) end

{
  :gridToWorld
  :gridToCell
}