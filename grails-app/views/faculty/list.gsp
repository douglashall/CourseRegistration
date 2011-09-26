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
    	<fieldset>
			<legend>Fall 2011, Harvard Business School - MBA Program</legend>
			<table class="grid petition_form">
				<thead>
					<tr>
						<th style="width: 100%" rowspan="1" colspan="1">Student</th>
						<th rowspan="1" colspan="1">School</th>
						<th rowspan="1" colspan="1">Level</th>
						<th rowspan="1" colspan="1">Grading Option</th>
						<th rowspan="1" colspan="1">Status</th>
					</tr>
				</thead>
				<tbody>
	    			<g:each in="${studentCourseList}" var="studentCourse">
						<tr class="course" id="${studentCourse.id}">
							<td rowspan="1" colspan="1">
								<span>${studentCourse.student.firstName} ${studentCourse.student.lastName}</span>
								<br/>
								<a href="mailto:${studentCourse.student.email}">${studentCourse.student.email}</a>
							</td>
							<td rowspan="1" colspan="1">${studentCourse.student.school}</td>
							<td rowspan="1" colspan="1">${studentCourse.studentCourseAttributes['levelOption']}</td>
							<td rowspan="1" colspan="1">${studentCourse.studentCourseAttributes['gradingOption']}</td>
							<td rowspan="1" colspan="1">
								<a class="course_approve approvethis" style="font-size: small" title="" href="javascript:void(0);" shape="rect">approve</a>
								<a class="course_deny denythis" style="font-size: small" title="" href="javascript:void(0);" shape="rect">deny</a>
							</td>
						</tr>
					</g:each>
				</tbody>
			</table>
		</fieldset>
    </body>
</html>