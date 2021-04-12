//
//  Parser.h
//  PacketParser
//
//  Created by Roderick Mann on 12/30/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import "Interpreter.h"




/**
	Parses packets conforming to a PacketType
*/


@interface Parser : Interpreter

@property (nonatomic, strong)	NSManagedObjectContext*			moc;

- (void)			parseData: (NSData*) inData;

@end
