uniform vec2 Offset;   // blur direction: (1,0) = horizontal, (0,1) = vertical
uniform int Radius;    // samples to each side of the center pixel

const int MAX_RADIUS = 32;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec2 texel_size = 1.0 / love_ScreenSize.xy;
    vec3 sum = vec3(0.0);

    for (int i = -MAX_RADIUS; i <= MAX_RADIUS; i++)
    {
        if (i < -Radius || i > Radius) continue;
        sum += Texel(tex, texture_coords + Offset * float(i) * texel_size).rgb;
    }

    sum /= float(Radius * 2 + 1);
    return vec4(sum, 1.0);
}