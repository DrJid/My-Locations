//
//  NSMutableString+AddText.m
//  MyLocations
//
//  Created by Maijid  Moujaled on 12/21/11.
//  Copyright (c) 2011 Grinnell College. All rights reserved.
//

#import "NSMutableString+AddText.h"

@implementation NSMutableString (AddText)

- (void)addText:(NSString *)text withSeparator:(NSString *)separator
{
    if (text) {
        if (self.length > 0) {
            [self appendString:separator];
        }
        [self appendString:text];
    }
}
@end
