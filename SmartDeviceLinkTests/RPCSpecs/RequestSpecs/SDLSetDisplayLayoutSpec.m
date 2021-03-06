//
//  SDLSetDisplayLayoutSpec.m
//  SmartDeviceLink

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>

#import "SDLNames.h"
#import "SDLSetDisplayLayout.h"
#import "SDLTemplateColorScheme.h"

QuickSpecBegin(SDLSetDisplayLayoutSpec)

describe(@"SetDisplayLayout Tests", ^ {
    __block SDLPredefinedLayout predefinedLayout = SDLPredefinedLayoutMedia;
    __block NSString *otherLayout = @"test123";
    __block SDLTemplateColorScheme *dayScheme = [[SDLTemplateColorScheme alloc] initWithPrimaryColor:[UIColor blueColor] secondaryColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    __block SDLTemplateColorScheme *nightScheme = [[SDLTemplateColorScheme alloc] initWithPrimaryColor:[UIColor blueColor] secondaryColor:[UIColor purpleColor] backgroundColor:[UIColor blackColor]];

    describe(@"initializer tests", ^{
        it(@"should initialize with initWithPredefinedLayout:", ^{
            SDLSetDisplayLayout *testRequest = [[SDLSetDisplayLayout alloc] initWithPredefinedLayout:predefinedLayout];

            expect(testRequest.displayLayout).to(equal(predefinedLayout));
            expect(testRequest.dayColorScheme).to(beNil());
            expect(testRequest.nightColorScheme).to(beNil());
        });

        it(@"should initialize with initWithLayout:", ^{
            SDLSetDisplayLayout *testRequest = [[SDLSetDisplayLayout alloc] initWithLayout:otherLayout];

            expect(testRequest.displayLayout).to(equal(otherLayout));
            expect(testRequest.dayColorScheme).to(beNil());
            expect(testRequest.nightColorScheme).to(beNil());
        });

        it(@"should initialize with initWithPredefinedLayout:dayColorScheme:nightColorScheme:", ^{
            SDLSetDisplayLayout *testRequest = [[SDLSetDisplayLayout alloc] initWithPredefinedLayout:predefinedLayout dayColorScheme:dayScheme nightColorScheme:nightScheme];

            expect(testRequest.displayLayout).to(equal(predefinedLayout));
            expect(testRequest.dayColorScheme).to(equal(dayScheme));
            expect(testRequest.nightColorScheme).to(equal(nightScheme));
        });

        it(@"Should get correctly when initialized", ^ {
            NSMutableDictionary<NSString *, id> *dict = [@{SDLNameRequest:
                                                               @{SDLNameParameters:
                                                                     @{SDLNameDisplayLayout:@"wat"},
                                                                 SDLNameOperationName:SDLNameSetDisplayLayout}} mutableCopy];
            SDLSetDisplayLayout* testRequest = [[SDLSetDisplayLayout alloc] initWithDictionary:dict];

            expect(testRequest.displayLayout).to(equal(@"wat"));
        });

        it(@"Should return nil if not set", ^ {
            SDLSetDisplayLayout* testRequest = [[SDLSetDisplayLayout alloc] init];

            expect(testRequest.displayLayout).to(beNil());
        });
    });

    describe(@"getters/setter", ^{
        it(@"Should set and get correctly", ^ {
            SDLSetDisplayLayout* testRequest = [[SDLSetDisplayLayout alloc] init];

            testRequest.displayLayout = otherLayout;
            testRequest.dayColorScheme = dayScheme;
            testRequest.nightColorScheme = nightScheme;

            expect(testRequest.displayLayout).to(equal(otherLayout));
            expect(testRequest.dayColorScheme).to(equal(dayScheme));
            expect(testRequest.nightColorScheme).to(equal(nightScheme));
        });
    });
});

QuickSpecEnd
