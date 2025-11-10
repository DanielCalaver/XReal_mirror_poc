// This shader is for the avatar's Head, Body, and Glasses.
// It's a standard URP "Lit" shader, but with one crucial addition:
// It will only render if the Stencil Buffer has a value of 1.
Shader "Tutorial/AvatarMasked"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 200

        // Stencil properties
        Stencil
        {
            Ref 1         // The value to check for (1)
            Comp Equal    // Only pass the test if the buffer value is EQUAL to 1
            Pass Keep     // If the test passes, keep the buffer value (don't change it)
        }

        // Standard URP Lit Pass
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS   : NORMAL;
                float3 positionWS : TEXCOORD0;
            };

            // Shader Properties
            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half _Metallic;
                half _Smoothness;
            CBUFFER_END

            Varyings vert(Attributes v)
            {
                Varyings o;
                o.positionWS = TransformObjectToWorld(v.positionOS.xyz);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                // Get lighting
                Light mainLight = GetMainLight();
                half3 lightDir = mainLight.direction;
                half3 viewDir = normalize(_WorldSpaceCameraPos - i.positionWS);
                
                // Calculate Blinn-Phong lighting
                half3 normal = normalize(i.normalWS);
                half ndl = saturate(dot(normal, lightDir));
                half3 diffuse = ndl * _BaseColor.rgb * mainLight.color;

                half3 halfwayDir = normalize(lightDir + viewDir);
                half spec = pow(saturate(dot(normal, halfwayDir)), _Smoothness * 128.0);
                half3 specular = spec * _Metallic * mainLight.color;

                half3 ambient = GetMainLight().shadowAttenuation * 0.1 * _BaseColor.rgb; // Simple ambient
                
                half3 color = ambient + diffuse + specular;
                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }
}