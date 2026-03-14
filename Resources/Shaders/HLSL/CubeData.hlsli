// Procedural Cube mesh generator

#include "Structs.hlsli"

static const uint3 _cubeSwizzlesValues[] =
{
    uint3(2, 0, 1),
    uint3(1, 2, 0),
    uint3(0, 1, 2),
    uint3(2, 1, 0),
    uint3(0, 2, 1),
    uint3(1, 0, 2)
};

static const uint3 _cubeIndices[] =
{
    uint3(0, 1, 2),
    uint3(2, 1, 3),
    uint3(4, 5, 6),
    uint3(6, 5, 7),
    uint3(8, 9, 10),
    uint3(10,9, 11),
    uint3(12,13,14),
    uint3(14,13,15),
    uint3(16,17,18),
    uint3(18,17,19),
    uint3(20,21,22),
    uint3(22,21,23)
};

static const VertexInput _cubeVertices[] =
{
    {float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0)},
    {float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0)},
    {float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0)},
    {float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0)},
    
    {float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0)},
    {float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0)},
    {float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0)},
    {float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0)},
    
    {float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0)},
    {float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0)},
    {float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0)},
    {float4(0, 0, 0, 0), float4(0, 0, 0, 0), float4(0, 0, 0, 0)}
};

uint3 _GetIndices(uint id)
{
    uint t1 = (id >> 1) << 2;
    
    if ((id & 0x01) == 0)
        return uint3(0, 1, 2) + t1;
    else
        return uint3(2, 1, 3) + t1;

}

uint3 GetIndices(uint id)
{
    return _cubeIndices[id];
}

VertexInput GetCubeVertice(int id)
{
    VertexInput res;
    
    int t1 = id >> 2;
    int t2 = id & 0x03;
    
    float3 pos = float3(float(id & 0x01), float((id >> 1) & 0x01), t1 < 3 ? -1.f : 1.f);
    pos.x = pos.x * 2 - 1;
    pos.y = pos.y * 2 - 1;
    const uint3 swz = _cubeSwizzlesValues[t1];
    pos = float3(pos[swz[0]], pos[swz[1]], pos[swz[2]]);

    res.positionU = float4(pos, float(id & 0x01));
    res.normalV = float4(0, 0, 0, float((id >> 1) & 0x01));
    res.normalV[t1 % 3] = t1 < 3 ? -1.f : 1.f;
    res.tangent = float4(0, 0, 0, 0);
    res.tangent[(t1 + 2) % 3] = t1 < 3 ? -1.f : 1.f;
    return res;
}
