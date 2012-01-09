<%@ page contentType="text/html"%>
<html>
<head></head>
<body>
<p>Dear <b>${faculty.name}</b>,</p>

<p>Students are petitioning to cross register into <b>${course.code}</b>.</p>

<g:each var="student" in="${students}">
<b>${student.name}</b>, ${student.schoolDisplay}<br/>
</g:each>

<p><b>To take action on the petitions you may either:</b></p>
<ul>
<li>Log into the Cross Registration System and approve the petitions yourself, or</li>
<li>Forward this email to your faculty assistant, who will act as your proxy in approving or denying the petitions.</li>
</ul>

<p><b>To Approve the Petitions Yourself:</b></p>
<ul>
<li>Please visit <a href="${url}">Cross Registration System</a>. If the link is broken, copy and paste it (with no spaces) into your browser address bar. <a href="${url}">${url}</a>
<li>Login with your HUID and PIN.
<li>Petitions may be approved or denied, either individually or in bulk.
	<ul>
		<li>To approve or deny individually, click either “Approve” or “Deny” in the “Action” column next to the student’s name.</li>
		<li>To approve or deny multiple petitions, use the check boxes to select those petitions you want to take action on by clicking either “Approve” or “Deny” in the “Action” column next to the student’s name.</li>
		<li>To approve or deny all, click the check box in the column header, and then click either “Approve All Selected” or “Deny All Selected.”</li>
	</ul>
</li>
<li>Click “Confirm” in the pop-up, to finalize your approvals and/or denials.</li>
<li>If you need to change your selections after you click confirm or have any questions, please contact Charles Perreault, <a href="mailto:charles_perreault@gse.harvard.edu">charles_perreault@gse.harvard.edu</a>.</li>
</ul>

<p>Thank You.</p>
