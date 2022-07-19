Shader "UnityPbrSpec" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _SpecTex ("Spec", 2D) = "white" {}
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "MyCginc.cginc"
            #include "UnityPBSLighting.cginc"
            
            struct v2f {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed3 normal : TEXCOORD1;
                float3 posWorld : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _SpecTex;
            float _Smoothness;

            v2f vert (appdata_full v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                fixed4 c = tex2D (_MainTex, i.uv);
                fixed4 s = tex2D (_SpecTex, i.uv);
                
                half oneMinusReflectivity;
                fixed3 albedo = EnergyConservationBetweenDiffuseAndSpecular(c, s, oneMinusReflectivity);

                UnityLight light;
                light.color = _LightColor0.rgb;
                light.dir = _WorldSpaceLightPos0.xyz;
                light.ndotl = dot(_WorldSpaceLightPos0.xyz, normalize(i.normal));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);

                UnityIndirect gi;
                gi.diffuse = 0;
                gi.specular = 0;
                half4 color = UNITY_BRDF_PBS(albedo, s, oneMinusReflectivity, s.a * _Smoothness, normalize(i.normal), viewDir, light, gi);;
                return color;
            }
            ENDCG
        }
        Pass {
            // TODO Fix
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "MyCginc.cginc"
            #include "UnityPBSLighting.cginc"
            
            struct v2f {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed3 normal : TEXCOORD1;
                float3 posWorld : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _SpecTex;
            float _Smoothness;

            v2f vert (appdata_full v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                fixed4 c = tex2D (_MainTex, i.uv);
                fixed4 s = tex2D (_SpecTex, i.uv);
                
                half oneMinusReflectivity;
                fixed3 albedo = EnergyConservationBetweenDiffuseAndSpecular(c, s, oneMinusReflectivity);

                UnityLight light;
                light.color = _LightColor0.rgb;
                light.dir = _WorldSpaceLightPos0.xyz - i.posWorld;
                light.ndotl = dot(_WorldSpaceLightPos0.xyz - i.posWorld, normalize(i.normal));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);

                UnityIndirect gi;
                gi.diffuse = 0;
                gi.specular = 0;
                half4 color = UNITY_BRDF_PBS(albedo, s, oneMinusReflectivity, s.a * _Smoothness, normalize(i.normal), viewDir, light, gi);;
                return color;
            }
            ENDCG
        }
    }
}
