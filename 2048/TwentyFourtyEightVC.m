//
//  TwentyFourtyEightVC.m
//  2048
//
//  Created by Alex Smith on 18/10/2015.
//  Copyright © 2015 Alex Smith. All rights reserved.
//

#import "TwentyFourtyEightVC.h"
#import "TwentyFourtyEight.h"
#import "NoScrollGridVC.h"
#import "TwentyFourtyEightTileOffset.h"

@interface TwentyFourtyEightVC () <GridVCDelegate>

@property (strong, nonatomic) NoScrollGridVC *boardCVC;

@property (strong, nonatomic) TwentyFourtyEight *game;
@property (strong, nonatomic) NSDictionary *tileColours;

// outlets
@property (weak, nonatomic) IBOutlet UICollectionView *boardView;
@property (weak, nonatomic) IBOutlet UIView *boardContainerView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@end

@implementation TwentyFourtyEightVC

-(void)newGameWithRows:(int)rows andColumns:(int)cols
{
    [self.game removeObserver:self forKeyPath:@"score"];
    for (id obj in self.boardView.subviews) {
        [obj removeFromSuperview];
    }
    self.game = [[TwentyFourtyEight alloc] initWithGameOfSize:(GridSize){rows, cols}];
}

#pragma mark - GridVCDelegate

-(void)swipedInDirection:(UISwipeGestureRecognizerDirection)direction
{
    switch (direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            [self.game swipeInDirection:@"LEFT"];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            [self.game swipeInDirection:@"RIGHT"];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            [self.game swipeInDirection:@"UP"];
            break;
        case UISwipeGestureRecognizerDirectionDown:
            [self.game swipeInDirection:@"DOWN"];
            break;
        default:
            break;
    }
}

#pragma mark - Properties

-(NSDictionary *)tileColours
{
    return @{@0 : [UIColor whiteColor],
             @2 : [UIColor grayColor],
             @4 : [UIColor greenColor],
             @8 : [UIColor redColor],
             @16 : [UIColor blueColor],
             @32 : [UIColor orangeColor]};
}

-(void)setBoardCVC:(NoScrollGridVC *)boardCVC
{
    _boardCVC = boardCVC;
    _boardCVC.delegate = self;
}

-(void)setGame:(TwentyFourtyEight *)game
{
    _game = game;
    
    self.boardCVC = [[NoScrollGridVC alloc] initWithgridSize:self.game.board.size collectionView:self.boardView andCellConfigureBlock:^(UICollectionViewCell *cell, Position position, int index) {
        if ([cell.contentView.subviews count] == 0) {
            NSNumber *valueAtCurrPos = [self.game.board objectAtPosition:position];
            cell.contentView.backgroundColor = self.tileColours[valueAtCurrPos];
            UILabel *cellValueLabel = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
            cellValueLabel.textAlignment = NSTextAlignmentCenter;
            cellValueLabel.font = [UIFont systemFontOfSize:28];
            cellValueLabel.text = [valueAtCurrPos isEqualToNumber:@0] ? @"" : [valueAtCurrPos stringValue];
            cellValueLabel.layer.borderColor = [UIColor blackColor].CGColor;
            cellValueLabel.layer.borderWidth = 1.0;
            [cell.contentView addSubview:cellValueLabel];
        } else {
            /*UILabel *cellValueLabel = [[cell.contentView subviews] firstObject];
            
            TwentyFourtyEightTileOffset *offsetForCurrPos = [self.game.offsetsForMostRecentMove objectAtPosition:position];
            if (offsetForCurrPos.rowOffset != 0 || offsetForCurrPos.colOffset != 0) {
             
                UILabel *dummyLabel = [[UILabel alloc] initWithFrame:cell.frame];
                dummyLabel.textAlignment = NSTextAlignmentCenter;
                dummyLabel.font = [UIFont systemFontOfSize:28];
                dummyLabel.text = @"HELLO";
                [self.boardContainerView addSubview:dummyLabel];
                
                Position newPos = (Position){position.row + offsetForCurrPos.rowOffset, position.column + offsetForCurrPos.colOffset};
                int index = [self.boardCVC.grid indexOfPosition:newPos];
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                CGRect frame = [self.boardView cellForItemAtIndexPath:indexPath].frame;
                
                [UIView animateWithDuration:1.0
                                 animations:^{
                                     dummyLabel.frame = frame;
                                 }
                                 completion:^(BOOL finished) {
                                     [dummyLabel removeFromSuperview];
                                     NSNumber *valueAtCurrPos = [self.game.board objectAtPosition:position];
                                     cell.contentView.backgroundColor = self.tileColours[valueAtCurrPos];
                                     cellValueLabel.text = [valueAtCurrPos isEqualToNumber:@0] ? @"" : [valueAtCurrPos stringValue];
                                 }];
            } else {
                NSNumber *valueAtCurrPos = [self.game.board objectAtPosition:position];
                cell.contentView.backgroundColor = self.tileColours[valueAtCurrPos];
                cellValueLabel.text = [valueAtCurrPos isEqualToNumber:@0] ? @"" : [valueAtCurrPos stringValue];
            }*/
            
            UILabel *cellValueLabel = [[cell.contentView subviews] firstObject];
            NSNumber *valueAtCurrPos = [self.game.board objectAtPosition:position];
            cell.contentView.backgroundColor = self.tileColours[valueAtCurrPos];
            cellValueLabel.text = [valueAtCurrPos isEqualToNumber:@0] ? @"" : [valueAtCurrPos stringValue];
        }
    } andCellTapHandler:NULL];
    
    [self.game addObserver:self forKeyPath:@"score" options:NSKeyValueObservingOptionNew context:nil];
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"score"]) {
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
        //[self.boardView reloadData];
        
        for (int row = 0; row < self.game.board.size.rows; row++) {
            for (int col = 0; col < self.game.board.size.columns; col++) {
                Position position = (Position){row, col};
                
                TwentyFourtyEightTileOffset *offsetForCurrPos = [self.game.offsetsForMostRecentMove objectAtPosition:position];
                if (offsetForCurrPos.rowOffset != 0 || offsetForCurrPos.colOffset != 0) {
                    
                    int currIndex = [self.boardCVC.grid indexOfPosition:position];
                    NSIndexPath *currIndexPath = [NSIndexPath indexPathForItem:currIndex inSection:0];
                    UICollectionViewCell *cell = [self.boardView cellForItemAtIndexPath:currIndexPath];
                    UILabel *cellValueLabel = [[cell.contentView subviews] firstObject];
                    [self.boardView reloadItemsAtIndexPaths:@[currIndexPath]];

                    UILabel *dummyLabel = [[UILabel alloc] initWithFrame:cell.frame];
                    dummyLabel.backgroundColor = cell.contentView.backgroundColor;
                    dummyLabel.textAlignment = NSTextAlignmentCenter;
                    dummyLabel.font = [UIFont systemFontOfSize:28];
                    dummyLabel.text = cellValueLabel.text;
                    [self.boardContainerView addSubview:dummyLabel];
                    
                    Position newPos = (Position){position.row + offsetForCurrPos.rowOffset, position.column + offsetForCurrPos.colOffset};
                    int index = [self.boardCVC.grid indexOfPosition:newPos];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                    CGRect frame = [self.boardView cellForItemAtIndexPath:indexPath].frame;
                    
                    [UIView animateWithDuration:0.5
                                     animations:^{
                                         dummyLabel.frame = frame;
                                     }
                                     completion:^(BOOL finished) {
                                         
                                         [UIView animateWithDuration:0 animations:^{
                                             [self.boardView reloadItemsAtIndexPaths:@[indexPath]];
                                         } completion:^(BOOL finished) {
                                             [dummyLabel removeFromSuperview];
                                         }];
                                     }];
                } else if (offsetForCurrPos.newTileInserted) {
                    int currIndex = [self.boardCVC.grid indexOfPosition:position];
                    NSIndexPath *currIndexPath = [NSIndexPath indexPathForItem:currIndex inSection:0];
                    //UICollectionViewCell *cell = [self.boardView cellForItemAtIndexPath:currIndexPath];
                    [self.boardView reloadItemsAtIndexPaths:@[currIndexPath]];
                }
            }
        }
    }
}

#pragma mark - View Life Cycle

#define DEFAULT_ROWS 4
#define DEFAULT_COLS 4
-(void)viewDidLoad
{
    [self newGameWithRows:DEFAULT_ROWS andColumns:DEFAULT_COLS];
}

#pragma mark - Action

- (IBAction)newGame:(UIBarButtonItem *)sender
{
    UIAlertController *newGameAlert = [UIAlertController alertControllerWithTitle:@"New Game" message:@"Please select a board size:" preferredStyle:UIAlertControllerStyleAlert];
    
    [newGameAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Board height (4 is default)";
    }];
    
    [newGameAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Board width (4 is default)";
    }];
    
    [newGameAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL]];
    [newGameAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *heightText = [newGameAlert.textFields firstObject].text;
        NSString *widthText = [newGameAlert.textFields firstObject].text;
        int numRows = [heightText intValue];
        int numCols = [widthText intValue];
        [self newGameWithRows:numRows andColumns:numCols];
    }]];
    
    [self presentViewController:newGameAlert animated:YES completion:NULL];
}


@end
