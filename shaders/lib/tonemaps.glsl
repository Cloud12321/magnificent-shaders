vec3 jodieRoboTonemap(vec3 c){
    float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
    vec3 tc = c * inversesqrt( c * c + 1. );
    return mix(c * inversesqrt( l * l + 1. ), tc, tc);
}

float getL601(vec3 rgb) {
	return dot(rgb, vec3(0.2989, 0.5866, 0.1145));
}

float getL709(vec3 rgb) {
	return dot(rgb, vec3(0.2126, 0.7152, 0.0722));
}

vec3 BotWToneMap(vec3 color) {
	float Lumn = getL709(color);
	vec4 exptm = 1.0 - exp(-vec4(color, Lumn));
	vec3 cpre = exptm.w / Lumn * color;
	vec3 colorldr = mix(cpre, exptm.rgb, vec3(pow(exptm.w, 2.0)));//refine
	return colorldr;
}

vec3 ACESFilm(vec3 x)
{
    float a = 2.51f;
    float b = 0.52f;
    float c = 3.43f;
    float d = 0.59f;
    float e = 0.21f;
    return saturate((x*(a*x+b))/(x*(c*x+d)+e));
}

vec3 filmicToneMapping(vec3 color)
{
	color = max(vec3(0.), color - vec3(0.0001));
	color = (color * (6.2 * color + .5)) / (color * (6.2 * color + 1.7) + 0.06);
	return color;
}