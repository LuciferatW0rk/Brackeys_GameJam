shader_type spatial;
render_mode cull_disabled;

// Color gradient for the grass
uniform vec3 color : source_color;
uniform vec3 color2 : source_color;

// Wind effect variables
uniform vec3 wind_direction = vec3(1.0, 0.0, 0.0); // X-axis wind direction
uniform float wind_strength = 0.2;
uniform float wind_speed = 1.0;
uniform float wind_frequency = 2.0;  // How frequent the wind waves are

// Noise for color variation
uniform sampler2D noise;
uniform float noiseScale = 20.0;

varying vec3 worldPos;

// Vertex function for interactivity and wind
void vertex() {
    // World position of the vertex
    worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Wind effect (wave-like motion)
    float wind_offset = sin(TIME * wind_speed + worldPos.x * wind_frequency) * wind_strength * UV.y;  // Waves affect the top of the grass more
    VERTEX.x += wind_direction.x * wind_offset;  // Move along wind direction
    VERTEX.z += wind_direction.z * wind_offset;
}

void fragment() {
    // Noise-based color variation
    vec3 noiseLevel = texture(noise, worldPos.xz / noiseScale).rgb;
    ALBEDO = mix(color, color2, UV.y) * mix(color, color2, noiseLevel.r);

    // Handle backface normals correctly
    if (!FRONT_FACING) {
        NORMAL = -NORMAL;
    }
}
