<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.io.*,javax.servlet.*,
javax.servlet.http.*,java.sql.*,java.sql.Connection,java.sql.DriverManager,java.sql.PreparedStatement,java.sql.ResultSet,java.sql.Statement"%>

<html>
<head>
    <title>Login</title>
    <style type='text/css'>
        .login
        {
            text-align:center;
            width:80%;
            margin-top:20%;
            margin-left:10%;
            margin-right:10%;
            background-color: #66ccff;
        }
        .f1
        {
            border: 1px solid black;
            background-color: #D9DAB8;
        }
    </style>

</head>

<body>
<%
    String login = "";
    if ( !(request.getParameter("email") == null) ) //if
    {
        login = request.getParameter("email");
    }

%>
<div class='login'>
    <%
    if ( !(request.getParameter("fail") == null ) )  //if login failed
    {%>
        <span class="error"><p>Login failed.</p></span>
  <%}%>
    <form method='post' action='login.jsp'>
        <label>Please enter your username:<br/></label>
        <input type='text' name='email' value=<%=login%> ><br/>
        <label>Please enter a password for your account:<br/></label>
        <input type='password' name='pass'><br/>

        <input type='submit' value='login' name='login'>
        <br/></form>
<%
if (request.getParameter("login")!= null) //code below only executes upon hitting submit button
{

   try
   {
       Class.forName("org.postgresql.Driver");
   }
   catch(ClassNotFoundException ex)
   {
       out.println("Error: unable to load driver class!");
       return;
   }

   try
   {
      Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/web?user=postgres&password=a");
      PreparedStatement statement = conn.prepareStatement("SELECT sid " +
                                                          "FROM Undergraduate " +
                                                          "WHERE email = '" + request.getParameter("email")
                                                           + "@jsu.edu'" + " AND password = '"
                                                           + request.getParameter("pass") + "'");
      PreparedStatement statement1 = conn.prepareStatement("SELECT email FROM Professor WHERE email = '"
                                                           + request.getParameter("email") + "@jsu.edu'"
                                                           + " AND password = '" + request.getParameter("pass")
                                                           + "'");
      ResultSet resultSet = statement.executeQuery();
      ResultSet resultSet2 = statement1.executeQuery();


      if ( resultSet.next() ) //if student logged in
      {
         String sid = "";
         Integer temp = resultSet.getInt("sid");
         sid = temp.toString();
         Cookie cookie = new Cookie("WebSid",temp.toString()); //set cookie to student's sid
         cookie.setMaxAge(24*60*60); //set cookie for 24 hours
         cookie.setPath("/web");
         response.addCookie(cookie);
         response.sendRedirect("studentHome.jsp?sid=" + sid);
      }
      else if ( resultSet2.next() ) //if faculty logged in
      {
          String email = resultSet2.getString("email").trim();

          if ( email.equals("admin@jsu.edu") ) //if faculty person is admin
          {
              response.sendRedirect("adminHome.jsp?email=" + email);

          }
          else //log in as professor
          {
              Cookie cookie = new Cookie("WebEmail", email);
              cookie.setMaxAge(24*60*60); //set cookie for 24 hours
              cookie.setPath("/web");
              response.addCookie(cookie);
              response.sendRedirect("professorHome.jsp?email=" + email);
          }


      }
      else //wrong login details
      {
        response.sendRedirect("login.jsp?fail=1");

      }

   }
   catch (Exception ex)
   {%>
        <p><%=ex.getMessage()%></p></br>
        <p>SYSTEM UNAVAILABLE. CHECK BACK LATER.</p>
 <%}

}%>
</div>
To go back to home page <a href="home.jsp"> click here </a>
</body>
</html>
