#version 460 core

#include <flutter/runtime_effect.glsl>

// Uniforms passed from Flutter FragmentShader
uniform vec2 uResolution;  // Card width and height in logical pixels
uniform float uTime;        // Time in seconds for animated liquid sheen
uniform float uRefraction;  // Refraction intensity [0.0 - 1.0]
uniform float uSpecular;    // Specular highlight intensity [0.0 - 1.0]
uniform float uIsDark;      // 1.0 = Dark Mode, 0.0 = Light Mode

out vec4 fragColor;

// 2D Signed Distance Function for rounded rectangle card
float sdRoundedBox(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uResolution;
    vec2 p = fragCoord - (uResolution * 0.5);

    // 1. Physical Glass Geometry & Edge Fresnel
    float cornerRadius = 28.0;
    vec2 boxHalfSize = (uResolution * 0.5) - vec2(2.0);
    float d = sdRoundedBox(p, boxHalfSize, cornerRadius);

    // Hard clip outside card boundary with 1px smooth antialiasing
    float alphaMask = 1.0 - smoothstep(0.0, 1.5, d);
    if (alphaMask <= 0.001) {
        fragColor = vec4(0.0);
        return;
    }

    // 2. Liquid Optical Surface Normal & Caustics
    // Simulates gentle physical glass viscosity undulating in ambient space
    float wave1 = sin(uv.x * 6.283 + uTime * 0.8) * cos(uv.y * 5.0 - uTime * 0.5);
    float wave2 = cos(uv.x * 4.0 - uTime * 0.6) * sin(uv.y * 7.0 + uTime * 0.4);
    float heightMap = (wave1 + wave2) * 0.5;

    // Normal perturbation based on surface slope
    vec2 normalOffset = vec2(
        cos(uv.x * 8.0 + uTime) * 0.035,
        sin(uv.y * 8.0 + uTime) * 0.035
    ) * uRefraction;

    // 3. Anisotropic Diagonal Specular Sheen (Sweeping across at 35 degrees)
    float diagCoord = (uv.x * 0.82 + uv.y * 0.57);
    float sheenPhase = fract(uTime * 0.18);
    float sheenDist = abs(diagCoord - sheenPhase);
    float sheenBeam = exp(-sheenDist * sheenDist * 160.0) * uSpecular;

    // Secondary soft ambient glint
    float sheenDist2 = abs(diagCoord - fract(sheenPhase + 0.5));
    float sheenBeam2 = exp(-sheenDist2 * sheenDist2 * 80.0) * (uSpecular * 0.35);
    float totalSheen = (sheenBeam + sheenBeam2);

    // 4. Fresnel Perimeter Ring (Physical glass edge reflection)
    float edgeThickness = 4.5;
    float edgeDistance = abs(d);
    float fresnelRim = exp(-edgeDistance * 0.65) * 0.45;

    // 5. Chromatic Dispersion & Base Tint Generation
    vec4 surfaceColor;
    if (uIsDark > 0.5) {
        // --- LUXURY OBSIDIAN EMERALD GLASS (Dark Mode) ---
        // Base deep jade vitreous body
        vec3 baseTint = vec3(0.047, 0.141, 0.114); // #0C241D
        
        // Lime-glow chromatic caustics (#B9F36B)
        vec3 causticTint = vec3(0.725, 0.953, 0.420) * (heightMap * 0.08 + 0.04);
        
        // Specular highlight with cyan/mint chromatic aberration
        vec3 sheenColor = vec3(
            totalSheen * 0.85,
            totalSheen * 1.05,
            totalSheen * 0.92
        );

        // Edge internal refraction glow
        vec3 rimColor = vec3(0.098, 0.420, 0.290) * fresnelRim * 1.8;

        vec3 finalRgb = baseTint + causticTint + sheenColor + rimColor;
        surfaceColor = vec4(finalRgb, 0.92 * alphaMask);
    } else {
        // --- PRISTINE ALPINE QUARTZ GLASS (Light Mode) ---
        // Crisp optical translucent crystal body
        vec3 baseTint = vec3(0.965, 0.985, 0.975); // 97% crisp translucent white
        
        // Emerald subtle internal light refraction (#0F6B4A)
        vec3 causticTint = vec3(0.059, 0.420, 0.290) * (heightMap * 0.03 + 0.015);
        
        // Pure diamond white specular sheen
        vec3 sheenColor = vec3(1.0, 1.0, 1.0) * totalSheen * 0.95;

        // Subtle mint refractive rim
        vec3 rimColor = vec3(0.247, 0.639, 0.302) * fresnelRim * 0.75;

        vec3 finalRgb = baseTint + causticTint + sheenColor + rimColor;
        surfaceColor = vec4(finalRgb, 0.94 * alphaMask);
    }

    fragColor = surfaceColor;
}

