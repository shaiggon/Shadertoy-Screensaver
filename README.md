# Shadertoy Screensaver

![Screenshot of the screensaver](screenshot/screenshot.png?raw=true)

The goal with this project would be to load an arbitrary [Shadertoy](https://shadertoy.com) shader by giving an URL and
use it as a macOS screensaver. First goal is to just be able to load a single buffer shader
but more features will be added in the future.

## Development

I've heavily utilized ChatGPT while developing this app as I haven't used Objective-C much
previously.

## TODO

* One to one mapping of GL uniforms to the ones used in Shadertoy
* Multiple buffers (now just supports on image shaders)
* Execute arbitrary shaders from a Shadertoy URL
	* Fetch shader based on URL
	* Parse the JSON we get from Shadetoy API
* Clean up code
* Preview of the screensaver
* Configuration for setting the shader URL (and possibly also API key)
