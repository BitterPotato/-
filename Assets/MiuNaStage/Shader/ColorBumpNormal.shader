Shader "Custom/ColorBumpNormal"
{
	Properties
	{
		_Color("Diffuse", Color) = (1, 1, 1, 1)
		_NormalTex("Normal", 2D) = "normal" {}
		_NormalBumpScale("BumpScale", float) = 1.2
		_Multiplier ("Multiplier", float) = 2.0
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma enable_d3d11_debug_symbols

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"
#include "MiunaCG.cginc"

	struct v2f
	{
		float4 vertex : SV_POSITION;
		float4 uv : TEXCOORD0;
		float3 lightDir : TEXCOORD1;
	};

	fixed4 _Color;
	float _NormalBumpScale;
	float _Multiplier;

	sampler2D _NormalTex;
	float4 _NormalTex_ST;

	v2f vert(appdata_tan v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv.zw = TRANSFORM_TEX(v.texcoord, _NormalTex);

		// transform light to object space, then to tangent space
		// the normal there as one specific axis
		TANGENT_SPACE_ROTATION;
		o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)).xyz);

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		// since unity might optimize the storage of normal map,
		// so we can not directly access the coordinate
		fixed3 tangentNormal = UnpackNormal(tex2D(_NormalTex, i.uv.zw));
		tangentNormal.xy *= _NormalBumpScale;
		tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

		//return fixed4(tangentNormal, 1.0);
		fixed nl = halfLambert(dot(tangentNormal, i.lightDir));
		//fixed nl = max(0.0, dot(tangentNormal, i.lightDir));

		//fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

		return _Color *  nl * _Multiplier;
		//return _LightColor0.rgb * _Color * nl;
	}
		ENDCG
	}
	}
}
