uniform mat4 ortho;

attribute vec3 position;
attribute vec2 texCoord;

varying vec2 texCoordVar;

void main() { 
    gl_Position = ortho * vec4(position,1.0);
    texCoordVar = texCoord;
}