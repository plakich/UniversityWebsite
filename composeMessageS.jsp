<%--
  Created by IntelliJ IDEA.
  User: Phil
  Date: 4/22/17
  Time: 4:41 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.Types,
java.sql.DriverManager,java.sql.DriverPropertyInfo,java.sql.SQLPermission,java.sql.Connection,
java.sql.Statement,java.sql.ResultSet,java.sql.SQLException,java.text.SimpleDateFormat,
java.util.*,java.io.*,java.sql.PreparedStatement,java.sql.CallableStatement,
java.sql.DatabaseMetaData"%>
<html>
<head>
    <title>Compose Message Student</title>
    <link rel="stylesheet" href="bootstrap.css" type="text/css"/>
</head>
<body>
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

    if (  !(request.getParameter("sid") == null) || !(sid == null)  )//if student was sent here from login pg or has active cookie
    {


        if (!(request.getParameter("sid") == null)) //if user accessed page by logging in
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

            String getStudentInfo = "SELECT * FROM Undergraduate u WHERE sid = " + sid;
            ResultSet studentInfo = st.executeQuery(getStudentInfo);

            studentInfo.first();
            String from = studentInfo.getString("email").trim();
        %>
            <em>Student Portal</em>
            <h1 align="center">Compose Message</h1><hr><br>
            <h3>Type your message in the box below and hit send to send message.</h3>
            <form method="post" action="composeMessageS.jsp" id="form">
                <p>Sender Email: <%=from%><br>
                Sender Name: <%=studentInfo.getString("name")%><br><br>
                    To:  <input type="text" name="to"><br>
                Subject: <input type="text" name="subject"></p>



            <textarea rows="15" cols="50" name="message" form="form">Type here...
            </textarea><br>

                <input type="submit" name="send" value="Send">
            </form>


<%          if ( request.getParameter("message") != null && request.getParameter("to") != null ) //must have message and email of receiver
            {
                String newMessage = request.getParameter("message").trim();

                String temp = "";
                String temp2 = "";

                int counter = 0;
                for( int i = 0; i < newMessage.length(); i++ )//need to find how many single quotes are in string since sql throws error on insert of them
                {
                    if( newMessage.charAt(i) == '\'' )
                    {
                        counter++;
                    }
                }
                int[] index = new int[counter];

                for( int i = 0, j = 0; i < newMessage.length(); i++ ) //get the index of the single quotes
                {
                    if( newMessage.charAt(i) == '\'' )
                    {
                        index[j] = i;
                        j++;
                    }
                }

                StringBuilder str = new StringBuilder(newMessage); //escape the single quotes, then insert into database
                for ( int i = 0; i < counter; i++ )
                {
                    str.insert(index[i]+i, '\'');
                }
                newMessage = str.toString().trim();




                String sendMessage = "INSERT INTO Message (message, email, subject, sender) VALUES ('" +
                                     newMessage + "','" + request.getParameter("to") +
                                     "','" + request.getParameter("subject") + "','" + from + "')";


                int success = st2.executeUpdate(sendMessage);
                if ( 1 == success ) //1 row inserted into email table
                {%>
                    <p>Message Sent!</p>
              <%}
                else
                {%>
                    <p>Error. There was a problem with your message. Try sending it again.  </p>
              <%}
            }

        }
        catch(Exception e)
        {
            out.println("<p>Error: Message Not Sent!</p>");
        }
    }
    else //student tried accessing page without logging in
    {%>
        <p>Please <b><a href="login.jsp">login</a> to send messages.</b></p>


 <% }
%>
<form method="get" action="studentMessage.jsp?sid=<%=sid%>">
    <input type="submit" name="submit" value="Back To Inbox">
</form>
</body>
</html>
