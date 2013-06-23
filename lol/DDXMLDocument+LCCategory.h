//
//  DDXMLDocument+LCCategory.h
//  lol
//
//  Created by Di Wu on 6/18/13.
//  Copyright (c) 2013 WUDI. All rights reserved.
//

#import "DDXMLDocument.h"

@interface DDXMLDocument (LCCategory)
- (id)firstValueForXPath:(NSString *)xpath error:(NSError **)error;
@end
