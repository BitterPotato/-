// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/flock"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma target 4.5
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
#pragma enable_d3d11_debug_symbols
			
			#include "UnityCG.cginc"
#include "MiunaCG.cginc"

			struct Fish {
				float3 position;
				float3 velocity;
				float4 color;
			};
//#if SHADER_TARGET >= 50
			StructuredBuffer<Fish> fishBuffer;
//#endif

			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed4 color : TEXCOORD0;
				float2 uv : TEXCOORD1;
			};
			
			v2f vert (appdata v, uint instanceID : SV_InstanceID)
			{
				v2f o;

				UNITY_SETUP_INSTANCE_ID(v);

				float4 position;
				float4 color;
				float3 velocity;
//#if SHADER_TARGET >= 50
				position.xyz = fishBuffer[instanceID].position;
				position.w = 1.0;
				color = fishBuffer[instanceID].color;
				velocity = fishBuffer[instanceID].velocity;
//#else
//				position = 0;
//				color = 0.5;
//#endif

				unity_ObjectToWorld._14_24_34_44 += position;

				// velocity orientation to (1, 0, 0)
				zRotate(unity_ObjectToWorld, radians(90));
				yRotate(unity_ObjectToWorld, radians(90));
				
				//velocity = float3(1.0, 1.0, 1.0);
				applyVelocity(unity_ObjectToWorld, velocity);

				float4 temp = mul(unity_ObjectToWorld, v.vertex);
				o.pos = mul(UNITY_MATRIX_VP, temp);
				o.color = color;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				//fixed4 dest = tex2D(_MainTex, i.uv);

				//return blend(i.color, dest);
				fixed4 col = i.color;
				return col;
			}
			ENDCG
		}
	}
}
