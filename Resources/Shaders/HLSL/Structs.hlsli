
#define ROOT_SIG \
    "CBV(b0), \
     RootConstants(b1, num32BitConstants = 2), \
     DescriptorTable( CBV(b2, numDescriptors = 8), \
                      SRV(t0, numDescriptors = 32)), \
     SRV(t32)"

struct VertexFactory
{
	float3 position : POSITION;
	float3 normal : NORMAL;
	float3 tangent : TANGENT;
	float2 uv : TEXCOORD;
};

struct VertexOutput
{
	/// Vertex world position
	float3 worldPosition : POSITION;
	/// Shader view position
	float4 svPosition : SV_POSITION;
	/// Camera view position.
	float3 viewPosition : VIEW_POSITION;

	/// TBN (tangent, bitangent, normal) transformation matrix.
	float3x3 TBN : TBN;

	/// Vertex UV
	float2 uv : TEXCOORD;
};
