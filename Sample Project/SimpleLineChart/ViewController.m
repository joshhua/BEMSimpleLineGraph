//
//  ViewController.m
//  SimpleLineGraph
//
//  Created by Bobo on 12/27/13. Updated by Sam Spencer on 1/11/14.
//  Copyright (c) 2013 Boris Emorine. All rights reserved.
//  Copyright (c) 2014 Sam Spencer.
//

#import "ViewController.h"
#import "BEMGraphCalculator.h"

@interface ViewController () {
    int previousStepperValue;
    int totalNumber;
} @end

@implementation ViewController

// MARK: - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self hydrateDatasets];
    
    /* This is commented out because the graph is created in the interface with this sample app. However, the code remains as an example for creating the graph using code.
     BEMSimpleLineGraphView *myGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 60, 320, 250)];
     myGraph.delegate = self;
     myGraph.dataSource = self;
     [self.view addSubview:myGraph]; */
    
    // Create a gradient to apply to the bottom portion of the graph
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    
    // Apply the gradient to the bottom portion of the graph
    CGGradientRef gradient =  CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    self.myGraph.gradientBottom = gradient;

    CGColorSpaceRelease(colorspace);
    CGGradientRelease(gradient);


    // Enable and disable various graph properties and axis displays
    self.myGraph.enableTouchReport = YES;
    self.myGraph.enablePopUpReport = YES;
    self.myGraph.autoScaleYAxis = YES;
    // self.myGraph.alwaysDisplayDots = YES;
    // self.myGraph.alwaysDisplayPopUpLabels = YES;
    self.myGraph.enableReferenceXAxisLines = YES;
    self.myGraph.enableReferenceYAxisLines = YES;
    self.myGraph.enableReferenceAxisFrame = YES;

    // Draw an average line
    self.myGraph.averageLine.enableAverageLine = YES;
    self.myGraph.averageLine.alpha = 0.6;
    self.myGraph.averageLine.color = [UIColor darkGrayColor];
    self.myGraph.averageLine.width = 2.5;
    self.myGraph.averageLine.dashPattern = @[@(2),@(2)];
    self.myGraph.averageLine.title = @"Avg";

    // Set the graph's animation style to draw, fade, or none
    self.myGraph.animationGraphStyle = BEMLineAnimationDraw;
    
    // Dash the y reference lines
    self.myGraph.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    
    // Show the y axis values with this format string
    self.myGraph.formatStringForValues = @"%.1f";
    
    // Setup initial curve selection segment
    self.curveChoice.selectedSegmentIndex = self.myGraph.enableBezierCurve;

    // The labels to report the values of the graph when the user touches it
    self.labelValues.text = [NSString stringWithFormat:@"%i", [[BEMGraphCalculator sharedCalculator] calculatePointValueSumOnGraph:self.myGraph].intValue];
    self.labelDates.text = @"between now and later";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hydrateDatasets {
    // Reset the arrays of values (Y-Axis points) and dates (X-Axis points / labels)
    if (!self.arrayOfValues) self.arrayOfValues = [[NSMutableArray alloc] init];
    if (!self.arrayOfDates) self.arrayOfDates = [[NSMutableArray alloc] init];
    [self.arrayOfValues removeAllObjects];
    [self.arrayOfDates removeAllObjects];
    
    previousStepperValue = self.graphObjectIncrement.value;
    totalNumber = 0;
    NSDate *baseDate = [NSDate date];
    BOOL showNullValue = YES;
    
    // Add objects to the array based on the stepper value
    for (int i = 0; i < 9; i++) {
        [self.arrayOfValues addObject:@([self getRandomFloat])]; // Random values for the graph
        if (i == 0) {
            [self.arrayOfDates addObject:baseDate]; // Dates for the X-Axis of the graph
        } else if (showNullValue && i == 4) {
            [self.arrayOfDates addObject:[self dateForGraphAfterDate:self.arrayOfDates[i-1]]]; // Dates for the X-Axis of the graph
            self.arrayOfValues[i] = @(BEMNullGraphValue);
        } else {
            [self.arrayOfDates addObject:[self dateForGraphAfterDate:self.arrayOfDates[i-1]]]; // Dates for the X-Axis of the graph
        }
        
        totalNumber = totalNumber + [[self.arrayOfValues objectAtIndex:i] intValue]; // All of the values added together
    }
}

- (NSDate *)dateForGraphAfterDate:(NSDate *)date {
    NSTimeInterval secondsInTwentyFourHours = 24 * 60 * 60;
    NSDate *newDate = [date dateByAddingTimeInterval:secondsInTwentyFourHours];
    return newDate;
}

- (NSString *)labelForDateAtIndex:(NSInteger)index {
    NSDate *date = self.arrayOfDates[index];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MM/dd";
    NSString *label = [df stringFromDate:date];
    return label;
}

// MARK: - Graph Actions

// Refresh the line graph using the specified properties
- (IBAction)refresh:(id)sender {
    [self hydrateDatasets];
    
    UIColor *color = nil;
    if (self.graphColorChoice.selectedSegmentIndex == 0) color = [UIColor colorWithRed:31.0/255.0 green:187.0/255.0 blue:166.0/255.0 alpha:1.0];
    else if (self.graphColorChoice.selectedSegmentIndex == 1) color = [UIColor colorWithRed:255.0/255.0 green:187.0/255.0 blue:31.0/255.0 alpha:1.0];
    else if (self.graphColorChoice.selectedSegmentIndex == 2) color = [UIColor colorWithRed:0.0 green:140.0/255.0 blue:255.0/255.0 alpha:1.0];
    else color = [UIColor colorWithRed:31.0/255.0 green:187.0/255.0 blue:166.0/255.0 alpha:1.0]; // set the default color
    
    self.myGraph.enableBezierCurve = (BOOL) self.curveChoice.selectedSegmentIndex;
    self.myGraph.colorTop = color;
    self.myGraph.colorBottom = color;
    self.myGraph.colorBackgroundXaxis = color;
    self.myGraph.colorBackgroundYaxis = color;
    self.myGraph.backgroundColor = color;
    self.view.tintColor = color;
    self.graphObjectIncrement.tintColor = color;
    self.labelValues.textColor = color;
    self.navigationController.navigationBar.tintColor = color;
    
    self.myGraph.animationGraphStyle = BEMLineAnimationFade;
    [self.myGraph reloadGraph];
}

- (float)getRandomFloat {
    float i1 = arc4random_uniform(5000);
    return i1;
}

- (IBAction)addOrRemovePointFromGraph:(id)sender {
    if (self.graphObjectIncrement.value > previousStepperValue) {
        // Add point
        [self.arrayOfValues addObject:@([self getRandomFloat])];
        NSDate *lastDate = self.arrayOfDates.count > 0 ? [self.arrayOfDates lastObject]: [NSDate date];
        NSDate *newDate = [self dateForGraphAfterDate:lastDate];
        [self.arrayOfDates addObject:newDate];
        [self.myGraph reloadGraph];
    } else if (self.graphObjectIncrement.value < previousStepperValue && self.arrayOfValues.count > 0) {
        // Remove point
        [self.arrayOfValues removeObjectAtIndex:0];
        [self.arrayOfDates removeObjectAtIndex:0];
        [self.myGraph reloadGraph];
    }
    
    previousStepperValue = self.graphObjectIncrement.value;
}

- (IBAction)displayStatistics:(id)sender {
    [self performSegueWithIdentifier:@"showStats" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"showStats"]) {
        StatsViewController *controller = segue.destinationViewController;
        controller.standardDeviation = [NSString stringWithFormat:@"%.2f", [[[BEMGraphCalculator sharedCalculator] calculateStandardDeviationOnGraph:self.myGraph] floatValue]];
        controller.average = [NSString stringWithFormat:@"%.2f", [[[BEMGraphCalculator sharedCalculator] calculatePointValueAverageOnGraph:self.myGraph] floatValue]];
        controller.median = [NSString stringWithFormat:@"%.2f", [[[BEMGraphCalculator sharedCalculator] calculatePointValueMedianOnGraph:self.myGraph] floatValue]];
        controller.mode = [NSString stringWithFormat:@"%.2f", [[[BEMGraphCalculator sharedCalculator] calculatePointValueModeOnGraph:self.myGraph] floatValue]];
        controller.minimum = [NSString stringWithFormat:@"%.2f", [[[BEMGraphCalculator sharedCalculator] calculateMinimumPointValueOnGraph:self.myGraph] floatValue]];
        controller.maximum = [NSString stringWithFormat:@"%.2f", [[[BEMGraphCalculator sharedCalculator] calculateMaximumPointValueOnGraph:self.myGraph] floatValue]];
        controller.area = [NSString stringWithFormat:@"%.2f", [[[BEMGraphCalculator sharedCalculator] calculateAreaUsingIntegrationMethod:BEMIntegrationMethodParabolicSimpsonSum onGraph:self.myGraph xAxisScale:[NSNumber numberWithInt:1]] floatValue]];
        controller.correlation = [NSString stringWithFormat:@"%.2f", [[[BEMGraphCalculator sharedCalculator] calculateCorrelationCoefficientUsingCorrelationMethod:BEMCorrelationMethodPearson onGraph:self.myGraph xAxisScale:[NSNumber numberWithInt:1]] floatValue]];
        controller.snapshotImage = [self.myGraph graphSnapshotImage];
    }
}


// MARK: - SimpleLineGraph Data Source

- (NSUInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return (int)[self.arrayOfValues count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSUInteger)index {
    return [[self.arrayOfValues objectAtIndex:index] doubleValue];
}

// MARK: - SimpleLineGraph Delegate

- (NSUInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 2;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSUInteger)index {

    NSString *label = [self labelForDateAtIndex:index];
    return [label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSUInteger)index {
    self.labelValues.text = [NSString stringWithFormat:@"%@", [self.arrayOfValues objectAtIndex:index]];
    self.labelDates.text = [NSString stringWithFormat:@"in %@", [self labelForDateAtIndex:index]];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.labelValues.alpha = 0.0f;
        self.labelDates.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.labelValues.text = [NSString stringWithFormat:@"%i", [[[BEMGraphCalculator sharedCalculator] calculatePointValueSumOnGraph:self.myGraph] intValue]];
        self.labelDates.text = [NSString stringWithFormat:@"between %@ and %@", [self labelForDateAtIndex:0], [self labelForDateAtIndex:self.arrayOfDates.count - 1]];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.labelValues.alpha = 1.0f;
            self.labelDates.alpha = 1.0f;
        } completion:nil];
    }];
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
    if (self.arrayOfValues.count > 0) {
        NSNumber *pointSum = [[BEMGraphCalculator sharedCalculator] calculatePointValueSumOnGraph:self.myGraph];
        self.labelValues.text = [NSString stringWithFormat:@"%i", [pointSum intValue]];
        self.labelDates.text = [NSString stringWithFormat:@"between %@ and %@", [self labelForDateAtIndex:0], [self labelForDateAtIndex:self.arrayOfDates.count - 1]];
    } else {
        self.labelValues.text = @"No data";
        self.labelDates.text = @"";
    }
}

/* - (void)lineGraphDidFinishDrawing:(BEMSimpleLineGraphView *)graph {
    // Use this method for tasks after the graph has finished drawing
} */

- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return @" people";
}

//- (NSString *)popUpPrefixForlineGraph:(BEMSimpleLineGraphView *)graph {
//    return @"$ ";
//}

// MARK: - Optional Datasource Customizations
/*
 This section holds a bunch of graph customizations that can be made.  They are commented out because they aren't required.  If you choose to uncomment some, they will override some of the other delegate and datasource methods above.
 
*/

//- (NSInteger)baseIndexForXAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
//    return 0;
//}
//
//- (NSInteger)incrementIndexForXAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
//    return 2;
//}

//- (NSArray *)incrementPositionsForXAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
//    NSMutableArray *positions = [NSMutableArray array];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSInteger previousDay = -1;
//    for(int i = 0; i < self.arrayOfDates.count; i++) {
//        NSDate *date = self.arrayOfDates[i];
//        NSDateComponents * components = [calendar components:NSCalendarUnitDay fromDate:date];
//        NSInteger day = components.day;
//        if(day != previousDay) {
//            [positions addObject:@(i)];
//            previousDay = day;
//        }
//    }
//    return positions;
//    
//}
//
//- (CGFloat)baseValueForYAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
//    NSNumber *minValue = [graph calculateMinimumPointValue];
//    //Let's round our value down to the nearest 100
//    double min = minValue.doubleValue;
//    double roundPrecision = 100;
//    double offset = roundPrecision / 2;
//    double roundedVal = round((min - offset) / roundPrecision) * roundPrecision;
//    return roundedVal;
//}
//
//- (CGFloat)incrementValueForYAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
//    NSNumber *minValue = [graph calculateMinimumPointValue];
//    NSNumber *maxValue = [graph calculateMaximumPointValue];
//    double range = maxValue.doubleValue - minValue.doubleValue;
//    float increment = 1.0;
//    if (range <  10) {
//        increment = 2;
//    } else if (range < 100) {
//        increment = 10;
//    } else if (range < 500) {
//        increment = 50;
//    } else if (range < 1000) {
//        increment = 100;
//    } else if (range < 5000) {
//        increment = 500;
//    } else {
//        increment = 1000;
//    }
//    return increment;
//}

@end
