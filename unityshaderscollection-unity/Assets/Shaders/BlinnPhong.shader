Shader "BlinnPhong" {
    Properties {
        [NoScaleOffset]
        _MainTex ("Texture", 2D) = "white" {}
        _SpecTex ("SpecTex", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Glossy", Range(1,64)) = 16
    }
    SubShader {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        LOD 100

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed3 normal : TEXCOORD1;
                float3 posWorld : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _SpecTex;
            half _Glossiness;
            fixed4 _Color;

            v2f vert(appdata_full v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed4 mainTex = tex2D(_MainTex, i.uv);
                fixed4 specTex = tex2D(_SpecTex, i.uv);

                fixed3 normal = normalize(i.normal);
                fixed3 lightDir = _WorldSpaceLightPos0.xyz;
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                fixed3 halfwayDir = normalize(lightDir + viewDir);

                fixed diff = max(0, dot(normal, lightDir));
                fixed spec = max(0, dot(normal, halfwayDir));

                fixed3 diffuseCol = diff * _LightColor0.rgb * mainTex * _Color;
                float3 glossyCol = _LightColor0.rgb * specTex * pow(spec, _Glossiness);
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
                fixed2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                fixed3 normal :TEXCOORD1;
                float3 posWorld : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _SpecTex;
            half _Glossiness;
            fixed4 _Color;

            v2f vert(appdata_full v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed4 mainTex = tex2D(_MainTex, i.uv);
                fixed4 specTex = tex2D(_SpecTex, i.uv);

                UNITY_LIGHT_ATTENUATION(atten, i, i.posWorld)
                fixed3 normal = normalize(i.normal);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - i.posWorld);
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                fixed3 halfwayDir = normalize(lightDir + viewDir);

                fixed diff = max(0, dot(normal, lightDir));
                fixed spec = max(0, dot(normal, halfwayDir));

                fixed3 diffuseCol = diff * _LightColor0.rgb * mainTex * _Color;
                float3 glossyCol = _LightColor0.rgb * specTex * pow(spec, _Glossiness);
                
                fixed3 light = diffuseCol + glossyCol;

                fixed4 col = fixed4(light, 1) * atten;
                return col;
            }
            ENDCG
        }
    }
}
