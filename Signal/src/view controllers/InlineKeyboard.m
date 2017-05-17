//
//  InlineKeyboard.m
//  Medxnote
//
//  Created by Jan Nemecek on 13/4/17.
//  Copyright © 2017 Open Whisper Systems. All rights reserved.
//

#import "InlineKeyboard.h"
#import "InlineKeyboardCell.h"

@interface InlineKeyboard () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
    
@property NSArray *answers;

@end

@implementation InlineKeyboard
    
- (instancetype)initWithAnswers:(NSArray *)answers {
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
//        layout.estimatedItemSize = CGSizeMake(150, 60);
        layout.sectionInset = UIEdgeInsetsMake(5,10,5,10);
        _collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor colorWithWhite:249/255.0f alpha:1.0f];
//        _collectionView.scrollEnabled = false;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"InlineKeyboardCell" bundle:nil] forCellWithReuseIdentifier:@"KeyboardCell"];
        _answers = answers;
    }
    return self;
}
    
#pragma mark - Collection View
    
- (NSDictionary *)cellAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *answerSection = _answers[indexPath.section][@"cells"];
    NSDictionary *dict = answerSection[indexPath.row];
    return dict;
}
    
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _answers.count;
}
    
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *answerSection = _answers[section][@"cells"];
    return answerSection.count;
}
    
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    InlineKeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KeyboardCell" forIndexPath:indexPath];
    NSDictionary *dict = [self cellAtIndexPath:indexPath];
    cell.titleLabel.text = dict[@"title"];
    [cell customizeWithDictionary:dict[@"style"]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [self cellAtIndexPath:indexPath];
    [self.delegate tappedInlineKeyboardCell:dict];
}
    
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *answerSection = _answers[indexPath.section][@"cells"];
    CGFloat totalWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat itemWidth = totalWidth/answerSection.count;
    return CGSizeMake(itemWidth-20, 40);
}

@end
