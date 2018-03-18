<%--
  Created by IntelliJ IDEA.
  User: Phil
  Date: 3/31/17
  Time: 10:49 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.Types,
java.sql.DriverManager,java.sql.DriverPropertyInfo,java.sql.SQLPermission,java.sql.Connection,
java.sql.Statement,java.sql.ResultSet,java.sql.SQLException,java.text.SimpleDateFormat,
java.util.*,java.io.*,java.sql.PreparedStatement,java.sql.CallableStatement,
java.sql.DatabaseMetaData"%>
<%@ page import="java.security.interfaces.RSAKey" %>
<html>
<head>
    <title>Degree Requirements</title>
    <link rel="stylesheet" href="bootstrap.css" type="text/css"/>
</head>
<body>
  To go back to myHome, <a href="studentHome.jsp">click here</a> <br/>
<%
    int dno = 0;
    if ( request.getParameter("dno") != null )
    {
        dno = Integer.parseInt( request.getParameter("dno") );
    }
    else
    {%>
        <form method="get" action="">
            <label>Please select your major: </label>
            <select name="major" id="major">
                <option value="1">Computer Science</option>
                <option value="2">English</option>
                <option value="3">Mathematics</option>
                <option value="4">ECE</option>
            </select>
            <input type="submit" value="submit" name="list">
        </form>
    <%
        if ( request.getParameter("list") != null )
        {
            dno = Integer.parseInt( request.getParameter("major") );
        }
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
        con.setAutoCommit(true);

        Statement st = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
        Statement st2 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);

        String getFallCourses = "SELECT name, cid, semester FROM Course WHERE dno = " + dno + " AND semester = 'FA'"
                      + " ORDER BY cid";
        String getSpringCourses = "SELECT name, cid, semester FROM Course WHERE dno = " + dno + " AND semester = 'SP'"
                        + " ORDER BY cid";

        ResultSet fallCourse = st.executeQuery(getFallCourses);
        ResultSet springCourse = st2.executeQuery(getSpringCourses);

        if ( fallCourse.first() && springCourse.first() ) //if courses successfully grabbed from database
        {
            fallCourse.beforeFirst();
            springCourse.beforeFirst();

            String major = "";
            String elective[] = new String[4];
            if ( 1 == dno ) // set the header
            {
                major = "Major: Computer Science";
                elective[0] = "Math Elective";
                elective[1] = "English Elective";
                elective[2] = "ECE Elective";
                elective[3] = "Free Elective";
            }
            else if ( 2 == dno )
            {
                major = "Major: English Literature";
                elective[0] = "Math Elective";
                elective[1] = "Computer Science Elective";
                elective[2] = "ECE Elective";
                elective[3] = "Free Elective";
            }
            else if ( 3 == dno )
            {
                major = "Major: Mathematics";
                elective[0] = "Computer Science Elective";
                elective[1] = "English Elective";
                elective[2] = "ECE Elective";
                elective[3] = "Free Elective";

            }
            else // 4 == dno
            {
                major = "Major: ECE";
                elective[0] = "Computer Science Elective";
                elective[1] = "Math Elective";
                elective[2] = "English Elective";
                elective[3] = "Free Elective";
            }
            Date dNow = new Date( ); //print date for catalog year
            SimpleDateFormat ft = new SimpleDateFormat("yyyy");
            String date = ft.format(dNow);
            int nextYear = Integer.parseInt(date.trim()) + 1;
            %>
                <h2 style="text-decoration: underline">JSU</h2>
                <h3 align="center"><%=major%></h3>
                <p align="right"><em>Catalog Year: <%=nextYear-1%>-<%=nextYear%></em></p>
           <%

            int semester = 1;
            int year = 1;
            int count = 0;
            fallCourse.next();
            springCourse.next();
            boolean moreFallCourses = true;
            boolean moreSpringCourses = true;

            while ( year < 5 ) //display a four year course plan for selected major, with 5 courses for each semester (total of 8 semesters)
            {
                if ( 0 == count )
                {%>
                   <table border="2px">
                       <tr>
                           <th>Semester <%=semester%> Program</br>Requirements (Course Title)</th>
                           <th>Subject/Course Number</th>
                           <th>Semester Offered</th>
                           <th>Credit Hours</th>
                       </tr>

              <%}
                while ( moreFallCourses && fallCourse.getInt("cid")/100 == year ) // while (moreFallCourses && moreCoursesForThisLevel)
                {%>
                       <tr><td><%=fallCourse.getString("name")%></td>
                           <td><%=fallCourse.getInt("cid")%></td>
                           <td><%=fallCourse.getString("semester")%></td>
                           <td>3</td>
                       </tr>

              <%    moreFallCourses = fallCourse.next();
                    count++;
                }
                int i = 0;
                while ( count < 5 ) //if we ran out of courses for the major, we print electives to fill the spots for this semester
                {
                %>
                    <tr><td><%=elective[i]%></td>
                        <td>(Any <%=year*100%> Level)</td>
                        <td>
                            <%
                                if ( semester%2 == 1 )
                                {%>
                                    FA
                              <%}
                                else
                                {%>
                                    SP
                              <%}
                            %>
                        </td>
                        <td>3</td>
                    </tr>


              <%
                    count++;
                    i++;
                }
               %>
                    </table>
               <%

                count = 0;
                semester++;
                if ( 0 == count )
                {%>
                       <table border="2px">
                           <tr>
                               <th>Semester <%=semester%> Program</br>Requirements (Course Title)</th>
                               <th>Subject/Course Number</th>
                               <th>Semester Offered</th>
                               <th>Credit Hours</th>
                           </tr>

              <%}

                while ( moreSpringCourses && springCourse.getInt("cid")/100 == year )
                {%>
                       <tr><td><%=springCourse.getString("name")%></td>
                           <td><%=springCourse.getInt("cid")%></td>
                           <td><%=springCourse.getString("semester")%></td>
                           <td>3</td>
                       </tr>

                           <%
                    moreSpringCourses = springCourse.next();
                    count++;
                }
                i = 0;
                while ( count < 5 )
                {

                %>
                    <tr><td><%=elective[i]%></td>
                        <td>(Any <%=year*100%> Level)</td>
                        <td>
                            <%
                                if ( semester%2 == 1 )
                                {%>
                                    FA
                              <%}
                                else
                                {%>
                                    SP
                             <% }
                            %>
                        </td>
                        <td>3</td>
                    </tr>


               <%
                    count++;
                    i++;
                }
               %>
                    </table>
               <%
                count = 0;
                year++;
                semester++;
            }

        }
    }
    catch(SQLException e)
    {
        out.println(e.getMessage() + e.getErrorCode() + e.getSQLState());
    }
%>

</body>
</html>
