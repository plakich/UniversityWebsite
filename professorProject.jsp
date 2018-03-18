<%--
  Created by IntelliJ IDEA.
  User: Phil
  Date: 4/23/17
  Time: 10:52 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.Types,
java.sql.DriverManager,java.sql.DriverPropertyInfo,java.sql.SQLPermission,java.sql.Connection,
java.sql.Statement,java.sql.ResultSet,java.sql.SQLException,java.text.SimpleDateFormat,
java.util.*,java.io.*,java.sql.PreparedStatement,java.sql.CallableStatement,
java.sql.DatabaseMetaData"%>
<html>
<head>
    <title>Professor Project</title>
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
    String logout = "faculty";
    Cookie[] cookie = null;
    String email = null;
    cookie = request.getCookies();
    if( cookie != null )
    {
        for (int i = 0; i < cookie.length; i++)
        {
            if (cookie[i].getName().equals("WebEmail"))
            {
                email = cookie[i].getValue().trim();
            }
        }
    }

if ( !(request.getParameter("email") == null) || !(email == null) )
{%>
<div class="professorInfo">
<%
            if ( !(request.getParameter("email") == null) ) //if user accessed page by logging in
            {
                email = request.getParameter("email").trim();
            }
            else
            {
                //user successfully accessed page directly through active session cookie
                //which was set above by getCookies()
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
                Statement st7 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                Statement st8 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);

                String checkIfDeptHead = "SELECT COUNT(*) FROM Professor p, Dept d WHERE p.ssn = d.ssn AND p.email = '" +
                                         email + "'";
                String getProfessorInfo = "SELECT * FROM Professor p WHERE p.email = '" + email + "'";

                ResultSet professorInfo = st.executeQuery(getProfessorInfo);
                professorInfo.first();

                String getProjectManagerCount = "SELECT COUNT(*) FROM Project WHERE manager_ssn = '" + professorInfo.getString("ssn") + "'";
                String getProjectManagementInfo = "SELECT * FROM Project WHERE manager_ssn = '" + professorInfo.getString("ssn") + "'"
                                                   + " ORDER BY pid";
                String getStudentSupervisingInfo = "SELECT sid, name, email, pid FROM Supervises s, Undergraduate u WHERE s.ssn = '" +
                                           professorInfo.getString("ssn") + "' AND s.sid_ug = u.sid AND s.sid_ug IN (" +
                                           "SELECT sid_ug FROM Supervises WHERE ssn = '" + professorInfo.getString("ssn") + "')" +
                                           " ORDER BY pid";
                String getSupervisingCount = "SELECT COUNT(DISTINCT sid_ug) FROM Supervises WHERE ssn = '" + professorInfo.getString("ssn") + "'";
                String getProfessorsWorkProjectInfo = "SELECT * FROM Project p, Supervises s WHERE s.ssn = '" +
                                                      professorInfo.getString("ssn") + "' AND p.pid = s.pid ORDER BY p.pid";


                ResultSet studentSupervisingInfo = st3.executeQuery(getStudentSupervisingInfo);
                ResultSet supervisingCount = st4.executeQuery(getSupervisingCount);
                ResultSet projectManagementInfo = st5.executeQuery(getProjectManagementInfo);
                ResultSet projectManagerCount = st6.executeQuery(getProjectManagerCount);
                ResultSet professorsWorkProject = st7.executeQuery(getProfessorsWorkProjectInfo);


                projectManagerCount.first();

                String major = "";
                int dno = 0;

                 if ( professorInfo.getInt("dno") == 1 )
                 {
                    major = "Computer Science";
                    dno = 1;
                 }
                 else if ( professorInfo.getInt("dno") == 2 )
                 {
                    major = "English";
                    dno = 2;
                 }
                 else if ( professorInfo.getInt("dno") == 3 )
                 {
                    major = "Mathematics";
                    dno = 3;
                 }
                 else if ( professorInfo.getInt("dno") == 4 )
                 {
                    major = "ECE";
                    dno = 4;
                 }

                ResultSet deptHead = st2.executeQuery(checkIfDeptHead);
                supervisingCount.first();
                deptHead.first();

                if( deptHead.getInt(1) > 0 ) //professor is manager of projects for this dept
                {%>
                  <br/><br/>
                  <div class="nav_bar">
                      <ul>
                        <li><a href="professorHome.jsp"> myHome </a></li>
                        <li><a href="professorAcademics.jsp"> Academics </a></li>
                        <li><a href="professorProject.jsp"> Projects </a></li>
                        <li><a href="professorMessage.jsp"> Messages </a></li>
                        <li><a href="logout.jsp?logout=<%=logout%>"> Logout </a></li>
                      </ul>
                  </div>
                  <br/> <br/>
                    <h1 align="center">Professor <%=professorInfo.getString("name").substring(professorInfo.getString("name").indexOf(" "))%>'s
                    Management Page for <%=major%> Projects</h1><hr>
                    <h3>You are managing <%=projectManagerCount.getInt(1)%> project(s).<br>
                    You are supervising <%=supervisingCount.getInt(1)%> student(s).<br>
                    Project info: </h3><br>
              <%

                    while ( projectManagementInfo.next() )
                    {
                        String studentsSupervised = "";
                        int supervisedCount = 0;
                        String info = "";

                        while ( studentSupervisingInfo.next() )
                        {
                            if( studentSupervisingInfo.getInt("pid") == projectManagementInfo.getInt("pid") )
                            {
                                info = "<em>Info for Students in This Project: </em><br>";
                                studentsSupervised += "<b>Student Name:</b> " + studentSupervisingInfo.getString("name") +
                                                      "\n<br><b>Student Email:</b> " + studentSupervisingInfo.getString("email") + "\n<br>";
                                supervisedCount++;
                            }
                        }
                        studentSupervisingInfo.beforeFirst();

                    %>
                        <p>
                        <b>Project ID Number:</b> <%=projectManagementInfo.getInt("pid")%><br>
                        <b>Project Sponsor:</b> <%=projectManagementInfo.getString("sponsor")%><br>
                        <b>Project Start Date:</b> <%=projectManagementInfo.getString("start_date")%><br>
                        <b>Project End Date:</b> <%=projectManagementInfo.getString("end_date")%><br>
                        <b>Project Budget:</b> $<%=projectManagementInfo.getInt("budget")%><br>
                        <b>Project Description:</b> <%=projectManagementInfo.getString("description")%><br><br>
                        <%=info%>
                        <%=studentsSupervised%></p><br><br><hr>


                  <%}


                }
                else //professor is only supervisor
                {%>
                    <h1 align="center">Professor <%=professorInfo.getString("name").substring(professorInfo.getString("name").indexOf(" "))%>'s
                    Supervising Page for <%=major%> Projects</h1><hr>
                    <h3>You are supervising <%=supervisingCount.getInt(1)%> student(s). <br>
                    Project info: </h3><br>
              <%
                    while ( professorsWorkProject.next() )
                    {
                        int pid = professorsWorkProject.getInt("pid");
                        String info = "";
                        int supervisedCount = 0;
                        String studentsSupervised = "";

                        while ( studentSupervisingInfo.next() )
                        {
                            if( studentSupervisingInfo.getInt("pid") == pid )
                            {
                                info = "<em>Info for Students in This Project: </em><br>";
                                studentsSupervised += "<b>Student Name:</b> " + studentSupervisingInfo.getString("name") +
                                                      "\n<br><b>Student Email:</b> " + studentSupervisingInfo.getString("email") + "\n<br>";
                                supervisedCount++;
                            }
                        }
                        studentSupervisingInfo.beforeFirst();




                    %>
                        <p>
                        <b>Project ID Number:</b> <%=professorsWorkProject.getInt("pid")%><br>
                        <b>Project Sponsor:</b> <%=professorsWorkProject.getString("sponsor")%><br>
                        <b>Project Start Date:</b> <%=professorsWorkProject.getString("start_date")%><br>
                        <b>Project End Date:</b> <%=professorsWorkProject.getString("end_date")%><br>
                        <b>Project Description:</b> <%=professorsWorkProject.getString("description")%><br><br>
                        <%=info%>
                        <%=studentsSupervised%></p><br><br><hr>

                   <%   professorsWorkProject.next();
                        if ( pid == professorsWorkProject.getInt("pid") )
                        {
                            // do nothing, next iteration of while loop will move cursor to correct project

                        }
                        else
                        {
                            professorsWorkProject.previous();
                        }


                    }



                }




            }
            catch(SQLException e)
            {
                //
            }
}
else
{
    out.println("<p>Please <b><a href=\"login.jsp\">login</a></b> first to access your project page.");
}
%>

</body>
</html>
