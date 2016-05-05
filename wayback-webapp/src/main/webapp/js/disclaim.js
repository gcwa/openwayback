var notice =
	'<style type="text/css">' +
	' #openwayback-disclaim,#openwayback-disclaim p{font-family:"Helvetica Neue",Helvetica,Arial,sans-serif;font-size:16px;line-height:1.4375;color:#333;background-color:transparent;}#openwayback-disclaim{position:relative;border:1px solid #000;background-color:#ffffe0;padding:5px;text-align:left;-ms-text-size-adjust:100%;-webkit-text-size-adjust:100%;z-index:9999}#openwayback-disclaim a{font-family:"Helvetica Neue",Helvetica,Arial,sans-serif;font-size:16px;line-height:1.4375;color:#00f;text-decoration:underline;background-color:transparent}#openwayback-disclaim a:active,#openwayback-disclaim a:hover{font-family:"Helvetica Neue",Helvetica,Arial,sans-serif;font-size:16px;line-height:1.4375;color:#00f;text-decoration:underline;outline:0}#openwayback-disclaim p{margin:0 0 11.5px;padding:0;box-sizing:border-box}' +
	"</style>" +
     "<div id='openwayback-disclaim'>" + 
     wmNotice +
  	 " [ <a href=\"javascript:void(top.disclaimElem.style.display='none')\">" + wmHideNotice + "</a> ]" +
     "</div>";

function getFrameArea(frame) {
	if(frame.innerWidth) return frame.innerWidth * frame.innerHeight;
	if(frame.document.documentElement && frame.document.documentElement.clientHeight) return frame.document.documentElement.clientWidth * frame.document.documentElement.clientHeight;
	if(frame.document.body) return frame.document.body.clientWidth * frame.document.body.clientHeight;
	return 0;
}

function disclaim() {
	if(top!=self) {
		if(top.document.body.tagName == "BODY") {
			return;
		}
		largestArea = 0;
		largestFrame = null;
		for(i=0;i<top.frames.length;i++) {
			frame = top.frames[i];
			area = getFrameArea(frame);
			if(area > largestArea) {
				largestFrame = frame;
				largestArea = area;
			}
		}
		if(self!=largestFrame) {
			return;
		}
	}
	disclaimElem = document.createElement('div');
	disclaimElem.innerHTML = notice;
	top.disclaimElem = disclaimElem;
	document.body.insertBefore(disclaimElem,document.body.firstChild);
}
document.addEventListener('DOMContentLoaded', function(){
	disclaim();	
});
