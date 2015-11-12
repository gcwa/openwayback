<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="org.archive.wayback.ResultURIConverter" %>
<%@ page import="org.archive.wayback.WaybackConstants" %>
<%@ page import="org.archive.wayback.core.CaptureSearchResult" %>
<%@ page import="org.archive.wayback.core.CaptureSearchResults" %>
<%@ page import="org.archive.wayback.core.UIResults" %>
<%@ page import="org.archive.wayback.core.WaybackRequest" %>
<%@ page import="org.archive.wayback.partition.BubbleCalendarData" %>
<%@ page import="org.archive.wayback.util.Timestamp" %>
<%@ page import="org.archive.wayback.util.partition.Partition" %>
<%@ page import="org.archive.wayback.util.StringFormatter" %>
<%
UIResults results = UIResults.extractCaptureQuery(request);

StringFormatter fmt = results.getWbRequest().getFormatter();
StringFormatter gcwafmt = results.getGCWAFormatter();

ResultURIConverter uriConverter = results.getURIConverter();

// deployment-specific URL prefixes
String staticPrefix = results.getStaticPrefix();
String queryPrefix = results.getQueryPrefix();
String replayPrefix = results.getReplayPrefix();

//deployment-specific address for the graph generator:
String graphJspPrefix = results.getContextConfig("graphJspPrefix");
if(graphJspPrefix == null) {
	graphJspPrefix = queryPrefix;
}

// graph size "constants": These are currently baked-in to the JS logic...
int imgWidth = 0;
int imgHeight = 75;
int yearWidth = 49;
int monthWidth = 5;
int startYear = 2004;

for (int year = startYear; year <= Calendar.getInstance().get(Calendar.YEAR); year++)
    imgWidth += yearWidth;

BubbleCalendarData data = new BubbleCalendarData(results);

String yearEncoded = data.getYearsGraphString(imgWidth,imgHeight);
String yearImgUrl = graphJspPrefix + "jsp/graph.jsp?nomonth=1&graphdata=" + yearEncoded;

// a Calendar object for doing days-in-week, day-of-week,days-in-month math:
Calendar cal = BubbleCalendarData.getUTCCalendar();
// GCWA Specific
String langCode = results.getWbRequest().getLocaleLanguage();
if (langCode.substring(0,2).toLowerCase() == "fr") {
    langCode = "fr";
} else {
    langCode = "en";
};
String gcWebURL = staticPrefix.replace("wayback","GCWebArchive");
%><!DOCTYPE html><!--[if lt IE 9]><html class="no-js lt-ie9" lang="<%= langCode %>" dir="ltr"><![endif]--><!--[if gt IE 8]><!-->
<html class="no-js" lang="<%= langCode %>" dir="ltr">
<!--<![endif]-->
<head>
<meta charset="utf-8">
<!-- Web Experience Toolkit (WET) / Boîte à outils de l'expérience Web (BOEW)
wet-boew.github.io/wet-boew/License-en.html / wet-boew.github.io/wet-boew/Licence-fr.html -->
<title>Content page - No search, language toggle, site menu or breadcrumb trail - Working examples - Web Experience Toolkit
</title>
<meta content="width=device-width,initial-scale=1" name="viewport">
<!-- Meta data -->
<meta name="description" content="Web Experience Toolkit (WET) includes reusable components for building and maintaining innovative Web sites that are accessible, usable, and interoperable. These reusable components are open source software and free for use by departments and external Web communities">
<meta name="dcterms.title" content="Content page - No search, language toggle, site menu or breadcrumb trail - Web Experience Toolkit">
<meta name="dcterms.creator" content="French name of the content author / Nom en français de l'auteur du contenu">
<meta name="dcterms.issued" title="W3CDTF" content="Date published (YYYY-MM-DD) / Date de publication (AAAA-MM-JJ)">
<meta name="dcterms.modified" title="W3CDTF" content="Date modified (YYYY-MM-DD) / Date de modification (AAAA-MM-JJ)">
<meta name="dcterms.subject" title="scheme" content="French subject terms / Termes de sujet en français">
<meta name="dcterms.language" title="ISO639-2" content="eng">
<!-- Meta data-->
<!--[if gte IE 9 | !IE ]><!-->
<link href="<%= staticPrefix %>wet-boew/theme-gcwu-fegc/assets/favicon.ico" rel="icon" type="image/x-icon">
<link rel="stylesheet" href="<%= staticPrefix %>wet-boew/theme-gcwu-fegc/css/theme.min.css">
<!--<![endif]-->
<!--[if lt IE 9]>
<link href="<%= staticPrefix %>wet-boew/theme-gcwu-fegc/assets/favicon.ico" rel="shortcut icon" />
<link rel="stylesheet" href="<%= staticPrefix %>wet-boew/theme-gcwu-fegc/css/ie8-theme.min.css" />
<script src="<%= staticPrefix %>wet-boew/js/jquery/1.11.1/jquery.min.js"></script>
<script src="<%= staticPrefix %>wet-boew/wet-boew/js/ie8-wet-boew.min.js"></script>
<![endif]-->
<noscript><link rel="stylesheet" href="<%= staticPrefix %>wet-boew/wet-boew/css/noscript.min.css" /></noscript>




<jsp:include page="/WEB-INF/template/CookieJS.jsp" flush="true" />
<style type="text/css" src="<%= staticPrefix %>css/styles.css">
@import url("<%= staticPrefix %>css/styles.css");
</style>
<script type="text/javascript" src="<%= staticPrefix %>js/jquery-1.4.2.min.js"></script>
<script type="text/javascript" src="<%= staticPrefix %>js/excanvas.compiled.js"></script>
<script type="text/javascript" src="<%= staticPrefix %>js/jquery.bt.min.js" charset="utf-8"></script>
<script type="text/javascript" src="<%= staticPrefix %>js/jquery.hoverintent.min.js" charset="utf-8"></script>
<script type="text/javascript" src="<%= staticPrefix %>js/graph-calc.js" ></script>
<!-- More ugly JS to manage the highlight over the graph -->
<script type="text/javascript">


var firstDate = <%= data.dataStartMSSE %>;
var lastDate = <%= data.dataEndMSSE %>;
var wbPrefix = "<%= replayPrefix %>";
var wbCurrentUrl = "<%= data.searchUrlForJS %>";

var curYear = <%= data.yearNum - startYear %>;
var curMonth = -1;
var yearCount = 15;
var firstYear = <%= startYear %>;
var startYear = <%= data.yearNum - startYear %>;
var imgWidth = <%= imgWidth %>;
var yearImgWidth = <%= yearWidth %>;
var monthImgWidth = <%= monthWidth %>;
var trackerVal = "none";

function showTrackers(val) {
    if(val == trackerVal) {
        return;
    }

    document.getElementById("wbMouseTrackYearImg").style.display = val;
    trackerVal = val;
}
function getElementX2(obj) {
    var thing = jQuery(obj);
    if((thing == undefined) 
            || (typeof thing == "undefined") 
            || (typeof thing.offset == "undefined")) {
        return getElementX(obj);
    }
    return Math.round(thing.offset().left);
}
function setActiveYear(year) {
    if(curYear != year) {
        var yrOff = year * yearImgWidth;
        document.getElementById("wbMouseTrackYearImg").style.left = yrOff + "px";
        if(curYear != -1) {
            document.getElementById("highlight-"+curYear).setAttribute("class","inactiveHighlight");
        }
        document.getElementById("highlight-"+year).setAttribute("class","activeHighlight");
        curYear = year;
    }
}
function trackMouseMove(event,element) {

    var eventX = getEventX(event);
    var elementX = getElementX2(element);
    var xOff = eventX - elementX;
    if(xOff < 0) {
        xOff = 0;
    } else if(xOff > imgWidth) {
        xOff = imgWidth;
    }
    var monthOff = xOff % yearImgWidth;

    var year = Math.floor(xOff / yearImgWidth);
    var yearStart = year * yearImgWidth;
    var monthOfYear = Math.floor(monthOff / monthImgWidth);
    if(monthOfYear > 11) {
        monthOfYear = 11;
    }
    var month = (year * 12) + monthOfYear;
    var day = 1;
    if(monthOff % 2 == 1) {
        day = 15;
    }
    var dateString = 
        zeroPad(year + firstYear) + 
        zeroPad(monthOfYear+1,2) +
        zeroPad(day,2) + "000000";

    var url = "<%= queryPrefix %>" + dateString + '*/' +  wbCurrentUrl;
    document.getElementById('wm-graph-anchor').href = url;
    setActiveYear(year);
}
</script>

<script type="text/javascript">
$().ready(function(){
    $(".date").each(function(i){
        var actualsize = $(this).find(".hidden").text();
        var size = actualsize * 12;
        var offset = size / 2;
        if (actualsize == 1) {size = 30, offset = 15;}
        else if (actualsize == 2) {size = 40, offset = 20;}
        else if (actualsize == 3) {size = 50, offset = 25;}
        else if (actualsize == 4) {size = 60, offset = 30;}
        else if (actualsize == 5) {size = 70, offset = 35;}
        else if (actualsize == 6) {size = 80, offset = 40;}
        else if (actualsize == 7) {size = 90, offset = 45;}
        else if (actualsize == 8) {size = 100, offset = 50;}
        else if (actualsize == 9) {size = 110, offset = 55;}
        else if (actualsize >= 10) {size = 120, offset = 60;}
        $(this).find("img").attr("src","<%= staticPrefix %>images/blueblob-dk.png");
        $(this).find(".measure").css({'width':+size+'px','height':+size+'px','top':'-'+offset+'px','left':'-'+offset+'px'});
    });
    $(".day a").each(function(i){
        var dateClass = $(this).attr("class");
        var dateId = "#"+dateClass;
        $(this).hover(
            function(){$(dateId).removeClass("opacity20");},
            function(){$(dateId).addClass("opacity20");}
        );
    });
    $(".tooltip").bt({
        positions: ['top','right','left','bottom'],
        contentSelector: "$(this).find('.pop').html()",
        padding: 0, 
        width: '130px',
        spikeGirth: 8, 
        spikeLength: 8,
        overlap: 0,
        cornerRadius: 5,
        fill: '#efefef',
        strokeWidth: 1,
        strokeStyle: '#efefef',
        shadow: true, 
        shadowColor: '#333',
        shadowBlur: 5,
        shadowOffsetX: 0,
        shadowOffsetY: 0, 
        noShadowOpts: {strokeStyle:'#ccc'},
        hoverIntentOpts: {interval:60,timeout:3500}, 
        clickAnywhereToClose: true,
        closeWhenOthersOpen: true,
        windowMargin: 30,
        cssStyles: {
            fontSize: '12px',
            fontFamily: '"Arial","Helvetica Neue","Helvetica",sans-serif',
            lineHeight: 'normal',
            padding: '10px',
            color: '#333'
        }
    });

    var yrCount = $(".wbChartThisContainer").size();
    var yrTotal = <%= yearWidth %> * yrCount;
    var yrPad = (930 - yrTotal) / 2;
    $("#wbChartThis").css("padding-left",yrPad+"px");
});
</script>
<link rel="stylesheet" href="<%= staticPrefix %>gcwa/css/custom.css">
</head>
<body vocab="http://schema.org/" typeof="WebPage">
<ul id="wb-tphp">
<li class="wb-slc">
<a class="wb-sl" href="#wb-cont">Skip to main content</a>
</li>
<li class="wb-slc visible-sm visible-md visible-lg">
<a class="wb-sl" href="#wb-info">Skip to "About this site"</a>
</li>
</ul>
<header role="banner">
<div id="wb-bnr">
<div id="wb-bar">
<div class="container">
<div class="row">;
<object id="gcwu-sig" type="image/svg+xml" tabindex="-1" role="img" data="<%= staticPrefix %>wet-boew/theme-gcwu-fegc/assets/sig-<%= langCode %>.svg" aria-label="Government of Canada"></object>
<ul id="gc-bar" class="list-inline">
<li><a href="http://www.canada.ca/en/index.html" rel="external">Canada.ca</a></li>
<li><a href="http://www.canada.ca/en/services/index.html" rel="external">Services</a></li>
<li><a href="http://www.canada.ca/en/gov/dept/index.html" rel="external">Departments</a></li>
</ul>
<section class="wb-mb-links col-xs-12 visible-sm visible-xs" id="wb-glb-mn">
<h2>Search and menus</h2>
<ul class="pnl-btn list-inline text-right">
<li><a href="#mb-pnl" title="Search and menus" aria-controls="mb-pnl" class="overlay-lnk btn btn-sm btn-default" role="button"><span class="glyphicon glyphicon-search"><span class="glyphicon glyphicon-th-list"><span class="wb-inv">Search and menus</span></span></span></a></li>
</ul>
<div id="mb-pnl"></div>
</section>
</div>
</div>
</div>
<div class="container">
<div class="row">
<div id="wb-sttl" class="col-md-5">
<a href="<%= gcWebURL %>">
<span><%= gcwafmt.format("wayback.title") %></span>
</a>
</div>
<object id="wmms" type="image/svg+xml" tabindex="-1" role="img" data="<%= staticPrefix %>wet-boew/theme-gcwu-fegc/assets/wmms.svg" aria-label="Symbol of the Government of Canada"></object>
</div>
</div>
</div>
<span data-trgt="mb-pnl" class="wb-menu hide"></span>
</header>
<main role="main" property="mainContentOfPage" class="container">


<div id="position">


    <div id="wbSearch">
    
        <div id="logo">
            <a><img src="<%= staticPrefix %>gcwa/images/OpenWayback-banner-<%= langCode %>.png" alt="logo: OpenWayback" /></a>
        </div>

        <div id="form">
        
            <form name="form1" method="get" action="<%= queryPrefix %>query">
			<input type="hidden" name="<%= WaybackRequest.REQUEST_TYPE %>" value="<%= WaybackRequest.REQUEST_CAPTURE_QUERY %>">
                        <input type="text" name="<%= WaybackRequest.REQUEST_URL %>" value="<%= data.searchUrlForHTML %>" size="40" maxlength="256">
            <input type="submit" name="Submit" value="Go Wayback!"/>
            </form>
    
            <div id="wbMeta">
                <p class="wbThis"><%= fmt.format("BubbleCalendar.crawledInfo",
                                            data.searchUrlForHTML, 
                                            data.numResults,
                                            data.firstResultReplayUrl,
                                            data.firstResultDate,
                                            data.numYearResults,
                                            data.yearNum) %></p>
            </div>
        </div>
        
    </div>
    
    <div class="clearfix"></div>

    <div id="wbChart" onmouseout="showTrackers('none'); setActiveYear(startYear);">
    
  <div id="wbChartThis" style="padding-left: 223px">
        <a style="position:relative; white-space:nowrap; width:<%= imgWidth %>px;height:<%= imgHeight %>px;" href="<%= queryPrefix %>" id="wm-graph-anchor">
        <div id="wm-ipp-sparkline" style="position:relative; white-space:nowrap; width:<%= imgWidth %>px;height:<%= imgHeight %>px;background: #f3f3f3 -moz-linear-gradient(top,#ffffff,#f3f3f3);background: #f3f3f3 -webkit-gradient(linear, left top, left bottom, from(#fff), to(#f3f3f3), color-stop(1.0, #f3f3f3));background-color: #f3f3f3;filter: progid:DXImageTransform.Microsoft.Gradient(enabled='true',startColorstr=#FFFFFFFF, endColorstr=#FFF3F3F3);cursor:pointer;border: 1px solid #ccc;border-left:none;" title="<%= fmt.format("ToolBar.sparklineTitle") %>">
			<img id="sparklineImgId" style="position:absolute;z-index:9012;top:0;left:0;"
				onmouseover="showTrackers('inline');" 
				
				onmousemove="trackMouseMove(event,this)"
				alt="sparklines"
				width="<%= imgWidth %>"
				height="<%= imgHeight %>"
				border="0"
				src="<%= yearImgUrl %>"></img>
			<img id="wbMouseTrackYearImg" 
				style="display:none; position:absolute; z-index:9010;"
				width="<%= yearWidth %>" 
				height="<%= imgHeight %>"
				border="0"
				src="<%= staticPrefix %>images/toolbar/yellow-pixel.png"></img>
			<img id="wbMouseTrackMonthImg"
				style="display:none; position:absolute; z-index:9011; " 
				width="<%= monthWidth %>"
				height="<%= imgHeight %>" 
				border="0"
				src="<%= staticPrefix %>images/toolbar/transp-black-pixel.png"></img>
        </div>
        </a>
        	<%
        	for(int i = startYear; i <= Calendar.getInstance().get(Calendar.YEAR); i++) {
        		String curClass = "inactiveHighlight";
        		if(data.yearNum == i) {
            		curClass = "activeHighlight";
        		}
        	%>
	            <div class="wbChartThisContainer">
	                <a style="text-decoration: none;" href="<%= queryPrefix + i + "0201000000*/" + data.searchUrlForHTML %>">
	                
	                	<div id="highlight-<%= i - startYear %>"
						onmouseover="showTrackers('inline'); setActiveYear(<%= i - startYear %>)" 
	                	class="<%= curClass %>"><%= i %></div>
	                </a>
	            </div>
            <%
        	}
            %>
  </div>
</div>
<div class="clearfix"></div>

<div id="wbCalendar">
    
  <div id="calUnder" class="calPosition">

    


<%
// draw 12 months, 0-11 (0=Jan, 11=Dec)
for(int moy = 0; moy < 12; moy++) {
	Partition<Partition<CaptureSearchResult>> curMonth = data.monthsByDay.get(moy);
	List<Partition<CaptureSearchResult>> monthDays = curMonth.list();
%>
    <div class="month" id="<%= data.yearNum %>-<%= moy %>">
	    <table>
	
	       <thead>
	           <tr>
	               <th colspan="7"><span class="label"></span></th>
	           </tr>
	       </thead>
	       <tbody>
	           <tr>
<%
		cal.setTime(curMonth.getStart());
		int skipDays = cal.get(Calendar.DAY_OF_WEEK) - 1;
		int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
		// skip until the 1st:
		for(int i = 0; i < skipDays; i++) {
			%><td><div class="date"></div></td><%
		}
		int dow = skipDays;
		int dom;
		for(dom = 0; dom < daysInMonth; dom++) {


			int count = monthDays.get(dom).count();
			if(count > 0) {
				// one or more captures in this day:
				CaptureSearchResult firstCaptureInDay = 
					monthDays.get(dom).list().get(0);
				String replayUrl = uriConverter.makeReplayURI(
							firstCaptureInDay.getCaptureTimestamp(),
							firstCaptureInDay.getOriginalUrl());
				Date firstCaptureInDayDate = firstCaptureInDay.getCaptureDate();
				String safeUrl = fmt.escapeHtml(replayUrl);		
				%><td>
                    <div class="date">
                        <div class="position">
                           <div class="hidden"><%= count %></div>
                           <div class="measure opacity20" id="<%= fmt.format("{0,date,MMM-d-yyyy}",firstCaptureInDayDate) %>"><img width="100%" height="100%"/></div>
                        </div>
                    </div>
				</td><%

			} else {
				// zero captures in this day:
				%><td>
	                <div class="date"></div>
				</td><%
				
			}


			if(((dom+skipDays+1) % 7) == 0) {
				// end of the week, start a new tr:
				%></tr><tr><%
			}
		}
		// fill in blank days until the end of the current week:
		while(((dom+skipDays) % 7) != 0) {
			%><td></td><%
			dom++;
		}
%>
			   </tr>
			</tbody>
		</table>    
      </div>
    
<%
}
%>
  </div>
  <div id="calOver" class="calPosition">
<%

for(int moy = 0; moy < 12; moy++) {
	Partition<Partition<CaptureSearchResult>> curMonth = data.monthsByDay.get(moy);
	List<Partition<CaptureSearchResult>> monthDays = curMonth.list();
%>
    <div class="month" id="<%= data.yearNum %>-<%= moy %>">
	    <table>
	
	       <thead>
	           <tr>
	               <th colspan="7"><span class="label"><%= fmt.format("{0,date,MMM}",curMonth.getStart()) %></span></th>
	           </tr>
	       </thead>
	       <tbody>
	           <tr>
<%
		cal.setTime(curMonth.getStart());
		int skipDays = cal.get(Calendar.DAY_OF_WEEK) - 1;
		int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
		// skip until the 1st:
		for(int i = 0; i < skipDays; i++) {
			%><td><div class="date"></div></td><%
		}
		int dow = skipDays;
		int dom;
		for(dom = 0; dom < daysInMonth; dom++) {


			int count = monthDays.get(dom).count();
			
			if(count > 0) {
				// one or more captures in this day:
				CaptureSearchResult firstCaptureInDay =
					monthDays.get(dom).list().get(0);
				String replayUrl = uriConverter.makeReplayURI(
						firstCaptureInDay.getCaptureTimestamp(),
						firstCaptureInDay.getOriginalUrl());
				Date firstCaptureInDayDate = firstCaptureInDay.getCaptureDate();
				String safeUrl = fmt.escapeHtml(replayUrl);

				%><td>
                    <div class="date tooltip">
                        <div class="pop">
                            <h3><%= fmt.format("{0,date,MMMMM d, yyyy}",firstCaptureInDayDate) %></h3>
                            <p><%= count %> snapshots</p>
                            <ul>
							<%
							Iterator<CaptureSearchResult> dayItr = 
								monthDays.get(dom).iterator();
							while(dayItr.hasNext()) {
								CaptureSearchResult c = dayItr.next();
								String replayUrl2 = uriConverter.makeReplayURI(
										c.getCaptureTimestamp(),c.getOriginalUrl());
								String safeUrl2 = fmt.escapeHtml(replayUrl2);
								%>
								<li><a href="<%= safeUrl2 %>"><%= fmt.format("{0,date,HH:mm:ss}",c.getCaptureDate()) %></a></li>
								<%
							}
							%>
                            </ul>
                        </div>
                        <div class="day">

                            <a href="<%= safeUrl %>" title="<%= count %> snapshots" class="<%= fmt.format("{0,date,MMM-d-yyyy}",firstCaptureInDayDate) %>"><%= dom + 1 %></a>
                        </div>
                    </div>
			      </td><%

			} else {
				// zero captures in this day:
				%><td>
	                <div class="date">
	    	            <div class="day"><span><%= dom + 1 %></span></div>
		            </div>
				</td><%
				
			}


			if(((dom+skipDays+1) % 7) == 0) {
				// end of the week, start a new tr:
				%></tr><tr><%
			}
		}
		// fill in blank days until the end of the current week:
		while(((dom+skipDays) % 7) != 0) {
			%><td></td><%
			dom++;
		}
%>
			   </tr>
			</tbody>
		</table>    
      </div>
<%
}
%>
    </div>
  </div>
  <div id="wbCalNote">
    <h2><%= fmt.format("BubbleCalendar.wbCalNoteTitle") %></h2>
    <p><%= fmt.format("BubbleCalendar.wbCalNote", data.searchUrlForHTML, fmt.format("UIGlobal.helpUrl")) %></p>
  </div>
</div>
  


</main>
<footer role="contentinfo" id="wb-info" class="visible-sm visible-md visible-lg wb-navcurr">
<div class="container">
<nav role="navigation">
<h2>About this site</h2>
<ul id="gc-tctr" class="list-inline">
<li><a rel="license" href="<%= gcwafmt.format("footer.terms.and.condition.link") %>"><%= gcwafmt.format("footer.terms.and.condition") %></a></li>
<li><a href="<%= gcwafmt.format("footer.transparency") %>"><%= gcwafmt.format("footer.transparency") %></a></li>
</ul>
<div class="row">
<section class="col-sm-3">
<h3><%= gcwafmt.format("footer.about.us") %></h3>
<ul class="list-unstyled">
<li><a href="<%= gcwafmt.format("footer.mandate.link") %>"><%= gcwafmt.format("footer.mandate") %></a></li>
<li><a href="<%= gcwafmt.format("footer.librarian.and.archivist.link") %>"><%= gcwafmt.format("footer.librarian.and.archivist") %></a></li>
<li><a href="<%= gcwafmt.format("footer.service.and.program.link") %>"><%= gcwafmt.format("footer.service.and.program") %></a></li>
<li><a href="<%= gcwafmt.format("footer.lac.events.link") %>"><%= gcwafmt.format("footer.lac.events") %></a></li>
</ul>
</section>
<section class="col-sm-3">
<h3><%= gcwafmt.format("footer.news.title") %></h3>
<ul class="list-unstyled">
<li><a href="<%= gcwafmt.format("footer.news.release.link") %>"><%= gcwafmt.format("footer.news.release") %></a></li>
<li><a href="<%= gcwafmt.format("footer.speeches.link") %>"><%= gcwafmt.format("footer.speeches") %></a></li>
<li><a href="<%= gcwafmt.format("footer.photo.gallery.link") %>"><%= gcwafmt.format("footer.photo.gallery") %></a></li>
<li><a href="<%= gcwafmt.format("footer.videos.link") %>"><%= gcwafmt.format("footer.videos") %></a></li>
<li><a href="<%= gcwafmt.format("footer.podcasts.link") %>"><%= gcwafmt.format("footer.podcasts") %></a></li>
</ul>
</section>
<section class="col-sm-3">
<h3><%= gcwafmt.format("footer.contactus.title") %></h3>
<ul class="list-unstyled">
<li><a href="<%= gcwafmt.format("footer.address.link") %>"><%= gcwafmt.format("footer.address") %></a></li>
<li><a href="<%= gcwafmt.format("footer.telephone.numbers.link") %>"><%= gcwafmt.format("footer.telephone.numbers") %></a></li>
<li><a href="<%= gcwafmt.format("footer.emails.link") %>"><%= gcwafmt.format("footer.emails") %></a></li>
<li><a href="<%= gcwafmt.format("footer.find.employee.link") %>"><%= gcwafmt.format("footer.find.employee") %></a></li>
</ul>
</section>
<section class="col-sm-3">
<h3><%= gcwafmt.format("footer.stay.connected.title") %></h3>
<ul class="list-unstyled">
<li><a href="http://www.flickr.com/photos/lac-bac/collections/">Flickr </a></li>
<li><a href="https://twitter.com/@LibraryArchives">Twitter </a></li>
<li><a href="http://www.facebook.com/pages/Library-and-Archives-Canada/383985531647785"> Facebook </a></li>
<li><a href="http://www.youtube.com/user/LibraryArchiveCanada/">Youtube</a></li>
<li><a href="<%= gcwafmt.format("footer.rss.feed.link") %>"><%= gcwafmt.format("footer.rss.feed") %></a></li>
</ul>
</section>
</div>
</nav>
</div>
<div id="gc-info">
<div class="container">
<nav role="navigation">
<h2>Government of Canada footer</h2>
<ul class="list-inline">
<li><a href="<%= gcwafmt.format("footer.health.title.link") %>"><span><%= gcwafmt.format("footer.health.title") %></span></a></li>
<li><a href="<%= gcwafmt.format("footer.travel.title.link") %>"><span><%= gcwafmt.format("footer.travel.title") %></span></a></li>
<li><a href="<%= gcwafmt.format("footer.service.canada.title.link") %>"><span><%= gcwafmt.format("footer.service.canada.title") %></span></a></li>
<li><a href="<%= gcwafmt.format("footer.jobs.title.link") %>"><span><%= gcwafmt.format("footer.jobs.title") %></span></a></li>
<li><a href="<%= gcwafmt.format("footer.economy.title.link") %>"><span><%= gcwafmt.format("footer.economy.title") %></span></a></li>
<li id="canada-ca"><a href="http://www.canada.ca/en/index.html">Canada.ca</a></li>
</ul>
</nav>
</div>
</div>
</footer>
<!--[if gte IE 9 | !IE ]><!-->
<script src="<%= staticPrefix %>wet-boew/js/jquery/2.1.4/jquery.js"></script>
<script src="<%= staticPrefix %>wet-boew/wet-boew/js/wet-boew.min.js"></script>
<!--<![endif]-->
<!--[if lt IE 9]>
<script src="<%= staticPrefix %>wet-boew/wet-boew/js/ie8-wet-boew2.min.js"></script>

<![endif]-->
<script src="<%= staticPrefix %>wet-boew/theme-gcwu-fegc/js/theme.min.js"></script>
</body>
</html>