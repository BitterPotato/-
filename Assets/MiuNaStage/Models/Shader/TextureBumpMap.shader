Shader "Custom/TextureBumpMap"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_NormalTex("Normal", 2D) = "normal" {}
		_NormalBumpScale("BumpScale", float) = 1.2
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
#include "MiunaCG.cginc"

	struct v2f
	{
		float4 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
		float3 lightDir : TEXCOORD2;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	sampler2D _NormalTex;
	float4 _NormalTex_ST;

	float _NormalBumpScale;

	v2f vert(appdata_tan v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
		o.uv.zw = TRANSFORM_TEX(v.texcoord, _NormalTex);

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

		fixed nl = halfLambert(dot(tangentNormal, i.lightDir));
		//fixed nl = max(0.0, dot(tangentNormal, i.lightDir));

		fixed3 inherent = tex2D(_MainTex, i.uv.xy).xyz;

		fixed3 diffuse = inherent * nl;

		//return fixed4(diffuse + inherent, 1.0);
		return fixed4(diffuse, 1.0);
		//return fixed4(nl, nl, nl, 1.0);
		//return _LightColor0.rgb * _Color * nl;
	}
		ENDCG
	}
	}
}
