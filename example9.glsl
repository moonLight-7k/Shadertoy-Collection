vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.800, 0.565, 0.996);
    vec3 c = vec3(0.043, 0.278, 0.357);
    vec3 d = vec3(0.173, 0.427, 0.365);

    return a + b * cos(6.28318 * (c * t + d));

}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);

    for(float i = 0.0; i < 4.0; i++) {

        uv = fract(uv * 1.5) - 0.5;

        float d = length(uv) * exp(-length(uv0));

        vec3 col = palette(length(uv0) + i * 4. + iTime * .4);

        d = sin(d * 28. + iTime) / 8.;
        d = abs(d);

        d = pow(0.006 / d, 1.5);

        finalColor += col * d;
    }
    fragColor = vec4(finalColor, 1.0);

}