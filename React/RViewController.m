//
//  RViewController.m
//  React
//
//  Created by Andreas Hammer on 02/11/13.
//  Copyright (c) 2013 Andreas Hammer. All rights reserved.
//

#import "RViewController.h"

@interface RViewController ()

@end

int second;
int fraction;
int state;
int state2;
NSTimer *switchTimer;
NSTimer *newGameTimer;
NSString *plistPath;
NSInteger highScore;
NSInteger totalTimeDelay;
NSInteger gamesPlayed;
NSInteger average;

@implementation RViewController

-(NSString *)docsDir{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    plistPath = [[self docsDir] stringByAppendingPathComponent:@"Data.plist"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:plistPath]){
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle]pathForResource:@"Data" ofType:@"plist"] toPath:plistPath error:nil];
        [self loadData];
    }
    else{
        [self loadData];
    }
    state2 = 0;
    [self mainMenu];
}

-(void)mainMenu{
    [[[UIAlertView alloc] initWithTitle:@"React!" message:@"You wait for the screen to be black and tap, the lower highscore you get the better!" delegate:self cancelButtonTitle:@"Start!" otherButtonTitles:@"Show Highscore", @"Stats", nil] show];
}

-(void)loadData{
    NSArray *objects = [[NSArray alloc] initWithContentsOfFile:plistPath];
    if([objects count] < 4){
        [[NSFileManager defaultManager] removeItemAtPath:plistPath error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"] toPath:plistPath error:nil];
    }
    NSNumber *num = [objects objectAtIndex:0];
    highScore = num.intValue;
    num = [objects objectAtIndex:1];
    totalTimeDelay = num.intValue;
    num = [objects objectAtIndex:2];
    gamesPlayed = num.intValue;
    num = [objects objectAtIndex:3];
    average = num.intValue;
}

-(void)save{
    NSNumber *num = [[NSNumber alloc] initWithInt:(int)highScore];
    NSNumber *num1 = [[NSNumber alloc] initWithInt:(int)totalTimeDelay];
    NSNumber *num2 = [[NSNumber alloc] initWithInt:(int)gamesPlayed];
    NSNumber *num3 = [[NSNumber alloc] initWithInt:(int)average];
    NSArray *objects = [[NSArray alloc] initWithObjects:num, num1, num2, num3, nil];
    [objects writeToFile:plistPath atomically:YES];
    
    
}

-(void)newGame{
    [self save];
    state = 0;
    state2 = 1;
    fraction = 0;
    second = 0;
    NSLog(@"New Game");
    [self.view setBackgroundColor:[UIColor whiteColor]];
    NSInteger delay = (int)1+arc4random()%10;
    newGameTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(start) userInfo:nil repeats:NO];
}

-(void)start{
    [newGameTimer invalidate];
    NSLog(@"Game Start");
    newGameTimer = nil;
    state = 1;
    switchTimer = [NSTimer scheduledTimerWithTimeInterval:0.0001 target:self selector:@selector(time) userInfo:nil repeats:YES];
    [self.view setBackgroundColor:[UIColor blackColor]];
}

-(void)time{
    fraction++;
    if(fraction >= 10000){
        second++;
        fraction = 0;
        NSLog(@"Second ran");
    }
    if(second == 10){
        [self save];
        exit(0);
    }
}

-(IBAction)click:(id)sender{
    [self save];
    if(state == 1){
        [self checkNewHighScore];
        NSString *string;
        [switchTimer invalidate];
        switchTimer = nil;
        NSLog(@"Game complete");
        if(fraction < 10){
            string = [NSString stringWithFormat:@"You reacted in: %i,000%i seconds! Highscore: %@ seconds", second, fraction, [self createStringsOfHighScore]];
        }
        else if(fraction < 100 && fraction > 9){
            string = [NSString stringWithFormat:@"You reacted in: %i,00%i seconds! Highscore: %@ seconds", second, fraction, [self createStringsOfHighScore]];
        }
        else if(fraction < 1000 && fraction > 99){
            string = [NSString stringWithFormat:@"You reacted in: %i,0%i seconds! Highscore: %@ seconds", second, fraction, [self createStringsOfHighScore]];
        }
        else{
            string = [NSString stringWithFormat:@"You reacted in: %i,%i seconds! Highscore: %@ seconds", second, fraction, [self createStringsOfHighScore]];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"React!" message:string delegate:self cancelButtonTitle:@"Restart" otherButtonTitles:@"Show Highscore", @"Stats", nil];
        [alert show];
        return;
    }
    else if(state == 0){
        NSLog(@"Not now");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"React!" message:@"You can't tap before the screen turns black!" delegate:self cancelButtonTitle:@"Restart" otherButtonTitles:nil];
        [alert show];
        [newGameTimer invalidate];
        newGameTimer = nil;
        return;
    }
}

-(void)checkNewHighScore{
    int tst = second*10000;
    tst += fraction;
    [self addStats:tst];
    if(tst < highScore){
        highScore = tst;
    }
    [self save];
}

-(void)addStats:(int)timeDelay{
    gamesPlayed++;
    totalTimeDelay += timeDelay;
    [self averageCalculationFunc];
}

-(void)averageCalculationFunc{
    average = totalTimeDelay/gamesPlayed;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        [self newGame];
        return;
    }
    [self save];
    if(buttonIndex == 1){
        if(state2 == 0){
        [[[UIAlertView alloc] initWithTitle:@"React!" message:[NSString stringWithFormat:@"Your highscore is: %@ seconds", [self createStringsOfHighScore]] delegate:self cancelButtonTitle:@"Start" otherButtonTitles:nil]show];
        }
        else{
            [[[UIAlertView alloc] initWithTitle:@"React!" message:[NSString stringWithFormat:@"Your highscore is: %@ seconds", [self createStringsOfHighScore]] delegate:self cancelButtonTitle:@"Restart" otherButtonTitles:nil]show];
        }
    }
    else if(buttonIndex == 2){
        if(state2 == 0){
            [[[UIAlertView alloc] initWithTitle:@"React!" message:[NSString stringWithFormat:@"Highscore: %@ seconds \n Total timedelay: %@ seconds \n Amount of games played: %li \n Average timedelay: %@ seconds", [self createStringsOfHighScore], [self createStringsOfTotalTimeDelay], (long)gamesPlayed, [self createStringsOfAverage]] delegate:self cancelButtonTitle:@"Start" otherButtonTitles:nil]show];
        }
        else{
            [[[UIAlertView alloc] initWithTitle:@"React!" message:[NSString stringWithFormat:@"Highscore: %@ seconds \n Total timedelay: %@ seconds \n Amount of games played: %li \n Average timedelay: %@ seconds", [self createStringsOfHighScore], [self createStringsOfTotalTimeDelay], (long)gamesPlayed, [self createStringsOfAverage]] delegate:self cancelButtonTitle:@"Restart" otherButtonTitles:nil]show];
        }
    }
}

-(NSString *)createStringsOfAverage{
    NSString *string;
    int second1 = (int)average/10000;
    int fraction1 = (int)average-(10000*second1);
    if(fraction1 < 10){
        string = [NSString stringWithFormat:@"%i,000%i", second1, fraction1];
    }
    else if(fraction1 < 100 && fraction1 > 9){
        string = [NSString stringWithFormat:@"%i,00%i", second1, fraction1];
    }
    else if(fraction1 < 1000 && fraction1 > 99){
        string = [NSString stringWithFormat:@"%i,0%i", second1, fraction1];
    }
    else{
        string = [NSString stringWithFormat:@"%i,%i", second1, fraction1];
    }
    return string;
}

-(NSString *)createStringsOfTotalTimeDelay{
    NSString *string;
    int second1 = (int)totalTimeDelay/10000;
    int fraction1 = (int)totalTimeDelay-(10000*second1);
    if(fraction1 < 10){
        string = [NSString stringWithFormat:@"%i,000%i", second1, fraction1];
    }
    else if(fraction1 < 100 && fraction1 > 9){
        string = [NSString stringWithFormat:@"%i,00%i", second1, fraction1];
    }
    else if(fraction1 < 1000 && fraction1 > 99){
        string = [NSString stringWithFormat:@"%i,0%i", second1, fraction1];
    }
    else{
        string = [NSString stringWithFormat:@"%i,%i", second1, fraction1];
    }
    return string;
}

-(NSString *)createStringsOfHighScore{
    NSString *string;
    int second1 = (int)highScore/10000;
    int fraction1 = (int)highScore-(10000*second1);
    if(fraction1 < 10){
        string = [NSString stringWithFormat:@"%i,000%i", second1, fraction1];
    }
    else if(fraction1 < 100 && fraction1 > 9){
        string = [NSString stringWithFormat:@"%i,00%i", second1, fraction1];
    }
    else if(fraction1 < 1000 && fraction1 > 99){
        string = [NSString stringWithFormat:@"%i,0%i", second1, fraction1];
    }
    else{
        string = [NSString stringWithFormat:@"%i,%i", second1, fraction1];
    }
    return string;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
