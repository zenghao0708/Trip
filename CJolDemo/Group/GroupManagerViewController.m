//
//  GroupManagerViewController.m
//  CJolDemo
//
//  Created by zenghao on 10/29/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import "GroupManagerViewController.h"
#import "AppDelegate.h"

@interface GroupManagerViewController ()
@property NSMutableArray * items;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButton;
- (IBAction)logout:(UIBarButtonItem *)sender;

@end

@implementation GroupManagerViewController

@synthesize items;
@synthesize addBarButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SetCurViewController(self);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    items = [NSMutableArray array];
    [items addObject:@"默认组"];
    
    addBarButton.enabled = NO;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    // Configure the cell...
    
    NSLog(@"Enter cellForRowAtIndexPath row:%D!",[indexPath row]);
    NSUInteger row = [indexPath row];
    NSString *identifier = @"GroupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSAssert(nil != cell, @"GroupCell is nil!");
    
    UILabel *GroupName=(UILabel *)[cell viewWithTag:101];
    GroupName.text = [items objectAtIndex:row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destination = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString:@"AddGroup"]) {
        NSLog(@"prepareforsegue:AddGroup:");
        
        if ([destination respondsToSelector:@selector(setPreViewController:)]) {
            //将自身传递给目的ViewController
            NSLog(@"enter setPreViewController()!");
            [destination setValue:self forKey:@"preViewController"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"GroupDetail"]) {
        NSLog(@"prepareforsegue:GroupDetail!");
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        id object = [self.items objectAtIndex:indexPath.row];
        NSDictionary *selection = [NSDictionary dictionaryWithObjectsAndKeys:
                                   indexPath, @"indexPath",
                                   object, @"groupName",
                                   nil];
        [destination setValue:selection forKey:@"selection"];
    }
}

-(void)addGroupInTableView:(NSString *)GroupName{
    [self.items addObject:GroupName];
    [self.tableView reloadData];
}

- (IBAction)logout:(UIBarButtonItem *)sender {
    
    NSMutableDictionary *loginInfo = [NSDictionary dictionaryWithContentsOfFile:LOGIN_INFO_FILE_PATH];
    if (nil != loginInfo) {
        [loginInfo setObject:@"" forKey:LOGIN_PASSWORD];
        [loginInfo writeToFile:LOGIN_INFO_FILE_PATH atomically:YES];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}
@end
