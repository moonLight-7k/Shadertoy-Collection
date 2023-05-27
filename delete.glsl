vec3 palette(float t) {
    vec3 a = vec3(0.000, 0.000, 0.000);
    vec3 b = vec3(0.071, 0.071, 0.071);
    vec3 c = vec3(0.239, 0.259, 0.522);
    vec3 d = vec3(0.220, 0.137, 0.443);
    vec3 e = vec3(0.996, 0.486, 0.835);

    return a + b * cos(6.28318 * (c * t + d + e));

}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    vec3 finalColor = vec3(.0);

    for(float i = 0.0; i < 3.0; i++) {

        uv = fract(uv * 1.0) - 0.5;

        float d = length(uv);

        vec3 col = palette(length(uv0) + iTime * .4);

        d = sin(d * 16. + iTime) / 8.;
        d = abs(d);

        d = 0.02 / d;

        finalColor += col * d;
    }
    fragColor = vec4(finalColor, 1.0);

}