Shader "CloudGenerateShader"
{
    Properties
    {
        _Emission("Emission", Float) = 2
        _BowlShape("BowlShape", Float) = 2
        _TransparentRange("TransparentRange", Float) = 100
        _Strength("Strength", Float) = 100
        _RotationOffset("RotationOffset", Vector) = (1, 0, 0, 90)
        _NoiseScale("NoiseScale", Float) = 1
        _NoiseSpeed("NoiseSpeed", Float) = 1
        _NoisePower("NoisePower", Float) = 0
        _Remap("Remap", Vector) = (0, 1, -1, 1)
        _ColorUp("ColorUp", Color) = (1, 1, 1, 0)
        _ColorDown("ColorDown", Color) = (0.6698113, 0.6698113, 0.6698113, 0)
        _EdgeMin("EdgeMin", Float) = 0
        _EdgeMax("EdgeMax", Float) = 1
        _BaseNoiseScale("BaseNoiseScale", Float) = 5
        _BaseNoiseSpeed("BaseNoiseSpeed", Float) = 1
        _BaseNoiseStrength("BaseNoiseStrength", Float) = 2
        _FresnelPower("FresnelPower", Float) = 3
        _FresnelStrength("FresnelStrength", Float) = 2
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        //ZWrite Off
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0 = _ColorUp;
            float4 _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0 = _ColorDown;
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float4 _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3;
            Unity_Lerp_float4(_Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0, _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxxx), _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3);
            float _Property_7fa455baf1b543a2ae3d46d031db6930_Out_0 = _Emission;
            float _Multiply_f749052975384592bcd1937f23d9b46e_Out_2;
            Unity_Multiply_float_float(_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2, _Property_7fa455baf1b543a2ae3d46d031db6930_Out_0, _Multiply_f749052975384592bcd1937f23d9b46e_Out_2);
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.BaseColor = (_Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_f749052975384592bcd1937f23d9b46e_Out_2.xxx);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0 = _ColorUp;
            float4 _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0 = _ColorDown;
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float4 _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3;
            Unity_Lerp_float4(_Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0, _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxxx), _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3);
            float _Property_7fa455baf1b543a2ae3d46d031db6930_Out_0 = _Emission;
            float _Multiply_f749052975384592bcd1937f23d9b46e_Out_2;
            Unity_Multiply_float_float(_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2, _Property_7fa455baf1b543a2ae3d46d031db6930_Out_0, _Multiply_f749052975384592bcd1937f23d9b46e_Out_2);
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.BaseColor = (_Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_f749052975384592bcd1937f23d9b46e_Out_2.xxx);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.texCoord1;
            output.interp3.xyzw =  input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.texCoord1 = input.interp2.xyzw;
            output.texCoord2 = input.interp3.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0 = _ColorUp;
            float4 _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0 = _ColorDown;
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float4 _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3;
            Unity_Lerp_float4(_Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0, _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxxx), _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3);
            float _Property_7fa455baf1b543a2ae3d46d031db6930_Out_0 = _Emission;
            float _Multiply_f749052975384592bcd1937f23d9b46e_Out_2;
            Unity_Multiply_float_float(_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2, _Property_7fa455baf1b543a2ae3d46d031db6930_Out_0, _Multiply_f749052975384592bcd1937f23d9b46e_Out_2);
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.BaseColor = (_Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3.xyz);
            surface.Emission = (_Multiply_f749052975384592bcd1937f23d9b46e_Out_2.xxx);
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0 = _ColorUp;
            float4 _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0 = _ColorDown;
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float4 _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3;
            Unity_Lerp_float4(_Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0, _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxxx), _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3);
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.BaseColor = (_Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3.xyz);
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0 = _ColorUp;
            float4 _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0 = _ColorDown;
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float4 _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3;
            Unity_Lerp_float4(_Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0, _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxxx), _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3);
            float _Property_7fa455baf1b543a2ae3d46d031db6930_Out_0 = _Emission;
            float _Multiply_f749052975384592bcd1937f23d9b46e_Out_2;
            Unity_Multiply_float_float(_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2, _Property_7fa455baf1b543a2ae3d46d031db6930_Out_0, _Multiply_f749052975384592bcd1937f23d9b46e_Out_2);
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.BaseColor = (_Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_f749052975384592bcd1937f23d9b46e_Out_2.xxx);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.texCoord1;
            output.interp3.xyzw =  input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.texCoord1 = input.interp2.xyzw;
            output.texCoord2 = input.interp3.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0 = _ColorUp;
            float4 _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0 = _ColorDown;
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float4 _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3;
            Unity_Lerp_float4(_Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0, _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxxx), _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3);
            float _Property_7fa455baf1b543a2ae3d46d031db6930_Out_0 = _Emission;
            float _Multiply_f749052975384592bcd1937f23d9b46e_Out_2;
            Unity_Multiply_float_float(_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2, _Property_7fa455baf1b543a2ae3d46d031db6930_Out_0, _Multiply_f749052975384592bcd1937f23d9b46e_Out_2);
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.BaseColor = (_Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3.xyz);
            surface.Emission = (_Multiply_f749052975384592bcd1937f23d9b46e_Out_2.xxx);
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _RotationOffset;
        float _NoiseScale;
        float _Strength;
        float _NoiseSpeed;
        float4 _Remap;
        float4 _ColorUp;
        float4 _ColorDown;
        float _BaseNoiseScale;
        float _BaseNoiseSpeed;
        float _BaseNoiseStrength;
        float _EdgeMin;
        float _EdgeMax;
        float _NoisePower;
        float _Emission;
        float _BowlShape;
        float _FresnelPower;
        float _FresnelStrength;
        float _TransparentRange;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2);
            float _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2;
            Unity_Divide_float(1, _Distance_23fdb0b4c3644bfcb848e65118efad4d_Out_2, _Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2);
            float _Property_b95f07900ac44331a5ab833f40796c52_Out_0 = _BowlShape;
            float _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2;
            Unity_Power_float(_Divide_cc39d3c5d09c407c9394ca8ebde81610_Out_2, _Property_b95f07900ac44331a5ab833f40796c52_Out_0, _Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2);
            float3 _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Power_10e1c78b7db742d3b38aaf44ec93e42d_Out_2.xxx), _Multiply_b7a3537023204067878c9cd730caf4eb_Out_2);
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float3 _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxx), _Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2);
            float _Property_23e56a4f5792404c8987942916319a3a_Out_0 = _Strength;
            float3 _Multiply_2285afcd6717423ba765e113131f7506_Out_2;
            Unity_Multiply_float3_float3(_Multiply_70ec6c9ad88d47b59d9da79ad678818a_Out_2, (_Property_23e56a4f5792404c8987942916319a3a_Out_0.xxx), _Multiply_2285afcd6717423ba765e113131f7506_Out_2);
            float3 _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2285afcd6717423ba765e113131f7506_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2);
            float3 _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            Unity_Add_float3(_Multiply_b7a3537023204067878c9cd730caf4eb_Out_2, _Add_67b5e5ba78c145e1b59c27cb2a170172_Out_2, _Add_e7c318812da4428cb2457195d3563e70_Out_2);
            description.Position = _Add_e7c318812da4428cb2457195d3563e70_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0 = _ColorUp;
            float4 _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0 = _ColorDown;
            float _Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0 = _EdgeMin;
            float _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0 = _EdgeMax;
            float4 _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0 = _RotationOffset;
            float _Split_da6aed90b2424efe84958238a299634a_R_1 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[0];
            float _Split_da6aed90b2424efe84958238a299634a_G_2 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[1];
            float _Split_da6aed90b2424efe84958238a299634a_B_3 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[2];
            float _Split_da6aed90b2424efe84958238a299634a_A_4 = _Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0[3];
            float3 _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, (_Property_50ed3b36689e4f7bb3a89e86163186a1_Out_0.xyz), _Split_da6aed90b2424efe84958238a299634a_A_4, _RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3);
            float _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0 = _NoiseSpeed;
            float _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a33ab21d84b44d8dbadbf5b6ff72a7ce_Out_0, _Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2);
            float2 _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_aab4eaf793a048da8bd6aa5bd6d35d94_Out_2.xx), _TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3);
            float _Property_fa18e147456c4d4f89f34828e2311797_Out_0 = _NoiseScale;
            float _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_3a02fec24dc5409b93b745ff323a3f3d_Out_3, _Property_fa18e147456c4d4f89f34828e2311797_Out_0, _GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2);
            float2 _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3);
            float _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0 = _NoiseScale;
            float _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_56fbd0a4f59648108601f79235dd93e5_Out_3, _Property_ec35e3b61b18441f8bf075835d363c0a_Out_0, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2);
            float _Add_718922b381244e8ea3597ab5fa864fa1_Out_2;
            Unity_Add_float(_GradientNoise_3394b06c355d4d6e80a8392f419a2212_Out_2, _GradientNoise_ec20a6d0daf9469bab70fc854e971e71_Out_2, _Add_718922b381244e8ea3597ab5fa864fa1_Out_2);
            float _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2;
            Unity_Divide_float(_Add_718922b381244e8ea3597ab5fa864fa1_Out_2, 2, _Divide_10e93e20d4db433c885a2a7d3b913663_Out_2);
            float _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1;
            Unity_Saturate_float(_Divide_10e93e20d4db433c885a2a7d3b913663_Out_2, _Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1);
            float _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0 = _NoisePower;
            float _Power_b27ec25adef34771839f14cc00dc7d42_Out_2;
            Unity_Power_float(_Saturate_1f65c0ac57884891bf4e903fc02a3f7d_Out_1, _Property_55891db2e9234d67b9b9057d9686ffb2_Out_0, _Power_b27ec25adef34771839f14cc00dc7d42_Out_2);
            float4 _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0 = _Remap;
            float _Split_5dc7bbfa089944c382853b8eb235fc90_R_1 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[0];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_G_2 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[1];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_B_3 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[2];
            float _Split_5dc7bbfa089944c382853b8eb235fc90_A_4 = _Property_58c4fd0706be47e395e98c81e3661e3c_Out_0[3];
            float4 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4;
            float3 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5;
            float2 _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_R_1, _Split_5dc7bbfa089944c382853b8eb235fc90_G_2, 0, 0, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGBA_4, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RGB_5, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6);
            float4 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4;
            float3 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5;
            float2 _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6;
            Unity_Combine_float(_Split_5dc7bbfa089944c382853b8eb235fc90_B_3, _Split_5dc7bbfa089944c382853b8eb235fc90_A_4, 0, 0, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGBA_4, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RGB_5, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6);
            float _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3;
            Unity_Remap_float(_Power_b27ec25adef34771839f14cc00dc7d42_Out_2, _Combine_1f1fa337ce814cb6a47fedf2f5465177_RG_6, _Combine_9bf1add72c0f41b6a74deaf83ae59554_RG_6, _Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3);
            float _Absolute_04ac7196005743fabaef7db010d6859d_Out_1;
            Unity_Absolute_float(_Remap_d8bfdf4b287c4d8cab66bb0e31a2e699_Out_3, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1);
            float _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3;
            Unity_Smoothstep_float(_Property_7ccb3e82e0e040f2b247ba6d36c02013_Out_0, _Property_272191ca48b042d7a62c0af4f1f5997d_Out_0, _Absolute_04ac7196005743fabaef7db010d6859d_Out_1, _Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3);
            float _Property_9613f60e147b4f35a44b3404d476ad82_Out_0 = _BaseNoiseSpeed;
            float _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2;
            Unity_Multiply_float_float(_Property_9613f60e147b4f35a44b3404d476ad82_Out_0, IN.TimeParameters.x, _Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2);
            float2 _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2d9403765281418ab466fca418bdd55e_Out_3.xy), float2 (1, 1), (_Multiply_36dbc92388e64b1bb8aaeb9941152346_Out_2.xx), _TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3);
            float _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0 = _BaseNoiseScale;
            float _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5ae9bb0edc2f41beaf8ee80c2e35611b_Out_3, _Property_2f09afd6347343d6bd36cf8eae02e81a_Out_0, _GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2);
            float _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0 = _BaseNoiseStrength;
            float _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2;
            Unity_Multiply_float_float(_GradientNoise_80c8160b0ac440559a4c568e32be6860_Out_2, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2);
            float _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2;
            Unity_Add_float(_Smoothstep_764297d670884474b0545ccd0bdc3f9b_Out_3, _Multiply_445fe3ad91734d7195db39c5e598bf86_Out_2, _Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2);
            float _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2;
            Unity_Add_float(1, _Property_9617453fd9ce4b18b572afa7693c0d87_Out_0, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2);
            float _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2;
            Unity_Divide_float(_Add_7679a6e860c24f4fa63a29aa97e2ab76_Out_2, _Add_0592f9c5bb874567813e42cd88ea5df8_Out_2, _Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2);
            float4 _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3;
            Unity_Lerp_float4(_Property_c4532ee74f5446dd9c61c6d5f1312958_Out_0, _Property_6b871cb3d16f4f92a9da14b48052f3b3_Out_0, (_Divide_1777b209effe4c9c930d571b3c4fabfa_Out_2.xxxx), _Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3);
            float _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1);
            float4 _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0 = IN.ScreenPosition;
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_R_1 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[0];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_G_2 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[1];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_B_3 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[2];
            float _Split_a81f5d00cd534c4c89ea8b83aba58945_A_4 = _ScreenPosition_7db2be51eed04aae9c54cb7054d17e97_Out_0[3];
            float _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2;
            Unity_Subtract_float(_Split_a81f5d00cd534c4c89ea8b83aba58945_A_4, 1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2);
            float _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2;
            Unity_Subtract_float(_SceneDepth_9052994f32ac48e6bdbe3e200eb27cb0_Out_1, _Subtract_1d57d48e3b2849bdb5f81a6b1498795f_Out_2, _Subtract_1265614a854446fa979a49e4f1e4757f_Out_2);
            float _Property_c0570f4398b145c7b1e806dbdf700686_Out_0 = _TransparentRange;
            float _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2;
            Unity_Divide_float(_Subtract_1265614a854446fa979a49e4f1e4757f_Out_2, _Property_c0570f4398b145c7b1e806dbdf700686_Out_0, _Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2);
            float _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            Unity_Saturate_float(_Divide_722d3ee6e8564329b88bd4461e3a8ada_Out_2, _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1);
            surface.BaseColor = (_Lerp_45fdb7d952ae4c9484c68e145beb7caa_Out_3.xyz);
            surface.Alpha = _Saturate_56dbc48365bb448091148ea6b68f175a_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}