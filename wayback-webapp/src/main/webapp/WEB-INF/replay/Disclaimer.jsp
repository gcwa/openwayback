<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.Date" %>
<%@ page import="org.archive.wayback.WaybackConstants" %>
<%@ page import="org.archive.wayback.core.CaptureSearchResult" %>
<%@ page import="org.archive.wayback.core.UIResults" %>
<%@ page import="org.archive.wayback.core.WaybackRequest" %>
<%@ page import="org.archive.wayback.util.StringFormatter" %>
<%
UIResults results = UIResults.extractReplay(request);

StringFormatter fmt = results.getWbRequest().getFormatter();
StringFormatter gcwafmt = results.getGCWAFormatter();
CaptureSearchResult result = results.getResult();
String dupeMsg = "";
if(result != null) {
        if(result.isDuplicateDigest()) {
                Date dupeDate = result.getDuplicateDigestStoredDate();
                String prettyDate = "";
                if(dupeDate != null) {
                    prettyDate = "(" + 
                    		fmt.format("MetaReplay.captureDateDisplay",
                    				dupeDate) + ")";
                }
                dupeMsg = fmt.format("ReplayView.disclaimerText", dupeDate);
        }
}

Date resultDate = result.getCaptureDate();
String resultUrl = result.getOriginalUrl();
String queryPrefix = results.getQueryPrefix();
String starLink = queryPrefix + results.getWbRequest().getReplayTimestamp() + "*/" + resultUrl;

String wmNotice = fmt.format("ReplayView.banner", resultUrl, resultDate, starLink);
String wmHideNotice = fmt.format("ReplayView.bannerHideLink");
%>
<script type="text/javascript">
  var wmNotice = "<%= wmNotice %> <%= dupeMsg %>";
  var wmHideNotice = "<%= wmHideNotice %>";
</script>
<script type="text/javascript" src="<%= results.getStaticPrefix() %>js/disclaim.js"></script>

<script type="text/javascript">
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

ga('create', '<% gcwafmt.format("google.analytics.tracking.id"); %>', 'auto');
ga('send', 'pageview');
</script>