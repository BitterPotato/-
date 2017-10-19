Shader "Custom/NoiseStone"
{
	Properties
	{
		_DiffuseColor("Diffuse Color", Color) = (1, 1, 1, 1)
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

#pragma vertex vert_base
#pragma fragment frag

#define DIFFUSE_COLOR
#include "BasicLight.cg"

	fixed4 frag(v2f_base i) : SV_Target
	{

		float noise = shiftRange(fbm_perlin_noise(i.texcoord.xy*16.0));
		// TODO: 拉开最低值和最高值的差距，构成对比；并保留飞线形
		noise = (1 - clamp(noise, 0.0, 0.6)) * 1.5;

		//float begin = 0.45f;
		//float end = 0.5f + sin(noise)*0.1f;

		//noise = step(begin, noise)*noise;
		//noise = step(end, noise);
		fixed4 col = frag_base_base(i) *  noise;
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

#pragma vertex vert_base
#pragma fragment frag_base_add

#define DIFFUSE_COLOR
#include "BasicLight.cg"

		ENDCG
	}

	}
	Fallback "VertexLit"
}
