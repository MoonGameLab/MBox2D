path = ...
export MBOX2D_ROOT = path .. "."



Mbox2D = {
  World: assert require MBOX2D_ROOT .. "World"
  Collider: assert require MBOX2D_ROOT .. "Collider"
}

Mbox2D.Collider!
return Mbox2D