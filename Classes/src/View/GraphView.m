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

- (void)initPadding {
	self.graph.paddingLeft = 0.0;
	self.graph.paddingTop = 0.0;
	self.graph.paddingRight = 0.0;
	self.graph.paddingBottom = 0.0;
}

- (void)createGraph {
	self.graph = [[[CPXYGraph alloc] initWithFrame:CGRectZero] autorelease];
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
	[self.graph applyTheme:theme];
	[self initPadding];
}

- (void)createDrawArea:(BOOL)allowsUserInteraction {
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = allowsUserInteraction;
	plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-2.5) length:CPDecimalFromFloat(12.0)];
	plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-55) length:CPDecimalFromFloat(365.0)];
}

- (CPTextStyle*)createTextStyle:(NSString*)fontName color:(CPColor*)color {
	CPTextStyle *textStyleX = [[[CPTextStyle alloc] init] autorelease];
	[textStyleX setFontName:fontName];
	[textStyleX setColor:color];
	return textStyleX;
}

- (CPTextStyle*)createTextStyle:(NSString*)fontName color:(CPColor*)color size:(CGFloat)size {
	CPTextStyle *textStyleX = [self createTextStyle:fontName color:color];
	[textStyleX setFontSize:size];
	return textStyleX;
}

- (NSNumberFormatter*)createXFormatter {
	NSNumberFormatter* xFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[xFormatter setMaximumFractionDigits:0];
	return xFormatter;
}

#define MIN_XAXIS -100.0
#define MAX_XAXIS 100.0
#define XAXIS_LENGTH (MAX_XAXIS - MIN_XAXIS)

- (void)createXAxis:(CPXYAxisSet*)axisSet {
	CPXYAxis *xAxis = axisSet.xAxis;
	xAxis.majorIntervalLength = CPDecimalFromString(@"1");
	xAxis.orthogonalCoordinateDecimal = CPDecimalFromString(@"0");
	xAxis.minorTicksPerInterval = 0;

	[xAxis setTitle:@"X Jump"];
	[xAxis setVisibleRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(MIN_XAXIS) length:CPDecimalFromFloat(XAXIS_LENGTH)]];

	[xAxis setLabelTextStyle:[self createTextStyle:@"Georgia" color:[CPColor cyanColor]]];
	[xAxis setTitleTextStyle:[self createTextStyle:@"Georgia" color:[CPColor yellowColor] size:16.0f]];

	xAxis.labelFormatter = [self createXFormatter];
}

- (NSNumberFormatter*)createYFormatter {
	NSNumberFormatter *yFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[yFormatter setMaximumFractionDigits:0];
	return yFormatter;
}

#define MIN_YAXIS -500.0
#define MAX_YAXIS 500.0
#define YAXIS_LENGTH (MAX_YAXIS - MIN_YAXIS)

- (void)createYAxis:(CPXYAxisSet*)axisSet {
	CPXYAxis *yAxis = axisSet.yAxis;
	yAxis.majorIntervalLength = CPDecimalFromString(@"50");
	yAxis.minorTicksPerInterval = 1;
	yAxis.orthogonalCoordinateDecimal = CPDecimalFromString(@"0");

	[yAxis setTitle:@"Score"];
	[yAxis setVisibleRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(MIN_YAXIS) length:CPDecimalFromFloat(YAXIS_LENGTH)]];

	[yAxis setLabelTextStyle:[self createTextStyle:@"Georgia" color:[CPColor cyanColor]]];
	[yAxis setTitleTextStyle:[self createTextStyle:@"Georgia" color:[CPColor yellowColor] size:16.0f]];

	yAxis.labelFormatter = [self createYFormatter];

}

- (void)createAxis {
	CPXYAxisSet* axisSet = (CPXYAxisSet*)self.graph.axisSet;
	[self createXAxis:axisSet];
	[self createYAxis:axisSet];
}

- (CPScatterPlot*)createScorePlot {
	CPScatterPlot *scorePlot = [[[CPScatterPlot alloc] init] autorelease];
	scorePlot.identifier = @"Score Plot";
	scorePlot.dataLineStyle.miterLimit = 1.0f;
	scorePlot.dataLineStyle.lineWidth = 3.0f;
	scorePlot.dataLineStyle.lineColor = [CPColor blueColor];
	scorePlot.dataSource = self;
	return scorePlot;
}

- (CPFill*)createAreaFill {
	CPColor *areaColor = [CPColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
	CPGradient *areaGradient = [CPGradient gradientWithBeginningColor:areaColor endingColor:[CPColor clearColor]];
	return [CPFill fillWithGradient:areaGradient];
}

- (CPPlotSymbol*)createPlotSymbol {
	CPLineStyle *symbolLineStyle = [CPLineStyle lineStyle];
	symbolLineStyle.lineColor = [CPColor blackColor];
	CPPlotSymbol *plotSymbol = [CPPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill = [CPFill fillWithColor:[CPColor blueColor]];
	plotSymbol.lineStyle = symbolLineStyle;
	plotSymbol.size = CGSizeMake(10.0, 10.0);
	return plotSymbol;
}

#define UNLIMITED_BLINK 1e100f

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

#define ARRAY_CAPACITY 200

- (void)createPlots {
	NSMutableArray *contents = [NSMutableArray arrayWithCapacity:ARRAY_CAPACITY];
	for (NSInteger i = -100; i < 100; i++) {
		id x = [NSNumber numberWithFloat:i];
		id y = [NSNumber numberWithInt:-(i * i)];
		[contents addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
	}
	self.plots = contents;
}

- (void)createGraphView {
	[self createPlots];

	[self createGraph];

	CPGraphHostingView *hostingView = [[[CPGraphHostingView alloc] initWithFrame:self.bounds] autorelease];
	hostingView.hostedGraph = self.graph;
	hostingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
	UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin|
	UIViewAutoresizingFlexibleBottomMargin;


	[self createDrawArea:YES];

	[self createAxis];

	CPScatterPlot *scorePlot = [self createScorePlot];
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

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
	return [self.plots count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	NSNumber* number = nil;
	NSDictionary* coord = [self.plots objectAtIndex:index];
	if (coord != nil && [coord count] > 0 ) {
		switch (fieldEnum) {
			case CPScatterPlotFieldX:
				number = [coord objectForKey:@"x"];
				break;
			case CPScatterPlotFieldY:
				number = [coord objectForKey:@"y"];
				break;
		}
	}
	return number;
}

@end
