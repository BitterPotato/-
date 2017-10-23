Shader "Miuna/Hair"
{
	Properties
	{
		_DiffuseTex("Diffuse", 2D) = "white" {}
		_SpecularTex("Specular", 2D) = "white" {}

		_DiffuseRamp("Diffuse Ramp", 2D) = "white" {}
		_DiffuseVert("Diffuse Vertical V", Range(0.0, 1.0)) = 0.25

		_SpecularRamp("Specular Ramp", 2D) = "white" {}
		_SpecularVert("Specular Vertical V", Range(0.0, 1.0)) = 0.25

		_FresnelScale("Fresnel Scale", Range(0.0, 1.0)) = 0.5
		_EnvMap("Environment Cubemap", Cube) = "_Skybox" {}

		_AOTex("AO", 2D) = "white" {}
		_AORatio("AO Ratio", Range(0.0, 1.0)) = 0.3

		_JitterTex("Jitter Map", 2D) = "white" {}
		_JitterCellSize ("Jitter Cell Size", Range(0.0, 1.0)) = 0.2
		_JitterColor ("Jitter Color", Color) = (0.3, 0.4, 0.5, 1.0)

		_LowExponent("Low Exponent", float) = 10.0
		_LowLumi("Low Lumi", float) = 1.0

		_HighExponent("High Exponent", float) = 80.0
		_HighLumi("High Lumi", float) = 4.0
		// ==== for outline ====
		_EdgeThickness("Edge Thickness", float) = 0.001
		_DeltaEdge("Delta Edge", float) = 0.001
		_NearEdgeDepth("Near Depth(Edge)", float) = 2.0
		_FarEdgeDepth("Far Depth(Edge)", float) = 4.0
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
	{
		Cull Back
		ZTest LEqual

		CGPROGRAM
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#include "AutoLight.cginc"
		#include "MiunaCG.cginc"

		#pragma vertex vert
		#pragma fragment frag

		sampler2D _DiffuseTex;
		float4 _DiffuseTex_ST;

		sampler2D _SpecularTex;
		float4 _SpecularTex_ST;

		sampler2D _DiffuseRamp;
		float _DiffuseVert;

		sampler2D _SpecularRamp;
		float _SpecularVert;

		samplerCUBE _EnvMap;
		fixed _FresnelScale;

		sampler2D _AOTex;
		fixed _AORatio;

		sampler2D _JitterTex;
		fixed4 _JitterColor;
		fixed _JitterCellSize;

		fixed _LowExponent;
		fixed _LowLumi;
		fixed _HighExponent;
		fixed _HighLumi;

		struct v2f_base
		{
			float4 pos : SV_POSITION;
			float4 texcoord : TEXCOORD0;
			float3 worldNormal : TEXCOORD2;
			float3 worldPos : TEXCOORD3;
			float3 worldTan : TEXCOORD4;
			// SHADOW_COORDS(4)
		};

		void xRotate(inout float3 toModify, float radian)
		{
			float sinv = sin(radian);
			float cosv = cos(radian);

			float3x3 rotateMatrix = float3x3(
				1.0, 0.0, 0.0,
				0.0, cosv, -sinv,
				0.0, sinv, cosv
				);

			toModify = mul(toModify, rotateMatrix);
		}

		void yRotate(inout float3 toModify, float radian)
		{
			float sinv = sin(radian);
			float cosv = cos(radian);

			float3x3 rotateMatrix = float3x3(
				cosv, 0.0, sinv,
				0.0, 1.0, 0.0,
				-sinv, 0.0, cosv
				);

			toModify = mul(toModify, rotateMatrix);
		}

		void zRotate(inout float3 toModify, float radian)
		{
			float sinv = sin(radian);
			float cosv = cos(radian);

			float3x3 rotateMatrix = float3x3(
				cosv, -sinv, 0.0,
				sinv, cosv, 0.0,
				0.0, 0.0, 1.0
				);

			toModify = mul(toModify, rotateMatrix);
		}

		// exponent upper : spread lower； strength upper : light upper 
		float StrandSpecular(float3 T, float3 V, float3 L, float exponent, float strength) {
			// zRotate(T, radians(90.0));
			float3 H = normalize(L + V);
			float dotTH = dot(T, H);
			float sinTH = sqrt(1.0 - dotTH*dotTH);
			float dirAtten = smoothstep(-1.0, 0.0, dotTH);
			return dirAtten*pow(sinTH, exponent)*strength;
		}

		v2f_base vert(appdata_tan v)
		{
			v2f_base o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.worldNormal = normalize(mul(unity_ObjectToWorld, v.normal));
			o.worldPos = mul(unity_ObjectToWorld, v.vertex);
			o.worldTan = mul(unity_ObjectToWorld, v.tangent.xyz);

			o.texcoord.xy = TRANSFORM_TEX(v.texcoord.xy, _DiffuseTex);
			o.texcoord.zw = TRANSFORM_TEX(v.texcoord.xy, _SpecularTex);

			// TRANSFER_SHADOW(o);

			return o;
		}


		fixed4 frag(v2f_base i) : SV_Target
		{
			fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
			fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldTan = normalize(i.worldTan);
			fixed3 worldRefl = reflect(-worldViewDir, worldNormal);

			fixed3 combinedColor = fixed3(0.0, 0.0, 0.0);
			
			fixed2 ori_uv = i.texcoord.xy;
			ori_uv.x = fmod(ori_uv.x, _JitterCellSize) / _JitterCellSize;
			ori_uv.y = fmod(ori_uv.y, _JitterCellSize) / _JitterCellSize;

			//ambient
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			combinedColor += ambient * tex2D(_AOTex, ori_uv.xy) * _AORatio;

			// diffuse ramp
			fixed nl = halfLambert(dot(i.worldNormal, worldLightDir));
			fixed nv = dot(i.worldNormal, worldViewDir);
			fixed rampU = 1 - min(nl, nv);
			fixed3 diffuseRamp = tex2D(_DiffuseRamp, fixed2(rampU, _DiffuseVert));

			fixed3 diffuse = tex2D(_DiffuseTex, ori_uv.xy).rgb;
			fixed3 rampDiffuse = diffuse * diffuse;
			rampDiffuse.b += diffuseRamp.b;
			// combinedColor += diffuse * diffuseRamp.rgb;
			// combinedColor += lerp(rampDiffuse, diffuse, diffuseRamp) * _LightColor0.rgb;

			// specular ramp
			fixed3 halfDir = normalize(worldViewDir + worldLightDir);
			fixed phong = max(0, pow(dot(halfDir, worldNormal), 5));
			fixed3 specularRamp = tex2D(_SpecularRamp, fixed2(1 - phong, _SpecularVert));
			specularRamp = pow(specularRamp, 0.1);

			fixed3 specular = tex2D(_SpecularTex, i.texcoord.zw).rgb;
			// combinedColor += specular * specularRamp.rgb;
			combinedColor += specular * pow(specularRamp.rgb, 100) * _LightColor0.rgb;

			// jitter
			fixed lerp_weight = 0.3;
			fixed jitter = (1.0 - Luminance(tex2D(_JitterTex, ori_uv).rgb))*2;

			float low_atten = StrandSpecular(worldTan, worldViewDir, worldLightDir, _LowExponent, _LowLumi);
			fixed3 lowatten_Ramp = lerp(specularRamp, fixed3(low_atten, low_atten, low_atten), lerp_weight);
			combinedColor += specular * _JitterColor * lowatten_Ramp * jitter * _LightColor0.rgb;

			float high_atten = StrandSpecular(worldTan, worldViewDir, worldLightDir, _HighExponent, _HighLumi);
			fixed3 highatten_Ramp = lerp(specularRamp, fixed3(high_atten, high_atten, high_atten), lerp_weight);
			combinedColor += specular * _JitterColor *  highatten_Ramp * jitter * _LightColor0.rgb;

			// env
			fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);
			// combinedColor += saturate(fresnel) * texCUBE(_EnvMap, worldRefl).rgb;

			// combine shadow to light atten
			// UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

			// the alpha aisle not in use right now
			return fixed4(combinedColor, 1.0);
		}
		ENDCG
	}
			Pass{
		Name "Outline"

		Cull Front
		ZTest Less

		CGPROGRAM

#pragma vertex outlineVert
#pragma fragment outlineFrag

#include "MiunaCharacter.cg"

		ENDCG
	}
	}
	Fallback "VertexLit"
}
