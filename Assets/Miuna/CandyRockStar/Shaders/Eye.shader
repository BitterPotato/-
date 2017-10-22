// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Miuna/Eye"
{
	Properties
	{
		_MainTex("Diffuse", 2D) = "white" {}

		_EnvMap("Environment Cubemap", Cube) = "_Skybox" {}
		_RefractColor("Refraction Color", Color) = (1, 1, 1, 1)
		_RefractWeight("Refraction Weight", Range(0.0, 1.0)) = 0.8
		_RefractEta("Refraction Eta", Range(0.0, 1.0)) = 0.5
	}
		SubShader
		{
			Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" }
			LOD 100

			Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha, One One
			Cull Back
			ZTest LEqual

			CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag

	#include "UnityCG.cginc"

		samplerCUBE _EnvMap;
		fixed4 _RefractColor;
		fixed _RefractWeight;
		fixed _RefractEta;
		
	struct v2f
	{
		float4 vertex : SV_POSITION;
		float2 uv : TEXCOORD0;
		float3 worldRefr : TEXCOORD1;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	v2f vert(appdata_base v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);

		float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
		float worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
		o.worldRefr = refract(-worldViewDir, worldNormal, _RefractEta);

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		// sample the texture
		fixed4 diffuse = tex2D(_MainTex, i.uv);
	fixed3 refraction = texCUBE(_EnvMap, i.worldRefr).rgb * _RefractColor.rgb;

	fixed atten = 0.6;
	fixed3 color = lerp(diffuse.rgb, refraction, _RefractWeight) * atten;
	return fixed4(color, diffuse.a);
	}
		ENDCG
	}
	}
}
