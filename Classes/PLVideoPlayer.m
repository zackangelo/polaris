//
//  PLVideoPlayer.m
//  Polaris
//
//  Created by Zachary Angelo on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PLVideoPlayer.h"
#import "PLFrame.h"

void BufProviderReleaseData(void *info,const void *buf,size_t sz) { 
//    free(buf);
}

@implementation PLVideoPlayer

@synthesize centerVideo = _centerVideo;

- (BOOL) isRetina { 
    CGFloat scale = [[UIScreen mainScreen] scale];
   
    if(scale > 1.9) { 
        return YES;
    } else { 
        return NO;
    }
}

- (void) setupLayer { 
    if([self isRetina]) { 
        NSLog(@"Retina display detected.");
    } else { 
        NSLog(@"Non-retina display detected.");
    }
    
    self.contentScaleFactor = ([self isRetina] ? 2.0 : 1.0);
    _glLayer = (CAEAGLLayer*) self.layer;
    _glLayer.opaque = YES;
    _glLayer.contentsScale = ([self isRetina] ? 2.0 : 1.0);
}

- (void) setupContext { 
    _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if(!_glContext) { 
        NSLog(@"Unable to allocate GL context.");
    }
    
    if(![EAGLContext setCurrentContext:_glContext]) { 
        NSLog(@"Unable to set current GL context.");
    }
    
}

- (void) setupGlBuffers { 
    glBindRenderbuffer(GL_RENDERBUFFER, _glColorBuffer);
    
    if(![_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_glLayer]) { 
        NSLog(@"Render buffer allocation failed.");
    }
    
//    moved to init
//    glGenFramebuffers(1, &_glFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _glFrameBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _glColorBuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_frameBufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_frameBufferHeight);
}


//From http://www.raywenderlich.com/3664/opengl-es-2-0-for-iphone-tutorial
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    NSString *shaderExt;
    
    if(shaderType == GL_VERTEX_SHADER) { 
        shaderExt = @"vsh";
    } else if (shaderType == GL_FRAGMENT_SHADER) { 
        shaderExt = @"fsh";
    } else { 
        NSLog(@"Shader type not recognized.");
        return 0;
    }
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName 
                                                           ofType:shaderExt];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath 
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        return 0;
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);    
    
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];    
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        return 0;
    }
    
    return shaderHandle;
    
}

- (void) setupShaders { 
    GLuint vertexShader = [self compileShader:@"simple" withType:GL_VERTEX_SHADER];
    GLuint fragShader = [self compileShader:@"simple" withType:GL_FRAGMENT_SHADER];
    
    GLuint program = glCreateProgram();
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragShader);
    
    glLinkProgram(program);
    
    
    GLint linkSuccess; 
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    
    if(linkSuccess == GL_FALSE) { 
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
    }

    glUseProgram(program);
    
    _glPositionAttrib = glGetAttribLocation(program, "position");
    glEnableVertexAttribArray(_glPositionAttrib);
    
    _glTexCoordAttrib = glGetAttribLocation(program, "texCoord");
    glEnableVertexAttribArray(_glTexCoordAttrib);
    
    _glOrthoUniform = glGetUniformLocation(program, "ortho");
    
//    _glFrameTexUniform = glGetUniformLocation(program, "frameTex");
 
    _glYTexUniform = glGetUniformLocation(program, "yTex");
    _glUTexUniform = glGetUniformLocation(program, "uTex");
    _glVTexUniform = glGetUniformLocation(program, "vTex");
}

- (void) setupViewport { 
//    CGRect bounds = [self bounds];

//    NSLog(@"Viewport dimensions: %f x %f",self.bounds.size.width, self.bounds.size.height);
    NSLog(@"Viewport dimensions: %i x %i",_frameBufferWidth, _frameBufferHeight);
    
    glViewport(0, 0, _frameBufferWidth, _frameBufferHeight);
}

//generates and stores a matrix so that the origin is upper left and vertices are in screen space
- (void) setupOrthoMatrix { 
//    CGRect screenBounds = [self bounds];
//    CGFloat screenScale = [[UIScreen mainScreen] scale];
    
    GLfloat screenWidth = _frameBufferWidth;// * screenScale;
    GLfloat screenHeight = _frameBufferHeight;// * screenScale;
        
    GLfloat xScale = 1.0; // 2.0 / screenWidth;//0.35;//
    GLfloat yScale = 1.0; //-2.0 / screenHeight;
    GLfloat orthoMatrix[] = { 
        xScale * (2.0f / screenWidth),     0.0f,                               0.0f,          0.0f,
        0.0f,                             yScale * (-2.0f/screenHeight),       0.0f,          0.0f,
        0.0f,                             0.0f,                               0.0f,          0.0f,
        -1.0f,                             1.0f,                               0.0f,          1.0f
    };
    
    glUniformMatrix4fv(_glOrthoUniform, 1, GL_FALSE, orthoMatrix);
}

- (void) layoutSubviews { 
    [super layoutSubviews];
    
    NSLog(@"Layout subviews called. (%f x %f)",self.frame.size.width,self.frame.size.height);
    
    //if there's an existing color buffer, destroy it first
    if(_glColorBuffer) { 
        [_glContext renderbufferStorage:_glColorBuffer fromDrawable:nil];   //detach
        glDeleteBuffers(1, &_glColorBuffer);
    }

    if(_glFrameBuffer) { 
        glDeleteFramebuffers(1, &_glFrameBuffer);
    }

    [self setupLayer];

    [self setupGlBuffers];
    [self setupViewport];
}

- (void) setupTextures { 
    glGenTextures(1, &_glYTex);
    glBindTexture(GL_TEXTURE_2D, _glYTex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glGenTextures(1, &_glUTex);
    glBindTexture(GL_TEXTURE_2D, _glUTex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glGenTextures(1, &_glVTex);
    glBindTexture(GL_TEXTURE_2D, _glVTex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (void) setupGeometryForFrameSize:(CGSize)videoSize  { 
    CGSize adjSize = CGSizeMake(_frameBufferWidth, (_frameBufferWidth*videoSize.height)/videoSize.width);

    GLfloat yOfs;
    
    if(_centerVideo) { 
        yOfs = (_frameBufferHeight - adjSize.height) / 2;
    } else { 
        yOfs = 0;
    }
    
    if(yOfs < 0.0f) yOfs = 0.0;
    
    GLfloat vertexData[] = { //2 triangles, single quad
        0.0, yOfs, 0.0,
        adjSize.width, yOfs, 0.0,
        0.0, yOfs + adjSize.height, 0.0,
        
        adjSize.width, yOfs, 0.0,
        0.0, yOfs + adjSize.height, 0.0,
        adjSize.width, yOfs + adjSize.height, 0.0
    };
    
    GLfloat texCoordData[] = { 
        0.0, 1.0,
        1.0, 1.0,
        0.0, 0.0,
        
        1.0, 1.0,
        0.0, 0.0,
        1.0, 0.0
    };
    
    glGenBuffers(1, &_glVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _glVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_glTexCoordBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _glTexCoordBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(texCoordData), texCoordData, GL_STATIC_DRAW);
}

- (void) setupView {
    _decoder = [[PLVideoDecoder alloc] init];
    
    _decoder.delegate = self;
    
    // OpenGL setup
    [self setupLayer];
    [self setupContext];
    //        [self setupColorBuffer];
    //        [self setupFrameBuffer];
    
    glGenRenderbuffers(1, &_glColorBuffer);
    glGenFramebuffers(1, &_glFrameBuffer);
    
    [self setupGlBuffers];
    
    [self setupShaders];
    [self setupTextures];
    
    [self setupViewport];
    
//    [_decoder playVideoAtUrl:@"rtsp://video.vbar.com:1935/rtp-live/vb10k-vm2.stream"];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"hungergames" ofType:@"mov"];
//    [_decoder playVideoAtUrl:path];
    
    _framesLastSecond = 0;
    
    self.clearsContextBeforeDrawing = NO;
    
//    UILabel *_bufferingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, 200, 20)];
//    _bufferingLabel.text = @"Buffering";
//    _bufferingLabel.textColor = [UIColor whiteColor];
//    _bufferingLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//    _bufferingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self addSubview:_bufferingLabel];

    _statusOverlay = [[PLStatusOverlayView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//    [self addSubview:_statusOverlay];
    
    self.autoresizesSubviews = YES;
    
    self.centerVideo = NO;
    
//    _frameCounter = 0;
    
    
}
- (id)initWithCoder:(NSCoder *)aDecoder { 
    self = [super initWithCoder:aDecoder];
    
    if(self) { 
        [self setupView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void) renderFrame { 
    double currentTime = CACurrentMediaTime();
    if(_framesLastSecond == 0) { 
        _frameCountStartTime = currentTime;
    }
    
    if(!_decoder) { 
        //if we don't have an active decoder reference, bail out
        return;
    }
    
    PLFrame *nextFrame = [_decoder nextFrame];
    
    if(nextFrame) { 
        if(_currentFrame) [_currentFrame destroy];  //recycles image buffer back into the pool
        _currentFrame = nextFrame;
        
//        if(++_frameCounter == (15*5)) { 
//            _nextUrl = @"rtsp://video.vbar.com:1935/rtp-live/vb10k-vm1.stream";
//            [_decoder stop];
//        }
        
        glBindTexture(GL_TEXTURE_2D, _glYTex);
//        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, _currentFrame.width, _currentFrame.height, GL_LUMINANCE, GL_UNSIGNED_BYTE, _currentFrame.yImageData);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, _currentFrame.width, _currentFrame.height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, _currentFrame.yImageData);
        
        glBindTexture(GL_TEXTURE_2D, _glUTex);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, _currentFrame.width/2, _currentFrame.height/2, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, _currentFrame.uImageData);
        
        glBindTexture(GL_TEXTURE_2D, _glVTex);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, _currentFrame.width/2, _currentFrame.height/2, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, _currentFrame.vImageData);

    } 
    
    glClearColor(0, 0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if(_currentFrame && _glTexCoordBuffer && _glVertexBuffer) { 
        [self setupOrthoMatrix];
        
        glBindBuffer(GL_ARRAY_BUFFER, _glVertexBuffer);
        glVertexAttribPointer(_glPositionAttrib, 3, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glBindBuffer(GL_ARRAY_BUFFER, _glTexCoordBuffer);
        glVertexAttribPointer(_glTexCoordAttrib, 2, GL_FLOAT, GL_FALSE, 0, NULL);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _glYTex);
        glUniform1i(_glYTexUniform,0);
        
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, _glUTex);
        glUniform1i(_glUTexUniform, 1);
        
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, _glVTex);
        glUniform1i(_glVTexUniform, 2);
        
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
    
    [_glContext presentRenderbuffer:GL_RENDERBUFFER];
    
    _framesLastSecond++;
    
    if(currentTime - _frameCountStartTime > 1.0) { 
//        NSLog(@"FPS: %i",_framesLastSecond);
        _framesLastSecond = 0;
    }
}

+ (Class) layerClass { 
    return [CAEAGLLayer class];
}

- (void) playVideoAtUrl:(NSString *)videoUrl { 
    if([_decoder isDecoding]) { 
        _nextUrl = videoUrl;
        [_decoder stop];
    } else {
        [_decoder playVideoAtUrl:videoUrl];
    }
}

- (void) stop { 
    [_decoder stop];
}

#pragma mark - Video Decoder Delegate

- (void) videoDecoder:(PLVideoDecoder *)aDecoder didChangeWidth:(int)width height:(int)height { 
    NSLog(@"Stream dimensions changed to %i x %i",width,height);   
    [self setupGeometryForFrameSize:CGSizeMake(width,height)];
}

- (void) videoDecoderDidStartPlaying:(PLVideoDecoder *)aDecoder { 
    if(!_displayLink) { 
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(renderFrame)];
//        _displayLink.frameInterval = 2;
        
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        NSLog(@"Video started playing, display link created.");
    } else { 
        NSLog(@"Did not create new display link because one already existed.");
    }
}

- (void) videoDecoderDidStop:(PLVideoDecoder *)aDecoder { 
    [_displayLink invalidate];
    _displayLink = nil;
    
    if(_nextUrl) { 
        [_decoder playVideoAtUrl:_nextUrl];
        _nextUrl = nil;
    }
}


@end
