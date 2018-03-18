

<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.Types,
java.sql.DriverManager,java.sql.DriverPropertyInfo,java.sql.SQLPermission,java.sql.Connection,
java.sql.Statement,java.sql.ResultSet,java.sql.SQLException,java.text.SimpleDateFormat,
java.util.*,java.io.*,java.sql.PreparedStatement,java.sql.CallableStatement,
java.sql.DatabaseMetaData"%>
<html>
<head>
    <title>Professor Message</title>
</head>
<body>
<%  //there are only two ways to gain access to this page: by active cookie or logging in directly from login page

    Cookie[] cookie = null;
    String email = null;
    cookie = request.getCookies();
    if( cookie != null )
    {
        for (int i = 0; i < cookie.length; i++)
        {
            if ( cookie[i].getName().equals("WebEmail") )
            {
                email = cookie[i].getValue().trim();
            }
        }
    }

    if (  !(request.getParameter("email") == null) || !(email == null)  )//if professor was sent here from login pg or has active cookie
    {

        if ( !(request.getParameter("email") == null) ) //if user accessed page by logging in
        {
            email = request.getParameter("email").trim();
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

			String getProfessorInfo = "SELECT * FROM Professor WHERE email = '" + email + "'";
            ResultSet professorInfo = st.executeQuery(getProfessorInfo);
            professorInfo.first();

            String ssn = professorInfo.getString("ssn").trim();

			String getStudents = "SELECT e.cid, e.sid FROM enrolled_in e WHERE exists (SELECT c.cid"
			                     + " FROM course c WHERE c.ssn = '" + ssn + "')";
            ResultSet students = st2.executeQuery(getStudents);

            if ( students.first() )
            {%>
			 <em>Professor Portal</em><br>

                <h1 align="center">Professor <%=professorInfo.getString("name").substring(professorInfo.getString("name").indexOf(" "))%>'s
                Grade Book </h1><hr><br>
				<p>Enter Grades below and hit submit to update your gradebook<br>
        (error: gradebook only available at the end of the semester.)</p><br><br>
				<form method="get" action="professorAcedemics.jsp">
				<%
				    students.beforeFirst();
					int i = 1;
					while ( students.next() )
					{%>
					<p><input="radio" name="cid" value="<%=students.getString("cid")%>`<%=students.getInt("sid")%> checked>
					Student ID: <%=students.getString("sid")%>
					|| Grade: <input type="text" name="grade"> </p>
					<input type="hidden" name="sid<%=i%>" value="<%=students.getString("sid")%>">
					<input type="hidden" name="studentName<%=i%>" value="<%=students.getString("name")%>">
				<%  }
				%>  <input type="submit" name="submit" value="Enter Grade">
					</form>
				<%
					if (request.getParameter("submit") != null )
					{
					  	String cid = request.getParameter("cid").trim().substring(0,request.getParameter("cid").indexOf("`"));
                        String sid = request.getParameter("cid").trim().substring(request.getParameter("cid").indexOf("`") + 1);
						String insertGrade = "INSERT INTO enrolled_in (cid, sid, date, grade) VALUES ("+
						                   cid + "," + sid + ",'2017'," + request.getParameter("grade").toUpperCase() + ")";
						int success = st3.executeUpdate(insertGrade);
						if ( 1 == success )
						{%>
							<p>Grade Successfully Added!</p>
					  <%}
					}

				%>


		  <%}
            else
            {%>
				<h1 align="center">Professor <%=professorInfo.getString("name").substring(professorInfo.getString("name").indexOf(" "))%>'s
                Grade Book </h1><hr><br>
                <p>You are not teaching any classes this semester.</p>
		<%  }
		}
		catch(SQLException e)
		{
			out.println(e.getMessage() + e.getSQLState() + e.getErrorCode());
		}
	}
    else
    {
		out.println("Please <b><a href=\"login.jsp\">login</a></b> first to access your homepage.");
	}
%>
</body>
</html>
