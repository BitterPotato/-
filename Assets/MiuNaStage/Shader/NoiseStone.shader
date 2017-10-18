Shader "Custom/NoiseStone"
{
	Properties
	{
		_Color("Diffuse", Color) = (1, 1, 1, 1)
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
	{
		Tags{ "LightMode" = "ForwardBase" }

		CGPROGRAM
		#pragma multi_compile_fwdbase
		#pragma vertex vert
		#pragma fragment frag

		#include "UnityCG.cginc"
		#include "MiunaCG.cginc"

		fixed4 _Color;

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

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{

		float noise = fbm_perlin_noise(i.uv*16.0) * 0.5 + 0.5;
		// TODO: 拉开最低值和最高值的差距，构成对比；并保留飞线形
		noise = (1 - clamp(noise, 0.0, 0.6)) * 3;

		//float begin = 0.45f;
		//float end = 0.5f + sin(noise)*0.1f;

		//noise = step(begin, noise)*noise;
		//noise = step(end, noise);
		fixed4 col = _Color *  noise;
		//noise_color(ori, voronoi(i.uv*16.0));
		//noise_color(ori, perlin_noise(i.uv*2.0));
		return col;
	}
		ENDCG
	}
		Pass{
		Tags{ "LightMode" = "ForwardAdd" }

		Blend one one

		CGPROGRAM

#pragma multi_compile_fwdadd

#pragma vertex vert
#pragma fragment fragd

#include "BasicLight.cg"

		ENDCG
	}

	}
	Fallback "VertexLit"
}
