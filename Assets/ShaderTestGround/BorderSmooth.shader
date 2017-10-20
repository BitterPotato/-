Shader "Test/BorderSmooth"
{
	Properties
	{
		_MainColor ("Color", Color) = (1, 0, 0, 1)
	}
	SubShader
	{
		Tags { "Queue"="Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};

			float4 _MainColor;

			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = mul(unity_ObjectToWorld, v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				float3 worldViewDir = UnityWorldSpaceViewDir(i.worldPos);
				float before = dot(normalize(worldViewDir), normalize(i.worldNormal));
				// bigger the num, the less obvious we will see the plane, since they are (0, 0, 0, 0) now
				// abs(before - num)
				float falloff = max(abs(before) - 0.75, 0.0);
				// use pow will weaken the center effect
				//falloff = falloff * falloff;
				
				return _MainColor*falloff;
				//return fixed4(0.0, 0.0, 0.0, 0.0);
				//return fixed4(before, before, before, before);
			}
			ENDCG
		}
	}
}
