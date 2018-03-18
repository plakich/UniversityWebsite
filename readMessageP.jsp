<%--
  Created by IntelliJ IDEA.
  User: Phil
  Date: 4/25/17
  Time: 11:02 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.Types,
java.sql.DriverManager,java.sql.DriverPropertyInfo,java.sql.SQLPermission,java.sql.Connection,
java.sql.Statement,java.sql.ResultSet,java.sql.SQLException,java.text.SimpleDateFormat,
java.util.*,java.io.*,java.sql.PreparedStatement,java.sql.CallableStatement,
java.sql.DatabaseMetaData"%>
<html>
<head>
    <title>Read Message P</title>
    <link rel="stylesheet" href="bootstrap.css" type="text/css"/>
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

    if (  (!(request.getParameter("email") == null) || !(email == null)) && request.getParameter("message") != null )//if professor was sent here from login pg or has active cookie
    {

        if (!(request.getParameter("email") == null)) //if user accessed page by logging in
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
        catch (ClassNotFoundException ex)
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

            String message = request.getParameter("message").substring(0,request.getParameter("message").lastIndexOf("`")).trim();
            String sender = request.getParameter("message").substring(request.getParameter("message").lastIndexOf("`")+1).trim();
            int counter = 0;
            for( int i = 0; i < message.length(); i++ )//need to find how many single quotes are in string since sql throws error on select
            {
                if( message.charAt(i) == '\'' )
                {
                    counter++;
                }
            }
            int[] index = new int[counter];

            for( int i = 0, j = 0; i < message.length(); i++ ) //get the index of the single quotes
            {
                if( message.charAt(i) == '\'' )
                {
                    index[j] = i;
                    j++;
                }
            }

            StringBuilder str = new StringBuilder(message); //escape the single quotes, then select from database
            for ( int i = 0; i < counter; i++ )
            {
                str.insert(index[i]+i, '\''); //single quote escape is two single quotes or ''
            }
            message = str.toString().trim();

            String getMessage = "SELECT message FROM Message WHERE message = '" + message + "'" + " AND sender = '" +
                    sender + "' AND email = '" + request.getParameter("email") + "'";
            ResultSet theMessage = st.executeQuery(getMessage);
            String getNameOfProfessorSender = "SELECT name FROM Professor WHERE email = '" + sender + "'";
            String getNameofStudentSender = "SELECT name FROM Undergraduate WHERE email = '" + sender + "'";
            ResultSet nameOfProfessorSender = st2.executeQuery(getNameOfProfessorSender);
            ResultSet nameofStudentSender = st3.executeQuery(getNameofStudentSender);

            String senderName = "";

            if ( nameOfProfessorSender.first() )
            {
                senderName = nameOfProfessorSender.getString("name");
            }
            else if ( nameofStudentSender.first() )
            {
                senderName = nameofStudentSender.getString("name");
            }
            else
            {
                senderName = "John Smith";
            }

            if ( theMessage.first() )
            {%>
                <em>Professor Portal</em>
                    <h1 align="center">Read Message</h1><hr><br>
                <br>
                <p>Message sent by <%=senderName%> from <%=sender%></p><br><br>
                    <textarea rows="15" cols="50" name="message"><%=theMessage.getString("message")%>
                    </textarea><br><br><br>

          <%}

            String setRead = "UPDATE Message SET Read = true WHERE message = '" + message + "'" + " AND sender = '" +
            sender + "' AND email = '" + request.getParameter("email") + "'";
            int success = 0;

            success = st4.executeUpdate(setRead);

%>
            <form action="professorMessage.jsp?email=<%=request.getParameter("email")%>" method="get" align="bottom">
                <input type="submit" name="submit" value="Back To Inbox">
            </form>
<%



        }
        catch(Exception e)
        {
            out.print("Error in system.");
        }
    }
    else
    {
        out.println("<p>Please <b><a href=\"login.jsp\">login</a></b> first to access your inbox.</p>");

    }
%>


</body>
</html>
