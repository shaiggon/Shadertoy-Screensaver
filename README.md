# Shadertoy Screensaver

![Screenshot of the screensaver](screenshot/screenshot.png?raw=true)

Load an arbitrary [Shadertoy](https://shadertoy.com) shader by giving a shader ID and
use it as a macOS screensaver. First goal is to just be able to load a single buffer shader
but more features will be added in the future.

## Installation

Open the project in Xcode and build it. Double click on the created `Shadertoy-Screensaver.saver` to install it.

I've only tested the project on Xcode 14.3.1 on an M1 Macbook Pro.

## Usage

In the options give the Shadertoy shader ID the ID of the shader you want to show. For example
for the shader in URL [https://www.shadertoy.com/view/dtG3z1](https://www.shadertoy.com/view/dtG3z1)
the shader ID is `dtG3z1`. You also need to provide the API key that you can request from
[https://www.shadertoy.com/myapps](https://www.shadertoy.com/myapps). After pressing `Done` the
shader will be downloaded and used as your screensaver.

## Development

I've heavily utilized ChatGPT while developing this app as I haven't used Objective-C much
previously. The project is using OpenGL 4.1 for rendering. This might cause some shaders
not working exactly as they work in your browser. For example on Shadertoy an uninitialized
variable may be initialized to zero while the same variable might be garbage in this project.

## TODO

* One to one mapping of GL uniforms to the ones used in Shadertoy
* Multiple buffers (now just supports on image shaders)
* Clean up code
* Fix bug where only a part of the shader might be shown on a secondary monitor
* Allow user to load shaders from disk to allow using shaders which are not available via the API
* Easier installation