//
//  GraphView.h
//  CoreGraph
//
//  Created by 荻野 雅 on 11/02/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CorePlot/CorePlot-CocoaTouch.h>


@interface GraphView : UIView<CPTPlotDataSource> {
@private
	CPTXYGraph* graph_;
	NSArray* plots_;
}

@property (nonatomic, retain) CPTXYGraph* graph;
@property (nonatomic, retain) NSArray* plots;

@end
