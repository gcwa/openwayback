<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8"%>
<%@ page import="org.archive.wayback.core.UIResults" %>
<%@ page import="org.archive.wayback.util.StringFormatter" %>
<%
UIResults results = UIResults.getGeneric(request);
StringFormatter fmt = results.getWbRequest().getFormatter();
StringFormatter gcwafmt = results.getGCWAFormatter();

String staticPrefix = results.getStaticPrefix();
String queryPrefix = results.getQueryPrefix();
String replayPrefix = results.getReplayPrefix();
String otherLangQueryPrefix;

String langCode = results.getWbRequest().getLocaleLanguage().substring(0,2).toLowerCase();
if ("fr".equals(langCode)) {
    otherLangQueryPrefix = queryPrefix.replaceAll("\\/wayback-fr\\/", "/wayback/");
} else {
    otherLangQueryPrefix = queryPrefix.replaceAll("\\/wayback\\/", "/wayback-fr/");
};
%>
<!-- FOOTER -->
		<div align="center">
			<hr noshade size="1" align="center">
			
			<p>
				<a href="<%= gcwafmt.format("gcwa.home.title.link") %>">
					<%= gcwafmt.format("gcwa.home.title") %></a>
			    |
				<a href="<%= otherLangQueryPrefix %>">
					<%= gcwafmt.format("wayback.otherLang") %></a>
			</p>
		</div>
	</body>
</html>
<!-- /FOOTER -->
