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
    	<div class="course_catalog_tool">
    	<div class="result">
    	<g:each in="${model}" var="entry">
	    	<fieldset>
				<legend>${entry.key}</legend>
				<table class="grid petition_form">
					<thead>
						<tr>
							<th style="width: 100%" rowspan="1" colspan="1">Student</th>
							<th rowspan="1" colspan="1">School</th>
							<th rowspan="1" colspan="1">Level</th>
							<th rowspan="1" colspan="1">Grading&nbsp;Option</th>
							<th rowspan="1" colspan="1">Status</th>
						</tr>
					</thead>
					<tbody>
		    			<g:each in="${entry.value}" var="studentCourse">
							<tr class="course" id="${studentCourse.id}">
								<td rowspan="1" colspan="1">
									<span>${studentCourse.student.firstName} ${studentCourse.student.lastName}</span>
									<br/>
									<a href="mailto:${studentCourse.student.email}">${studentCourse.student.email}</a>
								</td>
								<td rowspan="1" colspan="1">${studentCourse.student.school}</td>
								<td rowspan="1" colspan="1">
									${studentCourse.levelOption}
								</td>
								<td rowspan="1" colspan="1">
									${studentCourse.gradingOption}
								</td>
								<td rowspan="1" colspan="1">
									<a class="course_approve approvethis" style="font-size: small" title="" href="javascript:void(0);" shape="rect">Approve</a>
									<a class="course_deny denythis" style="font-size: small" title="" href="javascript:void(0);" shape="rect">Deny</a>
								</td>
							</tr>
						</g:each>
					</tbody>
				</table>
			</fieldset>
		</g:each>
		</div>
		</div>
    </body>
</html>