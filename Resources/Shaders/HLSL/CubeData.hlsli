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

static const uint2 _cubeUVSwizzlesValues[] =
{
    uint2(1, 2),
    uint2(2, 0),
    uint2(0, 1),
    uint2(2, 1),
    uint2(0, 2),
    uint2(1, 0)
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

// Cube bitmask data, packed in a 32 bit integer
// bit 0..5 has the xyz position, bit 8..13 is a bitmask of
// the -+xyz culling for each cube and bit 16..21 is a
// bitmask of the -+xyz culling for each cube relative to the
// edge of the "main" cube
static const uint _cubeData[] =
{
    0x00073800u,
    0x00060901u,
    0x000E3102u,
    0x00032410u,
    0x000A2412u,
    0x00231C20u,
    0x00220921u,
    0x002A1522u,
    
    0x00051204u,
    0x000C1206u,
    0x00211224u,
    0x00281226u,
    
    0x00152A08u,
    0x00140909u,
    0x001C230Au,
    0x00112418u,
    0x0018241Au,
    0x00310E28u,
    0x00300929u,
    0x0038072Au,
};

static const uint _countTable[] =
{
    1, 1,
    20, 1,
    20, 20,
    400, 20,
    400, 400,
    8000, 400,
    8000, 8000
};
/*
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
*/
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

VertexInput GetCubeVertice(int id, float3 offset, float scale)
{
    VertexInput res;
    
    int t1 = id >> 2;
    int t2 = id & 0x03;
    
    float3 pos = float3(float(id & 0x01), float((id >> 1) & 0x01), t1 < 3 ? -1.f : 1.f);
    pos.x = pos.x * 2 - 1;
    pos.y = pos.y * 2 - 1;
    const uint3 swz0 = _cubeSwizzlesValues[t1];
    pos = float3(pos[swz0[0]], pos[swz0[1]], pos[swz0[2]]);
    pos = pos * scale + offset;
    const uint2 swz1 = _cubeUVSwizzlesValues[t1];
    
    res.positionU = float4(pos, (pos[swz1[0]] + 1) / 2);
    res.normalV = float4(0, 0, 0, (pos[swz1[1]] + 1) / 2);
    res.normalV[t1 % 3] = t1 < 3 ? -1.f : 1.f;
    res.tangent = float4(0, 0, 0, 0);
    res.tangent[(t1 + 2) % 3] = t1 < 3 ? -1.f : 1.f;
    return res;
}

float3 GetCubePosition(uint pos)
{
    uint mask = _cubeData[pos];

    return float3(mask & 0x03, (mask >> 2) & 0x03, (mask >> 4) & 0x03);
}

uint GetCubeFaceCull(uint pos)
{
    return (_cubeData[pos] >> 8) & 0x3F;
}

uint GetCubeFaceKeep(uint pos)
{
    return (_cubeData[pos] >> 16) & 0x3F;
}

uint3 GetDimensions(uint level)
{
    level = min(level, 6);
    return uint3(_countTable[level * 2], _countTable[level * 2 + 1], 1);

}
