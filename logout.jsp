<%--
  Created by IntelliJ IDEA.
  User: Phil
  Date: 4/14/17
  Time: 7:35 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Logout</title>
    <link rel="stylesheet" href="bootstrap.css" type="text/css"/>
</head>
<body>
<%
    if ( request.getParameter("logout") == null ) //page wasn't accessed from link on homepage; it was accessed directly
    {%>
       <h4>Error. Please logout from your homeportal or
           <strong><a href="login.jsp">log back in</a></strong> to access your homeportal.</h4>
 <% }
    else if ( request.getParameter("logout").equals("success") )
    {%>
        <h4>Logout successful! Please <strong><a href="login.jsp">log back in</a></strong> to access your homepage.</h4>
  <%}
    else if ( request.getParameter("logout").equals("failed") )
    {%>
        <h4>You are already logged out. Please <strong><a href="login.jsp">log back in</a></strong> to access your homepage.</h4>
  <%}
    else if ( request.getParameter("logout") != null ) //logout user
    {


        Boolean loggedOut = false;
        Cookie[] cookies = request.getCookies();

        if ( cookies != null ) //check for old cookies, delete before sending back to login
        {

            for (int i = 0; i < cookies.length; i++)
            {
                if (cookies[i].getName().equals("WebSid") && request.getParameter("logout").equals("student")) //logout student
                {
                    cookies[i].setMaxAge(0); //set cookie so it expires
                    response.addCookie(cookies[i]);
                    cookies[i].setPath("/web"); //need to set to /web
                    loggedOut = true;
                    break;
                }
                else if (cookies[i].getName().equals("WebEmail") && request.getParameter("logout").equals("faculty")) //logout faculty
                {
                    cookies[i].setMaxAge(0); //set cookie so it expires
                    response.addCookie(cookies[i]);
                    cookies[i].setPath("/web"); //need to set to /web
                    loggedOut = true;
                    break;
                }
                else // do nothing, not this site's cookie
                {
                    //empty
                }
            }

        }
        if ( loggedOut )
        {
            response.sendRedirect("logout.jsp?logout=success");
        }
        else // user already loggedOut and tried logging out again.
        {
            response.sendRedirect("logout.jsp?logout=failed");
        }

    }
    else
    {%>

  <%}



%>



</body>
</html>
