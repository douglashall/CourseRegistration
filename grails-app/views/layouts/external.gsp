<!DOCTYPE html>
<html>
    <head>
    	<link rel="stylesheet" href="http://isites.harvard.edu/js/ext/resources/css/ext-all.css" />
        <link rel="stylesheet" href="http://isites.harvard.edu/js/ext/resources/css/xtheme-gray.css" />
        <link rel="stylesheet" href="${resource(dir:'css',file:'course-catalog.css')}" />
        <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" />
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
        <script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>
        <script src="http://isites.harvard.edu/js/ext/adapter/ext/ext-base-debug.js"></script>
        <script src="http://isites.harvard.edu/js/ext/ext-all-debug.js"></script>
        <g:render template="/templates/commonJS" />
        <g:layoutHead />
    </head>
    <body>
    	<g:render template="/templates/commonCSS" />
        <g:layoutBody />
    </body>
</html>