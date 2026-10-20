var cookie = {
set: function(key, value, days) {
document.cookie = key + '=' + value + '; expires=' +
(new Date(new Date().getTime() + ((days ? days : 14) * 86400000))).toUTCString() + '; path=/';
},
get: function(key) {
var r = ('; ' + document.cookie + ';').match(key + '=(.*?);');
return r ? r[1] : null;
},
unset: function(key) {
document.cookie = key + '=; expires=' +
(new Date(1)).toUTCString() + '; path=/';
}
};
function Check_Https_Redirect_Status(){
var result = false;
const isTargetRegionSku = (function(){
const ttc = 'US/01' || '';
const targetRegions = ['SG', 'AA', 'EU'];
return targetRegions.some(region => ttc.startsWith(region));
})();
var http_enable = '2';
if(isTargetRegionSku && isSupport("secure_default") && (http_enable == "2") &&
(location.protocol != 'https:') &&
((cookie.get("not_show_https_redirect") != "1") && (cookie.get("from_https_redirect") != "1")) ){
result = true;
}
cookie.unset("from_https_redirect");
return result;
}
function Initial_Https_Redirect(){
$('link[href*="/js/https_redirect/https_redirect.css"]').remove();
$('link').last().after('<link rel="stylesheet" type="text/css" href="/js/https_redirect/https_redirect.css">');
$("#https_redirect_component").remove();
$("body").append(Get_Component_Https_Redirect());
}
function Get_Component_Https_Redirect(){
var $https_redirect_component = $("<div>").addClass("https_redirect_component").attr("id","https_redirect_component");
var $content_bg = $("<div>").addClass("content_bg").appendTo($https_redirect_component);
var $content_container = $("<div>").addClass("content_container").appendTo($content_bg);
var $main_block = $("<div>").addClass("main_block").appendTo($content_container);
var $left_block = $("<div>").addClass("left_block").appendTo($main_block);
$("<div>").addClass("illustration").appendTo($left_block);
var $right_block = $("<div>").addClass("right_block").appendTo($main_block);
var $content_container = $("<div>").appendTo($right_block);
var $logo_block = $("<div>").addClass("logo_block").appendTo($content_container);
$("<div>").addClass("logo_icon").appendTo($logo_block);
$("<div>").addClass("logo_desc").appendTo($logo_block).html("Welcome to ASUS Router");
var $desc_block = $("<div>").addClass("desc_block").appendTo($content_container);
$desc_block.html(`HTTPS is a relatively more secured web access protocol. We strongly suggest to enter the ASUS router setting page via HTTPS protocol.Please download <a style="font-weight: bolder;text-decoration: underline;" href="cert.crt" target="_blank">certificate</a> and install it to "Trusted Root Certification Authorization" store.`);
var $https_desc_link = $("<div>").addClass("https_desc_link").appendTo($content_container);
$("<span>").html("Click here to continue.").appendTo($https_desc_link);
$https_desc_link.unbind("click").click(function(e){
e = e || event;
e.stopPropagation();
$("body").append(Get_Component_Https_Desc());
$("body").find("#https_redirect_component").addClass("blur_effect");
});
var $qr_code_and_icon_block = $("<div>").addClass("qr_code_and_icon_block").appendTo($content_container);
var $scan_qr_code_block = $("<div>").addClass("scan_qr_code_block").appendTo($qr_code_and_icon_block);
var $qr_code_icon = $("<div>").addClass("qr_code_icon").appendTo($scan_qr_code_block);
var $scan_title = $("<div>").addClass("scan_title").appendTo($scan_qr_code_block).html("Scan the QR code for more details.");
var $illustration_block = $("<div>").addClass("illustration_block").appendTo($qr_code_and_icon_block);
var $illustration = $("<div>").addClass("illustration").appendTo($illustration_block);
var $access_http_link = $("<div>").addClass("access_http_link").appendTo($content_container);
$access_http_link.html("Still wish to access setting page with <span>HTTP protocol</span>?");
$access_http_link.unbind("click").click(function(e){
e = e || event;
e.stopPropagation();
$("body").append(Get_Component_Http_Desc());
$("body").find("#https_redirect_component").addClass("blur_effect");
});
$("<div>").addClass("mobile_bottom_space").appendTo($content_container);
return $https_redirect_component;
}
function Get_Component_Http_Desc(){
if($("#http_desc_component").length > 0)
return;
var $popup_component = $("<div>").addClass("popup_component http_desc no_highlights").attr("id","http_desc_component");
var $content_container = $("<div>").addClass("content_container").appendTo($popup_component);
var $desc_text_bg = $("<div>").addClass("desc_text_bg").appendTo($content_container);
$("<div>")
.html("HTTP is a relatively less secure web access protocol. Still want to access setting page with HTTP protocol?")
.appendTo($desc_text_bg);
var $action_bg = $("<div>").addClass("action_bg").appendTo($content_container);
var $cb_text_bg = $("<div>").addClass("cb_text_bg").appendTo($action_bg);
$("<input>").attr({"type":"checkbox", "id":"https_redirect_hint"}).appendTo($cb_text_bg);
$("<label>").attr("for","https_redirect_hint").html("Do not show this message again").appendTo($cb_text_bg);
var $btn_bg = $("<div>").addClass("btn_bg").appendTo($action_bg);
var $btn_no = $("<div>").html("No").appendTo($btn_bg);
$btn_no.unbind("click").click(function(e){
e = e || event;
e.stopPropagation();
$("body").find("#https_redirect_component").removeClass("blur_effect");
$("body").find("#http_desc_component").remove();
});
var $btn_yes = $("<div>").html("Yes").appendTo($btn_bg);
$btn_yes.unbind("click").click(function(e){
e = e || event;
e.stopPropagation();
if($(this).closest(".popup_component").find("#https_redirect_hint").prop("checked"))
cookie.set("not_show_https_redirect", "1", 365);
location.reload();
});
return $popup_component;
}
function Get_Component_Https_Desc(){
if($("#popup_component").length > 0)
return;
var $popup_component = $("<div>").addClass("popup_component no_highlights").attr("id","popup_https_desc");
var $content_container = $("<div>").addClass("content_container").appendTo($popup_component);
var $illustration_bg = $("<div>").addClass("illustration_bg").appendTo($content_container);
var $desc_text_bg = $("<div>").addClass("desc_text_bg").appendTo($content_container);
$("<div>")
.html("When using HTTPS protocol, your browser may show a security certificate warning, the connection to the ASUS router settings page (www.asusrouter.com) remains secure.")
.appendTo($desc_text_bg);
/*
$("<div>")
.html("When using HTTPS protocol, a warning message may display to inform the security certificate issue by your browser.")
.appendTo($desc_text_bg);
$("<div>")
.html("The connection between your browser and the ASUS router setting page (www.asusrouter.com) remains secure despite this warning message.")
.appendTo($desc_text_bg);
*/
var $action_bg = $("<div>").addClass("action_bg").appendTo($content_container);
var $cb_text_bg = $("<div>").addClass("cb_text_bg").appendTo($action_bg);
$("<input>").attr({"type":"checkbox", "id":"https_redirect_hint"}).appendTo($cb_text_bg);
$("<label>").attr("for","https_redirect_hint").html("Do not show this message again").appendTo($cb_text_bg);
var $btn_bg = $("<div>").addClass("btn_bg").appendTo($action_bg);
var $btn_no = $("<div>").html("No").appendTo($btn_bg);
$btn_no.unbind("click").click(function(e){
e = e || event;
e.stopPropagation();
$("body").find("#https_redirect_component").removeClass("blur_effect");
$("body").find("#popup_https_desc").remove();
});
var $btn_yes = $("<div>").html("Yes").appendTo($btn_bg);
$btn_yes.unbind("click").click(function(e){
e = e || event;
e.stopPropagation();
if($(this).closest(".popup_component").find("#https_redirect_hint").prop("checked"))
cookie.set("not_show_https_redirect", "1", 365);
$("body").find(".popup_component").remove();
$("body").find("#https_redirect_component").remove();
if(location.protocol != 'https:'){
const https_lanport = '8443';
const https_lanip = '192.168.1.1';
let redirect_page = window.location.pathname;
if(redirect_page.indexOf("Main_Login.asp"))
redirect_page = "/";
const isAMeshRE = ('0' === '1');
if (isAMeshRE) {
const parseLoginInfo = (typeof tryParseJSON === "function") ? tryParseJSON : function(jsonString) {
try {
const o = JSON.parse(jsonString);
if (o && typeof o === "object") {
return o;
}
}
catch (e) {
}
return false;
};
const loginInfo = parseLoginInfo('{ "lock_time": -96357, "error_status": 0, "last_time_lock_warning": 0, "error_num": 0, "page": "index.asp" }');
if (loginInfo && loginInfo.page) {
redirect_page = loginInfo.page.indexOf('/') === 0 ? loginInfo.page : '/' + loginInfo.page;
}
}
const redirectUrl = `https://${https_lanip}:${https_lanport}${redirect_page}`;
window.location.href = redirectUrl;
}
else
location.reload();
});
return $popup_component;
}
$(document).ready(function(){
/*
if($(location).attr("pathname").indexOf("Main_Login.asp") > -1){
var referrer = document.referrer;
if(referrer.indexOf("login.cgi") > -1){
return;
}
}
if($(location).attr("pathname").indexOf("QIS_wizard.htm") > -1)
return;
*/
if(Check_Https_Redirect_Status())
Initial_Https_Redirect();
});

