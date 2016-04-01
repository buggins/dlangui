in vec4 vertex;
in vec4 colAttr;
out vec4 col;
uniform mat4 matrix;
void main(void)
{
    gl_Position = matrix * vertex;
    col = colAttr;
}
