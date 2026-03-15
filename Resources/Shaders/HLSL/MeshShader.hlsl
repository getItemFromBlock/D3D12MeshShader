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

VertexOutput GetVertexAttributes(float3 offset, float scale, uint vertexIndex)
{
    VertexInput v = GetCubeVertice(vertexIndex);
	VertexOutput output;

	//---------- Position ----------
    float3 pos = v.positionU.xyz * scale + offset;
	const float4 worldPosition4 = mul(object.transform, float4(pos, 1.0));
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

[NumThreads(NUM_THREADS, 1, 1)]
[OutputTopology("triangle")]
void main(
    uint3 tid : SV_GroupID,
    uint3 tig : SV_GroupThreadID,
    out vertices VertexOutput verts[MAX_VERTS],
    out indices uint3 tris[MAX_PRIMS])
{

    uint numVerticesInThreadGroup = MAX_VERTS;
    uint numPrimitivesInThreadGroup = MAX_PRIMS;
    uint3 offset = uint3(0,0,0);
    uint scale = 1;
    
    uint3 dims = GetDimensions(object.level);
    uint uniqueID = tid.x + dims.x * (tid.y + dims.y * tid.z);
	
    for (uint i = 0; i < object.level; i++)
    {
        uint id = uniqueID % 20;
        uniqueID = uniqueID / 20;
		
        offset = offset * 3 + GetCubePosition(id);
        scale *= 3;
    }
	
    SetMeshOutputCounts(numVerticesInThreadGroup, numPrimitivesInThreadGroup);
	
    if (tig.x < numVerticesInThreadGroup)
    {
        float3 off = float3(offset) / scale;
        verts[tig.x] = GetVertexAttributes(off, 1 / (float(scale * 2)), tig.x);
    }

    if (tig.x < numPrimitivesInThreadGroup)
    {
        tris[tig.x] = GetIndices(tig.x);
    }
}
