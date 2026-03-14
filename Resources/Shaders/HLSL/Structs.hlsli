// Shared structs

struct VertexInput
{
	float4 positionU;
	float4 normalV;
	float4 tangent;
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
