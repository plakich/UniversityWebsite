<%--
  Created by IntelliJ IDEA.
  User: Phil
  Date: 4/15/17
  Time: 5:34 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.Types,
java.sql.DriverManager,java.sql.DriverPropertyInfo,java.sql.SQLPermission,java.sql.Connection,
java.sql.Statement,java.sql.ResultSet,java.sql.SQLException,java.text.SimpleDateFormat,
java.util.*,java.io.*,java.sql.PreparedStatement,java.sql.CallableStatement,
java.sql.DatabaseMetaData"%>
<html>
<head>
    <title>Student Projects</title>
    <link rel="stylesheet" href="bootstrap.css" type="text/css"/>
    <style>
			.nav_bar{
				margin: auto;
				padding: 0px 20px 0px 20px;
			}
			.nav_bar ul{
				padding: 0;
				list-style: none;
			}
			.nav_bar ul li{
				float:left;
				font-size: 16px;
				font-weight: bold;
				margin-right: 10px;
			}
			.nav_bar ul li a{
				text-decoration: none;
				color: #000000;
				background: #6db1e4;
				border: 1px solid #000000;
				border-bottom: none;
				padding: 20px 20px 20px 20px;
			}
		</style>
</head>
<body>
    <%  //there are only two ways to gain access to this page: by active cookie or logging in directly from login page
    String logout = "student";
    Cookie[] cookie = null;
    String sid = null;
    cookie = request.getCookies();
    if( cookie != null )
    {
      for (int i = 0; i < cookie.length; i++)
      {
          if ( cookie[i].getName().equals("WebSid") )
          {
              sid = cookie[i].getValue().trim();
          }
      }
    }
if ( !(request.getParameter("sid") == null) || !(sid == null) )//if student was sent here from login pg or has active cookie
{%>
<div class="studentInfo">
<%
            if ( !(request.getParameter("sid") == null) ) //if user accessed page by logging in
            {
                sid = request.getParameter("sid").trim();
            }
            else
            {
                //user successfully accessed page directly through active session cookie
                //which was set above through request.getCookies()
            }

            try
            {
                Class.forName("org.postgresql.Driver");
            }
            catch(ClassNotFoundException ex)
            {
                out.println("Error: unable to load driver class!");
                return;
            }
            String login = "jdbc:postgresql://localhost:5432/web";
            String user = "postgres";
            String pass = "a";
            try
            {
                Connection con = DriverManager.getConnection(login, user, pass);
                Statement st = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                Statement st2 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                Statement st3 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                Statement st4 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                Statement st5 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                Statement st6 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);

                String getStudentProjects = "SELECT * FROM Supervises s NATURAL JOIN Project p WHERE s.pid = p.pid AND s.sid_ug = " + sid
                                            + " ORDER BY pid";
                String getStudentInfo = "SELECT deg_prog, email, name FROM Undergraduate WHERE sid = " + sid;


                ResultSet studentInfo = st.executeQuery(getStudentInfo);
                ResultSet studentProjects = st2.executeQuery(getStudentProjects);
                int major = 0;

                studentInfo.next();
                if ( studentInfo.getString("deg_prog").trim().equals("Undecided") )
                {%>
                     <h4>The student research provided by JSU is offered only to students who have declared their major.</br>
                         Go to the <a href="studentAcademics.jsp">academics page</a> to declare your major and take part in JSU's </br>
                         unique research opportunities!</h4>
              <%
                }
                else //student has declared major, set major = to dept number of major
                {
                     if ( studentInfo.getString("deg_prog").trim().equals("Computer Science") )
                     {
                         major = 1;
                     }
                     else if ( studentInfo.getString("deg_prog").trim().equals("English") )
                     {
                         major = 2;
                     }
                     else if ( studentInfo.getString("deg_prog").trim().equals("Mathematics") )
                     {
                         major = 3;
                     }
                     else if ( studentInfo.getString("deg_prog").trim().equals("ECE") )
                     {
                         major = 4;
                     }
                }

                if ( !studentProjects.first() ) //if student hasn't selected projects yet
                {%>
                     <h1 align="center">Welcome to JSU's student research project page!</h1><hr><hr><br>
                     <h1 align="center">You are not currently signed up for any projects. Click <a href="addProjects.jsp?&major=<%=major%>">
                     <strong>here</strong></a> to see a list of projects you can sign up for.</h1>
              <%}
                else //display student projects
                {
                    studentProjects.beforeFirst();

                    String getStudentProjectsCount = "SELECT COUNT(*) FROM Supervises WHERE sid_ug = " + sid;
                    String getProjectManagerInfo = "SELECT DISTINCT s.name, s.email, s.dno FROM project p NATURAL JOIN " +
                                               "professor s WHERE p.manager_ssn = s.ssn AND p.dno = " + major + " ORDER BY dno";
                    String getSupervisorInfo = "SELECT DISTINCT name, office, email, pid FROM supervises s, professor p WHERE "
                                               + "p.ssn = s.ssn AND s.sid_ug = " + sid + " ORDER BY pid";


                    ResultSet projectCount = st3.executeQuery(getStudentProjectsCount);
                    ResultSet projectManager = st4.executeQuery(getProjectManagerInfo);
                    ResultSet supervisorInfo = st5.executeQuery(getSupervisorInfo);

                    projectCount.first();
                    projectManager.first();

                    String project = "";
                    if ( projectCount.getInt(1) > 1 ) //if student has more than one project, set string to plural, else singular
                    {
                        project = "projects";
                    }
                    else
                    {
                        project = "project";
                    }

                %>
                <br/> <br/>
                <div class="nav_bar">
                    <ul>
                      <li><a href="studentHome.jsp"> myHome </a></li>
                      <li><a href="studentAcedemics.jsp"> Academics </a></li>
                      <li><a href="studentProject.jsp"> Projects </a></li>
                      <li><a href="studentMessage.jsp"> Messages </a></li>
                      <li><a href="logout.jsp?logout=<%=logout%>"> Logout </a></li>
                    </ul>
                </div>
                <br/><br/>
                    <h1 align="center"><%=studentInfo.getString("name")%>'s <%=studentInfo.getString("deg_prog")%> Projects.</h1><hr><hr>
                    <h2>You are participating in <%=projectCount.getInt(1)%> research <%=project%>.</h2>
                    <h3>The project manager for your <%=project%> is <%=projectManager.getString("name")%>.
                    <br>All work on your <%=project%> is to be submitted to your manager at email address <%=projectManager.getString("email")%></h3>
                    <br><br><br>

                        <%
                            int i = 1;
                            while ( studentProjects.next() && supervisorInfo.next() )
                            {%> <%=i%>.
                                <table style="table-layout: fixed; width: 100%"; align="center" border="2px">
                                    <tr><th>Project Sponsor</th>
                                        <th>Start Date</th>
                                        <th>End Date</th>
                                        <th>Project Description</th>
                                    </tr>
                                    <tr>
                                        <td><%=studentProjects.getString("sponsor")%></td>
                                        <td><%=studentProjects.getString("start_date")%></td>
                                        <td><%=studentProjects.getString("end_date")%></td>
                                        <td><%=studentProjects.getString("description")%></td>
                                    </tr>
                                </table>
                                <em>Please report to your supervisor <%=supervisorInfo.getString("name")%>
                                at office <%=supervisorInfo.getString("office")%> each week to receive assignments.</em><br><br><br>
                          <%    i++;

                            }//while()


                        %>      <form method="post" action="studentProject.jsp?" id="form">
                                 To <input type="text" name="to" value="<%=projectManager.getString("email")%>">
                                    <input type="hidden" name="from" value="<%=studentInfo.getString("email")%>">
                                    <input type="hidden" name="name" value="<%=studentInfo.getString("name")%>">
                                    <input type="submit" name="message" value="Submit Report">
                                </form>


                                <textarea rows="15" cols="50" name="body" form="form">Type message here.
                                </textarea>

<%
                                if ( request.getParameter("message") != null ) //if user submitted a research report
                                {

                                    String sendMessage = "INSERT INTO message (message, email, subject, sender) VALUES ('" +
                                    request.getParameter("message") + "','" + request.getParameter("to") + "','" +
                                                          ",'" + request.getParameter("from") + "')";
                                    int sent = st6.executeUpdate(sendMessage);
                              %>
                                    <p>Message sent!</p>
                              <%
                                }
                              %>
                                    <form align="center">
                                        <button formaction="addProjects.jsp?sid=<%=sid%>">Add Project(s)</button>
                                    </form>
                                    <form align="right">
                                        <button formaction="dropProjects.jsp?sid=<%=sid%>">Drop Project(s)</button>
                                    </form>
                             <%
                }//else
            }
            catch(Exception e)
            {
                out.println("<p>Message Sent!.</p>");
            }
}
else //user accessed page without logging in or having active session cookie.
{
%>
    <h4>Please <b><a href="login.jsp">login</a></b> to see your research projects.</h4>
<%

}


%>

</body>
</html>
