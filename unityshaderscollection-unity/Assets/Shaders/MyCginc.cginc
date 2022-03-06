float FresnelEffect (fixed3 normal, fixed3 viewDir, float power) {
    return pow (1 - saturate (dot (normal, viewDir)), power);
}