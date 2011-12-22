<%@ page contentType="text/html"%>
<html>
<head></head>
<body>
<p>Dear <b>${faculty.name},</b></p>

<p>Students are requesting to cross-register into <b>${course.code}</b>.</p>

<g:each var="student" in="${students}">
<b>${student.name}</b>, ${student.schoolDisplay}<br/>
</g:each>

<p><b>To take action on the petitions you may either:</b></p>
<ul>
<li>Log into the Cross Registration System and approve the petitions yourself, or</li>
<li>Forward this email to your faculty assistant, who will act as your proxy in approving or denying the petitions.</li>
</ul>

<p><b>To Approve the Petitions Yourself</b></p>
<ul>
<li>Please visit the <a href="${url}">Cross Registration System</a>. If you are unable to click the link, please copy and paste the link, with no spaces, into your browser address bar.  <a href="${url}">${url}</a></li>
<li>Login with your HUID and PIN.</li>
<li>Petitions can be approved/denied individually or in bulk.
	<ul>
		<li>To approve/deny individually, click either approve or deny in the Action column.</li>
		<li>To approve/deny in bulk, use the check boxes to select petitions you want to take action on or to select all petitions, click the check box in the column header, and then click either Approve All Selected or Deny All Selected.</li>
	</ul>
</li>   
<li>Click confirm in the pop-up to finalize your selections.</li>
<li>If you need to change your selections after you click confirm, please contact the HSPH Registrar’s Office.</li>
</ul>

<p>If you have any questions, please contact Carter Svensson, <a href="mailto:svensson@hsph.harvard.edu">Svensson@hsph.harvard.edu</a></p>


<p>Thank You.</p>
</body>
</html>
