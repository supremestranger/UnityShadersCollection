Shader "Lambert" {
    Properties {
        [NoScaleOffset]
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
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

                fixed3 normal = normalize(i.normal);
                fixed3 lightDir = _WorldSpaceLightPos0.xyz;
                
                fixed diff = max(0, dot(normal, lightDir));
                
                fixed3 diffuseCol = diff * _LightColor0.rgb * mainTex * _Color;
                fixed3 ambientCol = UNITY_LIGHTMODEL_AMBIENT * mainTex * _Color;
                
                fixed3 light = diffuseCol + ambientCol;

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
                
                UNITY_LIGHT_ATTENUATION(atten, i, i.posWorld);
                fixed3 normal = normalize(i.normal);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - i.posWorld.xyz);
                
                fixed diff = max(0, dot(normal, lightDir));

                fixed3 diffuseCol = diff * _LightColor0.rgb * mainTex * _Color;
                
                fixed3 light = diffuseCol;
                
                fixed4 col = fixed4(light, 1) * atten;
                return col;
            }
            ENDCG
        }
        
        Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f { 
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}
