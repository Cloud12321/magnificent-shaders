const int noiseTextureResolution = 64;

struct waveParams {
	vec2 inverseScale;
	vec2 scaledTranslation;
	vec2 skew;
	float height;
	bool sharpen;
	float sharpenThreshold;
	float sharpenMin;
};

float almostIdentity(float x, float m, float n) {
	if (x > m) return x;
	float t = x / m;
	return (((2.0 * n - m) * t + (2.0 * m - 3.0 * n)) * t * t) + n;
}

float water_waveNoise(vec2 coord) {
	//return textureSmooth(noisetex, coord / 64.0).r; // slightly faster but has banding artifacts

	vec2 floored = floor(coord);
	vec4 samples = textureGather(noisetex, 0.015625 * floored); // textureGather is slightly offset (at least on nvidia) and this offset can change with driver versions, which is why i floor the coords
	vec4 weights = (coord - floored).xxyy * vec4(1,-1,1,-1) + vec4(0,1,0,1);
	weights *= weights * (-2.0 * weights + 3.0);
	return dot(samples, weights.yxxy * weights.zzww);
}
float water_calculateWave(vec2 pos, const waveParams params) {
	pos = params.inverseScale * pos + params.scaledTranslation * frameTimeCounter;
	pos = pos.yx * params.skew + pos;
	float wave = water_waveNoise(pos);
	if (params.sharpen)
		wave = 1.0 - almostIdentity(abs(wave * 2.0 - 1.0), params.sharpenThreshold, params.sharpenMin);
	return wave * params.height;
}

vec2 rotateNoMat(vec2 coord, float a, float b) {
    float ns = b * coord.y + a * coord.x;
    float nc = a * coord.y - b * coord.x;
    return vec2(ns, nc);
}

float water_calculateWaves(vec3 pos) {
	const waveParams[4] params = waveParams[4](
		waveParams(1.0 / vec2(2.50, 3.33), vec2(2.40, 0.43) / vec2(2.50, 3.33), vec2(0.2, 1.3), 0.250,  true, 0.16, 0.08),
		waveParams(1.0 / vec2(0.71, 1.11), vec2(0.91,-0.71) / vec2(0.71, 1.11), vec2(0.0,-1.2), 0.120, false, 0.16, 0.08),
		waveParams(1.0 / vec2(0.26, 0.40), vec2(0.62, 0.26) / vec2(0.26, 0.40), vec2(0.0, 1.0), 0.020, false, 0.16, 0.08),
		waveParams(1.0 / vec2(0.09, 0.20), vec2(0.22, 0.16) / vec2(0.09, 0.20), vec2(0.0, 0.3), 0.008, false, 0.16, 0.08)
	);

	float waves = 0.0;
	for (int i = 0; i < params.length(); i++) {
		waves += water_calculateWave(pos.xz, params[i]) - params[i].height;
	}

	return waves;
}

