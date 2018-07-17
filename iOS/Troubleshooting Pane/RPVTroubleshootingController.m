//
//  RPVTroubleshootingController.m
//  iOS
//
//  Created by Matt Clarke on 04/07/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import "RPVTroubleshootingController.h"
#import <TORoundedTableView/TORoundedTableView.h>
#import <TORoundedTableView/TORoundedTableViewCell.h>
#import <TORoundedTableView/TORoundedTableViewCapCell.h>

#import "RPVTroubleshootingCertificatesViewController.h"

@interface RPVTroubleshootingController ()
@property (nonatomic, strong) NSArray *dataSource;
@end

#define REUSE @"troubleshoot.cell"

@implementation RPVTroubleshootingController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    }
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:REUSE];
    self.tableView.allowsSelection = YES;
    
    [[self navigationItem] setTitle:@"Troubleshooting"];
    
    [self _setupDataSource];
    [self.tableView reloadData];
}

- (void)loadView {
    [super loadView];
    
    // Styling on iPad.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.tableView = [[TORoundedTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        self.tableView.separatorColor = self.tableView.backgroundColor;
    }
}

- (void)_setupDataSource {
    // data sauce.
    NSMutableArray *items = [NSMutableArray array];
    
    NSMutableArray *submitDevelopmentCSR = [NSMutableArray array];
    [submitDevelopmentCSR addObject:@"submitDevelopmentCSR"];
    [submitDevelopmentCSR addObject:@"This error usually occurs when the same Apple ID is logged in more than twice to applications like Cydia Impactor and ReProvision.\n\nEach application creates a certificate to sign applications with, but free accounts are limited to only two certificates.\n\nTo resolve this, tap below to remove the extra certificates."];
    [submitDevelopmentCSR addObject:@"Manage Certificates"];
    
    [items addObject:submitDevelopmentCSR];
    
    NSMutableArray *dotAppInfoPlist = [NSMutableArray array];
    [dotAppInfoPlist addObject:@".app/Info.plist"];
    [dotAppInfoPlist addObject:@"This error may occur when ReProvision attempts to create an IPA for an application.\n\nTo resolve, simply try again another time."];
    
    [items addObject:dotAppInfoPlist];
    
    NSMutableArray *archive = [NSMutableArray array];
    [archive addObject:@"Could not extract archive"];
    [archive addObject:@"This error may occur when an IPA is signed, but not repackaged correctly.\n\nTo resolve, simply try again another time."];
    
    [items addObject:archive];
    
    self.dataSource = items;
}

// table view delegate.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dataSource objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    // Fancy cell styling on iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cell = [self tableView:(TORoundedTableView*)tableView _ipadCellForIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:REUSE forIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSE];
        }
    }
    
    NSArray *items = [self.dataSource objectAtIndex:indexPath.section];
    NSString *str = [items objectAtIndex:indexPath.row];
    
    BOOL isBold = indexPath.row == 0;
    
    cell.textLabel.text = str;
    cell.textLabel.textColor = isBold ? [UIColor darkTextColor] : [UIColor grayColor];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    // Also handle if a link cell.
    if (indexPath.row == 2) {
        cell.textLabel.textColor = [UIApplication sharedApplication].delegate.window.tintColor;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (UITableViewCell*)tableView:(TORoundedTableView*)tableView _ipadCellForIndexPath:(NSIndexPath*)indexPath {
    static NSString *cellIdentifier     = @"Cell";
    static NSString *capCellIdentifier  = @"CapCell";
    
    // Work out if this cell needs the top or bottom corners rounded (Or if the section only has 1 row, both!)
    BOOL isTop = (indexPath.row == 0);
    BOOL isBottom = indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1);
    
    // Create a common table cell instance we can configure
    UITableViewCell *cell = nil;
    
    // If it's a non-cap cell, dequeue one with the regular identifier
    if (!isTop && !isBottom) {
        TORoundedTableViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (normalCell == nil) {
            normalCell = [[TORoundedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        cell = normalCell;
    }
    else {
        // If the cell is indeed one that needs rounded corners, dequeue from the pool of cap cells
        TORoundedTableViewCapCell *capCell = [tableView dequeueReusableCellWithIdentifier:capCellIdentifier];
        if (capCell == nil) {
            capCell = [[TORoundedTableViewCapCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:capCellIdentifier];
        }
        
        // Configure the cell to set the appropriate corners as rounded
        capCell.topCornersRounded = isTop;
        capCell.bottomCornersRounded = isBottom;
        cell = capCell;
    }
    
    cell.textLabel.opaque = YES;
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

-(CGRect)boundedRectForFont:(UIFont*)font andText:(id)text width:(CGFloat)width {
    if (!text || !font) {
        return CGRectZero;
    }
    
    if (![text isKindOfClass:[NSAttributedString class]]) {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font}];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        return rect;
    } else {
        return [(NSAttributedString*)text boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIFont *font = [UIFont systemFontOfSize:18];
    NSArray *items = [self.dataSource objectAtIndex:indexPath.section];
    NSString *str = [items objectAtIndex:indexPath.row];
    
    CGFloat extra = 24;
    
    // We also need to add an additional 20pt for each instance of "\n\n" in the string.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray *split = [str componentsSeparatedByString:@"\n\n"];
        extra += (split.count - 1) * 20;
    }
    
    return [self boundedRectForFont:font andText:str width:self.tableView.contentSize.width].size.height + extra;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 2) {
        // This is a link.
        
        switch (indexPath.section) {
            case 0: {
                // Jump to the certificate management panel.
                RPVTroubleshootingCertificatesViewController *certsController = [[RPVTroubleshootingCertificatesViewController alloc] init];
                
                [self.navigationController pushViewController:certsController animated:YES];
                
                break;
                
            } default:
                break;
        }
    }
}

@end