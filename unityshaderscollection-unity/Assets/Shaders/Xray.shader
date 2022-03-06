Shader "Unlit/Xray"
{
    Properties {
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _FresnelPower ("Fresnel Power", float) = 0
        _NoiseAmount ("NoiseAmount", float) = 0
        _NoiseTiling ("NoiseTiling", Vector) = (2, 5, 0, 0)
        _NoiseSpeed ("NoiseSpeed", float) = 0
    }
    SubShader {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent"}
        LOD 100

        Pass {
            ZWRITE Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile instancing
            
            #include "UnityCG.cginc"
            #include "MyCginc.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed3 normal : TEXCOORD1;
                fixed3 viewDir : TEXCOORD2;
            };

            sampler2D _NoiseTex;
            fixed4 _Color;
            float _FresnelPower;
            float _NoiseAmount;
            float4 _NoiseTiling;
            float _NoiseSpeed;

            v2f vert (appdata_full v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v)
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = posWorld.y * float2(_NoiseTiling.x, _NoiseTiling.y) + _Time.r * _NoiseSpeed;
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz - posWorld);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed4 noise = tex2D(_NoiseTex, i.uv);
                float fresnel = FresnelEffect(i.normal, i.viewDir, _FresnelPower) * 2;
                float multiplied = fresnel * noise;
                float interpolated = lerp(fresnel, multiplied, _NoiseAmount);
                fixed4 col = _Color * interpolated;
                return col;
            }
            ENDCG
        }
    }
}
