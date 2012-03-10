//
//  UnretinaViewController.h
//  Unretiner
//
//  Created by Stuart Hall on 31/07/11.
//

#import <Cocoa/Cocoa.h>
#import "NSDroppableView.h"

@interface UnretinaViewController : NSViewController<NSOpenSavePanelDelegate, NSDroppableViewDelegate,NSTableViewDataSource>

@property (assign) IBOutlet NSButton* saveToOriginCheckBox;
@property (assign) IBOutlet NSButton* overwriteCheckBox;
@property (assign) IBOutlet NSTableView* tableView;

// Button handlers
- (IBAction)onSelectFolder:(id)sender;
- (IBAction)onCheckOverwriteChange:(id)sender;


@end
