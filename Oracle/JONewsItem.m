//
//  JONewsItem.m
//  Oracle
//
//  Created by Joshua Oldenburg on 10/13/13.
//  Copyright (c) 2013 Joshua Oldenburg. All rights reserved.
//

#import "JONewsItem.h"
#import "tidy.h"
#import "buffio.h"
#import "NSString+JOUtilAdditions.h"

@interface JONewsItem () <NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableArray *tempImageURLs;
@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSMutableArray *callbacks;
@end

@implementation JONewsItem
@synthesize tidiedContent = _tidiedContent;
@synthesize imageURLs = _imageURLs;

- (id)init {
	self = [super init];
	if (self) {
		_callbacks = [NSMutableArray array];
	}
	return self;
}

- (void)setContent:(NSString *)content {
	if ([_content isEqualToString:content]) return;
	
	_content = content;
	self.tidiedContent = nil;
}

- (NSString *)tidiedContent {
	TidyBuffer output = {0};
	TidyDoc tidyDoc = tidyCreate();
    if (!tidyOptSetBool(tidyDoc, TidyXmlOut, yes)) return nil; // Convert to XML
    if (!tidyOptSetValue(tidyDoc, TidyCharEncoding, "utf8")) return nil; // UTF-8
	TidyBuffer errorBuffer = {0};
	if (tidySetErrorBuffer(tidyDoc, &errorBuffer) < 0) return nil; // Shut up tidy: puts errors to stderr if this isn't set
    if (tidyParseString(tidyDoc, self.content.UTF8String) < 0) return nil; // Parse
    if (tidyCleanAndRepair(tidyDoc) < 0) return nil; // Fix/tidy
    if (tidySaveBuffer(tidyDoc, &output) < 0) return nil; // Save
	
	return _tidiedContent = [NSString stringWithUTF8String:(char *)output.bp];
}
- (void)setTidiedContent:(NSString *)tidiedContent {
	if ([_tidiedContent isEqualToString:tidiedContent]) return;
	
	_tidiedContent = tidiedContent;
	self.imageURLs = nil;
}

- (NSArray *)imageURLs {
	if (_imageURLs) return _imageURLs;
	
	[self getImageURLsWithCallback:nil];
	return nil;
}
- (void)setImageURLs:(NSArray *)imageURLs {
	if ([_imageURLs isEqualToArray:imageURLs]) return;
	
	_imageURLs = imageURLs;
	self.parser = nil;
	self.tempImageURLs = nil;
	[self.callbacks removeAllObjects];
}
- (void)getImageURLsWithCallback:(void (^)(NSArray *imageURLs))callback {
	if (_imageURLs) {
		if (callback) callback(self.imageURLs);
		return;
	}
	
	if (callback) [self.callbacks addObject:callback];
	if (self.parser) return;
	
	self.parser = [[NSXMLParser alloc] initWithData:[[self.tidiedContent stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "] dataUsingEncoding:NSUTF8StringEncoding]];
	self.parser.delegate = self;
	[self.parser parse];
}

#pragma mark - NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser {
	self.tempImageURLs = [NSMutableArray array];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"img"] && attributeDict[@"src"]) [self.tempImageURLs addObject:attributeDict[@"src"]];
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSArray *callbacks = self.callbacks.copy;
	self.imageURLs = self.tempImageURLs;
	for (void (^callback)(NSArray *imageURLs) in callbacks) {
		callback(_imageURLs);
		[self.callbacks removeObject:callback];
	}
	self.parser = nil;
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	self.tempImageURLs = nil;
	[self parserDidEndDocument:parser];
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self && aDecoder) {
		self.identifier = [aDecoder decodeObjectForKey:@"JOCodingIdentifier"];
		self.publicationDate = [aDecoder decodeObjectForKey:@"JOCodingPublicationDate"];
		self.updateDate = [aDecoder decodeObjectForKey:@"JOCodingUpdateDate"];
		self.title = [aDecoder decodeObjectForKey:@"JOCodingTitle"];
		self.summary = [aDecoder decodeObjectForKey:@"JOCodingSummary"];
		self.enclosures = [aDecoder decodeObjectForKey:@"JOCodingEnclosures"];
		self.alternateURL = [aDecoder decodeObjectForKey:@"JOCodingAlternateURL"];
	}
	return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
	if (!aCoder) return;
	if (self.identifier) [aCoder encodeObject:self.identifier forKey:@"JOCodingIdentifier"];
	if (self.publicationDate) [aCoder encodeObject:self.publicationDate forKey:@"JOCodingPublicationDate"];
	if (self.updateDate) [aCoder encodeObject:self.updateDate forKey:@"JOCodingUpdateDate"];
	if (self.title) [aCoder encodeObject:self.title forKey:@"JOCodingTitle"];
	if (self.summary) [aCoder encodeObject:self.summary forKey:@"JOCodingSummary"];
	if (self.enclosures) [aCoder encodeObject:self.enclosures forKey:@"JOCodingEnclosures"];
	if (self.alternateURL) [aCoder encodeObject:self.alternateURL forKey:@"JOCodingAlternateURL"];
}

#pragma NSObject
- (NSUInteger)hash {
	return self.identifier.hash ^ self.publicationDate.hash;
}
- (BOOL)isEqual:(JONewsItem *)object {
	if (!object || ![object isKindOfClass:self.class]) return NO;
	if (object == self) return YES;
	return [self.identifier isEqualToString:object.identifier] && [self.publicationDate isEqualToDate:object.publicationDate];
}

@end
