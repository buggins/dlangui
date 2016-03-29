uniform sampler2D tex;
in vec4 col;
in vec4 texc;
out vec4 outColor;
void main(void)
{
    outColor = texture(tex, texc.st) * col;
}
