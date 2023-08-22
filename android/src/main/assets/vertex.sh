uniform mat4 uMVPMatrix;
uniform mat4 uSTMatrix;

attribute vec4 aPosition;
attribute vec4 aTextureCoord;

varying highp vec2 topTexCoord;
varying highp vec2 bottomTexCoord;

void main() {
    gl_Position = uMVPMatrix * aPosition;
    bottomTexCoord = (uSTMatrix * aTextureCoord).xy;
    float midY = (uSTMatrix * vec4(0.0, 0.5, 0.0, 1.0)).y;
    topTexCoord = vec2(bottomTexCoord.x, bottomTexCoord.y - midY);
}