

//
//  VisionDefectSimulation.h
//  xScope
//
//  Created by Craig Hockenberry on 8/29/11.
//  Copyright 2011 The Iconfactory. All rights reserved.
//
typedef enum {
	VisionDefectPresbyopia,
	VisionDefectDeuteranomaly,
	VisionDefectProtanopia,
	VisionDefectDeuteranopia,
	VisionDefectProtanomaly,
	VisionDefectTritanomaly,
	VisionDefectTritanopia,
	VisionDefectType_COUNT,
	VisionDefectNone
} VisionDefectType;

extern const NSUInteger defaultVisionDefectDimension;

@interface VisionDefectSimulation : NSObject

+ (NSData *)dataForVisionDefect:(VisionDefectType)type withDimension:(NSUInteger)dimension;
+ (CIFilter *)filterForVisionDefect:(VisionDefectType)type withBackingScaleFactor:(CGFloat)backingScaleFactor;
+ (NSString *)nameForVisionDefect:(VisionDefectType)type;

@end



@implementation VisionDefectSimulation

typedef struct {
	float confusionPointU;
	float confusionPointV;
	float axisBeginningPointU;
	float axisBeginningPointV;
	float axisEndingPointU;
	float axisEndingPointV;
} ColorBlindness;

// Protanopia
ColorBlindness protan = {
	0.735,
	0.265,
	0.115807,
	0.073581,
	0.471899,
	0.527051
};

// Deuteranopia
ColorBlindness deutan = {
    1.14,
	-0.14,
	0.102776,
	0.102864,
	0.505845,
	0.493211
};

// Tritanopia
ColorBlindness tritan = {
	0.171,
	-0.003,
	0.045391,
	0.294976,
	0.665764,
	0.334011
};

float ColorBlindnessAxisSlope(ColorBlindness colorBlindness)
{
	float result = (colorBlindness.axisEndingPointV - colorBlindness.axisBeginningPointV) / (colorBlindness.axisEndingPointU - colorBlindness.axisBeginningPointU);
	
	return result;
}

float ColorBlindnessAxisYIntercept(ColorBlindness colorBlindness)
{
	float axisSlope = ColorBlindnessAxisSlope(colorBlindness);
	float result = colorBlindness.axisBeginningPointV - colorBlindness.axisBeginningPointU  * axisSlope;
	
	return result;
}

typedef struct {
	float r;
	float g;
	float b;
} ColorRGB;

typedef struct {
	float x;
	float y;
	float z;
} ColorXYZ;

typedef struct {
	float u;
	float v;
} ColorUV;


ColorXYZ RGBtoXYZ(ColorRGB color)
{
	ColorXYZ result;
	result.x = ( 0.430574 * color.r + 0.341550 * color.g + 0.178325 * color.b );
	result.y = ( 0.222015 * color.r + 0.706655 * color.g + 0.071330 * color.b );
	result.z = ( 0.020183 * color.r + 0.129553 * color.g + 0.939180 * color.b );
	
	return result;
}

ColorRGB XYZtoRGB(ColorXYZ color)
{
	ColorRGB result;
	
	result.r = (  3.063218 * color.x - 1.393325 * color.y - 0.475802 * color.z );
	result.g = ( -0.969243 * color.x + 1.875966 * color.y + 0.041555 * color.z );
	result.b = (  0.067871 * color.x - 0.228834 * color.y + 1.069251 * color.z );
	
	return result;
}

ColorUV XYZtoUV(ColorXYZ color)
{
	ColorUV result;
	
	float componentSum = color.x + color.y + color.z;
	if (componentSum == 0.0) {
		result.u = 0.0;
		result.v = 0.0;
	}
	else {
		result.u = color.x / componentSum;
		result.v = color.y / componentSum;
	}
	
	return result;
}

ColorXYZ UVtoXYZ(ColorUV color)
{
	ColorXYZ result;
	
	return result;
}

ColorRGB simulateColor(ColorBlindness colorBlindness, ColorRGB color)
{
	float gamma = 2.2;
	
	ColorRGB colorRGB;
	colorRGB.r = powf(color.r, gamma);
	colorRGB.g = powf(color.g, gamma);
	colorRGB.b = powf(color.b, gamma);
	
	ColorXYZ colorXYZ = RGBtoXYZ(colorRGB);
	
	ColorUV colorUV = XYZtoUV(colorXYZ);
	float confusionLineSlope;
	if (colorUV.u < colorBlindness.confusionPointU) {
		confusionLineSlope = (colorBlindness.confusionPointV - colorUV.v) / (colorBlindness.confusionPointU - colorUV.u);
	}
	else {
		confusionLineSlope = (colorUV.v - colorBlindness.confusionPointV) / (colorUV.u - colorBlindness.confusionPointU);
	}
	float confusionLineYIntercept = colorUV.v - colorUV.u * confusionLineSlope;
	
	ColorUV deltaUV;
	deltaUV.u = (ColorBlindnessAxisYIntercept(colorBlindness) - confusionLineYIntercept) / (confusionLineSlope - ColorBlindnessAxisSlope(colorBlindness));
	deltaUV.v = (confusionLineSlope * deltaUV.u) + confusionLineYIntercept;
	
	ColorXYZ simulatedXYZ;
	simulatedXYZ.x = deltaUV.u * colorXYZ.y / deltaUV.v;
	simulatedXYZ.y = colorXYZ.y;
	simulatedXYZ.z = (1.0 - (deltaUV.u + deltaUV.v)) * colorXYZ.y / deltaUV.v;
	ColorRGB simulatedRGB = XYZtoRGB(simulatedXYZ);
	
	ColorXYZ whitePoint;
	whitePoint.x = 0.312713;
	whitePoint.y = 0.329016;
	whitePoint.z = 0.358271;
	ColorXYZ neutral;
	neutral.x = whitePoint.x * colorXYZ.y / whitePoint.y;
	neutral.z = whitePoint.z * colorXYZ.y / whitePoint.y;
	
	ColorXYZ deltaXYZ;
	deltaXYZ.x = neutral.x - simulatedXYZ.x;
	deltaXYZ.y = 0.0;
	deltaXYZ.z = neutral.z - simulatedXYZ.z;
	ColorRGB deltaRGB = XYZtoRGB(deltaXYZ);
	
	ColorRGB adjustmentRGB;
	if (deltaRGB.r != 0.0) {
		if (simulatedRGB.r < 0.0) {
			adjustmentRGB.r = (0.0 - simulatedRGB.r) / deltaRGB.r;
		}
		else {
			adjustmentRGB.r = (1.0 - simulatedRGB.r) / deltaRGB.r;
		}
	}
	else {
		adjustmentRGB.r = 0.0;
	}
	if (deltaRGB.g != 0.0) {
		if (simulatedRGB.g < 0.0) {
			adjustmentRGB.g = (0.0 - simulatedRGB.g) / deltaRGB.g;
		}
		else {
			adjustmentRGB.g = (1.0 - simulatedRGB.g) / deltaRGB.g;
		}
	}
	else {
		adjustmentRGB.g = 0.0;
	}
	if (deltaRGB.b != 0.0) {
		if (simulatedRGB.b < 0.0) {
			adjustmentRGB.b = (0.0 - simulatedRGB.b) / deltaRGB.b;
		}
		else {
			adjustmentRGB.b = (1.0 - simulatedRGB.b) / deltaRGB.b;
		}
	}
	else {
		adjustmentRGB.b = 0.0;
	}
	
	float adjust = 0.0;
	if (adjustmentRGB.r > 1.0 || adjustmentRGB.r < 0.0) {
		// leave adjust alone
	}
	else {
		if (adjustmentRGB.r > adjust) {
			adjust = adjustmentRGB.r;
		}
	}
	if (adjustmentRGB.g > 1.0 || adjustmentRGB.g < 0.0) {
		// leave adjust alone
	}
	else {
		if (adjustmentRGB.g > adjust) {
			adjust = adjustmentRGB.g;
		}
	}
	if (adjustmentRGB.b > 1.0 || adjustmentRGB.b < 0.0) {
		// leave adjust alone
	}
	else {
		if (adjustmentRGB.b > adjust) {
			adjust = adjustmentRGB.b;
		}
	}
	simulatedRGB.r = simulatedRGB.r + (adjust * deltaRGB.r);
	simulatedRGB.g = simulatedRGB.g + (adjust * deltaRGB.g);
	simulatedRGB.b = simulatedRGB.b + (adjust * deltaRGB.b);
	
	ColorRGB result;
	if (simulatedRGB.r <= 0.0) {
		result.r = 0.0;
	}
	else if (simulatedRGB.r >= 1.0) {
		result.r = 1.0;
	}
	else {
		result.r = powf(simulatedRGB.r, (1.0 / gamma));
	}
	if (simulatedRGB.g <= 0.0) {
		result.g = 0.0;
	}
	else if (simulatedRGB.g >= 1.0) {
		result.g = 1.0;
	}
	else {
		result.g = powf(simulatedRGB.g, (1.0 / gamma));
	}
	if (simulatedRGB.b <= 0.0) {
		result.b = 0.0;
	}
	else if (simulatedRGB.b >= 1.0) {
		result.b = 1.0;
	}
	else {
		result.b = powf(simulatedRGB.b, (1.0 / gamma));
	}
	
	return result;
}

double approximationMatrices[3][3][3] =
{
	// Protanopia
	{
		{0.202001295331, 0.991720719265, -0.193722014597},
		{0.163800203026, 0.792663865514, 0.0435359314602},
		{0.00913336570448, -0.0132684300993, 1.00413506439}
	},
	// Deuteranopia
	{
		{0.430749076295, 0.717402505462, -0.148151581757},
		{0.336582831043, 0.574447762213, 0.0889694067435},
		{-0.0236572929497, 0.0275635332006, 0.996093759749}
	},
	// Tritanopia
	{
		{0.971710712275, 0.112392320487, -0.0841030327623},
		{0.0219508442818, 0.817739672383, 0.160309483335},
		{-0.0628595877201, 0.880724870686, 0.182134717034}
	}
};

#pragma mark -

const NSUInteger defaultVisionDefectDimension = 32;

+ (NSData *)dataForVisionDefect:(VisionDefectType)type withDimension:(NSUInteger)dimension
{
	NSMutableData *result = nil;
	
    // specify size of resulting data
	NSUInteger count = dimension * dimension * dimension;
	NSUInteger items = count * 4;
    NSUInteger length = items * sizeof(float);
    result = [NSMutableData dataWithLength:length];
	if (result) {
		float *data = (float *)[result mutableBytes];
		if (data) {
			NSUInteger offset = 0;
			
			NSUInteger r, g, b;
			for (b = 0; b < dimension; b++) {
				for (g = 0; g < dimension; g++) {
					for (r = 0; r < dimension; r++) {
						ColorRGB color;
						color.r = (float)r / (float)(dimension - 1);
						color.g = (float)g / (float)(dimension - 1);
						color.b = (float)b / (float)(dimension - 1);
						
						float v = 1.75;
						float d = v + 1.0;
						
						ColorRGB simulatedColor;
						ColorRGB intermediateColor;
						switch (type) {
							default:
							case VisionDefectNone:
								// no vision defect
								simulatedColor = color;
								break;
							case VisionDefectProtanopia:
								// protanopia
								simulatedColor = simulateColor(protan, color);
								break;
							case VisionDefectDeuteranopia:
								// deuteranopia
								simulatedColor = simulateColor(deutan, color);
								break;
							case VisionDefectTritanopia:
								// tritanopia
								simulatedColor = simulateColor(tritan, color);
								break;
							case VisionDefectProtanomaly:
								// protanomaly
								intermediateColor = simulateColor(protan, color);
								simulatedColor.r = ((v * intermediateColor.r) + color.r) / d;
								simulatedColor.g = ((v * intermediateColor.g) + color.g) / d;
								simulatedColor.b = ((v * intermediateColor.b) + color.b) / d;
								break;
							case VisionDefectDeuteranomaly:
								// deuteranomaly
								intermediateColor = simulateColor(deutan, color);
								simulatedColor.r = ((v * intermediateColor.r) + color.r) / d;
								simulatedColor.g = ((v * intermediateColor.g) + color.g) / d;
								simulatedColor.b = ((v * intermediateColor.b) + color.b) / d;
								break;
							case VisionDefectTritanomaly:
								// tritanomaly
								intermediateColor = simulateColor(tritan, color);
								simulatedColor.r = ((v * intermediateColor.r) + color.r) / d;
								simulatedColor.g = ((v * intermediateColor.g) + color.g) / d;
								simulatedColor.b = ((v * intermediateColor.b) + color.b) / d;
								break;
						}
						
						data[offset] = simulatedColor.r;
						offset += 1;
						data[offset] = simulatedColor.g;
						offset += 1;
						data[offset] = simulatedColor.b;
						offset += 1;
						data[offset] = 1.0;
						offset += 1;
					}
				}
			}
		}
	}
	
	return [NSData dataWithData:result];
}

+ (CIFilter *)filterForVisionDefect:(VisionDefectType)type withBackingScaleFactor:(CGFloat)backingScaleFactor
{
	CIFilter *result = nil;
	
	if (type == VisionDefectPresbyopia) {
		result = [CIFilter filterWithName: @"CIGaussianBlur"];
		[result setValue:[NSNumber numberWithFloat:(backingScaleFactor * 0.75)] forKey:@"inputRadius"];
	}
	else {
		result = [CIFilter filterWithName: @"CIColorCube"];
		
		NSData *data = [self dataForVisionDefect:type withDimension:defaultVisionDefectDimension];
		[result setValue:data forKey:@"inputCubeData"];
		[result setValue:[NSNumber numberWithInt:defaultVisionDefectDimension] forKey:@"inputCubeDimension"];
	}
	
	return result;
}

+ (NSString *)nameForVisionDefect:(VisionDefectType)type
{
	NSString *result = nil;
	
	switch (type) {
		default:
		case VisionDefectNone: // normal vision
			result = @"Normal vision";
			break;
		case VisionDefectPresbyopia: // presbyopia
			result = @"Presbyopia (>30%)";
			break;
		case VisionDefectProtanopia: // protanopia
			result = @"Protanopia (1%)";
			break;
		case VisionDefectDeuteranopia: // deuteranopia
			result = @"Deuteranopia (1%)";
			break;
		case VisionDefectTritanopia: // tritanopia
			result = @"Tritanopia (<1%)";
			break;
		case VisionDefectProtanomaly: // protanomaly
			result = @"Protanomaly (1%)";
			break;
		case VisionDefectDeuteranomaly: // deuteranomaly
			result = @"Deuteranomaly (6%)";
			break;
		case VisionDefectTritanomaly: // tritanomaly
			result = @"Tritanomaly (<1%)";
			break;
	}
	
	return result;
}

@end















//
//  DMGridOverlayPlugin.m
//  iOS Test Settings Example
//
//  Created by Tobias DM on 27/12/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "DMColorBlindPlugin.h"



@protocol ColorDegradeScreenshotOperationDelegate <NSObject>
- (void)colorDegradeDidProduceImage:(UIImage *)image;
@end

@interface ColorDegradeScreenshotOperation: NSOperation
@property (strong, nonatomic) CIFilter *visionFilter;
@property (strong, nonatomic) id<ColorDegradeScreenshotOperationDelegate> delegate;
@end

@implementation ColorDegradeScreenshotOperation

- (void)main {
    // a lengthy operation
    @autoreleasepool
	{
		CGFloat scale = [UIScreen mainScreen].scale;
		
		// Get main window
		UIWindow *window = [UIApplication sharedApplication].keyWindow;
		CGRect rect = window.bounds;
		
		// Render to image
		UIGraphicsBeginImageContextWithOptions(rect.size,NO,scale);
		[window drawViewHierarchyInRect:rect afterScreenUpdates:NO];
		UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		CIImage *normalImage = [CIImage imageWithCGImage:screenshot.CGImage];

		[self.visionFilter setValue:normalImage forKey:kCIInputImageKey];
		CIImage *result = [self.visionFilter valueForKey:kCIOutputImageKey];

		CGRect r = rect;
		r.size.width *= scale;
		r.size.height *= scale;

		
		// Keep own CIContext – a little bit faster than:
		// __block UIImage *screenshotColorGraded = [UIImage imageWithCIImage:result];
		static CIContext *myContext;
		if (!myContext) {
			EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
			NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
			myContext = [CIContext contextWithEAGLContext:myEAGLContext options:options];
		}
		CGImageRef cgImage = [myContext createCGImage:result fromRect:r];
		__block UIImage *screenshotColorGraded = [UIImage imageWithCGImage:cgImage];
		CGImageRelease(cgImage);
		
			
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([self.delegate respondsToSelector:@selector(colorDegradeDidProduceImage:)]) {
				[self.delegate colorDegradeDidProduceImage:screenshotColorGraded];
			}
		});
		
    }
}
@end





@interface ColorBlind : DMWindow <ColorDegradeScreenshotOperationDelegate>

@property (nonatomic, assign) VisionDefectType visionDefectType;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@end


@implementation ColorBlind
{
	CIContext *myContext;
	CIFilter *visionFilter;
	UIImage *screenshotColorGraded;
	UIActivityIndicatorView *activityView;
	
	NSOperationQueue *queue;
}
@synthesize visionDefectType = _visionDefectType;

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		self.hidden = NO;
		
		CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refresh)];
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		
		EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
		myContext = [CIContext contextWithEAGLContext:myEAGLContext options:options];
	}
	return self;
}

- (void)refresh
{
	if (!self.hidden && self.visionDefectType != VisionDefectNone && visionFilter)
	{
		if (!queue)
		{
			queue = [NSOperationQueue new];
		}

		if (queue.operationCount < 1)
		{
			ColorDegradeScreenshotOperation *operation = [ColorDegradeScreenshotOperation new];
			operation.visionFilter = visionFilter;
			operation.delegate = self;
			operation.queuePriority = NSOperationQueuePriorityHigh;
			
			[queue addOperation:operation];
		}
	}
}





- (void)drawRect:(CGRect)rect
{
	// Draw image
	if (screenshotColorGraded)
		[screenshotColorGraded drawInRect:rect];
}


- (void)setVisionDefectType:(VisionDefectType)visionDefectType
{
	_visionDefectType = visionDefectType;
	
	[self.activityView startAnimating];
	
	BOOL enabled = (visionDefectType != VisionDefectNone);
	if (enabled) {
		visionFilter = nil;
		visionFilter = [VisionDefectSimulation filterForVisionDefect:visionDefectType
											  withBackingScaleFactor:[UIScreen mainScreen].scale];
	}
}


- (void)colorDegradeDidProduceImage:(UIImage *)image
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		
		screenshotColorGraded = image;
		[self setNeedsDisplay];
		
		if (activityView)
			[activityView stopAnimating];
	}];
}



- (UIActivityIndicatorView *)activityView
{
	if (!activityView) {
		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityView.backgroundColor = [UIColor colorWithWhite:0.500 alpha:0.500];
		[self.rootViewController.view addSubview:activityView];
		CGFloat size = 88.f;
		activityView.frame = CGRectMake(0, 0, size, size);
		activityView.center = self.rootViewController.view.center;
		activityView.layer.cornerRadius = size / 2.0;
	}
	return activityView;
}


@end







@implementation DMColorBlindPlugin
{
	ColorBlind *colorBlind;
}


#define cellIdentifier @"GridOverlayCellIdentifier"


#define kColorBlindType @"kColorBlindType"

#define defaults

- (void)setup
{
	self.name = @"Color Blind";
	self.uniqueID = @"ColorBlind";
	self.parameterDefaults = @{kColorBlindType		:	@(VisionDefectPresbyopia)};
	
	UITableViewController *tableViewController = [UITableViewController new];
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableViewController.tableView = tableView;
	self.viewController = tableViewController;
	
	[tableViewController.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
	tableViewController.tableView.dataSource = self;
	tableViewController.tableView.delegate = self;
}



- (void)setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	
	[self updateToNewSettings];
}


- (void)updateToNewSettings
{
	if (self.enabled)
	{
		if (!colorBlind)
			colorBlind = [ColorBlind new];
		
		colorBlind.visionDefectType = [[[DMTestSettings sharedInstance] objectForKey:kColorBlindType withPluginIdentifier:self.uniqueID] intValue];
	}
	else
	{
		colorBlind.hidden = YES; // To remove from app windows
		colorBlind = nil;
	}
}


- (NSString *)settingsDescription
{
	VisionDefectType visionDefectType = [[[DMTestSettings sharedInstance] objectForKey:kColorBlindType withPluginIdentifier:self.uniqueID] intValue];
	
	return [VisionDefectSimulation nameForVisionDefect:visionDefectType];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0: return @"Type";
		default: return nil;
	}
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	switch (section) {
		case 0: return @"Color vision deficiency is simulated using color grading and blur. Lagging will occur when using this plugin, but this is not a part of the wanted effect.";
		default: return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0: return VisionDefectType_COUNT;
		default: return 0;
	}
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	cell.accessoryView = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	
	switch (indexPath.section) {
		case 0:
		{
			cell.textLabel.text = [VisionDefectSimulation nameForVisionDefect:indexPath.row];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			VisionDefectType visionDefectType = [[[DMTestSettings sharedInstance] objectForKey:kColorBlindType withPluginIdentifier:self.uniqueID] intValue];
			if (indexPath.row == visionDefectType)
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
			break;
			break;
			
		default:
			break;
	}
	
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case 0:
		{
			VisionDefectType visionDefectType = (VisionDefectType)indexPath.row;
			[[DMTestSettings sharedInstance] setObject:@(visionDefectType) forKey:kColorBlindType withPluginIdentifier:self.uniqueID];
			if (colorBlind)
				colorBlind.visionDefectType = visionDefectType;
			[tableView reloadData];
		}
			break;
	}
}







@end
