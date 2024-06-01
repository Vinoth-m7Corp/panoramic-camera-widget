//
//  DMDLensSelector.m
//  TestLensSelector
//
//  Created by AMS on 10/19/16.
//  Copyright © 2016 AMS. All rights reserved.
//

#import "DMDLensSelector.h"
#import "DMDLensElement.h"

#define DMD_LENS_SELECTOR_REUSABLE_ID @"LensSelector"
#define DMD_CURRENT_SELECTED_LENS_KEY @"currentSelectedLens"

static NSMutableArray *dmdLensDatabase = nil;

@interface DMDLensSelector() <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tv;
    NSUserDefaults *userDefaults;
    int selectionIndex;
    UILabel *titleLabel;
    UILabel *subTitleLabel;
}

@property (nonatomic, assign) NSObject<DMDLensSelectionDelegate>* delegate;

@end

@implementation DMDLensSelector

+ (NSString*)getSelectedLensKey
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString* userValue=[userDefaults objectForKey:DMD_CURRENT_SELECTED_LENS_KEY];
    NSString* selectedLensKey=nil;
    if(userValue)
        selectedLensKey=[NSString stringWithString:userValue];
    if(!selectedLensKey) {
        
        selectedLensKey = NOLENS;
        [userDefaults setObject:selectedLensKey forKey:DMD_CURRENT_SELECTED_LENS_KEY];
        [userDefaults synchronize];
    }
    userDefaults=nil;
    
    return selectedLensKey;
}

+ (enum DMDLensID)currentLensID
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString* userValue=[userDefaults objectForKey:DMD_CURRENT_SELECTED_LENS_KEY];
    NSString* selectedLensKey=nil;
    if(userValue)
        selectedLensKey=[NSString stringWithString:userValue];
    if(!selectedLensKey) {
        
        selectedLensKey = NOLENS;
        [userDefaults setObject:selectedLensKey forKey:DMD_CURRENT_SELECTED_LENS_KEY];
        [userDefaults synchronize];
    }
    if([selectedLensKey isEqualToString:NOLENS])        return kLensNone;
    
    userDefaults=nil;
    
    return (enum DMDLensID)0;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (instancetype)initWithDelegate:(NSObject<DMDLensSelectionDelegate>*)delegate
{
    if(self=[super init]) {
        
        [DMDLensSelector initialize];
        
        self.delegate = delegate;
        
        tv=[[UITableView alloc] init];
        [tv registerClass:[UITableViewCell class] forCellReuseIdentifier:DMD_LENS_SELECTOR_REUSABLE_ID];
        tv.dataSource = self;
        tv.delegate = self;
        userDefaults=[NSUserDefaults standardUserDefaults];
        selectionIndex=0;
        titleLabel=nil;
        subTitleLabel=nil;
    }
    
    return self;
}

+ (void)initialize
{
    if(dmdLensDatabase) return;
    
    dmdLensDatabase=[[NSMutableArray alloc] init];
    [dmdLensDatabase addObject:[[DMDLensElement alloc] initWithName:@"No Lens" andDescription:@"Phone lens" andImagePath:@"nolens" andLensID:NOLENS]];
}

+ (NSString*)currentLensName
{
    [DMDLensSelector initialize];
    
    @autoreleasepool {

        NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
        NSString *selected=[def objectForKey:DMD_CURRENT_SELECTED_LENS_KEY];
        int selectedLensIndex=0;
        if(selected) {
            for(int i=0; i<[dmdLensDatabase count]; i++) {
                DMDLensElement *elem=[dmdLensDatabase objectAtIndex:i];
                if([selected isEqualToString:elem.lensID]) {
                    return elem.lensName;
                }
            }
        }
        else {
            [def setObject:NOLENS forKey:DMD_CURRENT_SELECTED_LENS_KEY];
            [def synchronize];
        }
        
        DMDLensElement *elem=[dmdLensDatabase objectAtIndex:selectedLensIndex];
        return elem.lensName;
    }
    
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* selectedLensKey=[DMDLensSelector getSelectedLensKey];
    
    for(int i=0; i<[dmdLensDatabase count]; i++) {
        DMDLensElement *elem=[dmdLensDatabase objectAtIndex:i];
        if([selectedLensKey isEqualToString:elem.lensID]) {
            selectionIndex = i;
            break;
        }
    }
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.text = @"Available Lenses";
    [titleLabel sizeToFit];
    
    subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bounds.size.height + 1, 0, 0)];
    subTitleLabel.backgroundColor = [UIColor clearColor];
    subTitleLabel.textColor = [UIColor lightGrayColor];
    subTitleLabel.font = [UIFont systemFontOfSize:12];
    DMDLensElement *currentSelection=(DMDLensElement*)[dmdLensDatabase objectAtIndex:selectionIndex];
    subTitleLabel.text = [NSString stringWithFormat:@"current: %@", currentSelection.lensName];
    [subTitleLabel sizeToFit];
    
    UIView *twoLineTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(subTitleLabel.frame.size.width, titleLabel.frame.size.width), 30)];
    [twoLineTitleView addSubview:titleLabel];
    [twoLineTitleView addSubview:subTitleLabel];
    
    float widthDiff = subTitleLabel.frame.size.width - titleLabel.frame.size.width;
    
    if (widthDiff > 0) {
        CGRect frame = titleLabel.frame;
        frame.origin.x = widthDiff / 2.0;
        titleLabel.frame = CGRectIntegral(frame);
    }else{
        CGRect frame = subTitleLabel.frame;
        frame.origin.x = fabs(widthDiff) / 2.0;
        subTitleLabel.frame = CGRectIntegral(frame);
    }
    
    self.navigationItem.titleView = twoLineTitleView;
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    float topShift=self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    [tv setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + topShift, self.view.bounds.size.width, self.view.bounds.size.height - topShift)];
    [self.view addSubview:tv];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];

}

- (void)donePressed:(id)sender
{
    [self saveSelection:selectionIndex];
    if(self.delegate&&[self.delegate respondsToSelector:@selector(onLensSelectionFinished)])
        [self.delegate onLensSelectionFinished];
    [self closeViewController];
}

- (void)cancelPressed:(id)sender
{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(onLensSelectionClosed)])
        [self.delegate onLensSelectionClosed];
    [self closeViewController];
}

- (void)saveSelection:(int)index
{
    if(index>=0) {
        DMDLensElement *elem=(DMDLensElement*)[dmdLensDatabase objectAtIndex:index];
        [userDefaults setObject:elem.lensID forKey:DMD_CURRENT_SELECTED_LENS_KEY];
        [userDefaults synchronize];
    }
}

- (void)closeViewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dmdLensDatabase.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str=[userDefaults objectForKey:DMD_CURRENT_SELECTED_LENS_KEY];
    DMDLensElement *elem=(DMDLensElement*)[dmdLensDatabase objectAtIndex:indexPath.row];
    selectionIndex=(str&&[str isEqualToString:elem.lensID])?-1:(int)indexPath.row;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:DMD_LENS_SELECTOR_REUSABLE_ID];
    
    //if(!cell) {
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DMD_LENS_SELECTOR_REUSABLE_ID] ;
    //}
    DMDLensElement *elem=(DMDLensElement*)[dmdLensDatabase objectAtIndex:indexPath.row];
    cell.textLabel.textColor=[UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:1.0];
    [cell.textLabel setText:elem.lensName];
    [cell.textLabel setFont:[UIFont systemFontOfSize:24]];
    cell.detailTextLabel.textColor=[UIColor lightGrayColor];
    [cell.detailTextLabel setText:elem.lensDescription];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:15]];
    [cell.imageView setImage:elem.lensImage?[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:elem.lensImage ofType:@"png"]]:nil];
    
    NSString *userSelection=[userDefaults objectForKey:DMD_CURRENT_SELECTED_LENS_KEY];
    if(userSelection && [userSelection isEqualToString:elem.lensID]) {
        [tv selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

- (void)dealloc
{
    if(dmdLensDatabase) dmdLensDatabase=nil;
    if(titleLabel) titleLabel=nil;
    if(subTitleLabel) subTitleLabel=nil;
    if(tv) tv=nil;
}

@end
