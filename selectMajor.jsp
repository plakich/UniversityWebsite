<%--
  Created by IntelliJ IDEA.
  User: Phil
  Date: 4/25/17
  Time: 11:40 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.Types,
java.sql.DriverManager,java.sql.DriverPropertyInfo,java.sql.SQLPermission,java.sql.Connection,
java.sql.Statement,java.sql.ResultSet,java.sql.SQLException,java.text.SimpleDateFormat,
java.util.*,java.io.*,java.sql.PreparedStatement,java.sql.CallableStatement,
java.sql.DatabaseMetaData"%>
<html>
<head>
    <title>Select/Change Major</title>
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
                Statement st4 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                Statement st5 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);

                String getStudentInfo = "SELECT * FROM Undergraduate WHERE sid = " + sid;

                String getCourseInfo = "SELECT c.cid, name, semester, date, grade FROM Course c, Enrolled_in e " +
                        "WHERE c.cid = e.cid AND e.sid = " + sid;

                ResultSet courseInfo = st.executeQuery(getCourseInfo);
                ResultSet studentInfo = st2.executeQuery(getStudentInfo);
                studentInfo.first();
            %>
                <em align="left">Student Portal</em>
                <h1 align="center">Select/Change Major</h1><hr><br>
                <p>Current Major: <%=studentInfo.getString("deg_prog")%></p><br><br>
    <form method="get" action="selectMajor.jsp?sid=<%=sid%>">
        <label>Please select your major: </label>
        <select name="major" id="major">
            <option value="Computer Science">Computer Science</option>
            <option value="English">English</option>
            <option value="Mathematics">Mathematics</option>
            <option value="ECE">ECE</option>
        </select>
        <input type="submit" value="submit" name="list">
    </form>
    <%          if ( request.getParameter("list") != null )
                {

                    String major = request.getParameter("major").trim();
                    String changeMajor = "UPDATE Undergraduate SET deg_prog = '" + major + "'" +
                                         " WHERE sid = " + sid;

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


                    int majorChanged = st.executeUpdate(changeMajor);

                    if ( 1 == majorChanged ) //if major set, then select advisor for them
                    {
                        if ( !studentInfo.getString("level").equals("Senior") ) //if student is not senior, they have advisor
                        {
                            String getAdvisor = "SELECT TEMP2.advsid FROM (SELECT U2.advsid, COUNT(U2.advsid) FROM Undergraduate U2, " +
                                    "(SELECT U.advsid FROM Undergraduate U WHERE U.level = 'Senior' AND deg_prog = '" + major + "') AS " +
                                    "TEMP WHERE TEMP.advsid = U2.advsid GROUP BY U2.advsid HAVING COUNT(U2.advsid) <= MIN(U2.advsid) LIMIT 1) AS TEMP2";
                            ResultSet rs = st2.executeQuery(getAdvisor);
                            rs.first();
                            int advSid = rs.getInt(1);
                            String setAvisor = "UPDATE Undergraduate SET advsid = " + advSid + " WHERE sid = " + sid;
                            int advSet = st3.executeUpdate(setAvisor);

                            if ( 1 == advSet ) //if advisor successfully set, display message
                            {
                                String getAdvisorInfo = "SELECT * FROM Undergraduate WHERE sid = " + advSid;
                                ResultSet rs2 = st4.executeQuery(getAdvisorInfo);

                                rs2.first();
                                %>
                                    <h3>You successfully changed your major to <%=major%>!<br>
                                    Please visit the <a href="degreeRequirements.jsp?dno=<%=dno%>">Degree Requirements</a> page
                                    to see a four year plan for your major.</h3><br>
                                    <p>If you have any other questions or concerns, please contact your major's advisor at
                                    <%=rs2.getString("email")%>.</p>
                                <%
                            }



                        }
                        else
                        {%>
                            <h3>You successfully changed your major to <%=major%>!<br>
                                Please visit the <a href="degreeRequirements.jsp?dno=<%=dno%>">Degree Requirements</a> page
                                to see a four year plan for your major.</h3><br>

                      <%}



                    }




                }






            }
            catch(Exception e)
            {
                out.println("System Error.");
            }
}
else
{
    out.println("<p>Please <b><a href=\"login.jsp\">login</a></b> first to change your major.</p>");
}%>
<br/>
To go back, click on <a href="studentHome.jsp"> myHome </a>


</body>
</html>
