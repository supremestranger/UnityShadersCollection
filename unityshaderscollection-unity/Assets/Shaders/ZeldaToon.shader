Shader "ZeldaToon" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _GlossColor ("Gloss Color", Color) = (1,1,1,1)
        _Glossiness ("Glossy", Range(1, 256)) = 64
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        LOD 100

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed3 normal : TEXCOORD1;
                float3 posWorld : TEXCOORD2;
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _GlossColor;
            half _Glossiness;

            v2f vert (appdata_full v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed4 mainTex = tex2D(_MainTex, i.uv);
                
                fixed3 lightDir = _WorldSpaceLightPos0.xyz;
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float lightIntensity = smoothstep(0, 0.01, dot(normalize(i.normal), lightDir));
                fixed3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                
                fixed spec = dot(normalize(i.normal), halfVector);

                fixed3 diffuseCol = lightIntensity * _LightColor0.rgb * mainTex * _Color;
                float3 glossyCol = _LightColor0.rgb * smoothstep(0.005, 0.01, pow(spec * lightIntensity, _Glossiness)) * _GlossColor;
                fixed3 ambientCol = UNITY_LIGHTMODEL_AMBIENT * mainTex * _Color;
                
                fixed3 light = diffuseCol + glossyCol + ambientCol;

                fixed4 col = fixed4(light, 1);
                return col;
            }
            ENDCG
        }
        
        Pass {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile POINT SPOT
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed3 normal : TEXCOORD1;
                float3 posWorld : TEXCOORD2;
            };

           sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _GlossColor;
            half _Glossiness;

            v2f vert(appdata_full v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed4 mainTex = tex2D(_MainTex, i.uv);

                UNITY_LIGHT_ATTENUATION(atten, i, i.posWorld);
                fixed3 lightDir = (_WorldSpaceLightPos0.xyz - i.posWorld.xyz);
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float lightIntensity = smoothstep(0, 0.01, dot(normalize(i.normal), lightDir));
                fixed3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                
                fixed spec = dot(normalize(i.normal), halfVector);

                fixed3 diffuseCol = lightIntensity * _LightColor0.rgb * mainTex * _Color;
                float3 glossyCol = _LightColor0.rgb * smoothstep(0.005, 0.01, pow(spec * lightIntensity, _Glossiness)) * _GlossColor;
                
                fixed3 light = diffuseCol + glossyCol;

                fixed4 col = fixed4(light, 1) * atten;
                return col;
            }
            ENDCG
        }
    }
}
