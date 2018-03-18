
<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.Types,
java.sql.DriverManager,java.sql.DriverPropertyInfo,java.sql.SQLPermission,java.sql.Connection,
java.sql.Statement,java.sql.ResultSet,java.sql.SQLException,java.text.SimpleDateFormat,
java.util.*,java.io.*,java.sql.PreparedStatement,java.sql.CallableStatement,
java.sql.DatabaseMetaData"%>
<html>
<head>
    <title>Account Creation</title>
    <link rel="stylesheet" href="bootstrap.css" type="text/css"/>
</head>
<body>

  <div class="header">
    <div align="center">
      <img src="Navigationbar1.png" usemap="#nav"/>
        <map name="nav" id="">
          <area href="home.jsp" shape="rect" coords="267,117,530,0" />
          <area href="enroll.jsp" shape="rect" coords="545,117,758,0" />
          <area href="Majors.html" shape="rect" coords="765,117,1010,0" />
          <area href="login.jsp" shape="rect" coords="1020,117,1206,0" />
        </map>
    </div>
  </div>
<hr/>

<br/>
<div class="data">

    <h3 align="center">Welcome to the enrollment page.<br/>
        Please fill out the forms below. After you are finished,<br/>
        click the submit button to enroll.<br/></h3>
    <form method="post" action="enroll.jsp" onsubmit="return formValidate();">
        <div class="form-group">
        <label>Please enter your first name:<br/></label>
        <input class="form-control" type="text" name="first" id="first"><br/>
        <label>Please enter your last name:<br/></label>
        <input class="form-control" type="text" name="last" id="last"><br/>
        <label>Please enter your age:<br/></label>
        <input class="form-control" type="text" name="age" id="age"><br/>
        <label>Please enter your Street Address:</label><br/>
        <input class="form-control" type="text" name="street" id="street"><br/>
        <label>Please enter the city:</label><br/>
        <input class="form-control" type="text" name="city" id="city"><br/>
        <label>Please select your state from the menu:</label><br/>
        <select name="state" id="state">
            <option value="AL">Alabama</option>
            <option value="AK">Alaska</option>
            <option value="AZ">Arizona</option>
            <option value="AR">Arkansas</option>
            <option value="CA">California</option>
            <option value="CO">Colorado</option>
            <option value="CT">Connecticut</option>
            <option value="DE">Delaware</option>
            <option value="DC">District Of Columbia</option>
            <option value="FL">Florida</option>
            <option value="GA">Georgia</option>
            <option value="HI">Hawaii</option>
            <option value="ID">Idaho</option>
            <option value="IL">Illinois</option>
            <option value="IN">Indiana</option>
            <option value="IA">Iowa</option>
            <option value="KS">Kansas</option>
            <option value="KY">Kentucky</option>
            <option value="LA">Louisiana</option>
            <option value="ME">Maine</option>
            <option value="MD">Maryland</option>
            <option value="MA">Massachusetts</option>
            <option value="MI">Michigan</option>
            <option value="MN">Minnesota</option>
            <option value="MS">Mississippi</option>
            <option value="MO">Missouri</option>
            <option value="MT">Montana</option>
            <option value="NE">Nebraska</option>
            <option value="NV">Nevada</option>
            <option value="NH">New Hampshire</option>
            <option value="NJ">New Jersey</option>
            <option value="NM">New Mexico</option>
            <option value="NY">New York</option>
            <option value="NC">North Carolina</option>
            <option value="ND">North Dakota</option>
            <option value="OH">Ohio</option>
            <option value="OK">Oklahoma</option>
            <option value="OR">Oregon</option>
            <option value="PA">Pennsylvania</option>
            <option value="RI">Rhode Island</option>
            <option value="SC">South Carolina</option>
            <option value="SD">South Dakota</option>
            <option value="TN">Tennessee</option>
            <option value="TX">Texas</option>
            <option value="UT">Utah</option>
            <option value="VT">Vermont</option>
            <option value="VA">Virginia</option>
            <option value="WA">Washington</option>
            <option value="WV">West Virginia</option>
            <option value="WI">Wisconsin</option>
            <option value="WY">Wyoming</option>
        </select><br/>
        <label>Please enter the five digit zipcode:</label><br/>
        <input class="form-control" type="text" name="zip" id="zip"><br/>
        <label>Please enter your ten digit phone number without hyphens:</label><br/>
        <input class="form-control" type="text" name="phone" id="phone"><br/>
        <label>Please enter a username
            <small>(note: the name will be used for your new student email address)</small></label><br/>
        <input class="form-control" type="text" name="email" id="email"><br/>
        <label>Please enter a password for your account:<br/></label>
        <input class="form-control" type="password" name="pass" id="pass"><br/>
        <input class="btn btn-success" type="submit" value="submit" name="enroll"></div>
    </form> <hr/>
    <%
        if ( request.getParameter("enroll") != null ) //code below only executes upon hitting submit
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

            String login = "jdbc:postgresql://localhost:5432/web";
            String user = "postgres";
            String pass = "a";

            try
            {
                Connection con = DriverManager.getConnection(login, user, pass);
                con.setAutoCommit(true);
                String name = request.getParameter("first").trim();
                name += " " + request.getParameter("last").trim();
                String email = request.getParameter("email").trim();
                String phone = request.getParameter("phone").trim().substring(0,3);
                phone += "-" + request.getParameter("phone").substring(3,6) + "-" +
                        request.getParameter("phone").substring(6,10);
                pass = request.getParameter("pass");

                Statement st = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                Statement st2 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                Statement st3 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                Statement st4 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                Statement st5 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                Statement st6 = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);

                String userExists = "SELECT email FROM Undergraduate WHERE email = '"
                        + email + "@jsu.edu'";
                String insertStudent = "INSERT INTO Undergraduate (age,deg_prog,name,advsid,password,level,email,address) VALUES (" +
                        request.getParameter("age").trim() + ",'" + "Undecided','" + name  + "'," + "currval('sid'),'"
                        + request.getParameter("pass") + "','Freshman','" + email + "@jsu.edu','"
                        + request.getParameter("street").trim() + "')";
                String checkStreet = "SELECT street FROM S_address WHERE street = '" + request.getParameter("street").trim() + "'";


                ResultSet rs = st.executeQuery(userExists);


                if ( rs.next() )
                { %>
                    <script language="JavaScript">
                    alert("Enrollment failed. \n The username you entered is already in our system." +
                    "\nPlease go back and try to enroll again.");
                    window.location = 'enroll.jsp';
                    </script>
                  <%
                }
                else //create new entries in undergraduate and address tables
                {
                    ResultSet rs2 = st2.executeQuery(checkStreet); //select street from address table

                    if ( !rs2.first() ) // if student entered a new street address not in address table, insert new tuple
                    {
                        String newAddress = "INSERT INTO S_address (phone, zip, street, city, state) VALUES ('" +
                                phone + "','" + request.getParameter("zip").trim() + "','" +
                                request.getParameter("street").trim() + "','" + request.getParameter("city").trim() +
                                "','" + request.getParameter("state").trim() + "')";

                        st3.executeUpdate(newAddress);
                    }
                    else // student entered a street address already in address table
                    {
                        String verifyAddress = "SELECT * FROM S_address WHERE zip = '" +
                                request.getParameter("zip").trim() + "'" + " AND city = '" +
                                request.getParameter("city").trim() + "'" + " AND state = '" +
                                request.getParameter("state").trim() + "'";
                        ResultSet rs3 = st4.executeQuery(verifyAddress);

                        if ( !rs3.first() ) // if street does not match the rest of the corresponding tuple
                        { %>
                             <script language="JavaScript">
                                 alert("Enrollment failed. \n The street address you entered does not match the address" +
                                " already in our system. Please go back and try to enroll again.\n");
                                 window.location = 'enroll.jsp';
                             </script>

                      <%}
                        else //do nothing, since the address the new student entered is already in the table
                        {
                            //empty;
                        }
                        if(rs3!=null)rs3.close();
                    }

                    String process_email = "INSERT INTO EMAIL VALUES('" + email + "@jsu.edu')";
                    int rows = st5.executeUpdate(process_email);
                    if ( 1 == rows ) //if email was inserted into email table
                    {
                        st6.executeUpdate(insertStudent); //insert new undergraduate tuple
                    }

                    response.sendRedirect("login.jsp?email=" + email);

                    if(rs2!=null)rs2.close();
                }
                if (rs != null)rs.close();
                if (st != null)st.close();
                if (st2 != null)st2.close();
                if (st3 != null)st3.close();
                if (con != null)con.close();


            }
            catch(SQLException e)
            {
                out.println(e.getMessage() + e.getErrorCode() + e.getSQLState());
            }
        }

%>

        <script language="JavaScript">
        function formValidate()
        {
            var age = document.getElementById('age').value;
            var first = document.getElementById('first').value.trim();
            var last = document.getElementById('last').value.trim();
            var pass = document.getElementById('pass').value;
            var street = document.getElementById('street').value.trim();
            var city = document.getElementById('city').value.trim();
            var state = document.getElementById('state').value.trim();
            var zip = document.getElementById('zip').value.trim();
            var phone = document.getElementById('phone').value.trim();
            var email = document.getElementById('email').value.trim();

            if ( !pass.match(/^(?=.*\d)[A-Za-z0-9]{6,20}$/) || !age.match(/^[0-9]+$/) ||
                !first.match(/^[A-Za-z\u00C0-\u017F]+$/) || !last.match(/^[A-Za-z\u00C0-\u017F ]+$/) ||
                !street.match(/^[A-Za-z0-9. ]+$/) || !city.match(/^[A-Za-z ]+$/) ||
                !state.match(/^[A-Z]{2}$/) || !zip.match(/^[0-9]{5}$/) ||
                !phone.match(/^[0-9]{10}$/) || !email.match(/^[A-Za-z0-9]{2,40}$/) )
            {
                if ( !pass.match(/^(?=.*\d)[A-Za-z0-9]{6,20}$/) )
                {
                    alert("Error. Your password must be at least \n" +
                        "six characters long (20 max) and contain one number. \n" +
                        "Spaces and other symbols are not allowed. \n");
                    document.getElementById('pass').style.backgroundColor = "yellow";
                }

                if ( !age.match(/^[0-9]+$/) ) //make sure age only contains chars 0-9
                {
                    alert("Error. \n Your age can contain numbers only! " +
                        "No hyphens, letters, or other characters are accepted.");
                    document.getElementById('age').style.backgroundColor = "yellow";
                }

                if ( !first.match(/^[A-Za-z\u00C0-\u017F]+$/) ) //only allow upper and lower case chars in name
                {
                    if ( !last.match(/^[A-Za-z\u00C0-\u017F ]+$/) ) //allows spaces for surnames like Van Der Vei
                    {
                        alert("Error. Please enter a proper first and last name.\n");
                        document.getElementById('first').style.backgroundColor = "yellow";
                        document.getElementById('last').style.backgroundColor = "yellow";
                    }
                    else
                    {
                        alert("Error. Please enter a proper first name.\n");
                        document.getElementById('first').style.backgroundColor = "yellow";
                    }

                }

                if ( !last.match(/^[A-Za-z\u00C0-\u017F ]+$/) ) //\u00...etc allows for latin characters and diacritic marks
                {
                    alert("Error. Please enter a proper last name.\n");
                    document.getElementById('last').style.backgroundColor = "yellow";
                }

                if ( !street.match(/^[A-Za-z0-9. ]+$/) ) //allow characters and digits and spaces
                {
                    alert("Error. Please enter a proper street address.\n");
                    document.getElementById('street').style.backgroundColor = "yellow";
                }

                if ( !city.match(/^[A-Za-z. ]+$/) )
                {
                    alert("Error. Please enter a proper city.\n");
                    document.getElementById('city').style.backgroundColor = "yellow";
                }

                if ( !state.match(/^[A-Z]{2}$/) )
                {
                    alert("Error. There was a problem processing the state.\n" +
                         "Please go back and try to select your state again.\n");
                    document.getElementById('state').style.backgroundColor = "yellow";
                }

                if ( !zip.match(/^[0-9]{5}$/) )
                {
                    alert("Error. Please enter a proper five digit zipcode.\n");
                    document.getElementById('zip').style.backgroundColor = "yellow";
                }

                if ( !phone.match(/^[0-9]{10}$/) )
                {
                    alert("Error. Please enter a proper ten digit phone number.\n");
                    document.getElementById('phone').style.backgroundColor = "yellow";
                }

                if ( !email.match(/^[A-Za-z0-9]{2,40}$/) )
                {
                    alert("Error. Please enter a proper username.\n" +
                        "Note: no special characters or spaces are allowed.\n" +
                            "Only upper- and lower-case characters and digits 0-9 are accepted.\n");
                    document.getElementById('email').style.backgroundColor = "yellow";
                }
                return false;
            }

            return true;
        }
       </script>

</div>
</body>
</html>


<%--
<label>Please enter the state using upper-case initials:</label><br/>
<input type="text" name="state" id="state"><br/>
--%>
