#version 460 core

#include <flutter/runtime_effect.glsl>

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
    float wave1 = sin(uv.x * 6.283 + uTime * 0.8) * cos(uv.y * 5.0 - uTime * 0.5);
    float wave2 = cos(uv.x * 4.0 - uTime * 0.6) * sin(uv.y * 7.0 + uTime * 0.4);
    float heightMap = (wave1 + wave2) * 0.5;

    // 3. Anisotropic Diagonal Specular Sheen (Sweeping across at 35 degrees)
    float diagCoord = (uv.x * 0.82 + uv.y * 0.57);
    float sheenPhase = fract(uTime * 0.18);
    float sheenDist = abs(diagCoord - sheenPhase);
    float sheenBeam = exp(-sheenDist * sheenDist * 160.0) * uSpecular;
    float totalSheen = sheenBeam;

    // 4. Fresnel Perimeter Ring (Physical glass edge reflection)
    float edgeDistance = abs(d);
    float fresnelRim = exp(-edgeDistance * 0.65) * 0.45;

    // 5. Chromatic Dispersion & Base Tint Generation
    if (uIsDark > 0.5) {
        // --- LUXURY OBSIDIAN EMERALD GLASS (Dark Mode) ---
        vec3 baseTint = vec3(0.047, 0.141, 0.114); // #0C241D
        vec3 causticTint = vec3(0.725, 0.953, 0.420) * (heightMap * 0.08 + 0.04);
        vec3 sheenColor = vec3(totalSheen * 0.88, totalSheen * 1.05, totalSheen * 0.94);
        vec3 rimColor = vec3(0.098, 0.420, 0.290) * fresnelRim * 1.8;
        fragColor = vec4(baseTint + causticTint + sheenColor + rimColor, 0.92 * alphaMask);
    } else {
        // --- PRISTINE ALPINE QUARTZ GLASS (Light Mode) ---
        vec3 baseTint = vec3(0.965, 0.985, 0.975); // 97% Translucent White
        vec3 causticTint = vec3(0.059, 0.420, 0.290) * (heightMap * 0.03 + 0.015);
        vec3 sheenColor = vec3(1.0, 1.0, 1.0) * totalSheen * 0.95;
        vec3 rimColor = vec3(0.247, 0.639, 0.302) * fresnelRim * 0.75;
        fragColor = vec4(baseTint + causticTint + sheenColor + rimColor, 0.94 * alphaMask);
    }
}

