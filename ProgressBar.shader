Shader "Custom/ProgressBar"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Texture", 2D) = "white" {}

        [Header(Pattern)]
        [Space]
        _Pattern ("Pattern Texture", 2D) = "white" {}
        _PatternInfluence("Pattern Influence", Range(0, 1)) = 0
        _PatternSpeed("Pattern Speed", Range(0, 1)) = 0.1

        [Header(Shadow)]
        [Space]
        _ShadowHeight("Shadow Height", Range(0, 1)) = 0
        _ShadowIntensity("Shadow Intensity", Range(0, 1)) = 0

        [Header(Fill)]
        [Space]
        _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Fill("Fill", Range(0, 1)) = 0
        _BorderThickness("Border Thickness", Range(0, 0.1)) = 0.04
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 patternUV : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 patternUV : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _Pattern;
            float4 _MainTex_ST;
            float4 _Pattern_ST;

            float4 _Color;

            float _PatternInfluence;
            float _PatternSpeed;
            float _ShadowHeight;
            float _ShadowIntensity;
            float _BorderThickness;
            float _Fill;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.patternUV = TRANSFORM_TEX(v.uv, _Pattern);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 patternUV = i.patternUV + float2(_Time.y * _PatternSpeed, 0);

                float4 fill = step(i.uv.x, _Fill);

                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                fixed4 pattern = tex2D(_Pattern, patternUV);

                fixed4 stripBegin = 1 - step(_Fill, i.uv.x);
                fixed4 stripEnd = 1 - step(_Fill + _BorderThickness, i.uv.x);

                fixed4 finalStrip = stripEnd - stripBegin;

                fixed4 patternedCol = lerp(col, pattern * _PatternInfluence + col, pattern.a);

                fixed4 shadow = saturate(patternedCol * float4(0.5, 0.5, 0.5, 1));

                fixed4 finalCol = lerp(patternedCol, shadow, 0.5);
                finalCol.a = 1;

                fixed4 shadowStep = step(1 - i.uv.y, _ShadowHeight);

                shadowStep += float4(1 - _ShadowIntensity, 1 - _ShadowIntensity, 1 - _ShadowIntensity, 1);

                finalCol = saturate(shadowStep * patternedCol) * fill;
                finalCol += finalStrip;
                return finalCol;
            }
            ENDCG
        }
    }
}
