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
    VertexInput v = GetCubeVertice(vertexIndex, offset, scale);
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
    float3 offset = float3(0,0,0);
    float scale = 1;
    
    uint3 dims = GetDimensions(object.level);
    uint uniqueID = tid.x + dims.x * (tid.y + dims.y * tid.z);
    uint faceCullMask = 0x00;
	
    for (uint i = 0; i < object.level; i++)
    {
        uint id = uniqueID % 20;
        uniqueID = uniqueID / 20;
        
        uint mask = GetCubeFaceKeep(id);
        faceCullMask = (GetCubeFaceCull(id) & (~mask)) | (mask & faceCullMask);
		
        scale /= 3;
        offset += GetCubePosition(id) * scale;
    }
    offset = offset * 2 - (1 - scale);
    
    uint off = 0;
    for (uint i = 0; i < 6; i++)
    {
        if ((faceCullMask >> i) & 0x01)
        {
            numPrimitivesInThreadGroup -= 2;
            //numVerticesInThreadGroup -= 4;
            if ((tig.x / 2) + off >= i)
                off++;
        }
    }
    
    SetMeshOutputCounts(numVerticesInThreadGroup, numPrimitivesInThreadGroup);
	
    if (tig.x < MAX_VERTS)
    {
        verts[tig.x] = GetVertexAttributes(offset, scale, tig.x);
    }

    if (tig.x < numPrimitivesInThreadGroup)
    {
        tris[tig.x] = GetIndices(tig.x + off * 2);
    }
}
