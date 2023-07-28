/*#version 410 core
uniform vec3 iResolution;
uniform float iTime;
void mainImage( out vec4 c, in vec2 f );

out vec4 shadertoy_out_color;
void main( ){vec4 color = vec4(1e20);mainImage( color, (gl_FragCoord.xy + vec2(1.0)) * 0.5 );shadertoy_out_color = vec4(color.xyz,1.0);}*/
//#version 410 core

//uniform vec3  iResolution;
//uniform float iTime;

//in vec3 ourColor;
//in vec3 gl_FragCoord;
//in vec4 FragCoord_;

//out vec4 FragColor;

//out vec4 shadertoy_out_color;

//void main()
//void mainImage( out vec4 fragColor, in vec2 fragCoord )
//{
//    vec2 uv = fragCoord/iResolution.xy;
//    float r = 0.5 * (1.0 + sin(time));
//    float g = 0.5 * (1.0 + cos(time + 23.0));
//    fragColor = vec4(r, g, uv.y, 1.0);
//}

vec4 sun(vec2 uv, float time)
{
    vec3 sunUp = vec3(250.0/255.0, 242.0/255.0, 0.0);
    vec3 sunDown = vec3(252.0/255.0, 0.0, 140.0/255.0);
    //float sunTopPosition = 0.
    float gapSize = 0.2;
    float gapFrequency = 0.03;
    float sunSize = 0.19;
    float gapSpeed = 0.007;
    if (length(uv + vec2(0.0, -0.05)) < sunSize
        && mod(uv.y + time*gapSpeed, gapFrequency) > gapSize * gapFrequency)
    {
        return vec4(mix(sunUp, sunDown, 1.1 - (uv.y / 0.4 + 0.5)), 1.0);
    }
    return vec4(0.0);
}
 
vec4 neonFloor(vec2 uv, float time)
{
    float t = time * 0.2;
    vec3 baseFloor = vec3(10.0/255.0, 26.0/255.0, 48.0/255.0);
    vec3 lightFloor = vec3(208.0/255.0, 0.0/255.0, 255.0/255.0);
    if (uv.y < -0.06)
    {
        if (mod(uv.x / uv.y + sin(t), 1.1) < 0.05)
        {
            return vec4(lightFloor, 1.0);
        }
 
        if (mod((uv.y + 0.5) / (uv.y - 0.05) - t, 0.4) < 0.2*-uv.y) {
            return vec4(lightFloor, 1.0);
        }
        return vec4(baseFloor, 1.0);
    }
    return vec4(0.0);
}
 
vec4 middleGlow(vec2 uv, float time)
{
    float middlePoint = -0.06; // Modified uv
    float dist = abs(uv.y - middlePoint);
    float radialDist = length(uv*vec2(0.02, 1.0) - vec2(0.0, middlePoint));
    //return vec4(111.0/255.0, 0.0/255.0, 255.0/255.0, clamp(1.0 - dist*9.0, 0.0, 1.0)) * 0.6
    //    + vec4(1.0, 1.0, 1.0, clamp(1.0 - dist*20.0, 0.0, 1.0))*0.6;
    vec4 col = vec4(111.0/255.0, 0.0/255.0, 255.0/255.0, 1.0 - dist*4.0);
    col = mix(vec4(1.0, 1.0, 1.0, 1.0 / (1. + radialDist*20.)), col, 1.-1. / (1. + radialDist*20.));
    return clamp(col, 0.0, 1.0);
}
 
vec3 sunRays(vec2 uv, float time)
{
    float t = 0.1 * time;
    float PI = 3.14159265359;
    vec3 ray1 = vec3(252.0/255.0, 0.0, 140.0/255.0);
    vec3 ray2 = vec3(250.0/255.0, 242.0/255.0, 0.0);
    vec2 sunPosition = vec2(0.0, -0.05);
    vec2 p = uv + sunPosition;
    float c = round(mod(atan(p.y / p.x) * PI * 2.0 + t, 0.6) * 1.0/(0.6));
    //return ray1 * 
    return (c * ray1 + (1.0 - c) * ray2) * 0.4 * clamp(1.0-length(p*2.0), 0.0, 1.0) * clamp(length(p*3.0), 0.0, 1.0);
}
 
//Shamelessly copied from https://www.shadertoy.com/view/WtVBRG
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
vec4 starfield(vec2 C) {
    vec4 O=vec4(0);
    vec3 p=vec3(0.0),r=iResolution,
    d=normalize(vec3((C-.5*r.xy)/r.y,1));  
    for(float i=0.,g=0.,e=0.,s=0.;
        ++i<99.;
        O.xyz+=5e-5*abs(cos(vec3(3,2,1)+log(s*9.)))/dot(p,p)/e
    )
    {
        p=g*d;
        p.z+=iTime*.05;
        p=R(p,normalize(vec3(1,2,3)),.5);   
        s=2.5;
        p=abs(mod(p-1.,2.)-1.)-1.;
        
        for(int j=0;j++<10;)
            p=1.-abs(p-vec3(-1.)),
            s*=e=-1.8/dot(p,p),
            p=p*e-.7;
            g+=e=abs(p.z)/s+.001;
     }
     return O /= 16.0;
}
 
 
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;
 
    // Time varying pixel color
    //vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
    //vec3 col = vec3(0.0);
 
    //float beat = length(texture(iChannel0, vec2(0.0, 1.0)));
 
    vec2 mUV = vec2(uv.x - 0.5, (uv.y - 0.5) * (iResolution.y / iResolution.x));
 
    vec4 col = neonFloor(mUV, iTime);
    if (col.w < 0.5)
    {
        col += sun(mUV, iTime);
    }
    //if (col.w < 0.5)
    //{
    //    col += vec4(sunRays(mUV, iTime), 1.0);
    //}
 
    vec4 mg = middleGlow(mUV, iTime);
 
 
 
    col = vec4(mix(col.xyz, mg.xyz, mg.w), 1.0) + clamp(length(mUV) - 0.2, 0.0, 1.0)*starfield(fragCoord)+ length(mUV)*vec4(0.3, 0.0, 0.0, 1.0);
 
 
 
    // Output to screen
    //vec4 col = vec4(0.0, 1.0, uv.x, 1.0);
    fragColor = col;
}

/*void main() {
    vec2 fragCoord = (gl_FragCoord.xy + vec2(1.0)) * 0.5;//FragCoord_.xy;
    vec2 uv = fragCoord;// / iResolution.xy;
    vec4 fragColor = vec4(uv.x, 1.0, uv.y, 1.0);
    mainImage(fragColor, fragCoord);
    shadertoy_out_color = fragColor;
}*/