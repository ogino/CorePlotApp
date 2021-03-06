//
//  GraphView.m
//  CoreGraph
//
//  Created by 荻野 雅 on 11/02/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"


@implementation GraphView

@synthesize graph = graph_;
@synthesize plots = plots_;


#pragma mark -
#pragma mark Private Methods

#define NO_PADDING 0.0

- (void)initPadding {
	self.graph.paddingLeft = NO_PADDING;
	self.graph.paddingTop = NO_PADDING;
	self.graph.paddingRight = NO_PADDING;
	self.graph.paddingBottom = NO_PADDING;
}

- (void)createGraph {
	self.graph = [[[CPTXYGraph alloc] initWithFrame:CGRectZero] autorelease];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
	[self.graph applyTheme:theme];
	[self initPadding];
}

#define MIN_XAXIS -360.0
#define MAX_XAXIS 360.0
#define XAXIS_LENGTH (MAX_XAXIS - MIN_XAXIS)
#define XAXIS_PADDING (MAX_XAXIS / 10)
#define XAXIS_DISP_LENGTH (XAXIS_LENGTH + 2*XAXIS_PADDING)

#define MIN_YAXIS -1.0
#define MAX_YAXIS 1.0
#define YAXIS_LENGTH (MAX_YAXIS - MIN_YAXIS)
#define YAXIS_PADDING (MAX_YAXIS / 10)
#define YAXIS_DISP_LENGTH (YAXIS_LENGTH + 2*YAXIS_PADDING)

- (void)createDrawArea:(BOOL)allowsUserInteraction {
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = allowsUserInteraction;
	// Set Display Range.
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(MIN_XAXIS - XAXIS_PADDING) length:CPTDecimalFromFloat(XAXIS_DISP_LENGTH)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(MIN_YAXIS - YAXIS_PADDING) length:CPTDecimalFromFloat(YAXIS_DISP_LENGTH)];
}

- (CPTMutableTextStyle*)createTextStyle:(NSString*)fontName color:(CPTColor*)color {
	CPTMutableTextStyle *textStyleX = [[[CPTMutableTextStyle alloc] init] autorelease];
	[textStyleX setFontName:fontName];
	[textStyleX setColor:color];
	return textStyleX;
}

- (CPTTextStyle*)createTextStyle:(NSString*)fontName color:(CPTColor*)color size:(CGFloat)size {
	CPTMutableTextStyle *textStyleX = [self createTextStyle:fontName color:color];
	[textStyleX setFontSize:size];
	return textStyleX;
}

#define ZERO_DEGIT 0

- (NSNumberFormatter*)createXFormatter {
	NSNumberFormatter* xFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[xFormatter setMaximumFractionDigits:ZERO_DEGIT];
	return xFormatter;
}

#define XAXIS_INTERVAL @"30"
#define XAXIS_ORTHOGONAL @"0.0"

- (void)createXAxis:(CPTXYAxisSet*)axisSet {
	CPTXYAxis *xAxis = axisSet.xAxis;
	xAxis.majorIntervalLength = CPTDecimalFromString(XAXIS_INTERVAL);
	xAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(XAXIS_ORTHOGONAL);
	xAxis.minorTicksPerInterval = 0.0f;

	[xAxis setTitle:@"degree(°)"];
	[xAxis setVisibleRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(MIN_XAXIS) length:CPTDecimalFromFloat(XAXIS_LENGTH)]];

	[xAxis setLabelTextStyle:[self createTextStyle:@"Georgia" color:[CPTColor cyanColor]]];
	[xAxis setTitleTextStyle:[self createTextStyle:@"Georgia" color:[CPTColor yellowColor] size:12.0f]];

	xAxis.labelFormatter = [self createXFormatter];
}

- (NSNumberFormatter*)createYFormatter {
	NSNumberFormatter *yFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[yFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[yFormatter setMaximumFractionDigits:3];
	return yFormatter;
}

#define YAXIS_INTERVAL @"0.2"
#define YAXIS_ORTHOGONAL @"0.0"

- (void)createYAxis:(CPTXYAxisSet*)axisSet {
	CPTXYAxis *yAxis = axisSet.yAxis;
	yAxis.majorIntervalLength = CPTDecimalFromString(YAXIS_INTERVAL);
	yAxis.minorTicksPerInterval = 0;
	yAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(YAXIS_ORTHOGONAL);

	[yAxis setTitle:@"sin(x) value"];
	[yAxis setVisibleRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(MIN_YAXIS) length:CPTDecimalFromFloat(YAXIS_LENGTH)]];

	[yAxis setLabelTextStyle:[self createTextStyle:@"Georgia" color:[CPTColor cyanColor]]];
	[yAxis setTitleTextStyle:[self createTextStyle:@"Georgia" color:[CPTColor yellowColor] size:12.0f]];

	yAxis.labelFormatter = [self createYFormatter];

}

- (void)createAxis {
	CPTXYAxisSet* axisSet = (CPTXYAxisSet*)self.graph.axisSet;
	[self createXAxis:axisSet];
	[self createYAxis:axisSet];
}

- (CPTLineStyle*)createLineStyle:(double)limit width:(double)width color:(CPTColor*)color {
    CPTMutableLineStyle* lineStyle = [[[CPTMutableLineStyle alloc] init] autorelease];
    lineStyle.miterLimit = limit;
    lineStyle.lineWidth = width;
    lineStyle.lineColor = color;
    return lineStyle;
}

- (CPTScatterPlot*)createScorePlot {
	CPTScatterPlot *scorePlot = [[[CPTScatterPlot alloc] init] autorelease];
	scorePlot.identifier = @"Score Plot";
    scorePlot.dataLineStyle = [self createLineStyle:1.0f width:1.0f color:[CPTColor blueColor]];
	scorePlot.dataSource = self;
	return scorePlot;
}

- (CPTFill*)createAreaFill {
	CPTColor *areaColor = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
	CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
	return [CPTFill fillWithGradient:areaGradient];
}

- (CPTPlotSymbol*)createPlotSymbol {
	CPTLineStyle *symbolLineStyle = [self createLineStyle:1.0f width:1.0f color:[CPTColor blackColor]];
	CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
	plotSymbol.lineStyle = symbolLineStyle;
	plotSymbol.size = CGSizeMake(10.0, 10.0);
	return plotSymbol;
}

#define UNLIMITED_BLINK HUGE_VALF

- (CABasicAnimation *) createBlinkAnimation {
	CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeInAnimation.duration = 0.5f;
	fadeInAnimation.repeatCount = UNLIMITED_BLINK;
	fadeInAnimation.autoreverses = YES;
	fadeInAnimation.removedOnCompletion = YES;
	fadeInAnimation.fillMode = kCAFillModeForwards;
	fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.5];
	fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
	return fadeInAnimation;
}

#define ARRAY_CAPACITY XAXIS_LENGTH
#define degreeToRadian(x) (M_PI * (x) / 180.0)

- (void)createPlots {
	NSMutableArray *contents = [NSMutableArray arrayWithCapacity:ARRAY_CAPACITY];
	for (NSInteger i = MIN_XAXIS; i < MAX_XAXIS; i++) {
		id x = [NSNumber numberWithDouble:i];
		id y = [NSNumber numberWithDouble:sin(degreeToRadian(i % 360))];
		[contents addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
	}
	self.plots = contents;
}

- (void)createGraphView {
	[self createPlots];

	[self createGraph];

	CPTGraphHostingView *hostingView = [[[CPTGraphHostingView alloc] initWithFrame:self.bounds] autorelease];
	hostingView.hostedGraph = self.graph;
	hostingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
	UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin|
	UIViewAutoresizingFlexibleBottomMargin;


	[self createDrawArea:YES];

	[self createAxis];

	CPTScatterPlot *scorePlot = [self createScorePlot];
	[self.graph addPlot:scorePlot];

	scorePlot.areaFill = [self createAreaFill];
	scorePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
	scorePlot.plotSymbol = [self createPlotSymbol];

	[scorePlot addAnimation:[self createBlinkAnimation] forKey:@"animateOpacity"];

	[self addSubview:hostingView];
}

#pragma mark -
#pragma mark Inherit Methods

- (id)initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if (self) {
		[self createGraphView];
	}
	return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	// Drawing code.
}
*/

- (void)dealloc {
	self.graph = nil;
	self.plots = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark dataSource

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot*)plot {
	return [self.plots count];
}

-(NSNumber*)numberForPlot:(CPTPlot*)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	NSNumber* number = nil;
	NSDictionary* coord = [self.plots objectAtIndex:index];
	if (coord != nil && [coord count] > 0 ) {
		switch (fieldEnum) {
			case CPTScatterPlotFieldX:
				number = [coord objectForKey:@"x"];
				break;
			case CPTScatterPlotFieldY:
				number = [coord objectForKey:@"y"];
				break;
		}
	}
	return number;
}

@end
