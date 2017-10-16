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
#include "MiunaCG.cginc"

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
				
			
			float noise = voronoi(i.uv*16.0) * 0.5 + 0.5;

			//float begin = 0.45f;
			//float end = 0.5f + sin(noise)*0.1f;

			//noise = step(begin, noise)*noise;
			//noise = step(end, noise);
			ori *= noise;
			//noise_color(ori, voronoi(i.uv*16.0));
				//noise_color(ori, perlin_noise(i.uv*2.0));
				return ori;
			}
			ENDCG
		}
	}
}
