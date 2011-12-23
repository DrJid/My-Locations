//
//  NSMutableString+AddText.h
//  MyLocations
//
//  Created by Maijid  Moujaled on 12/21/11.
//  Copyright (c) 2011 Grinnell College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (AddText)

- (void)addText:(NSString *)text withSeparator:(NSString *)separator;
@end
