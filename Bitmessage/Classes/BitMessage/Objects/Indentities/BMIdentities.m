//
//  BMIdentities.m
//  Bitmarket
//
//  Created by Steve Dekorte on 1/29/14.
//  Copyright (c) 2014 Bitmarkets.org. All rights reserved.
//

#import "BMIdentities.h"
#import "BMProxyMessage.h"
#import "BMIdentity.h"

@implementation BMIdentities

- (id)init
{
    self = [super init];
    self.actions = [NSMutableArray arrayWithObjects:@"add", nil];
    return self;
}

- (void)fetch
{
    self.children = [self listAddresses2];
}

- (NSMutableArray *)listAddresses2 // identities
{
    BMProxyMessage *message = [[BMProxyMessage alloc] init];
    [message setMethodName:@"listAddresses2"];
    NSArray *params = [NSArray arrayWithObjects:nil];
    [message setParameters:params];
    [message sendSync];
    
    NSMutableArray *identities = [NSMutableArray array];
    
    //NSLog(@"[message parsedResponseValue] = %@", [message parsedResponseValue]);
    
    NSArray *dicts = [[message parsedResponseValue] objectForKey:@"addresses"];
    
    //NSLog(@"\n\ndicts = %@", dicts);
    
    for (NSDictionary *dict in dicts)
    {
        BMIdentity *child = [BMIdentity withDict:dict];
        [identities addObject:child];
    }
    
    //NSLog(@"\n\n contacts = %@", contacts);
    
    return identities;
}



- (void)add
{
    [self createRandomAddressWithLabel:@"Enter Label"];
}

- (void)createRandomAddressWithLabel:(NSString *)label
{
    BMProxyMessage *message = [[BMProxyMessage alloc] init];
    [message setMethodName:@"createRandomAddress"];
    NSArray *params = [NSArray arrayWithObjects:label.encodedBase64, nil];
    [message setParameters:params];
    [message sendSync];
    id response = [message parsedResponseValue];
    NSLog(@"createRandomAddress response %@", response);
    [self fetch];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BMNodeChanged" object:self];
}

- (BMIdentity *)identityWithAddress:(NSString *)address
{
    for (BMIdentity *child in self.children)
    {
        if ([child.address isEqualToString:address])
        {
            return child;
        }
    }
    
    return nil;
}

- (NSString *)firstIdentityAddress
{
    BMIdentity *identity = (BMIdentity *)self.children.firstObject;
    
    if (identity)
    {
        return identity.address;
    }
    
    return nil;
}

@end