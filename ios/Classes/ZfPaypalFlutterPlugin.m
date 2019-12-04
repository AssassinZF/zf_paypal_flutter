#import "ZfPaypalFlutterPlugin.h"
#import "BraintreeCore.h"
#import "BraintreeDropIn.h"
#import "BraintreePayPal.h"

@interface ZfPaypalFlutterPlugin()<BTViewControllerPresentingDelegate,BTAppSwitchDelegate>
{
    UIViewController *_viewController;
    FlutterResult _callbackResult;
    BTAPIClient * _braintreeClient;
}
@end

@implementation ZfPaypalFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"zf_paypal_flutter"
                                     binaryMessenger:[registrar messenger]];
    
    UIViewController *vc =
    [UIApplication sharedApplication].delegate.window.rootViewController;
    ZfPaypalFlutterPlugin* instance = [[ZfPaypalFlutterPlugin alloc] initWithViewController:vc];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    _callbackResult = result;
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }else if([@"paypal" isEqualToString:call.method]){
        NSString *authorizationKey = @"sandbox_mf5wtngr_2sk4yrpjxtsx3zwc";//sandbix env
        _braintreeClient = [[BTAPIClient alloc] initWithAuthorization:authorizationKey];
        //      [self showDropIn:authorizationKey];
        [self customPayPalButtonTapped:call.arguments];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)customPayPalButtonTapped:(NSDictionary *)payParam {
    
    
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:_braintreeClient];
    payPalDriver.viewControllerPresentingDelegate = self;
    payPalDriver.appSwitchDelegate = self; // Optional
    
    // Start the Vault flow, or...
//    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
//        NSLog(@"...");
//    }];
    
    // ...start the Checkout flow
    BTPayPalRequest *request = [[BTPayPalRequest alloc] initWithAmount:[NSString stringWithFormat:@"%f",[payParam[@"Amount"] doubleValue]]];
    request.currencyCode = @"USD"; // Optional; see BTPayPalRequest.h for other options
//    request.merchantAccountId = @"2sk4yrpjxtsx3zwc";
    request.localeCode = @"zh_CN";
    [payPalDriver requestOneTimePayment:request
                             completion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
                                 NSLog(@"...");
                                 if (error != nil) {
                                     self->_callbackResult(error.description);
                                 }else if (tokenizedPayPalAccount != nil){
                                     NSLog(@"Got a nonce: %@", tokenizedPayPalAccount.nonce);
                                     self->_callbackResult(tokenizedPayPalAccount.nonce);
                                 }else{
                                     self->_callbackResult(@"支付取消");
                                 }
                             }];
}

#pragma mark - BTViewControllerPresentingDelegate
// Required
- (void)paymentDriver:(id)paymentDriver
requestsPresentationOfViewController:(UIViewController *)viewController {
    [_viewController presentViewController:viewController animated:YES completion:nil];
}

// Required
- (void)paymentDriver:(id)paymentDriver
requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showDropIn:(NSString *)clientTokenOrTokenizationKey {
    BTDropInRequest *request = [[BTDropInRequest alloc] init];
    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:clientTokenOrTokenizationKey request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"ERROR");
        } else if (result.cancelled) {
            NSLog(@"CANCELLED");
        } else {
            
            // Use the BTDropInResult properties to update your UI
            // result.paymentOptionType
            // result.paymentMethod
            // result.paymentIcon
            // result.paymentDescription
        }
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    [_viewController presentViewController:dropIn animated:YES completion:nil];
}

#pragma mark - BTAppSwitchDelegate

// Optional - display and hide loading indicator UI
- (void)appSwitcherWillPerformAppSwitch:(id)appSwitcher {
    
    [self showLoadingUI];
    // You may also want to subscribe to UIApplicationDidBecomeActiveNotification
    // to dismiss the UI when a customer manually switches back to your app since
    // the payment button completion block will not be invoked in that case (e.g.
    // customer switches back via iOS Task Manager)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideLoadingUI:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)appSwitcherWillProcessPaymentInfo:(id)appSwitcher {
    [self hideLoadingUI:nil];
}

#pragma mark - Private methods

- (void)showLoadingUI {
    
}

- (void)hideLoadingUI:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
}


- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    // Update URL with your server
    NSURL *paymentURL = [NSURL URLWithString:@"https://your-server.example.com/checkout"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:paymentURL];
    request.HTTPBody = [[NSString stringWithFormat:@"payment_method_nonce=%@", paymentMethodNonce] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // TODO: Handle success and failure
    }] resume];
}

@end
