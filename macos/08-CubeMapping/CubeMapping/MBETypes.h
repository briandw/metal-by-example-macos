@import simd;

typedef struct
{
    matrix_float4x4 modelMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 normalMatrix;
    matrix_float4x4 modelViewProjectionMatrix;
    vector_float4 worldCameraPosition;
    uint32 padding[60];
} MBEUniforms;

typedef struct
{
    vector_float4 position;
    vector_float4 normal;
} MBEVertex;
