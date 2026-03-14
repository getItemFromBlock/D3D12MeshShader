#include "CubeData.hlsli"

struct Camera
{
	float4x4 view;
	float4x4 invViewProj;
};
cbuffer CameraBuffer : register(b0)
{
	Camera camera;
};

struct Object
{
	float4x4 transform;
	uint level;
};
cbuffer ObjectBuffer : register(b1)
{
	Object object;
};

// Mesh Shader

VertexOutput GetVertexAttributes(uint vertexIndex)
{
    VertexInput v = GetCubeVertice(vertexIndex);
	VertexOutput output;

	//---------- Position ----------
	const float4 worldPosition4 = mul(object.transform, float4(v.positionU.xyz, 1.0));
	output.worldPosition = worldPosition4.xyz / worldPosition4.w;
	output.svPosition = mul(camera.invViewProj, worldPosition4);
	output.viewPosition = float3(camera.view._14, camera.view._24, camera.view._34);


	//---------- Normal ----------
	const float3 normal = normalize(mul((float3x3)object.transform, v.normalV.xyz));
	const float3 tangent = normalize(mul((float3x3)object.transform, v.tangent.xyz));
	const float3 bitangent = cross(normal, tangent);

	/// HLSL uses row-major constructor: transpose to get TBN matrix.
	output.TBN = transpose(float3x3(tangent, bitangent, normal));


	//---------- UV ----------
	output.uv = float2(v.positionU.w, v.normalV.w);

	return output;
	
}

#define MAX_VERTS 24
#define MAX_PRIMS 12

groupshared uint indices[MAX_VERTS];

[NumThreads(NUM_THREADS, 1, 1)]
[OutputTopology("triangle")]
void main(
    uint tid : SV_DispatchThreadID,
    uint tig : SV_GroupIndex,
    out vertices VertexOutput verts[MAX_VERTS],
    out indices uint3 tris[MAX_PRIMS])
{

	uint numVerticesInThreadGroup = MAX_VERTS;
    uint numPrimitivesInThreadGroup = MAX_PRIMS;

	
	SetMeshOutputCounts(numVerticesInThreadGroup, numPrimitivesInThreadGroup);
	
	
    if (tig < numVerticesInThreadGroup)
    {
        verts[tig] = GetVertexAttributes(tig);
    }

    if (tig < numPrimitivesInThreadGroup)
    {
        tris[tig] = GetIndices(tig);
    }
}
