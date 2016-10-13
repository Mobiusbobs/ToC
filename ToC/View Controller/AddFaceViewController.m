//
//  AddFaceViewController.m
//  ToC
//
//  Created by LinYiting on 2016/10/13.
//  Copyright © 2016年 Mobiusbobs. All rights reserved.
//

#import "AddFaceViewController.h"
#import <TGCameraViewController.h>
#import <Masonry.h>

// UI
#import "AddFaceCollectionViewCell.h"
#import "FaceCollectionViewCell.h"

@interface AddFaceViewController ()
<
    TGCameraDelegate,
    UICollectionViewDelegate,
    UICollectionViewDataSource
>
@property (nonatomic, strong) NSArray *photosArray;

@property (nonatomic, assign) CGSize cellSize;
@property (nonatomic, weak) UICollectionView *collectionView;


@end

@implementation AddFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self constructViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadPhotoList
{
    self.photosArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"photos"];
    [self.collectionView reloadData];
}

- (void)constructViews
{
    // close button
    self.view.backgroundColor = [UIColor colorWithRed:119.0f/255.0f green:169.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    NSInteger numberOfColumns = 3;
    CGFloat itemWidth = floorf(CGRectGetWidth(self.view.frame) / numberOfColumns) - 2;
    self.cellSize = CGSizeMake(itemWidth, itemWidth);
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closePressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@40);
        make.left.top.equalTo(self.view).with.offset(16);
    }];
    
    [self setupCollectionView];
}

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = self.cellSize;
    layout.minimumLineSpacing = 2.0;
    layout.minimumInteritemSpacing = 2.0;
    
    
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.tag = 2;
    [collectionView registerClass:[AddFaceCollectionViewCell class]
       forCellWithReuseIdentifier:addFaceCollectionViewCellIdentifier];
    [collectionView registerClass:[FaceCollectionViewCell class]
       forCellWithReuseIdentifier:faceCollectionViewCellIdentifier];
    
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor colorWithRed:119.0f/255.0f green:169.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    [self.view addSubview:collectionView];
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(56);
    }];
    
    self.collectionView = collectionView;
    [self reloadPhotoList];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.photosArray count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        AddFaceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:addFaceCollectionViewCellIdentifier
                                                                                    forIndexPath:indexPath];
        
        if (!cell) {
            cell = [AddFaceCollectionViewCell new];
        }
        return cell;
    } else {
        FaceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:faceCollectionViewCellIdentifier
                                                                                    forIndexPath:indexPath];
        
        if (!cell) {
            cell = [FaceCollectionViewCell new];
        }
        
        [cell updateWithPhotoName:self.photosArray[indexPath.row - 1]];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        TGCameraNavigationController *navigationController =
        [TGCameraNavigationController newWithCameraDelegate:self];
        
        [self presentViewController:navigationController animated:YES completion:nil];
    } else {
        if ([self.delegate respondsToSelector:@selector(didSelectFace:)]) {
            [self.delegate didSelectFace:self.photosArray[indexPath.row - 1]];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


- (void)closePressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TGCameraDelegate optional

- (void)cameraWillTakePhoto
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)cameraDidSavePhotoAtPath:(NSURL *)assetURL
{
    // When this method is implemented, an image will be saved on the user's device
    NSLog(@"%s album path: %@", __PRETTY_FUNCTION__, assetURL);
}

- (void)cameraDidSavePhotoWithError:(NSError *)error
{
    NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
}

#pragma mark - TGCameraDelegate required

- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidTakePhoto:(UIImage *)image
{
    [self saveImage:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image
{
    [self saveImage:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImage:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *UUID = [[NSUUID UUID] UUIDString];
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",UUID]];
    
    NSLog(@"pre writing to file");
    if (![imageData writeToFile:imagePath atomically:NO])
    {
        NSLog(@"Failed to cache image data to disk");
    }
    else
    {
        NSLog(@"the cachedImagedPath is %@",imagePath);
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"photos"]) {
            NSMutableArray *photosArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"photos"]];
            [photosArray addObject:UUID];
            [[NSUserDefaults standardUserDefaults] setObject:photosArray forKey:@"photos"];
        } else {
            NSMutableArray *photosArray = [[NSMutableArray alloc] init];
            [photosArray addObject:UUID];
            [[NSUserDefaults standardUserDefaults] setObject:photosArray forKey:@"photos"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self reloadPhotoList];
    }
}


@end