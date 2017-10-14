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
				fixed2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed2 uv : TEXCOORD0;
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

			fixed2 hash22(fixed2 p)
			{
				p = fixed2(dot(p, fixed2(127.1, 311.7)),
					dot(p, fixed2(269.5, 183.3)));

				return -1.0 + 2.0 * saturate(sin(p)*43758.5453123);
			}
			float perlin_noise(fixed2 p)
			{
				fixed2 pi = floor(p);
				fixed2 pf = p - pi;

				fixed2 w = pf * pf * (3.0 - 2.0 * pf);

				return lerp(lerp(dot(hash22(pi + fixed2(0.0, 0.0)), pf - fixed2(0.0, 0.0)),
					dot(hash22(pi + fixed2(1.0, 0.0)), pf - fixed2(1.0, 0.0)), w.x),
					lerp(dot(hash22(pi + fixed2(0.0, 1.0)), pf - fixed2(0.0, 1.0)),
						dot(hash22(pi + fixed2(1.0, 1.0)), pf - fixed2(1.0, 1.0)), w.x),
					w.y);
			}

			fixed4 draw_simple(float f)
			{
				f = f * 0.5 + 0.5;
				return f * fixed4(25.0 / 255.0, 161.0 / 255.0, 245.0 / 255.0, 1.0);
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 ori = fixed4(0.16f, 0.31f, 0.70f, 1.0f);

				//fixed4 col = ori + frac(voronoi(32.0*i.vertex.xy));
				//fixed4 col = ori*abs(perlin_noise(8.0*i.vertex.xy));
				
			//return draw_simple(voronoi(i.uv*16.0));
				return draw_simple(perlin_noise(i.uv*2.0));
			}
			ENDCG
		}
	}
}
