# LÖVE test

## Intro
Exprimenting with Löve2D framework

https://love2d.org

### Screenshot
Running in Vmware linux guest
![image](https://github.com/user-attachments/assets/6d84465e-be41-42b8-a4ef-f80629d2008e)



## Setup

### Repo

```bash
~/work/own/projects
git@github.com:kikonen/love-test.git
```

### LÖVE

```bash
cd /tmp
wget https://github.com/love2d/love/releases/download/11.5/love-11.5-x86_64.AppImage
mv love-11.5-x86_64.AppImage ~/bin
cd ~/bin
chmod +x love-11.5-x86_64.AppImage love
ln -sf love-11.5-x86_64.AppImage love
ls -al *love*
```

### Libraries
Libraries required for compiling dependencies

```bash
sudo zypper install luajit-devel ode-devel
```

### Modules

Fetch external module dependencies
```bash
git submodule init
git submodule update
```


### Install: moonode
```bash
cd ~/work/own/projects/external
git clone git@github.com:kikonen/moonode.git
cd moonode
git branch -a
git checkout windows/luajit
make
cp -a src/moonode.so ~/work/own/projects/love-test
```

### Install: moonglmath
```bash
cd ~/work/own/projects/external
git clone git@github.com:kikonen/moonglmath.git
cd moonglmath
git branch -a
git checkout windows/luajit
make
cp -a src/moonglmath.so ~/work/own/projects/love-test
```

### Install: moonimage
```bash
cd ~/work/own/projects/external
git clone git@github.com:kikonen/moonimage.git
cd moonimage
git branch -a
git checkout windows/luajit
make
cp -a src/moonimage.so ~/work/own/projects/love-test
```


## Run

```bash
cd ~/work/own/projects/love-test
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
