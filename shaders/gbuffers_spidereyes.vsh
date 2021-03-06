#version 400 compatibility

layout (location = 0) in vec4 inPosition;
layout (location = 2) in vec4 inNormal;
layout (location = 3) in vec4 inColor;
layout (location = 8) in vec4 inTexCoord;
layout (location = 9) in vec4 inLightmapCoord;
layout (location = 10) in vec4 mc_Entity;
layout (location = 12) in vec4 inTangent;

out vec2 textureCoordinate;
out vec2 lightmapCoordinate;

uniform mat4 gbufferProjection;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform float viewWidth, viewHeight;
uniform int frameCounter;

mat4 projectionInverse = mat4(0.0);
mat4 projection = mat4(0.0);

vec4 textureSmooth(sampler2D sampler, vec2 coord) {
	vec2 resolution = textureSize(sampler, 0);
	coord = coord * resolution + 0.5;
	vec2 floored = floor(coord);
	coord -= floored;
	coord *= coord * (-2.0 * coord + 3.0);
	coord += floored - 0.5;
	coord /= resolution;
	return texture2D(sampler, coord);
}

vec2 haltonSequence(vec2 i, vec2 b) {
	vec2 f = vec2(1.0), r = vec2(0.0);
	while (i.x > 0.0 || i.y > 0.0) {
		f /= b;
		r += f * mod(i, b);
		i  = floor(i / b);
	} return r;
}

vec2 taa_offset() {
	vec2 scale = 2.0 / vec2(viewWidth, viewHeight);

	return haltonSequence(vec2(frameCounter % 16), vec2(2.0, 3.0)) * scale + (-0.5 * scale);
}

void calculateGbufferMatrices() {
	projection = gl_ProjectionMatrix;
	projectionInverse = gl_ProjectionMatrixInverse;

	// Add per-frame offset for TAA
	vec2 offset = taa_offset();
	projection[2].xy += offset;
	projectionInverse[3].xy += offset * vec2(projectionInverse[0].x, projectionInverse[1].y);
}

vec4 projectVertex(vec3 position) {
		return vec4(projection[0].x, projection[1].y, projection[2].zw) * position.xyzz + projection[3] + vec4(projection[2].xy * position.z, 0.0, 0.0);
}

void main() {
	calculateGbufferMatrices();

	gl_Position.xyz = mat3(gl_ModelViewMatrix) * inPosition.xyz + gl_ModelViewMatrix[3].xyz;
	gl_Position = projectVertex(gl_Position.xyz);

    textureCoordinate = inTexCoord.st;
    lightmapCoordinate = inLightmapCoord.st / 240.0;
}