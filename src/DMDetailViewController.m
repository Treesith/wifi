//
//  DMDetailViewController.m
//
//
//  Created by David Murray on 2013-03-03.
//
//

#import "DMDetailViewController.h"
#import "DMNetworksManager.h"

@interface DMDetailViewController ()

- (void)_managerDidFinishScanning;
- (void)_refreshControlWasPulled;

@end

@implementation DMDetailViewController

- (id)initWithStyle:(UITableViewStyle)style network:(DMNetwork *)network
{
	self = [super initWithStyle:style];

	if (self) {
		_network = [network retain];

		_networkRecord = [[network record] copy];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_managerDidFinishScanning) name:kDMNetworksManagerDidFinishScanning object:nil];
	}

	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[_network release];
	[_networkRecord release];

	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self setTitle:[_network SSID]];

	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(_refreshControlWasPulled) forControlEvents:UIControlEventValueChanged];
	[self setRefreshControl:refreshControl];
	[refreshControl release];
}

- (void)_managerDidFinishScanning
{
	[[self refreshControl] endRefreshing];

	NSArray *networks = [[DMNetworksManager sharedInstance] networks];

	for (DMNetwork *network in networks) {
		if ([[network BSSID] isEqualToString:[_network BSSID]]) {
			[_network release];
			_network = nil;
			_network = [network retain];

			[_networkRecord release];
			_networkRecord = nil;
			_networkRecord = [[network record] copy];

			[[self tableView] reloadData];
		}
	}
}

- (void)_refreshControlWasPulled
{
	[[DMNetworksManager sharedInstance] scan];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return ([_network isCurrentNetwork] ? 3 : 2);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	switch (section) {
		case 0:
			return ([_network isCurrentNetwork] ? 1 : 10);
		case 1:
			return ([_network isCurrentNetwork] ? 10 : [[_networkRecord allKeys] count]);
		case 2:
			return ([_network isCurrentNetwork] ? [[_networkRecord allKeys] count] : 0);
		default:
			return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *disconnectCellIndetifier = @"DisconnectCell";
	static NSString *informationCellIdentifier = @"InformationCell";

	UITableViewCell *cell = nil;

	switch ([indexPath section]) {
		case 0: {
			if ([_network isCurrentNetwork]) {
				cell = [tableView dequeueReusableCellWithIdentifier:disconnectCellIndetifier];

				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:disconnectCellIndetifier] autorelease];
					[[cell textLabel] setTextAlignment:NSTextAlignmentCenter];
				}

				[[cell textLabel] setText:@"Disconnect"];
				break;

			} else {
				cell = [tableView dequeueReusableCellWithIdentifier:informationCellIdentifier];

				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:informationCellIdentifier] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
				}

				switch ([indexPath row]) {
					case 0: {
						[[cell textLabel] setText:@"Encryption Model"];
						[[cell detailTextLabel] setText:[_network encryptionModel]];
						break;
					} case 1: {
						[[cell textLabel] setText:@"Channel"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%i", [_network channel]]];
						break;
					} case 2: {
						[[cell textLabel] setText:@"Bars"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%i", [_network bars]]];
						break;
					} case 3: {
						[[cell textLabel] setText:@"RSSI"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%.0f dBm", [_network RSSI]]];
						break;
					} case 4: {
						[[cell textLabel] setText:@"Apple Personal Hotspot"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", ([_network isAppleHotspot] ? @"Yes" : @"No")]];
						break;
					} case 5: {
						[[cell textLabel] setText:@"Mac Address"];
						[[cell detailTextLabel] setText:[_network BSSID]];
						break;
					} case 6: {
						[[cell textLabel] setText:@"Ad Hoc"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", ([_network isAdHoc] ? @"Yes" : @"No")]];
						break;
					} case 7: {
						[[cell textLabel] setText:@"Hidden"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", ([_network isHidden] ? @"Yes" : @"No")]];
						break;
					} case 8: {
						[[cell textLabel] setText:@"AP Mode"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%i", [_network APMode]]];
						break;
					} case 9: {
						[[cell textLabel] setText:@"Vendor"];
						[[cell detailTextLabel] setText:[_network vendor]];
						break;
					}
				}

				break;
			}
		} case 1: {
			if ([_network isCurrentNetwork]) {
				cell = [tableView dequeueReusableCellWithIdentifier:informationCellIdentifier];

				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:informationCellIdentifier] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
				}

				switch ([indexPath row]) {
					case 0: {
						[[cell textLabel] setText:@"Encryption Model"];
						[[cell detailTextLabel] setText:[_network encryptionModel]];
						break;
					} case 1: {
						[[cell textLabel] setText:@"Channel"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%i", [_network channel]]];
						break;
					} case 2: {
						[[cell textLabel] setText:@"Bars"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%i", [_network bars]]];
						break;
					} case 3: {
						[[cell textLabel] setText:@"RSSI"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%.0f dBm", [_network RSSI]]];
						break;
					} case 4: {
						[[cell textLabel] setText:@"Apple Personal Hotspot"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", ([_network isAppleHotspot] ? @"Yes" : @"No")]];
						break;
					} case 5: {
						[[cell textLabel] setText:@"Mac Address"];
						[[cell detailTextLabel] setText:[_network BSSID]];
						break;
					} case 6: {
						[[cell textLabel] setText:@"Ad Hoc"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", ([_network isAdHoc] ? @"Yes" : @"No")]];
						break;
					} case 7: {
						[[cell textLabel] setText:@"Hidden"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", ([_network isHidden] ? @"Yes" : @"No")]];
						break;
					} case 8: {
						[[cell textLabel] setText:@"AP Mode"];
						[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%i", [_network APMode]]];
						break;
					} case 9: {
						[[cell textLabel] setText:@"Vendor"];
						[[cell detailTextLabel] setText:[_network vendor]];
						break;
					}
				}

				break;
			} else {
				cell = [tableView dequeueReusableCellWithIdentifier:informationCellIdentifier];

				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:informationCellIdentifier] autorelease];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
				}

				// XXX: Consider caching this.
				NSArray *keys = [_networkRecord allKeys];
				NSString *key = [keys objectAtIndex:[indexPath row]];
				[[cell textLabel] setText:key];
				[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", [_networkRecord objectForKey:key]]];
				break;
			}
		} case 2: {
			cell = [tableView dequeueReusableCellWithIdentifier:informationCellIdentifier];

			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:informationCellIdentifier] autorelease];
				[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			}

			// XXX: Consider caching this.
			NSArray *keys = [_networkRecord allKeys];
			NSString *key = [keys objectAtIndex:[indexPath row]];
			[[cell textLabel] setText:key];
			[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", [_networkRecord objectForKey:key]]];
		}
	}

	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return ([_network isCurrentNetwork] ? nil : @"Information");
		case 1:
			return ([_network isCurrentNetwork] ? @"Information" : @"Record");
		case 2:
			return ([_network isCurrentNetwork] ? @"Record" : nil);
		default:
			return nil;
	}
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath section] == 0 && [_network isCurrentNetwork]) {
		[[DMNetworksManager sharedInstance] disassociate];

		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch ([indexPath section]) {
		case 0:
			return ([_network isCurrentNetwork] ? NO : YES);
		case 1:
			return YES;
		case 2:
			return YES;
		default:
			return NO;
	}
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

	NSString *text;
	if ([[cell detailTextLabel] text])
		text = [NSString stringWithFormat:@"%@: %@", [[cell textLabel] text], [[cell detailTextLabel] text]];
	else
		text = [[cell textLabel] text];

	[[UIPasteboard generalPasteboard] setString:text];
}

@end
