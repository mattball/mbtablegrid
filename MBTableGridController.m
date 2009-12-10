/*
 Copyright (c) 2008 Matthew Ball - http://www.mattballdesign.com
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MBTableGridController.h"

@interface NSMutableArray (SwappingAdditions)
- (void)moveObjectsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)index;
@end

@implementation MBTableGridController

- (void)awakeFromNib 
{
	columns = [[NSMutableArray alloc] initWithCapacity:500];
	
	// Add 10 columns
	int i = 0;
	while (i < 10) {
		[self addColumn:self];
		i++;
	}
	
	// Add 100 rows
	int j = 0;
	while (j < 100) {
		[self addRow:self];
		j++;
	}
	
	[tableGrid reloadData];
	
	// Register to receive text strings
	[tableGrid registerForDraggedTypes:[NSArray arrayWithObjects:NSStringPboardType, nil]];
}

- (void)dealloc
{
	[columns release];
	[super dealloc];
}

#pragma mark -
#pragma mark Protocol Methods

#pragma mark MBTableGridDataSource

- (NSUInteger)numberOfRowsInTableGrid:(MBTableGrid *)aTableGrid
{
	if ([columns count] > 0) {
		return [[columns objectAtIndex:0] count];
	}
	return 0;
}


- (NSUInteger)numberOfColumnsInTableGrid:(MBTableGrid *)aTableGrid
{
	return [columns count];
}

- (id)tableGrid:(MBTableGrid *)aTableGrid objectValueForColumn:(NSUInteger)columnIndex row:(NSUInteger)rowIndex
{
	if (columnIndex >= [columns count]) {
		return nil;
	}
	
	NSMutableArray *column = [columns objectAtIndex:columnIndex];
	
	if (rowIndex >= [column count]) {
		return nil;
	}
	
	id value = [column objectAtIndex:rowIndex];
	
	return value;
}

- (void)tableGrid:(MBTableGrid *)aTableGrid setObjectValue:(id)anObject forColumn:(NSUInteger)columnIndex row:(NSUInteger)rowIndex
{
	if (columnIndex >= [columns count]) {
		return;
	}	
	
	NSMutableArray *column = [columns objectAtIndex:columnIndex];
	
	if (rowIndex >= [column count]) {
		return;
	}
	
	if (anObject == nil) {
		anObject = @"";
	}
	
	[column replaceObjectAtIndex:rowIndex withObject:anObject];
	
}

#pragma mark Dragging

- (BOOL)tableGrid:(MBTableGrid *)aTableGrid writeColumnsWithIndexes:(NSIndexSet *)columnIndexes toPasteboard:(NSPasteboard *)pboard
{
	return YES;
}

- (BOOL)tableGrid:(MBTableGrid *)aTableGrid canMoveColumns:(NSIndexSet *)columnIndexes toIndex:(NSUInteger)index
{
	// Allow any column movement
	return YES;
}

- (BOOL)tableGrid:(MBTableGrid *)aTableGrid moveColumns:(NSIndexSet *)columnIndexes toIndex:(NSUInteger)index
{
	[columns moveObjectsAtIndexes:columnIndexes toIndex:index];
	return YES;
}

- (BOOL)tableGrid:(MBTableGrid *)aTableGrid writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
	return YES;
}

- (BOOL)tableGrid:(MBTableGrid *)aTableGrid canMoveRows:(NSIndexSet *)rowIndexes toIndex:(NSUInteger)index
{
	// Allow any row movement
	return YES;
}

- (BOOL)tableGrid:(MBTableGrid *)aTableGrid moveRows:(NSIndexSet *)rowIndexes toIndex:(NSUInteger)index
{
	for (NSMutableArray *column in columns) {
		[column moveObjectsAtIndexes:rowIndexes toIndex:index];
	}
	return YES;
}

- (NSDragOperation)tableGrid:(MBTableGrid *)aTableGrid validateDrop:(id <NSDraggingInfo>)info proposedColumn:(NSUInteger)columnIndex row:(NSUInteger)rowIndex
{
	return NSDragOperationCopy;
}

- (BOOL)tableGrid:(MBTableGrid *)aTableGrid acceptDrop:(id <NSDraggingInfo>)info column:(NSUInteger)columnIndex row:(NSUInteger)rowIndex
{
	NSPasteboard *pboard = [info draggingPasteboard];
	
	NSString *value = [pboard stringForType:NSStringPboardType];
	[self tableGrid:aTableGrid setObjectValue:value forColumn:columnIndex row:rowIndex];
	
	return YES;
}

#pragma mark MBTableGridDelegate

- (void)tableGridDidMoveRows:(NSNotification *)aNotification
{
	NSLog(@"moved");
}

#pragma mark -
#pragma mark Subclass Methods

- (void)addColumn:(id)sender 
{
	NSMutableArray *column = [[NSMutableArray alloc] init];
	
	// Default number of rows
	NSUInteger numberOfRows = 0;
	
	// If there are already other columns, get the number of rows from one of them
	if ([columns count] > 0) {
		numberOfRows = [(NSMutableArray *)[columns objectAtIndex:0] count];
	}
	
	NSUInteger row = 0;
	while (row < numberOfRows) {
		// Insert blank items for each row
		[column addObject:@""];
		
		row++;
	}
	
	[columns addObject:column];
	[column release];
	
	[tableGrid reloadData];
}

- (void)addRow:(id)sender
{
	for (NSMutableArray *column in columns) {
		// Add a blank item to each row
		[column addObject:@""];
	}
	
	[tableGrid reloadData];
}

@end

@implementation NSMutableArray (SwappingAdditions)

- (void)moveObjectsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)index
{
	NSArray *objects = [self objectsAtIndexes:indexes];
	
	// Determine the new indexes for the objects
	NSRange newRange = NSMakeRange(index, [indexes count]);
	if (index > [indexes firstIndex]) {
		newRange.location -= [indexes count];
	}
	NSIndexSet *newIndexes = [NSIndexSet indexSetWithIndexesInRange:newRange];
	
	// Determine where the original objects are
	NSIndexSet *originalIndexes = indexes;
	
	// Remove the objects from their original locations
	[self removeObjectsAtIndexes:originalIndexes];
	
	// Insert the objects at their new location
	[self insertObjects:objects atIndexes:newIndexes];
	
}

@end
