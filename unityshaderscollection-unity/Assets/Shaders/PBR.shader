Shader "PBR" {
    Properties {
        _Albedo ("Albedo", Color) = (1,1,1,1)
        _Metallic ("Metallic", Range(0,1)) = 1
        _Roughness ("Roughness", Range(0.01,1)) = 1
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "MyCginc.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed3 normal : TEXCOORD1;
                float3 posWorld : TEXCOORD2;
            };

            fixed4 _Albedo;
            float _Metallic;
            float _Roughness;

            v2f vert (appdata_full v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed3 normal = normalize(i.normal);
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                fixed4 Fo = fixed4(0.04, 0.04, 0.04, 1);
                Fo = lerp(Fo, _Albedo, _Metallic);
                float3 light = float3(0, 0, 0);

                fixed3 lightDir = _WorldSpaceLightPos0.xyz;
                fixed3 halfwayDir = normalize(viewDir + lightDir);
                float NdotL = max(dot(normal, lightDir), 0);
                
                float NDF = DistributionGgx(normal, halfwayDir, _Roughness);
                float G = GeometrySmith(normal, viewDir, NdotL, _Roughness);
                fixed3 F = FresnelSchlick(max(dot(halfwayDir, viewDir), 0), Fo);

                half3 numerator = NDF * G * F;
                float denominator = 4 * max(dot(normal, viewDir), 0.0001) * max(dot(normal, lightDir), 0.0001);
                float3 specular = numerator / denominator;

                float3 kS = F;
                float3 kD = float3(1, 1, 1) - kS;
                kD *= 1 - _Metallic;

                

                light += (kD * _Albedo / 3.14159265359 + specular) * _LightColor0.rgb * NdotL;

                float4 color = float4(light, 1);
                color = color / (color + float4(1, 1, 1, 1));
                color = pow(color, 0.454545);

                color = float4(color.rgb, 1);
                return color;
            }
            ENDCG
        }
        Pass {
            // TODO Fix
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile POINT SPOT

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "MyCginc.cginc"
            #include "AutoLight.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed3 normal : TEXCOORD1;
                float3 posWorld : TEXCOORD2;
            };

            fixed4 _Albedo;
            float _Metallic;
            float _Roughness;

            v2f vert (appdata_full v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed3 normal = normalize(i.normal);
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                fixed4 Fo = fixed4(0.04, 0.04, 0.04, 0.04);
                Fo = lerp(Fo, _Albedo, _Metallic);
                float3 light = float3(0, 0, 0);

                UNITY_LIGHT_ATTENUATION(atten, i, i.posWorld);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - i.posWorld);
                fixed3 halfwayDir = normalize(viewDir + lightDir);
                float NdotL = max(dot(normal, lightDir), 0);

                float NDF = DistributionGgx(normal, halfwayDir, _Roughness);
                float G = GeometrySmith(normal, viewDir, _WorldSpaceLightPos0.xyz - i.posWorld, _Roughness);
                fixed3 F = FresnelSchlick(clamp(dot(halfwayDir, viewDir), 0, 1), Fo);

                half3 numerator = NDF * G * F;
                float denominator = 4 * max(dot(normal, viewDir), 0.0001) * max(dot(normal, lightDir), 0.0001);
                float3 specular = numerator / denominator;

                float3 kS = F;
                float3 kD = float3(1, 1, 1) - kS;
                kD *= 1 - _Metallic;
                
                light += (kD * _Albedo / 3.14159265359 + specular) * _LightColor0.rgb * NdotL;

                float4 color = float4(light * atten, 1);
                color = pow(color, 0.4545);
                color = float4(color.rgb, 1);
                return color;
            }
            ENDCG
        }
    }
}
