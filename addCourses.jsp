

<!-- Course: CS 416 -->
<!-- Name: Drake and Phil-->
<!-- Iteration 1 -->

<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.io.*,javax.servlet.*,javax.servlet.http.*,java.sql.*,java.sql.Connection,java.sql.DriverManager,java.sql.PreparedStatement,java.sql.ResultSet,java.sql.Statement,java.util.ArrayList"%>

<%
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


    String semester = "FA";
// 1 = Computer Science;
// 2 = English;
// 3 = Mathematics;
// 4 = ECE;
    String subject = "1";
    String subjectName = "Computer Science";

    if (request.getParameter("semester") != null)
    {
        if (request.getParameter("semester").equals("FA") || request.getParameter("semester").equals("SP"))
        {
            semester = request.getParameter("semester");
        }
    }

    if (request.getParameter("subject") != null)
    {
        try
        {
            DriverManager.registerDriver(new org.postgresql.Driver());
            Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/web?user=postgres&password=a");
            PreparedStatement statement = conn.prepareStatement("SELECT COUNT(*) " +
                    "FROM dept D " +
                    "WHERE D.dno=" + request.getParameter("subject") );
            PreparedStatement statement2 = conn.prepareStatement("SELECT D.dname " +
                    "FROM dept D " +
                    "WHERE D.dno=" + request.getParameter("subject") );
            ResultSet resultSet = statement.executeQuery();
            resultSet.next();
            if ( resultSet.getInt(1) == 1 )
            {
                ResultSet resultSet2 = statement.executeQuery();
                resultSet2.next();
                subject = request.getParameter("subject");
                subjectName = resultSet2.getString(1);
            }
        } catch (Exception ex)
        {
%>1st query: <%=ex.getMessage()%><%
        }
    }

    String studentID = sid;

/* At this point I am not entirely
 * sure how we are detecting a user's
 * login. If someone could just insert
 * code into this spot to assign the
 * user's student id to the variable
 * 'studentID', that would be great.
 * AFAIK it is the only thing that
 * needs to be done for this page.
 */

    if (request.getParameter("course") != null)
    {
        try
        {
            DriverManager.registerDriver(new org.postgresql.Driver());
            Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/web?user=postgres&password=a");
            Statement st = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
            Statement st2 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
            String query = "SELECT COUNT(*) " +
                    "FROM Course C " +
                    "WHERE C.cid = " + request.getParameter("course") + " AND C.remaining_seats > 0 " +
                    "AND NOT EXISTS ( SELECT * " +
                    "FROM enrolled_in E " +
                    "WHERE C.cid = E.cid AND E.sid = " + studentID + ")" +
                    "AND (SELECT COUNT(*) " +
                    "FROM enrolled_in E " +
                    "WHERE E.sid = " + studentID + ") < 5";
            ResultSet resultSet = st.executeQuery(query);

            if ( resultSet.first() )
            {
         /*add a row to the enrolled_in table*/
                String query2 = "INSERT INTO enrolled_in (sid,cid, date) VALUES (" + studentID + "," +
                        request.getParameter("course") + ",'2017')";
                st2.executeUpdate(query2);
            } else
            {
         /*Invalid Course and/or too many credit hours*/
         /*reject the attempt to enroll*/
            }
        } catch (Exception ex)
        {
%>2nd query: <%=ex.getMessage()%><%
        }
    }

    ArrayList<String> courseIDs = new ArrayList<String>();
    ArrayList<String> courseNames = new ArrayList<String>();
    ArrayList<String> rooms = new ArrayList<String>();
    ArrayList<String> courseCapacities = new ArrayList<String>();
    ArrayList<String> courseRemainingSeats = new ArrayList<String>();

    try
    {
        DriverManager.registerDriver(new org.postgresql.Driver());
        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/web?user=postgres&password=a");
   /*The complexity of this query worries me a little bit. I am not sure if it is quite right.*/
        PreparedStatement statement = conn.prepareStatement("SELECT C.cid, C.name, C.room, C.capacity, C.remaining_seats " +
                "FROM Course C " +
                "WHERE C.semester = '" + semester + "' AND C.dno = " + subject + " AND C.remaining_seats > 0 " +
                "AND NOT EXISTS ( SELECT * " +
                "FROM enrolled_in E " +
                "WHERE C.cid = E.cid AND E.sid = " + studentID + " )" +
                "AND (SELECT COUNT(*) " +
                "FROM enrolled_in E " +
                "WHERE E.sid = " + studentID + ") < 5");
        ResultSet resultSet = statement.executeQuery();
        while (resultSet.next())
        {
            courseIDs.add(resultSet.getString(1));
            courseNames.add(resultSet.getString(2));
            if ( resultSet.getString(3) != null )
            {
                rooms.add(resultSet.getString(3));
            } else
            {
                rooms.add("none");
            }
            courseCapacities.add(resultSet.getString(4));
            courseRemainingSeats.add(resultSet.getString(5));
        }
    } catch (SQLException ex)
    {
%>3rd query: <%=ex.getMessage()%><%
    }

    ArrayList<String> otherCourseIDs = new ArrayList<String>();
    ArrayList<String> otherCourseNames = new ArrayList<String>();
    ArrayList<String> otherRooms = new ArrayList<String>();
    ArrayList<String> otherCourseCapacities = new ArrayList<String>();
    ArrayList<String> otherCourseRemainingSeats = new ArrayList<String>();

    try
    {
        DriverManager.registerDriver(new org.postgresql.Driver());
        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/web?user=postgres&password=a");

   /*The complexity of this query worries me a little bit. I am not sure if it is quite right.*/

   /*The query is intending to grab all courses fulfilling the search that are
    *either enrolled within or are completely filled. If the student is enrolled
    *in 5 or more courses, all courses are grabbed via this query.
    */
        PreparedStatement statement = conn.prepareStatement("SELECT C.cid, C.name, C.room, C.capacity, C.remaining_seats " +
                "FROM Course C " +
                "WHERE C.semester = '" + semester + "' AND C.dno =" + subject + " AND (C.remaining_seats <= 0 " +
                "OR EXISTS ( SELECT * " +
                "FROM enrolled_in E " +
                "WHERE C.cid = E.cid AND E.sid = " + studentID + ") " +
                "OR (SELECT COUNT(*) " +
                "FROM enrolled_in E " +
                "WHERE E.sid = " + studentID + " ) >= 6)");
        ResultSet resultSet = statement.executeQuery();
        while (resultSet.next())
        {
            otherCourseIDs.add(resultSet.getString(1));
            otherCourseNames.add(resultSet.getString(2));
            if ( resultSet.getString(3) != null )
            {
                otherRooms.add(resultSet.getString(3));
            } else
            {
                otherRooms.add("none");
            }
            otherCourseCapacities.add(resultSet.getString(4));
            otherCourseRemainingSeats.add(resultSet.getString(5));
        }
    } catch (SQLException ex)
    {
%>4th query: <%=ex.getMessage()%><%
    }
%>

<html>
<body>
<em align="left">Student Portal</em>

<form action="addCourses.jsp" id="searching"></form>

<div style="position: absolute; top: 100px; left: 100px;">
    SELECT SUBJECT
    <br>
    Subject: <select name="subject" form="searching">
    <option value="1">Computer Science</option>
    <option value="2">English</option>
    <option value="3">Mathematics</option>
    <option value="4">Electrical and Computer Engineering</option>
</select>
    <input type="submit" value="Submit" form="searching">
</div>

<div style="position: absolute; top: 200px; left: 100px;">
    SELECT SEMESTER
    <br>
    Semester: <select name="semester" form="searching">
    <option value="FA">Fall</option>
    <option value="SP">Spring</option>
</select>
    <input type="submit" value="Submit" form="searching">
</div>

<form action="addCourses.jsp" style="position: absolute; top: 300px; left: 100px;">
    SELECT CLASS
    <br>
    <%
        //the particular array I use for length is irrelevant
        //they should all be the same length
        for (int i = 0; i < rooms.size(); i += 1)
        {%>
    <input type="radio" name="course" value="<%=courseIDs.get(i)%>"><%=courseNames.get(i)%> | <%=rooms.get(i)%> | <%=courseRemainingSeats.get(i)%>/<%=courseCapacities.get(i)%><br>
    <%}
    %>
    <input type="submit" value="Submit">
    <br>
    <br>
    <%
        for (int i = 0; i < otherRooms.size(); i += 1)
        {%>
    <%=otherCourseNames.get(i)%> | <%=otherRooms.get(i)%> | <%=otherCourseRemainingSeats.get(i)%>/<%=otherCourseCapacities.get(i)%><br>
    <%}
    %>
    <br><br><p>Back to your <a href="studentHome.jsp">homepage</a>. 

</form>
<%
}
else
{
    out.println("<p>Error. Please <b><a href=\"login.jsp\">login</a></b> to register for courses.");
}
%>

</body>
</html>
