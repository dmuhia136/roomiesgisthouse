const BASE_URL2 = "http://34.215.46.113:8000";
const USER_ROUTE = BASE_URL2 + "/users";
const ACTIVITIES_ROUTE = BASE_URL2 + "/activities";
const TRANSACTIONS_ROUTE = BASE_URL2 + "/transactions";
const ENDED_ROOMS_ROUTE = BASE_URL2 + "/endedrooms";
const ONGOING_ROOMS_ROUTE = BASE_URL2 + "/ongoingrooms";
const UPCOMING_ROOMS_ROUTE = BASE_URL2 + "/upcomingroom";
const CLUBS_ROUTE = BASE_URL2 + "/clubs";
const UPLOAD_IMAGES_ROUTE = BASE_URL2 + "/vsdk";
const VSDK_ROUTE = BASE_URL2 + "/gistlytics";
const GISTLYTICS_ROUTE = BASE_URL2 + "/uploadimages";
const COINS_ROUTE = BASE_URL2 + "/coins";
const AUTH_API = BASE_URL2 + "/authenticate";
const SIGN_IN_ROUTE = BASE_URL2 + "/signin";

/// ******** Authenticate User POINTS ******* ///
const LOGIN = AUTH_API + "/login";
const SEND_CODE = SIGN_IN_ROUTE + "/sendcode";
const VERIFY_CODE = SIGN_IN_ROUTE + "/verifycode";
const AUTH_FOR_TESTING = SIGN_IN_ROUTE + "/ios";

/// ******** USER END POINTS ******* ///

//GET
const ALL_USERS = USER_ROUTE + "/";
const ALL_USERS_AFTER = USER_ROUTE + "/";
const ALL_USERS_WITH_LIMIT = USER_ROUTE + "/limit/";
const USER_BY_ID = USER_ROUTE + "/";
const USER_BY_FIRSTNAME = USER_ROUTE + "/firstname/";
const SEARCH_USER_BY_FIRSTNAME = USER_ROUTE + "/search/";
const USER_BY_USERNAME = USER_ROUTE + "/username/";
const USER_BY_COUNTRY = USER_ROUTE + "/country/";
const USER_BY_PHONE = USER_ROUTE + "/phonenumber/";
const USER_FOLLOWERS_TO_NOTIFY = USER_ROUTE + "/followers/tonotify/";
const USER_FOLLOWERS = USER_ROUTE + "/followers/";
const USER_FOLLOWERS_AFTER = USER_ROUTE + "/followers/after/user";
const USER_FOLLOWING = USER_ROUTE + "/following/";
const USER_FOLLOWING_AFTER = USER_ROUTE + "/following/after/user";
const USER_MUTUAL_FOLLOWER = USER_ROUTE + "/mutualfollow/";
const ONLINE_FRIENDS = USER_ROUTE + "/onlineFriends/";


///statistics/:type/:userid
const USER_STATISTICS = USER_ROUTE + "/statistics/";

//POST
const SAVE_USER = USER_ROUTE + "/";
const SAVE_USER_STATISTICS = USER_ROUTE + "/statistics";
const CHECK_USER_VERIFICATION = USER_ROUTE + "/verificationcheck/";

//PATCH
const UPDATE_USER = USER_ROUTE + "/";
const FOLLOW_USER = USER_ROUTE + "/follow/";
const UNFOLLOW_USER = USER_ROUTE + "/unfollow/";
const ADD_INTEREST = USER_ROUTE + "/interests/add/";
const REMOVE_INTEREST = USER_ROUTE + "/interests/remove/";
const BLOCK_USER = USER_ROUTE + "/block/add/";
const UNBLOCK_USER = USER_ROUTE + "/block/remove/";
const ADD_PAID_ROOM = USER_ROUTE + "/paidrooms/add/";

//DELETE
const DELETE_USER = USER_ROUTE + "/";

/// ******** USER END POINTS ******* ///

/// ******** UPCOMING ROOMS END POINTS ******* ///

//GET
const ALL_UPCOMING = UPCOMING_ROOMS_ROUTE + "/";
const ALL_UPCOMING_WITH_LIMIT = UPCOMING_ROOMS_ROUTE + "/allwithlimit/";
const UPCOMING_BY_ID = UPCOMING_ROOMS_ROUTE + "/";
const UPCOMING_FOR_USER = UPCOMING_ROOMS_ROUTE + "/userevents/";
const UPCOMING_FOR_USER_LIMIT = UPCOMING_ROOMS_ROUTE + "/userevents/limit/";
const UPCOMING_FOR_CLUB = UPCOMING_ROOMS_ROUTE + "/clubevents/";
const UPCOMING_FOR_CLUB_LIMIT = UPCOMING_ROOMS_ROUTE + "/clubevents/limit/";

//POST
const SAVE_UPCOMING = UPCOMING_ROOMS_ROUTE + "/";

//PATCH
const UPDATE_UPCOMING = UPCOMING_ROOMS_ROUTE + "/";
const ADD_NOTIFIED_UPCOMING = UPCOMING_ROOMS_ROUTE + "/tobenotified/add/";
const REMOVE_NOTIFIED_UPCOMING = UPCOMING_ROOMS_ROUTE + "/tobenotified/remove/";

//DELETE
const DELETE_UPCOMING = UPCOMING_ROOMS_ROUTE + "/";

/// ******** TRANSACTIONS END POINTS ******* ///

//GET
const ALL_TRANSACTIONS = TRANSACTIONS_ROUTE;
const TRANSACTIONS_FOR_USER = TRANSACTIONS_ROUTE + "/";

//POST
const SAVE_TRANSACTIONS = TRANSACTIONS_ROUTE;

/// ******** ONGOING ROOM END POINTS ******* ///

//GET
const ALL_ROOMS = ONGOING_ROOMS_ROUTE + "/";
const ROOM_BY_ID = ONGOING_ROOMS_ROUTE + "/id/";
const ALL_ROOMS_COMBINED = ONGOING_ROOMS_ROUTE + "/combinedrooms/";
const PRIVATE_ROOMS = ONGOING_ROOMS_ROUTE + "/privaterooms/";
const PUBLIC_ROOMS = ONGOING_ROOMS_ROUTE + "/publicrooms";
const CLUB_ROOMS_OPEN = ONGOING_ROOMS_ROUTE + "/clubrooms/open";
const CLUB_ROOMS_CLOSED = ONGOING_ROOMS_ROUTE + "/clubrooms/closed/";
const SOCIAL_ROOMS = ONGOING_ROOMS_ROUTE + "/socialrooms/";
const RAISED_HANDS = ONGOING_ROOMS_ROUTE + "/raisedHands/get/";
const ROOM_ALL_USERS = ONGOING_ROOMS_ROUTE + "/allusers/";
const ROOM_USER_BY_ID = ONGOING_ROOMS_ROUTE + "/user/";

//POST
const SAVE_ROOM = ONGOING_ROOMS_ROUTE + "/";

//UPDATE
const UPDATE_ROOM = ONGOING_ROOMS_ROUTE + "/";
const ADD_RAISED_HANDS = ONGOING_ROOMS_ROUTE + "/raisedhands/add/";
const REMOVE_RAISED_HANDS = ONGOING_ROOMS_ROUTE + "/raisedhands/remove/";
const ADD_USER_ROOM = ONGOING_ROOMS_ROUTE + "/adduser/";
///updateuser/user/:id/:uid
const UPDATE_USER_ROOM = ONGOING_ROOMS_ROUTE + "/updateuser/user/";
const REMOVE_USER_ROOM = ONGOING_ROOMS_ROUTE + "/removeuser/";
const REMOVE_ALL_USER_ROOM = ONGOING_ROOMS_ROUTE + "/removeallusers/";
const ADD_TO_REMOVED_USERS_ROOM = ONGOING_ROOMS_ROUTE + "/addtoremovedusers/";
const REMOVE_FROM_REMOVED_USERS_ROOM = ONGOING_ROOMS_ROUTE + "/removefromremovedusers/";
const ADD_ACTIVE_MODERATORS_ROOM = ONGOING_ROOMS_ROUTE + "/activemoderators/add/";
const REMOVE_ACTIVE_MODERATORS_ROOM = ONGOING_ROOMS_ROUTE + "/activemoderators/remove/";
const ADD_MODERATORS_ROOM = ONGOING_ROOMS_ROUTE + "/moderators/add/";
const REMOVE_MODERATORS_ROOM = ONGOING_ROOMS_ROUTE + "/moderators/remove/";
const ADD_INVITED_MODERATORS_ROOM = ONGOING_ROOMS_ROUTE + "/invitedmoderators/add/";
const REMOVE_INVITED_MODERATORS_ROOM = ONGOING_ROOMS_ROUTE + "/invitedmoderators/remove/";
const ADD_INVITED_USERS_ROOM = ONGOING_ROOMS_ROUTE + "/invitedusers/add/";
const REMOVE_INVITED_USERS_ROOM = ONGOING_ROOMS_ROUTE + "/invitedusers/remove/";
const ADD_SPEAKERS_ROOM = ONGOING_ROOMS_ROUTE + "/speakers/add/";
const REMOVE_SPEAKERS_ROOM = ONGOING_ROOMS_ROUTE + "/speakers/remove/";
const ADD_CLUB_MEMBERS_ROOM = ONGOING_ROOMS_ROUTE + "/clubmembers/add/";

//DELETE
const DELETE_ROOM = ONGOING_ROOMS_ROUTE + "/";

/// ******** ONGOING ROOM END POINTS ******* ///

/// ******** CLUB END POINTS ******* ///

//GET
const ALL_CLUBS = CLUBS_ROUTE + "/";
const ALL_CLUBS_AFTER = CLUBS_ROUTE + "/last/club";
const CLUB_BY_ID = CLUBS_ROUTE + "/";
const CLUB_BY_TITLE = CLUBS_ROUTE + "/title/";
const SEARCH_CLUB_BY_TITLE = CLUBS_ROUTE + "/search/";
const CLUB_USER_MEMBER = CLUBS_ROUTE + "/member/";
const CLUB_MEMBERS = CLUBS_ROUTE + "/clubmembers/";
const CLUB_MEMBERS_AFTER = CLUBS_ROUTE + "/clubmembers/after";
const CLUB_FOLLOWERS = CLUBS_ROUTE + "/clubfollowers/";
///analytics/:type/:clubid
const CLUB_ANALYTICS = CLUBS_ROUTE + "/analytics";

//POST
const SAVE_CLUB = CLUBS_ROUTE + "/";
const SAVE_CLUB_ANALYTICS = CLUBS_ROUTE + "/analytics";


//UPDATE
const UPDATE_CLUB = CLUBS_ROUTE + "/";
const INVITE_USER_CLUB = CLUBS_ROUTE + "/inviteuser/";
const ACCEPT_INVITE_USER_CLUB = CLUBS_ROUTE + "/acceptinvite/";
const JOIN_CLUB = CLUBS_ROUTE + "/joinclub/";
const JOIN_AS_OWNER_CLUB = CLUBS_ROUTE + "/joinasowner/";
const FOLLOW_CLUB = CLUBS_ROUTE + "/followclub/";
const UNFOLLOW_CLUB = CLUBS_ROUTE + "/unfollowclub/";
const LEAVE_CLUB = CLUBS_ROUTE + "/leaveclub/";
const ADD_TOPIC_CLUB = CLUBS_ROUTE + "/topics/add/";
const REMOVE_TOPIC_CLUB = CLUBS_ROUTE + "/topics/remove/";
const ADD_ROOM_CLUB = CLUBS_ROUTE + "/rooms/add/";
const REMOVE_ROOM_CLUB = CLUBS_ROUTE + "/rooms/remove/";

//DELETE
const DELETE_CLUB = CLUBS_ROUTE + "/";

/// ******** CLUB END POINTS ******* ///

/// ******** ACTIVITY END POINTS ******* ///

//GET
const ACTIVITIES_FOR_USER = ACTIVITIES_ROUTE + "/to/";
const ACTIVITIES_FOR_USER_AFTER = ACTIVITIES_ROUTE + "/to/after/activity";
const ACTIVITIES_BY_ID = ACTIVITIES_ROUTE + "/";
const ACTIVITIES_BY_TYPE = ACTIVITIES_ROUTE + "/type/";

//POST
const SAVE_ACTIVITY = ACTIVITIES_ROUTE + "/";

//PATCH
const UPDATE_ACTIVITY = ACTIVITIES_ROUTE + "/";

//DELETE
const DELETE_ACTIVITY = ACTIVITIES_ROUTE + "/";

/// ******** ACTIVITY END POINTS ******* ///

/// ******** COINS END POINTS ******* ///

const UPGRADE = COINS_ROUTE + "/upgrade";
const SEND_MONEY = COINS_ROUTE + "/sendmoney";
const DEPOSIT_TO_CLUB = COINS_ROUTE + "/deposittoclub";
const PAY_FOR_ROOM = COINS_ROUTE + "/payforroom";
const UPDATE_ROOM_STATS = ONGOING_ROOMS_ROUTE + "/stats/save";
const USER_VERIFICATION = BASE_URL2 + "/checkUserVerification";

















