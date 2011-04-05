//
//  Surface.mm
//  SpaceHauler
//
//  Created by Andy Sinesio on 6/25/10.
//  Copyright 2010 Precognitive Research, LLC. All rights reserved.
//

#import "Surface.h"
#import "triangulate.h"


@implementation PRFilledPolygon

@synthesize pointCount;
@synthesize points;

-(id) initWithSurfacePoints: (NSArray *) points andTexture: (CCTexture2D *) texture {

	if( (self=[super init])) {
		
		pointCount = [points count];
		 
		surfacePoints = (CGPoint *) malloc(sizeof(CGPoint) * pointCount);
		
		
		int i = 0;
		Vector2dVector *inputPointsForTriangulation = new Vector2dVector;
		for (NSValue *value in points) {
			surfacePoints[i] = [value CGPointValue];
			inputPointsForTriangulation->push_back( Vector2d(surfacePoints[i].x,surfacePoints[i].y));
			i++;
		}
		// Triangulate results
		Vector2dVector triangulatedPoints;
		CCLOG(@"Triangulating polygon...");
		Triangulate::Process(*inputPointsForTriangulation, triangulatedPoints);
		delete inputPointsForTriangulation;
		
		areaTrianglePointCount = triangulatedPoints.size();
		areaTrianglePoints = (CGPoint *) malloc(sizeof(CGPoint) * areaTrianglePointCount);
		textureCoordinates = (CGPoint *) malloc(sizeof(CGPoint) * areaTrianglePointCount);
		
		for (int j = 0; j < areaTrianglePointCount; j++) {
			areaTrianglePoints[j] = ccp(triangulatedPoints[j].GetX(), triangulatedPoints[j].GetY());
		}
		
		self.texture = [[CCTextureCache sharedTextureCache] addImage:@"rock.png"];
		 
	}
	
	return self;
}

-(void) calculateTextureCoordinates {
	for (int j = 0; j < areaTrianglePointCount; j++) {
		textureCoordinates[j] = ccpMult(areaTrianglePoints[j], 1.0f/texture.pixelsWide);
	}
}

-(void) draw {
	// we have a pointer to vertex points so enable client state
	glBindTexture(GL_TEXTURE_2D, self.texture.name);
	
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
	
	glVertexPointer(2, GL_FLOAT, 0, areaTrianglePoints);
	glTexCoordPointer(2, GL_FLOAT, 0, textureCoordinates);
	
	glDrawArrays(GL_TRIANGLES, 0, areaTrianglePointCount);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	
	//Restore texture matrix and switch back to modelview matrix
	glEnableClientState(GL_COLOR_ARRAY);
	
}

-(void) updateBlendFunc {
	// it's possible to have an untextured sprite
	if( !texture || ! [texture hasPremultipliedAlpha] ) {
		blendFunc.src = GL_SRC_ALPHA;
		blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
		//[self setOpacityModifyRGB:NO];
	} else {
		blendFunc.src = CC_BLEND_SRC;
		blendFunc.dst = CC_BLEND_DST;
		//[self setOpacityModifyRGB:YES];
	}
}

-(void) setBlendFunc:(ccBlendFunc)blendFuncIn {
	blendFunc = blendFuncIn;
}

-(ccBlendFunc) blendFunc {
	return blendFunc;
}

-(void) setTexture:(CCTexture2D*)texture2D {
	
	// accept texture==nil as argument
	NSAssert( !texture || [texture isKindOfClass:[CCTexture2D class]], @"setTexture expects a CCTexture2D. Invalid argument");
	
	[texture release];
	texture = [texture2D retain];
	ccTexParams texParams = { GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT };
	[texture setTexParameters: &texParams];
	
	[self updateBlendFunc];
	[self calculateTextureCoordinates];
}

-(CCTexture2D*) texture {
	return texture;
}
		 
-(CGPoint *) surfacePoints {
	return surfacePoints;
}


//generated block

- (void) generatedDeallocForSurface
{
	
}
//end generated block

-(void) dealloc {
	free(surfacePoints);
	//free(areaTrianglePoints);
	//free(textureCoordinates);
	[self generatedDeallocForSurface];
	//[texture release];
	[super dealloc];
}

@end
