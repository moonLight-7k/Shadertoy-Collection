#define NONE  -1
#define PLANE  0
#define SPHERE 1

#define TMAX 10000.

const float N = 55.0;

const vec4 skyTop = vec4(0.001f, 0.0f, 0.1f, 1.0f);
const vec4 skyBottom = vec4(0.55f, 0.08f, 0.896f, 1.0f);

// see https://iquilezles.org/articles/checkerfiltering
float gridTextureGradBoxFilter(vec2 uv, vec2 ddx, vec2 ddy) {
    uv += 0.5f;
    vec2 w = max(abs(ddx), abs(ddy)) + 0.01;
    vec2 a = uv + 0.015 + w;
    vec2 b = uv - 0.015 + w;

    vec2 i = (floor(a) + min(fract(a) * N, 1.0) -
        floor(b) - min(fract(b) * N, 1.0)) / (N * w);

    return (1.0 - i.x) * (1.0 - i.y);
}

float gridTexture(vec2 uv) {
    uv += 0.5f;
    vec2 i = step(fract(uv), vec2(1.0 / N, 1.0 / N));
    return (1.0 - i.x) * (1.0 - i.y);
}

vec2 texCoords(vec3 pos, int objectType) {
    vec2 uv;
    if(objectType == PLANE) {
        uv = pos.xz;
    }

    uv.y -= iTime * 10.;
    return 0.5 * uv;
}

float traceRay(vec3 rayOrigin, vec3 rayDir, inout vec3 pos, inout vec3 nor, inout int objType) {
    float tmin = TMAX;
    pos = vec3(0.0f, 0.0f, 0.0f);
    nor = vec3(0.0f, 0.0f, 0.0f);
    objType = NONE;

    float t = (-1.0 - rayOrigin.y) / rayDir.y;

    if(t > 0.0) {
        tmin = t;
        nor = vec3(0.0f, 1.0f, 0.0f);
        pos = rayOrigin + rayDir * t;
        objType = PLANE;
    }

    return tmin;
}

void createRay(in vec2 pixel, inout vec3 rayOrigin, inout vec3 rayDirection) {
    vec2 p = (2. * pixel.xy - iResolution.xy) / iResolution.y;

    vec3 camPos = vec3(0.1f, 1.0f, 5.0f);
    vec3 camDir = vec3(0.1f, 1.0f, 0.0f);

    vec3 dir = normalize(camDir - camPos);
    vec3 right = normalize(cross(dir, vec3(0.0f, 1.0f, 0.0f)));
    vec3 up = normalize(cross(right, dir));

    rayDirection = normalize(p.x * right + p.y * up + 3.0f * dir);
    rayOrigin = camPos;
}

float rand(float x) {
    return fract(sin(x) * 50000.0f);
}

void mainImage(out vec4 fragColor, vec2 fragCoord) {
    vec2 p = (-iResolution.xy + 2.0 * fragCoord) / iResolution.y;

    float radius = 0.6f;
    vec2 ctr = vec2(0.0f, 0.3f);
    vec2 diff = p - ctr;

    float width = 40.0;
    float skylineHeight = rand((mod(trunc(p.x * width), width)));

    float falloffFactor = 0.8;
    skylineHeight *= 1.0 - abs(p.x) * falloffFactor;

    float t = TMAX;
    if(p.y > 0.0 && p.y * 2.7 < skylineHeight) {
        fragColor = vec4(0.216, 0.165, 0.165, 1.0);
        fragColor *= rand(p.y) * rand(p.x) * 3.0f;
        t = 50.0f;
    } else if(dot(diff, diff) < (radius * radius) && p.y > 0.0f) {
        fragColor = vec4(1.0f, 0.55f, 0.28f, 1.0f) * step(fract(p.y * 10.) - p.y / 4., 8. / 10.0);
        t = 5.0;
    } else {
        fragColor = mix(skyTop, skyBottom, .25 - p.y / 3.);
    }

    vec3 rayDir;
    vec3 rayOrigin;
    vec3 rayOriginDdx;
    vec3 rayDirDdx;
    vec3 rayOriginDdy;
    vec3 rayDirDdy;

    createRay(fragCoord, rayOrigin, rayDir);
    createRay(fragCoord + vec2(1.0, 0.0), rayOriginDdx, rayDirDdx);
    createRay(fragCoord + vec2(0.0, 1.0), rayOriginDdy, rayDirDdy);

    vec3 pos;
    vec3 nor;
    int objectType = NONE;

    float groundt = traceRay(rayOrigin, rayDir, pos, nor, objectType);

    t = min(groundt, t);

    vec3 posDdx = rayOriginDdx - rayDirDdx * dot(rayOriginDdx - pos, nor) / dot(rayDirDdx, nor);
    vec3 posDdy = rayOriginDdy - rayDirDdy * dot(rayOriginDdy - pos, nor) / dot(rayDirDdy, nor);

    vec2 uv = texCoords(pos, objectType);

    vec2 uvDdx = texCoords(posDdx, objectType) - uv;
    vec2 uvDdy = texCoords(posDdy, objectType) - uv;

    if(objectType == PLANE) {
        float color = gridTextureGradBoxFilter(uv, uvDdx, uvDdy);
        fragColor = mix(vec4(217.0 / 255.0, 10.0 / 255.0, 217.0 / 225.0, 1.0f), vec4(133.0 / 255.0, 46.0 / 255.0, 106.0 / 255.0, 1.0f), color);
    }

    if(t < TMAX) {
        fragColor = mix(fragColor, skyBottom, 1.0 - exp(-0.0001 * t * t));
    }
    return;
}