<%--
  Created by IntelliJ IDEA.
  User: Phil
  Date: 4/20/17
  Time: 5:12 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.Types,
java.sql.DriverManager,java.sql.DriverPropertyInfo,java.sql.SQLPermission,java.sql.Connection,
java.sql.Statement,java.sql.ResultSet,java.sql.SQLException,java.text.SimpleDateFormat,
java.util.*,java.io.*,java.sql.PreparedStatement,java.sql.CallableStatement,
java.sql.DatabaseMetaData"%>
<html>
<head>
    <title>Student Acedemics</title>
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
if ( ( !(request.getParameter("sid") == null) || !(sid == null) )  )//if student was sent here from login pg or has active cookie
{%>

<div class="selectProject">
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

                String getStudentInfo = "SELECT deg_prog, email, name FROM Undergraduate WHERE sid = " + sid;

                String getCourseInfo = "SELECT c.cid, name, semester, date, grade FROM Course c, Enrolled_in e " +
                                       "WHERE c.cid = e.cid AND e.sid = " + sid;

                ResultSet courseInfo = st.executeQuery(getCourseInfo);
                ResultSet studentInfo = st2.executeQuery(getStudentInfo);
                studentInfo.first();

                String major = studentInfo.getString("deg_prog");

                int dno = 0;

                if ( major.equals("Computer Science") )
                {
                    dno = 1;
                }
                else if ( major.equals("English") )
                {
                    dno = 2;
                }
                else if ( major.equals("Mathematics") )
                {
                    dno = 3;
                }
                else //ECE
                {
                    dno = 4;
                }
            %>  <em align="left">Student Portal</em> <br/> <br/>
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
                <h1 align="center"><%=studentInfo.getString("name").substring(0, studentInfo.getString("name").indexOf(" "))%>'s Acedemics Page</h1><hr><br>
                <p>Current Major: <%=studentInfo.getString("deg_prog")%></p>
                <p>To see current degree Requirements, <a href="degreeRequirements.jsp?dno=<%=dno%>">click here</a></p>
                <br/>
                <p align="left"><b><a href="selectMajor.jsp?sid=<%=sid%>">Change/Select Major</a></b></p><br>
                <p align="left"><b><a href="addCourses.jsp?sid=<%=sid%>">Add/Drop Courses</a></b></p><br>

                <hr/>
                <div class="grades" align="center">
                    <h3 style="text-align: center">Grades</h3>
                    <table align="center" border="2px">
                        <tr>
                            <th>Course #</th>
                            <th>Name</th>
                            <th>Semester</th>
                            <th>Date</th>
                            <th>Final Grade</th>
                        </tr>
            <%
                        while ( courseInfo.next() )
                        {
                            String grade = "";
                            if ( courseInfo.getString("grade") != null )
                            {
                                grade = courseInfo.getString("grade");

                            }

                        %>
                            <tr>
                                <td><%=courseInfo.getInt("cid")%></td>
                                <td><%=courseInfo.getString("name")%></td>
                                <td><%=courseInfo.getString("semester")%></td>
                                <td><%=courseInfo.getString("date")%></td>
                                <td><%=grade%></td>
                                <td></td>
                            </tr>
                      <%}
            %>
                    </table>
                </div>




          <%}
            catch(SQLException e)
            {
                out.print(e.getErrorCode() + e.getSQLState() + e.getMessage());
            }
}
else
{
    out.println("<p>Please <b><a href=\"login.jsp\">login</a></b> first to access this page.</p>");
}
%>
</body>
</html>
