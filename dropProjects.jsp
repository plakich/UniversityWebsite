<%--
  Created by IntelliJ IDEA.
  User: Phil
  Date: 4/22/17
  Time: 5:16 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.Types,
java.sql.DriverManager,java.sql.DriverPropertyInfo,java.sql.SQLPermission,java.sql.Connection,
java.sql.Statement,java.sql.ResultSet,java.sql.SQLException,java.text.SimpleDateFormat,
java.util.*,java.io.*,java.sql.PreparedStatement,java.sql.CallableStatement,
java.sql.DatabaseMetaData"%>
<html>
<head>
    <title>Title</title>
    <link rel="stylesheet" href="bootstrap.css" type="text/css"/>
</head>
<body>
    <%  //there are only two ways to gain access to this page: by active cookie or logging in directly from login page

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
if ( !(request.getParameter("sid") == null) || !(sid == null) && request.getParameter("project") == null )//if student was sent here from login pg or has active cookie
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


                if ( studentInfo.first() )
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
                }%>
                    <h1 align="center">Drop Projects </h1>
                    <hr></hr>
                <%
                if ( !studentProjects.first() ) //if student hasn't selected projects yet
                {%>
                    <h1 align="center">You are not signed up for any projects.
                    Click <a href="addProjects.jsp?&major=<%=major%>">
                    <strong>here</strong></a> to see a list of projects you can sign up for.</h1>

              <%}
                else //display projects to drop
                {%>
                    <form method="post" action="dropProjects.jsp">
                <%
                    int i = 0;
                    studentProjects.beforeFirst();

                    while ( studentProjects.next() )
                    {%>
                        <input type="checkbox" name="project<%=i+1%>" value="<%=studentProjects.getInt("pid")%>"><%=i+1%>.
                        <b>Project Sponsor</b>: <%=studentProjects.getString("sponsor")%>.
                        <b>Project Description</b>: <%=studentProjects.getString("description")%><br><br><br>
                  <%    i++;
                    }%>
                        <input type="hidden" name="projectNum" value="<%=i%>">
                        <input type="submit" value="Drop Project(s)" name="project">
                    </form>
                   <%
                }
            }
            catch(SQLException e)
            {
                out.println("<p>" + e.getMessage() + e.getErrorCode() + e.getSQLState() + "</p>");
            }
}
else if ( (!(request.getParameter("sid") == null) || !(sid == null) ) && request.getParameter("project").trim().equals("Drop Project(s)") ) //delete project from database
{
     if ( !(request.getParameter("sid") == null) ) //if user accessed page by logging in
     {
        sid = request.getParameter("sid").trim();
     }
     else
     {
                //user successfully accessed page directly through active session cookie
                //which was set at the top of page through request.getCookies()
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

        //the query below selects a supervisor for the student based on which professor is supervising the
        //minimum number of students for that major at this particular time



        String sid_ug = request.getParameter("sid");

        int numProjectsToAdd = Integer.parseInt(request.getParameter("projectNum"));


        String pids = "pid in ("; //build tuples to insert into supervises table
        Boolean firstTupleAdded = false;
        for (int i = 0; i < numProjectsToAdd; i++ )
        {
            if ( !firstTupleAdded && (request.getParameter("project" + (i+1)) != null) ) //if first time through loop, values string already has opening right parenthesis
            {
                pids += request.getParameter("project" + (i+1));
                firstTupleAdded = true;
            }
            else if ( firstTupleAdded && request.getParameter("project" + (i+1)) != null ) //if student actually clicked the checkbox for the project
            {
                pids += "," +  request.getParameter("project" + (i+1));
            }

        }
        pids += ")";

        int success = 0;

        if ( !(pids.equals("pid in ()")) )
        {
            String studentProjects = "DELETE FROM supervises where sid_ug = " + sid + " AND " + pids;
            success = st2.executeUpdate(studentProjects);
        }


        response.sendRedirect("studentProject.jsp?sid=" + sid + "&success=" + success + "&value=" + pids );
        return;

     }
     catch(SQLException e)
     {
        out.println("<p>" + e.getMessage() + e.getErrorCode() + e.getSQLState() + "</p>");
     }

}
else
{%>
    <h4>Please <a href="login.jsp">login</a> drop research projects.</h4>
<%
}
%>

</body>
</html>
