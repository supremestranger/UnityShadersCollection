float FresnelEffect (fixed3 normal, fixed3 viewDir, float power) {
    return pow (1 - saturate (dot (normal, viewDir)), power);
}

float pow5(float x) {
    float xx = x * x;
    return xx * xx * x;
}

float DistributionGgx(fixed3 normal, fixed3 halfwayDir, float roughness) {
    float a = roughness * roughness;
    float aa = a * a;
    float NdotH = max(dot(normal, halfwayDir), 0);

    float denom = NdotH * NdotH * (aa - 1) + 1;
    denom = 3.14159265359 * denom * denom;
	
    return aa / denom;
}

float GeometrySchlickGgx(float NdotV, float roughness) {
    float r = roughness + 1;
    float k = r * r / 8;

    float denom = NdotV * (1 - k) + k;
	
    return NdotV / denom;
}

float GeometrySmith(fixed3 normal, fixed3 viewDir, fixed3 lightDir, float roughness) {
    fixed NdotV = max(dot(normal, viewDir), 0);
    fixed NdotL = max(dot(normal, lightDir), 0);

    float ggx2 = GeometrySchlickGgx(NdotV, roughness);
    float ggx1 = GeometrySchlickGgx(NdotL, roughness);

    return ggx1 * ggx2;
}

fixed3 FresnelSchlick(float cosTheta, fixed3 f0) {
    return f0 + (1 - f0) * pow5(clamp(1 - cosTheta, 0, 1));
}  