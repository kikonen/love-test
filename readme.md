# LÖVE test

## Intro
Exprimenting with Löve2D framework

https://love2d.org


## Setup

Fetch external module dependencies

```bash
git submodule init
git submodule update
```

## Run

```bash
love .
```

## 3D control

Using example from 3DreamEngine

### Viewport
- W, A, S, D: up, left, down, right
- Q, E: rotate left/right
- page up: up
- page down: down
- mouse + button-1: rotate

### Paddle
- up, down: move Z dir
- left, right: move X dir
- home, end: move Y dir

# Notes

## ODE

## Geometry

- These functions set and get the body associated with a placeable geom. Setting a body on a geom automatically combines the position vector and rotation matrix of the body and geom, so that setting the position or orientation of one will set the value for both objects.
- Setting a body ID of zero gives the geom its own position and rotation, independent from any body. If the geom was previously connected to a body then its new independent position/rotation is set to the current position/rotation of the body.


# References
## Lua
- https://www.lua.org/pil/contents.html

## LÖVE
- https://github.com/love2d-community/awesome-love2d#3d
- https://github.com/3dreamengine/3DreamEngine
- http://www.iforce2d.net/b2dtut/collision-anatomy

## moonode integration
- https://github.com/stetre/moonode
  + https://stetre.github.io/moonode/doc/index.html
  + https://github.com/kikonen/moonode/pull/2
- https://www.ode.org
  + http://ode.org/wiki/index.php/Main_Page
  + https://github.com/thomasmarsh/ODE
- https://www.reddit.com/r/love2d/comments/72rfp7/what_lua_version_does_love_use/
- https://www.lua.org/ftp/
- https://github.com/kikonen/CompilingLua
- https://stackoverflow.com/questions/4438900/how-to-view-dll-functions
- https://github.com/Nigh/simple_dll_for_Love2D
- https://love2d.org/forums/viewtopic.php?t=79958
- http://lua-users.org/wiki/CreatingBinaryExtensionModules
- https://www.msys2.org
   + totally misguided wrong path (but was valid for initial testing of concept)
