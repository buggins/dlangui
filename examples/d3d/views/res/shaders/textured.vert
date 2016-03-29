in vec4 vertex;
in vec4 colAttr;
in vec4 texCoord;
out vec4 col;
out vec4 texc;
uniform mat4 matrix;
void main(void)
{
    gl_Position = matrix * vertex;
    col = colAttr;
    texc = texCoord;
}
