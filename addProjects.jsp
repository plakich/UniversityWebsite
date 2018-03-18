<%--
  Created by IntelliJ IDEA.
  User: Phil
  Date: 4/21/17
  Time: 11:27 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.Types,
java.sql.DriverManager,java.sql.DriverPropertyInfo,java.sql.SQLPermission,java.sql.Connection,
java.sql.Statement,java.sql.ResultSet,java.sql.SQLException,java.text.SimpleDateFormat,
java.util.*,java.io.*,java.sql.PreparedStatement,java.sql.CallableStatement,
java.sql.DatabaseMetaData"%>
<html>
<head>
    <title>Add Projects</title>
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
if ( ( !(request.getParameter("sid") == null) || !(sid == null) ) && request.getParameter("project") == null )//if student was sent here from login pg or has active cookie
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
                   return;
                }
                else if ( request.getParameter("major") != null ) //student accessed this page from studentProject page
                {
                    major = Integer.parseInt( request.getParameter("major").trim() );
                }
                else //student accessed page directly, so set student's major from database
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
                    <h1 align="center"><%=studentInfo.getString("deg_prog")%> Projects </h1>
                    <hr></hr>
                <%
                String getProjectList = "SELECT * FROM Project WHERE dno = " + major + " ORDER BY pid";
                ResultSet projectList = st3.executeQuery(getProjectList);


                {%> <form action="addProjects.jsp" method="post">
                <%

                    int i;
                    Boolean studentHasProjects;

                    if( studentProjects.first() ) //if student sid was anywhere in project table, they are working on a project
                    {
                        studentHasProjects = true;
                    }
                    else
                    {
                        studentHasProjects = false;
                    }

                    for ( i = 0; projectList.next(); ) //for however many projects that major has
                    {


                        if (  studentHasProjects && (studentProjects.getInt("pid") == projectList.getInt("pid"))  ) //if student has already signed up for this project, don't list as checkable option
                        {%>
                            <b>Project Sponsor</b>: <%=projectList.getString("sponsor")%>. <b>Project Description</b>:
                            <%=projectList.getString("description")%><br><br><br>
                      <%    if(!studentProjects.next())studentProjects.first(); //only advance resultset forward if not null

                        }
                        else //student hasn't sign up for this project, so make a checkbox next to project name so they can sign up
                        {
                      %>
                            <input type="checkbox" name="project<%=i+1%>" value="<%=projectList.getInt("pid")%>"><%=i+1%>.
                            <b>Project Sponsor</b>: <%=projectList.getString("sponsor")%>.
                            <b>Project Description</b>: <%=projectList.getString("description")%><br><br><br>
                      <%
                            i++;
                        }
                    }
                %>
                        <input type="hidden" name="sid" value="<%=sid%>">
                        <input type="hidden" name="major" value="<%=major%>">
                        <input type="hidden" name="projectNum" value="<%=i%>">
                        <input type="submit" value="Add Project(s)" name="project">
                    </form>
                    <em>Note: projects without a checkbox are ones you have already signed up for.</em>
                <%

                }
            }
            catch(SQLException e)
            {
                out.println("<p>" + e.getMessage() + e.getErrorCode() + e.getSQLState() + "</p>");
            }
}
else if ( (!(request.getParameter("sid") == null) || !(sid == null) ) && request.getParameter("project").trim().equals("Add Project(s)") ) //add project to database, select project advisor for student
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

        String getSupervisor = "SELECT temp2.ssn FROM (SELECT temp.ssn, MIN(temp.count) FROM (SELECT ssn, " +
                               "COUNT(ssn) FROM professor p NATURAL JOIN supervises s WHERE s.ssn = p.ssn AND " +
                               "dno = " + request.getParameter("major") +
                               " GROUP BY ssn) as temp GROUP BY temp.count, temp.ssn limit 1) as temp2";


        ResultSet studentSupervisor = st.executeQuery(getSupervisor);
        studentSupervisor.first();
        String supervisor = studentSupervisor.getString("ssn").trim();
        String sid_ug = request.getParameter("sid");

        int numProjectsToAdd = Integer.parseInt(request.getParameter("projectNum"));


        String values = "VALUES ("; //build tuples to insert into supervises table
        Boolean firstTupleAdded = false;
        for (int i = 0; i < numProjectsToAdd; i++ )
        {
            if ( !firstTupleAdded && (request.getParameter("project" + (i+1)) != null) ) //if first time through loop, values string already has opening right parenthesis
            {
                values += request.getParameter("project" + (i+1)) + ",'" + supervisor + "'," +
                      sid_ug + ")";
                firstTupleAdded = true;
            }
            else if ( firstTupleAdded && request.getParameter("project" + (i+1)) != null ) //if student actually clicked the checkbox for the project
            {
                values += ",(" + request.getParameter("project" + (i+1)) + ",'" + supervisor + "'," +
                      sid_ug + ")";
            }

        }

        int success = 0;

        if ( !(values.equals("VALUES (")) ) //if projects were actually selected by checkbox and added to string
        {
            String studentProjects = "INSERT INTO Supervises (pid, ssn, sid_ug) " + values;
            success = st2.executeUpdate(studentProjects);
        }


        response.sendRedirect("studentProject.jsp?sid=" + sid + "&success=" + success + "&value=" + values );
        return;

     }
     catch(SQLException e)
     {
        out.println("<p>" + e.getMessage() + e.getErrorCode() + e.getSQLState() + "</p>");
     }

}
else
{%>
    <h4>Please <a href="login.jsp">login</a> first to select your research projects.</h4>
<%
}
%>


</body>
</html>
