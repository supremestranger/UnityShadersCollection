Shader "Unlit/Hologram" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _FresnelPower ("Fresnel Power", float) = 0
        _Tiling ("Tiling", float) = 0
        _ScrollSpeed ("Scroll Speed", float) = 0
    }
    SubShader {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            ZWRITE Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #include "MyCginc.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                fixed3 normal : TEXCOORD0;
                fixed3 viewDir : TEXCOORD1;
                fixed2 uv : TEXCOORD2;
            };

            half _ScrollSpeed;
            half _Tiling;
            
            v2f vert (appdata_full v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = _Time.x * _ScrollSpeed + posWorld.y * _Tiling;
                o.normal = normalize(mul (v.normal, (float3x3)unity_WorldToObject));
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz - posWorld);
                return o;
            }
            
            fixed4 _Color;
            fixed4 _FresnelColor;
            half _FresnelPower;
            sampler2D _MainTex;
            
            fixed4 frag (v2f i) : SV_Target {
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed3 rim = _FresnelColor * FresnelEffect(i.normal, i.viewDir, _FresnelPower);
                fixed4 col = _Color + fixed4(rim, 1);
                col.a = tex.r;
                return col;
            }
            ENDCG
        }
    }
}
