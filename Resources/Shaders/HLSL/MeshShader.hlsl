#include "Structs.hlsli"

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

StructuredBuffer<VertexFactory>	Vertices : register(t0);
StructuredBuffer<uint>			PrimitiveIndices : register(t1);

// Mesh Shader

VertexOutput GetVertexAttributes(uint vertexIndex)
{
    VertexFactory v = Vertices[vertexIndex];
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

	uint numVerticesInThreadGroup;
    uint numPrimitivesInThreadGroup;
    uint packedConnectivityForThisLanesPrimitive;
    ReadTriangleListIndices(
        numVerticesInThreadGroup, // out
        numPrimitivesInThreadGroup, // out
        indices, // out
        packedConnectivityForThisLanesPrimitive, // out
        PrimitiveIndices, // SRV with the offline made IB
        tig, // Thread group index
        false); // 32 bit per index
	
	SetMeshOutputCounts(numVerticesInThreadGroup, numPrimitivesInThreadGroup);
	
	
    if (tig < numVerticesInThreadGroup)
    {
        verts[tig] = GetVertexAttributes(indices[tig]);
    }

    if (tig < numPrimitivesInThreadGroup)
    {
        tris[tig] = uint3(
            packedConnectivityForThisLanesPrimitive & 0xFF,
            (packedConnectivityForThisLanesPrimitive >> 8) & 0xFF,
            (packedConnectivityForThisLanesPrimitive >> 16) & 0xFF);
    }
}