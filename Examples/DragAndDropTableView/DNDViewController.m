//
//  DNDViewController.m
//  DragAndDropTableView
//
//  Created by Erik Johansson on 4/1/13.
//  Copyright (c) 2013 Erik Johansson. All rights reserved.
//

#import "DNDViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DNDViewController ()

@end

@implementation DNDViewController

-(id)init
{
    if(self = [super init])
    {
        _datasource = [NSMutableArray arrayWithObjects:
                       [NSMutableArray arrayWithObjects:@"a",@"b",@"c",@"d",nil],
                       [NSMutableArray array],
                       [NSMutableArray arrayWithObjects:@"e",@"f",@"g",@"h", nil],
                       [NSMutableArray arrayWithObjects:@"i",@"j",@"k",@"l", nil],
                       [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4", nil],
                       [NSMutableArray arrayWithObjects:@"5",@"6",@"7",@"8", nil],
                       [NSMutableArray arrayWithObjects:@"9",@"10",@"11",@"12", nil],
                       nil];
        _tableView = [[DragAndDropTableView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _datasource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_datasource objectAtIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableViewCellName = @"TableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellName];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewCellName];
    }
    
    cell.textLabel.text = [[_datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSObject *o = [[_datasource objectAtIndex:sourceIndexPath.section] objectAtIndex:sourceIndexPath.row];
    [[_datasource objectAtIndex:sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
    [[_datasource objectAtIndex:destinationIndexPath.section] insertObject:o atIndex:destinationIndexPath.row];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(UITableViewCellEditingStyleInsert == editingStyle)
    {
        // inserts are always done at the end
        
        [tableView beginUpdates];
        [_datasource addObject:[NSMutableArray array]];
        [tableView insertSections:[NSIndexSet indexSetWithIndex:[_datasource count]-1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        
    }
    else if(UITableViewCellEditingStyleDelete == editingStyle)
    {
        // check if we are going to delete a row or a section
        [tableView beginUpdates];
        if([[_datasource objectAtIndex:indexPath.section] count] == 0)
        {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_datasource removeObjectAtIndex:indexPath.section];
        }
        else
        {
            // Delete the row from the table view.
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            // Delete the row from the data source.
            [[_datasource objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
        }
        [tableView endUpdates];
    }
}

#pragma mark -

#pragma mark UITableViewDelegate

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 37;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

#pragma mark -

#pragma mark DragAndDropTableViewDataSource

-(BOOL)canCreateNewSection:(NSInteger)section
{
    return YES;
}

#pragma mark -

#pragma mark DragAndDropTableViewDelegate

-(void)tableView:(UITableView *)tableView willBeginDraggingCellAtIndexPath:(NSIndexPath *)indexPath placeholderImageView:(UIImageView *)placeHolderImageView
{
    // this is the place to edit the snapshot of the moving cell
    // add a shadow 
    placeHolderImageView.layer.shadowOpacity = .3;
    placeHolderImageView.layer.shadowRadius = 1;
    

}

-(void)tableView:(DragAndDropTableView *)tableView didEndDraggingCellAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)toIndexPath placeHolderView:(UIImageView *)placeholderImageView
{
    // The cell has been dropped. Remove all empty sections (if you want to)
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for(int i = 0; i < _datasource.count; i++)
    {
        NSArray *ary = [_datasource objectAtIndex:i];
        if(ary.count == 0)
            [indexSet addIndex:i];
    }
    
    [tableView beginUpdates];
    [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    [_datasource removeObjectsAtIndexes:indexSet];
    [tableView endUpdates];
}

-(CGFloat)tableView:tableView heightForEmptySection:(int)section
{
    return 10;
}

#pragma mark -


@end
