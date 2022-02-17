const APP_ENV_DEV = false;
const ENABLE_TWILIO_AUTH = false;
const ENABLE_FIREBASE_AUTH = true;
var APPROVE_ONLY = false;
var FORCE_MEMBERSHIP = false;
var USER_TRIAL_PERIOD = false;
var TRIAL_DAYS = 0;
var ACTIVE_ROOM_UPDATE = 10;
var MAIN_CLUB_ID = "";

//AWARD POINTS
var AWARD_COINS = false;
var SING_UP_COINS = 0;
var PREMIUM_UPGRADE_COINS_AMOUNT = 0;
var IMAGE_UPLOAD_SIZE = 300;

//agora app id
var APP_ID = 'eb2b573198f24c98a285c82094696299';

//agora token path
const tokenpath = "https://us-central1-gisthouse-887e3.cloudfunctions.net/generateagoratoken";
const vsdktokenpath = "https://us-central1-gisthouse-887e3.cloudfunctions.net/videosdktoken";
final getmeetingidUrl = "https://api.videosdk.live/v1/meetings";

//api url
const gistcoindeposit = "https://checkout.gistcoin.io/api/deposit/initiate";
const merchantId = "GCM618039";
const publicKey = "pk_test_HjYlOaugnz3hzkES4GDNf7lqdNeiDC37BIlkpJf9nPAp1cHhz5PiNDFluN0l";
const depositfinalize = "https://checkout.gistcoin.io/api/deposit/finalize";

//firebase server token
const serverToken =
    "AAAA3R3jUA8:APA91bGvPV4IA4IhCJ9tpYP5We7tGgCz1AVjS78WCsWgMpuyIqb2DgAMzQRVR7jhppny8L5kw4sGAG8HZqVjmnDB9LcshRuo7FP1w46T397CBA1fzBzG_BBMuwqDgt7c2xj8nyUANJEA";

/*
    sharing of links configurations
 */
//firebase deep link share url
const deeplinkuriPrefix = "https://gisthouseroom.page.link";

/*
  valid website domain where users will be directed if the app is not installed
 */
const websitedomain = "https://gisthouse.com";

/*
    app package name
    package name to checked if its installed and if not then ${websitedomain} will invoked
 */
const packagename = "com.gistgist.gisthouse";

/*
* google play store url, for users to update the app
* */
const playstoreUrl =
    "https://play.google.com/store/apps/details?id=com.gistgist.gisthouse&hl=en_US&gl=US";


// const Stripe_Secret_Key = "sk_test_51JAh2WIkB1tLztr96L6wnMBYa3YiOefq9hLO3mKXUuqkWedjTwfsaHqmJNxH0XaWKFXgx6O0iX1k851eynKRkAcl00WgSKKBPV";
// const Stripe_Pulic_Key = "pk_test_51JAh2WIkB1tLztr9Gaezdh2yQpzxShrrEMyfKBJFWg2uHKOzbm0DVfNe5TDehF2UbcVhtBcCZOQDOIG0Qsckt5SI00BIf2zAMs";

const Stripe_Secret_Key = "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";
const Stripe_Pulic_Key = "pk_live_51JAh2WIkB1tLztr9WqufnOg9EDorkhZ9flWs04tAuwdagZ6tNrioPUGFhC3z9qGggz6aTVUXjir9yTQyvGmwsimx00HBDKVIzG";

const mongoDbClusterConnectionString = "mongodb+srv://gist-house-user:qPXzKQkSOqdL7AP3@cluster0.trtul.mongodb.net/gistHouseDatabase?retryWrites=true&w=majority";

