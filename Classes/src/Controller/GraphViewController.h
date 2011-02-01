//
//  GraphViewController.h
//  CoreGraph
//
//  Created by 荻野 雅 on 11/01/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"


@interface GraphViewController : UIViewController {
@private
	GraphView* graph_;
}

@property (nonatomic, retain) GraphView* graph;

@end
