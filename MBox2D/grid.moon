floor = math.floor


gridToWorld = (cellSize, cx, cy) ->
  return (cx - 1)*cellSize, (cy - 1)*cellSize

gridToCell = (cellSize, x, y) ->
  return floor(x / cellSize) + 1, floor(y / cellSize) + 1


{
  :gridToWorld
  :gridToCell
}