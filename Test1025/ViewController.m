//
//  ViewController.m
//  Test1025
//
//  Created by Teddy Matinde
//
//  Simple class testing memory usage when graphics layer uses are dynamic rendering
//  mode.  Instrumentation is used to monitor memory.
//
//
#include <stdlib.h>
#import "ViewController.h"

@interface ViewController ()
@property(nonatomic, strong) AGSGeometryEngine* geometryEngine;
@property(nonatomic) double minX;
@property(nonatomic) double width;
@property(nonatomic) double numberOfPolygons;
@property(nonatomic) double maxX;
@property(nonatomic) double yMax;
@property(nonatomic) double yMin;
@property(nonatomic) float sleepInterval;
@property(nonatomic) int maxIterations;

-(NSArray*) generatePolyonsStartingAtX:(double) x
                                     y:(double) y
                                 width:(double) w
                                height:(double) h
                      numberOfPolygons:(int) polygonNumber
                      spatialReference:(AGSSpatialReference*) spatRef;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.minX = -117.2161213;
    self.width = 0.000001;
    self.numberOfPolygons = 10000;
    self.maxX = -117.2000016;
    self.yMax = 34.0485989;
    self.yMin = 34.0481812;
    self.sleepInterval = -1;
    self.maxIterations = 1000000000;
    
    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:-180.0 ymin:-90 xmax:180 ymax:90 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:102100] ];
    self.graphicsLayer = [[AGSGraphicsLayer alloc] initWithFullEnvelope:env
                                                          renderingMode:AGSGraphicsLayerRenderingModeDynamic];
    self.geometryEngine = [[AGSGeometryEngine alloc] init];
    AGSTiledMapServiceLayer *mapServiceLayer = [[AGSTiledMapServiceLayer alloc] initWithURL: [NSURL URLWithString:@"https://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer"]];
    [self.mapView addMapLayer:mapServiceLayer withName:@"myServiceLayer"];
    [self.mapView addMapLayer:self.graphicsLayer withName:@"myGraphicsLayer"];
    self.graphicsLayer.renderer = [self createPolygonRenderer:@"magicNumber"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self runGraphicsTest];
    });
}

//Generates a block of graphics.  Then continues by adding a graphic and erasing the oldest gexisting graphic from the
//graphics layer
- (void) runGraphicsTest {
    
    double movingStartX = self.minX;
    AGSSpatialReference* spt4326 = [AGSSpatialReference spatialReferenceWithWKID:4326];
    AGSSpatialReference* spt102100 = [AGSSpatialReference spatialReferenceWithWKID:102100];
    
    AGSEnvelope *env = [[AGSEnvelope alloc] initWithXmin:self.minX ymin:self.yMin xmax:self.maxX ymax:self.yMax
                                        spatialReference:spt4326];
    
    AGSEnvelope *newEnv = (AGSEnvelope*)[self.geometryEngine projectGeometry:env toSpatialReference:spt102100];
    [self.mapView zoomToEnvelope:newEnv animated:TRUE];
    
    NSArray *geometries = nil;
    for(int i = 0; i < self.maxIterations; i++) {
        @autoreleasepool {
            geometries = [self generatePolyonsStartingAtX:movingStartX y:self.yMin width:self.width height:fabs(self.yMax - self.yMin) numberOfPolygons:self.numberOfPolygons spatialReference: spt4326];
            for(int j = 0; j < [geometries count]; j++) {
                @autoreleasepool {
                    
                    AGSGeometry *geometry = geometries[j];
                    int magicNumber = arc4random()%49;
                    AGSGeometry *processedGeometry = [self.geometryEngine projectGeometry:geometry toSpatialReference:spt102100];
                    NSDictionary *attributes = @{
                                                 @"anObject" : @"",
                                                 @"helloString" : @"Hello, World!",
                                                 @"magicNumber" : [[NSNumber alloc] initWithInt:magicNumber],
                                                 @"aValue" : @""
                                                 };
                    AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:processedGeometry symbol:nil attributes:attributes];
                    [self.graphicsLayer addGraphic:graphic];
                    if( i > 0) {
                        AGSGraphic *graphic = [[[self graphicsLayer] graphics] firstObject];
                        [[self graphicsLayer] removeGraphic:graphic];
                        graphic = nil;
                    }
                    
                    if(self.sleepInterval > 0) {
                        [NSThread sleepForTimeInterval:self.sleepInterval];
                    }
                }
                
            }
            movingStartX = movingStartX + self.width * self.numberOfPolygons;
            if(movingStartX > self.maxX) {
                movingStartX = self.minX;
            }
            NSLog(@"Starting new iteration %i out of %i",i, self.maxIterations);
            geometries = nil;
        }
        
    }
    
}

// Utility method to create cllass break
- (AGSClassBreak*) createPolygonRendererClassBreakWithMaxValue:(double) maxValue
                                                     fillColor:(UIColor *)fillColor
                                                  outlineColor:(UIColor *)outlineColor
{
    AGSSimpleFillSymbol *symbol = [[AGSSimpleFillSymbol alloc] initWithColor: fillColor outlineColor: outlineColor];
    AGSClassBreak *classBreak = [[AGSClassBreak alloc] init];
    classBreak.maxValue = maxValue;
    classBreak.symbol = symbol;
    symbol.outline.width = 0;
    return classBreak;
}

// Creates renderer to be used for symbolizing the polygons generated
- (AGSClassBreaksRenderer *) createPolygonRenderer: (NSString *)field {
    AGSClassBreaksRenderer *renderer = [[AGSClassBreaksRenderer alloc] init];
    
    NSMutableArray *classBreaks = [[NSMutableArray alloc] init];
    AGSClassBreak *classBreak = [self createPolygonRendererClassBreakWithMaxValue:0 fillColor:[UIColor purpleColor] outlineColor:[UIColor blackColor]];
    classBreaks[[classBreaks count]] = classBreak;
    classBreak = [self createPolygonRendererClassBreakWithMaxValue:20 fillColor:[UIColor redColor] outlineColor:[UIColor blackColor]];
    classBreaks[[classBreaks count]] = classBreak;
    classBreak = [self createPolygonRendererClassBreakWithMaxValue:30 fillColor:[UIColor blackColor] outlineColor:[UIColor blackColor]];
    classBreaks[[classBreaks count]] = classBreak;
    classBreak = [self createPolygonRendererClassBreakWithMaxValue:40 fillColor:[UIColor greenColor] outlineColor:[UIColor blackColor]];
    classBreaks[[classBreaks count]] = classBreak;
    classBreak = [self createPolygonRendererClassBreakWithMaxValue:50 fillColor:[UIColor yellowColor] outlineColor:[UIColor blackColor]];
    classBreaks[[classBreaks count]] = classBreak;
    renderer.classBreaks = [NSArray arrayWithArray: classBreaks];
    renderer.field = field;
    return renderer;
}

// Generates polygons that will be used for display. Returns array of AGSPolygons
-(NSMutableArray*) generatePolyonsStartingAtX:(double) x
                                            y:(double) y
                                        width:(double) w
                                       height:(double) h
                             numberOfPolygons:(int) polygonNumber
                             spatialReference:(AGSSpatialReference*) spatRef
{
    double displaceX = 0;
    NSMutableArray *polygons = [[NSMutableArray alloc] init];
    for(int i = 0; i < polygonNumber; i++) {
        displaceX = i * w;
        NSArray *ring1 =@[
                          @[[NSNumber numberWithDouble:x + displaceX], [NSNumber numberWithDouble:y]],
                          @[[NSNumber numberWithDouble:x + displaceX], [NSNumber numberWithDouble:(y+h)]],
                          @[[NSNumber numberWithDouble:(x+w + displaceX)], [NSNumber numberWithDouble:(y+h)]],
                          @[[NSNumber numberWithDouble:(x+w + displaceX)], [NSNumber numberWithDouble:y]],
                          @[[NSNumber numberWithDouble:x + displaceX], [NSNumber numberWithDouble:y]]
                          ];
        AGSMutablePolygon *polygon = [[AGSMutablePolygon alloc] initWithSpatialReference:spatRef];
        [polygon insertRingAtIndex:0];
        for (int j = 0; j < [ring1 count]; j++) {
            AGSPoint *point = [AGSPoint pointWithX:[ring1[j][0] doubleValue] y:[ring1[j][1] doubleValue] spatialReference:spatRef];
            [polygon insertPoint:point onRing:0 atIndex:j];
        }
        [polygons addObject: polygon];
        
        
    }
    return polygons;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Memory Warning!!!!!!!");
    // Dispose of any resources that can be recreated.
}



@end
