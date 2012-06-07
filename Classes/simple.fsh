uniform sampler2D yTex,uTex,vTex;
varying lowp vec2 texCoordVar;
///vec2(gl_FragCoord.x/880.0,gl_FragCoord.y/360.0)
void main() { 
    lowp float y,u,v;
    lowp float r,g,b;
    
    lowp vec2 flipTexCoord;
    
    flipTexCoord = vec2(texCoordVar.s, 1.0 - texCoordVar.t);
    
    y = texture2D(yTex,flipTexCoord).r;
    u = texture2D(uTex,flipTexCoord).r;
    v = texture2D(vTex,flipTexCoord).r;
    
    y=1.1643*(y-0.0625);
    u=u-0.5;
    v=v-0.5;
    
    r=y+1.5958*v;
    g=y-0.39173*u-0.81290*v;
    b=y+2.017*u;
    
    gl_FragColor = vec4(r,g,b,1.0); //vec4(1.0,0.0,0.0,1.0);
}