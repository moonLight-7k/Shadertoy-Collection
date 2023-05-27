vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(0.396, 0.063, 0.388);
    vec3 d = vec3(0.278, 0.043, 0.514);

    return a + b * cos(6.28318 * (c * t + d));

}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);

    for(float i = 0.0; i < 4.0; i++) {

        uv = fract(uv * 1.0) - 0.5;

        float d = length(uv);

        vec3 col = palette(length(uv0) + iTime * .8);

        d = sin(d * 92. + iTime) / 1.;
        d = abs(d);

        d = 0.04 / d;

        finalColor += col * d;
    }
    fragColor = vec4(finalColor, 1.0);

}