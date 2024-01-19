love = love
Physics = love.physics

_WORLD_METER = 32

utils = {
  math: assert require MBOX2D_ROOT .. 'libs.MoonMath' 
}


class Singleton
  __inherited: (By) =>
    By.getInstance = (...) ->
      if I = By.Instance then return I
      with I = By ...
        By.Instance = I

class World extends Singleton
  -- Class vars
  @DEBUG: false
  @DEBUG_DRAW: false
  @DEBUG_DRAW_FOR_N_FRAMES: 10

  init: (xg, yg, sleep) =>
    settings = settings or {}

    @collisionClasses = {}
    @masks = {}

    Physics.setMeter _WORLD_METER
    @box2DWorld = Physics.newWorld xg, yg, sleep
  
  new: (xg, yg, sleep) =>
    