<%--
  Created by IntelliJ IDEA.
  User: Phil
  Date: 4/24/17
  Time: 9:52 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.Types,
java.sql.DriverManager,java.sql.DriverPropertyInfo,java.sql.SQLPermission,java.sql.Connection,
java.sql.Statement,java.sql.ResultSet,java.sql.SQLException,java.text.SimpleDateFormat,
java.util.*,java.io.*,java.sql.PreparedStatement,java.sql.CallableStatement,
java.sql.DatabaseMetaData"%>
<html>
<head>
    <title>Professor Message</title>
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

            String ssn = professorInfo.getString("ssn");

            String getStudentMessages = "SELECT * FROM Message WHERE email = '" + email + "'";
            ResultSet studentMessages = st2.executeQuery(getStudentMessages);
            String getStudentMessagesCount = "SELECT COUNT(*) FROM Message WHERE email = '" + email
                    + "'";
            ResultSet studentMessagesCount = st3.executeQuery(getStudentMessagesCount);
            String getNewStudentMessagesCount = "SELECT COUNT(*) FROM Message WHERE email = '" + email
                    + "' AND NOT read";
            ResultSet newStudentMessagesCount = st4.executeQuery(getNewStudentMessagesCount);


            int messageCount = 0;
            int newMessageCount = 0;

            if ( studentMessagesCount.first() ) //get total count
            {
                messageCount = studentMessagesCount.getInt(1);
            }

            if ( newStudentMessagesCount.first() ) //get new message count
            {
                newMessageCount = newStudentMessagesCount.getInt(1);
            }

%>              <em>Professor Portal</em><br/><br/>
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
                <h1 align="center">Professor <%=professorInfo.getString("name").substring(professorInfo.getString("name").indexOf(" "))%>'s
                Message Box </h1><hr><br>
                <form method="post" action="composeMessageP.jsp?email=<%=email%>" align="left">
                    <input type="submit" name="compose" value="Compose Message">
                </form>

                <em>Your Email Address: <%=email%></em><br><br>
                <b>Total Messages: <%=messageCount%></b>
                <h3>You have <%=newMessageCount%> new messages!</h3><br>
                <form method="post" action="readMessageP.jsp?email=<%=email%>">
    <%
            int i = 1;
            if ( studentMessages.first() )
            {

                studentMessages.beforeFirst();
                while ( studentMessages.next() )
                {


                    if ( !studentMessages.getBoolean("read")  )
                    {


    %>
                    <p><h3><%=i%><input type="radio" name="message" value="<%=studentMessages.getString("message")%>`<%=studentMessages.getString("sender")%>" checked> From:
                    <%=studentMessages.getString("sender")%> || Subject: <%=studentMessages.getString("subject")%><br><hr></h3></p>
    <%
                    }
                    else //message read, don't bold
                    {%>
                    <p><%=i%><input type="radio" name="message" value="<%=studentMessages.getString("message")%>`<%=studentMessages.getString("sender")%>" checked> From:
                    <%=studentMessages.getString("sender")%> || Subject: <%=studentMessages.getString("subject")%><br><hr></p>
                  <%}
                        i++;
               }%>
                <input type="hidden" name="email" value="<%=email%>">
                <input type="submit" name="submit" value="Read Message">
            </form>



<%
            }
            else
            {%>
                <h4 align="center">Inbox Empty</h4>

          <%}




        }
        catch(SQLException e)
        {
            out.print(e.getErrorCode() + e.getSQLState() + e.getMessage());
        }
    }
    else
    {
        out.println("<p>Please <b><a href=\"login.jsp\">login</a></b> to access your email.</p>");
    }
%>


</body>
</html>


</body>
</html>
