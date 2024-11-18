MBOX2DPATH = MBOX2DPATH

{:rectGetSquareDist} = assert require MBOX2DPATH .. ".rect"
{:assertIsPositiveNum} = assert require MBOX2DPATH .. ".aux"

{
  :touch
  :cross
  :slide
  :bounce
} =  assert require MBOX2DPATH .. ".response"

World = {}
WorlsMeta = { __index: World }

with World
  .new = (cellSize) ->
    local _world
    cellSize = cellSize or 64
    assertIsPositiveNum cellSize, 'cellSize'
    _world = setmetatable {
      cellSize: cellSize
      rects: {}
      rows: {}
      occupiedCells: {}
      responses: {}
    }, WorlsMeta

    _world\addResponse 'touch', touch
    _world\addResponse 'cross', cross
    _world\addResponse 'slide', slide
    _world\addResponse 'bounce', bounce

    _world

  .addResponse = (name, response) =>
    @responses[name] = response

---------------------------------------------
---            HELPERS                    ---
---------------------------------------------

sortByWeight = (a, b) ->
  return a.weight < b.weight

sortByTiAndDist = (a, b) ->
  if a.ti == b.ti
    ir, ar, br = a.itemRect, a.otherRect, b.otherRect
    ab = rectGetSquareDist ir.x,ir.y,ir.w,ir.h, ar.x,ar.y,ar.w,ar.h
    bd = rectGetSquareDist ir.x,ir.y,ir.w,ir.h, br.x,br.y,br.w,br.h
    return ab < bd
  a.ti < b.ti
addItemToCell = (self, item, cx, cy) ->
  self.rows[cy] = self.rows[cy] or setmetatable {}, {__mode: 'v'}
  row = self.rows[cy]
  row[cx] = row[cx] or { itemCount: 0, x: cx, y: cy, items: setmetatable {}, {__mode: 'k'} }
  cell = row[cx]
  self.occupiedCells[cell] = true
  unless cell.items[item]
    cell.items[item] = true
    cell.itemCount += 1

removeItemToCell = (self, item, cx, cy) ->
  row = self.rows[cy]
  if not row or not row[cx] or not row[cx].items[item] then return false

  cell = row[cx]
  cell.items[item] = nil
  cell.itemCount -= 1

  if cell.itemCount == 0
    self.nonEmptyCells[cell] = nil

  true




World
