<%@ page import="edu.harvard.coursereg.StudentCourse" %>
<%@ page import="edu.harvard.icommons.coursedata.CourseInstance" %>
<%@ page import="edu.harvard.icommons.coursedata.Course" %>
<%@ page import="edu.harvard.icommons.coursedata.Term" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
    </head>
    <body>
    	<g:each in="${model}" var="entry">
	    	<fieldset>
				<legend>${entry.key}</legend>
				<table class="grid petition_form">
					<thead>
						<tr>
							<th style="width: 100%" rowspan="1" colspan="1">Course</th>
							<th rowspan="1" colspan="1">Level</th>
							<th rowspan="1" colspan="1">Grading Option</th>
							<th rowspan="1" colspan="1">Status</th>
						</tr>
					</thead>
					<tbody>
		    			<g:each in="${entry.value}" var="studentCourse">
							<tr class="course" id="${studentCourse.id}">
								<td rowspan="1" colspan="1">
									<span>${studentCourse.courseInstance.title} (${studentCourse.courseInstance.course.registrarCodeDisplay})</span>
									<br/>${studentCourse.courseInstance.instructorsDisplay}<br/>${studentCourse.courseInstance.meetingTime}
								</td>
								<td rowspan="1" colspan="1">${studentCourse.studentCourseAttributes['levelOption']}</td>
								<td rowspan="1" colspan="1">${studentCourse.studentCourseAttributes['gradingOption']}</td>
								<td rowspan="1" colspan="1">
									<a class="course_add addthis" style="font-size: small" title="" href="javascript:void(0);" shape="rect">add</a>
									<a class="course_print printthis" style="font-size: small" title="" href="javascript:void(0);" shape="rect">print</a>
									<a class="course_remove removethis" style="font-size: small" title="" href="javascript:void(0);" shape="rect">remove</a>
								</td>
							</tr>
						</g:each>
					</tbody>
				</table>
			</fieldset>
		</g:each>
    </body>
</html>