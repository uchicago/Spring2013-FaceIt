//
//  ViewController.m
//  FaceIt
//
//  Created by T. Andrew Binkowski on 5/8/13.
//
//  This example was derived from tutorial at
//  http://www.bobmccune.com/2012/03/22/ios-5-face-detection-with-core-image/

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

////////////////////////////////////////////////////////////////////////////////
@interface ViewController ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@end

////////////////////////////////////////////////////////////////////////////////
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _image = [UIImage imageNamed:@"obama.jpeg"];
    _imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.center = self.view.center;
    [self.view addSubview:self.imageView];
}

/*******************************************************************************
 * @method          viewDidAppear
 * @abstract
 * @description
 ******************************************************************************/
- (void)viewDidAppear:(BOOL)animated
{
    [self findFaces:self.imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Face Detection
/*******************************************************************************
 * @method          drawOnFaces:
 * @abstract
 * @description
 ******************************************************************************/
-(void)findFaces:(UIImageView *)imageView
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CIImage *image = [[CIImage alloc] initWithImage:imageView.image];
    
        NSString *accuracy = CIDetectorAccuracyHigh;
        NSDictionary *options = [NSDictionary dictionaryWithObject:accuracy forKey:CIDetectorAccuracy];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
        NSArray *features = [detector featuresInImage:image];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self drawImageAnnotatedWithFeatures:features];
        });
        
    });
}

/*******************************************************************************
 * @method          drawImageAnnotatedWithFeatures
 * @abstract
 * @description      
 ******************************************************************************/
- (void)drawImageAnnotatedWithFeatures:(NSArray *)features {
    
	UIImage *faceImage = self.image;
    UIGraphicsBeginImageContextWithOptions(faceImage.size, YES, 0);
    [faceImage drawInRect:self.imageView.bounds];
    
    // Get image context reference
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip Context
    CGContextTranslateCTM(context, 0, self.imageView.bounds.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if (scale > 1.0) {
        // Loaded 2x image, scale context to 50%
        CGContextScaleCTM(context, 0.5, 0.5);
    }
    
    for (CIFaceFeature *feature in features) {
        
        CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.5f);
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(context, 2.0f * scale);
        CGContextAddRect(context, feature.bounds);
        CGContextDrawPath(context, kCGPathFillStroke);
        
        // Set red feature color
        CGContextSetRGBFillColor(context, 1.0f, 0.0f, 0.0f, 0.4f);
        
        if (feature.hasLeftEyePosition) {
            [self drawFeatureInContext:context atPoint:feature.leftEyePosition];
        }
        
        if (feature.hasRightEyePosition) {
            [self drawFeatureInContext:context atPoint:feature.rightEyePosition];
        }
        
        if (feature.hasMouthPosition) {
            [self drawFeatureInContext:context atPoint:feature.mouthPosition];
        }
    }
    
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

/*******************************************************************************
 * @method          drawFeatureInContext
 * @abstract
 * @description      
 ******************************************************************************/
- (void)drawFeatureInContext:(CGContextRef)context atPoint:(CGPoint)featurePoint {
    CGFloat radius = 20.0f * [UIScreen mainScreen].scale;
    CGContextAddArc(context, featurePoint.x, featurePoint.y, radius, 0, M_PI * 2, 1);
    CGContextDrawPath(context, kCGPathFillStroke);
}


@end
