vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(0.380, 0.290, 0.039);
    vec3 d = vec3(0.220, 0.067, 0.373);

    return a + b * cos(6.28318 * (c * t + d));

}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);

    for(float i = 0.0; i < 5.0; i++) {

        uv = fract(uv * 3.0) - 0.5;

        float d = length(uv);

        vec3 col = palette(length(uv) + iTime * .6);

        d = sin(d * 8. + iTime * .4) / 2.;
        d = abs(d);

        d = 0.02 / d;

        finalColor += col * d;
    }
    fragColor = vec4(finalColor, 1.0);

}