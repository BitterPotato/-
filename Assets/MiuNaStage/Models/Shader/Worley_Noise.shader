Shader "Custom/Worley_Noise"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			float2 hash2( float2 p )
			{
			    float2 q = float2( dot(p,float2(127.1,311.7)), 
							   dot(p,float2(269.5,183.3)));
				return frac(sin(q)*43758.5453);
			}

			float voronoi(float2 x) {
				int2 p = floor(x);
				float2 f = frac(x);

				float res = 8.0f;
				for(int j= -1; j<=1; j++) {
					for(int i=-1; i<=1; i++) {
						int2 b = int2(i, j);
						float2 r = float2(b) - f + hash2(p+b);
						float d = dot(r, r);

						res = min(res, d);
					}
				}
				return sqrt(res);
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 ori = fixed4(1.0f, 0.0f, 0.0f, 1.0f);
				fixed4 col = ori + frac(voronoi(i.vertex.xy));
				return col;
			}
			ENDCG
		}
	}
}
