// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Unlit"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
#pragma enable_d3d11_debug_symbols

			#include "UnityCG.cginc"
#include "MiunaCG.cginc"

			//float4 transform = float4(20, 1, 1, 0);
			fixed4 color = fixed4(1.0, 0.0, 0.0, 0.0);
	#define ratio 1.0

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 prevertex : TEXCOORD1;
				float4 first : TEXCOORD2;
				float4 second : TEXCOORD3;
				float4 third : TEXCOORD4;
				float4 fourth : TEXCOORD5;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				float4 preVertex = v.vertex;
				// TODO: why the following two expressions are different?
				//float4x4 rotateMatrix;
				//float4x4 rotateMatrix = float4x4 (
				//	0.0, -1.0, 0.0, 0.0,
				//	1.0, 0.0, 0.0, 0.0,
				//	0.0, 0.0, 1.0, 0.0,
				//	0.0, 0.0, 0.0, 1.0
				//	);
				// row-first
				//rotateMatrix._11_12_13_14 = (1.0, 0.0, 0.0, 0.0);
				//rotateMatrix._21_22_23_24 = (0.0, 1.0, 0.0, 0.0);
				//rotateMatrix._31_32_33_34 = (0.0, 0.0, 1.0, 0.0);
				//rotateMatrix._41_42_43_44 = (0.0, 0.0, 0.0, 1.0);
				//preVertex = mul(rotateMatrix, preVertex);
				//o.prevertex = preVertex;
				//o.first = rotateMatrix._11_12_13_14;
				//o.second = rotateMatrix._21_22_23_24;
				//o.third = rotateMatrix._31_32_33_34;
				//o.fourth = rotateMatrix._41_42_43_44;

				unity_ObjectToWorld._14_24_34_44 += float4(10, 1, 1, 0);
				float3 velocity = float3(0.0, 0.0, 0.0);
				applyVelocity(unity_ObjectToWorld, velocity);

				zRotate(unity_ObjectToWorld, radians(0));
				float4 temp = mul(unity_ObjectToWorld, preVertex);
				o.vertex = mul(UNITY_MATRIX_VP, temp);

				//o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				//fixed4 col = mul(tex2D(_MainTex, i.uv), ratio);
			//fixed4 col = fixed4(0.0, 0.0, 0.0, 0.0);
				
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
