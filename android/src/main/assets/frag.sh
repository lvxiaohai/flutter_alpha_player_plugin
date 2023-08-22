#extension GL_OES_EGL_image_external : require
precision mediump float;
uniform samplerExternalOES sTexture;
varying highp vec2 topTexCoord;
varying highp vec2 bottomTexCoord;

void main() {
    vec4 color = texture2D(sTexture, topTexCoord);
    vec4 alpha = texture2D(sTexture, vec2(bottomTexCoord.x, bottomTexCoord.y));
    gl_FragColor = vec4(color.rgb, alpha.r);
}