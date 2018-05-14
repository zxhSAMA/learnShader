Shader "Custom/RippleShader" {
	Properties {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        [HideInInspector] _StartTime("StartTime",Float)=0
        _AnimationTime("AnimationTime",Range(0.1,10.0))=1.5
        _Width("Width",Range(0.1,3.0))=0.3
        _StartWidth("StartWidth",Range(0.0,1.0))=0.3
        [Toggle] _isAlpha("isAlpha",Float)=1
        [Toggle] _isColorShift("isColorShift",Float)=1
        [MaterialToggle] _PixelSnap("Pixel snap",Float)=1
	}
	SubShader{
        pass{
            CGPROGRAM

            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _StartTime;
            float _AnimationTime;
            float _Width;
            float _StartWidth;
            float _isAlpha; 
            float _isColorShift;
            float _PixelSnap;

            struct v2f
			{
				float4 vertex   : SV_POSITION;
//				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
			};

        	fixed3 shift_col(fixed3 RGB,half3 shift){
        		fixed3 RESULT=fixed3(RGB);
        		float VSU=shift.z*shift.y*cos(shift.x*3.1415926/180);
        		float VSW=shift.z*shift.y*sin(shift.x*3.1415926/180);
        		RESULT.x=(0.299*shift.z+0.701*VSU+0.168*VSW)*RGB.x+(0.587*shift.z-0.587*VSU+0.330*VSW)*RGB.y+(0.114*shift.z-0.114*VSU-0.497*VSW)*RGB.z;
        		RESULT.y=(0.299*shift.z-0.299*VSU-0.328*VSW)*RGB.x+(0.587*shift.z+0.413*VSU+0.035*VSW)*RGB.y+(0.114*shift.z-0.114*VSU+0.292*VSW)*RGB.z;
        		RESULT.z=(0.299*shift.z-0.300*VSU+1.250*VSW)*RGB.x+(0.587*shift.z-0.588*VSU-1.050*VSW)*RGB.y+(0.114*shift.z+0.886*VSU-0.203*VSW)*RGB.z;
        		return RESULT;
			}

			v2f vert(appdata_base IN){
		    	v2f OUT;
		    	OUT.vertex=UnityObjectToClipPos(IN.vertex);
            	OUT.texcoord=IN.texcoord;
            	return OUT;
			}

			fixed4 frag(v2f IN):SV_Target{
				fixed4 color=tex2D(_MainTex,IN.texcoord);
				float2 pos=(IN.texcoord-float2(0.5,0.5))*2;
				float dis=(_Time.y-_StartTime)/_AnimationTime+_StartWidth-length(pos);
				if(dis<0||dis>_Width){
					return fixed4(0,0,0,0);
				}
				float alpha=1;
				if(_isAlpha==1){
					alpha=clamp((_Width-dis),0.1,1.5);
				}
				fixed3 shiftColor=color;
				if(_isColorShift==1){
					half3 shift=half3(_Time.w*10,1,1);
					shiftColor=shift_col(color,shift);
				}
				return fixed4(shiftColor,color.a*alpha);
			}
            ENDCG
        }
    }
    FallBack "Diffuse"
}
