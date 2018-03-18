
<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.Types,
java.sql.DriverManager,java.sql.DriverPropertyInfo,java.sql.SQLPermission,java.sql.Connection,
java.sql.Statement,java.sql.ResultSet,java.sql.SQLException,java.text.SimpleDateFormat,
java.util.*,java.io.*,java.sql.PreparedStatement,java.sql.CallableStatement,
java.sql.DatabaseMetaData"%>
<html>
<head>
    <title>Professor Homepage</title>
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
            String getProfessorInfo = "SELECT p.ssn, p.name, p.age, p.address, p.email, p.speciality, p.office "
                    + "FROM Professor p WHERE p.email = '" + email + "'";

            ResultSet rs = st.executeQuery(getProfessorInfo);
            ResultSet rs2;

            if ( rs.first() ) //if there's a professor with the specified email in the system
            {
                String getDeptHead = "SELECT d.dno, d.dname FROM Dept d WHERE d.ssn = '" + rs.getString("ssn") + "'";

                rs2 = st2.executeQuery(getDeptHead);


            %>
    <em><h4>Professor Portal</h4></em><br/>
    <div class="nav_bar">
        <ul>
          <li><a href="professorHome.jsp"> myHome </a></li>
          <li><a href="professorAcademics.jsp"> Academics </a></li>
          <li><a href="professorProject.jsp"> Projects </a></li>
          <li><a href="professorMessage.jsp"> Messages </a></li>
          <li><a href="logout.jsp?logout=<%=logout%>"> Logout </a></li>
        </ul>
    </div>
    <br/><br/>
                <h2 align="center">Professor <%=rs.getString("name").substring(rs.getString("name").indexOf(" "))%>'s Homepage</h2>
                <h4>Personal Info:</h4>
                <p><strong>Name:</strong> <%=rs.getString("name")%> </p>
                <p><strong>Age:</strong> <%=rs.getInt("age")%> </p>
                <p><strong>Address:</strong> <%=rs.getString("address")%> </p>
                <p><strong>Professor Email:</strong> <%=rs.getString("email")%> </p>
                <p><strong>Speciality:</strong> <%=rs.getString("speciality")%> </p>
                <p><strong>Office:</strong> <%=rs.getString("office")%> </p>
            <%
                if ( rs2.first() )
                {
                    String deptHead = "";
                    int deptNum = 0;
                    deptHead = rs2.getString("dname");
                    deptNum = rs2.getInt("dno");
                %>
                    <p><strong>Head of: </strong><%=deptHead%></p>
                    <p><strong>Dept #:</strong> <%=deptNum%></p>

              <%}
              %>
</div>
<div class="courses">
             <% String searchCondition = rs.getString("ssn");
                if (searchCondition != null)
                {%>
                    <B><%= getCourseList(searchCondition) %> </B> <HR><BR>
              <%}%>
</div>

<div class="major">

</div><%
            }
        }
        catch(SQLException e)
        {
            out.println(e.getMessage() + e.getErrorCode() + e.getSQLState());
        }
        %>
<%
}
else //user tried accessing homepage without logging in first
{%>
    <p>Please <a href="login.jsp">login</a> first to access your homepage.</p>
<%
}
%>

</body>
</html>


<%! private String getCourseList(String ssn) throws SQLException {
    Connection conn = null;
    Statement stmt = null;
    ResultSet rset = null;
    String login = "jdbc:postgresql://localhost:5432/web";
    String user = "postgres";
    String pass = "a";

    try
    {
        Class.forName("org.postgresql.Driver");
    }
    catch(ClassNotFoundException ex)
    {
        System.out.println("Error: unable to load driver class!");
    }

    try
    {
        System.out.println("here");
        //DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        conn = DriverManager.getConnection(login,
                user, pass);
        stmt = conn.createStatement();
        // dynamic query
        rset = stmt.executeQuery ("SELECT C.cid, C.name, C.dno, C.room, C.semester FROM course C WHERE C.ssn = '"
                + ssn + "'");
        return (formatResult(rset));
    }
    catch (SQLException e)
    {
        return ("<P> SQL error: <PRE> " + e + " </PRE> </P>\n");
    }
    finally
    {
        if (rset!= null) rset.close();
        if (stmt!= null) stmt.close();
        if (conn!= null) conn.close();
    }
}
    private String formatResult(ResultSet rset) throws SQLException
    {
        StringBuffer sb = new StringBuffer();
        if (!rset.next())
            sb.append("<P align=\"right\"> You are not currently teaching any courses.<P>\n");
        else
        {
            String semester = rset.getString("semester").trim();
            if ( semester.equals("FA") )
            {
                semester = "Fall ";
            }
            else
            {
                semester = "Spring ";
            }
            Date dNow = new Date( );
            SimpleDateFormat ft = new SimpleDateFormat("yyyy");
            String date = ft.format(dNow);
            semester += date + " Teaching Schedule:";

            String day[] = new String[5];
            day[0] = "MW";
            day[1] = "TR";
            day[2] = "MW";
            day[3] = "TR";
            day[4] = "F";
            String time[] = new String[5];
            time[0] = "9:00-10:15 A.M.";
            time[1] = "9:00-10:15 A.M.";
            time[2] = "10:30-11:45 A.M.";
            time[3] = "10:30-11:45 A.M.";
            time[4] = "12:30-3:15 P.M.";
            int i = 0;


            sb.append("<h1 align=\"right\">" + semester + "</h1>" +
                    "<table border=\"2px\" align=\"right\">"
                    + "<tr><th>" + "course number " + "</th>"
                    + "<th>" + "course name" + "</th>" + "<th>" + "department number" + "</th>"
                    + "<th>" + "room number" + "</th>" + "<th>" + "Day" + "</th>" +
                    "<th>" + "time" + "</th>" + "</tr>");
            do
            {
                sb.append("<tr><td>" + rset.getInt(1) + "</td>" + "<td>" + rset.getString(2)
                        + "</td>" + "<td>" + rset.getInt(3) + "</td>" + "<td>"
                        + rset.getString(4) + "</td>" + "<td>" + day[i] + "</td>" +
                        "<td>" + time[i] + "</td>" + "<tr>");
                i++;
            } while (rset.next());
            sb.append("</table>");
        }
        return sb.toString();
    } //formatResult()
%>
