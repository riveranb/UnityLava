// Author: River Wang
// Date: 2017-06-10
////////////////////////////////////////////////////////////////////////////////
 
 Shader "Unlit/LavaSimple"
{
	Properties
	{
		_LavaTex ("Lava", 2D) = "white" {}
		_NoiseTex ("Noise", 2D) = "black" {}
		_Flow1 ("flow1", Vector) = (1, 0, 0, 0)
		_Flow2 ("flow2", Vector) = (-1, -1, 0, 0)
		_Pulse ("pulse", Float) = 1.0
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 lava_uv : TEXCOORD0;
				float2 noise_uv : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _LavaTex;
			sampler2D _NoiseTex;
			float4 _LavaTex_ST;
			float4 _NoiseTex_ST;
			float4 _Flow1;
			float4 _Flow2;
			float _Pulse;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.lava_uv = TRANSFORM_TEX(v.uv, _LavaTex);
				o.lava_uv += _Flow1.xy * _Time.x;
				o.noise_uv = TRANSFORM_TEX(v.uv, _NoiseTex);
				o.noise_uv += _Flow2.xy * _Time.x;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 noise = tex2D(_NoiseTex, i.noise_uv);
				fixed2 pertube = noise.xy * 0.5 - 0.5;

				fixed4 lavacol = tex2D(_LavaTex, i.lava_uv + pertube);
				fixed pulse = tex2D(_NoiseTex, i.noise_uv + pertube).a;
				
				// important part, exposure effect.
				fixed4 temper = lavacol * pulse * _Pulse + (lavacol * lavacol - 0.1);
				// TODO: conditions are important?
			   	if(temper.r > 1.0)
			   	{
			   		temper.bg += clamp(temper.r-2.0, 0.0, 5.0);
			   	} 
   				if(temper.g > 1.0)
   				{
   					temper.rb += temper.g - 1.0;
   				} 
   				if(temper.b > 1.0)
   				{
   					temper.rg += temper.b - 1.0;
   				}
				//temper = normalize(temper) * (1.0 + pulse); // another try

				lavacol = temper;
				lavacol.a = 1.0;
				return lavacol;
			}
			ENDCG
		}
	}
}
