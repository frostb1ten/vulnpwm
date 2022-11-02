<%@ page import="password.pwm.config.PasswordStatus" %>
<%--
  ~ Password Management Servlets (PWM)
  ~ http://code.google.com/p/pwm/
  ~
  ~ Copyright (c) 2006-2009 Novell, Inc.
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or
  ~ (at your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  --%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page language="java" session="true" isThreadSafe="true" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<% PasswordStatus passwordStatus = PwmSession.getPwmSession(session).getUserInfoBean().getPasswordState(); %>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<%@ include file="header.jsp" %>
<body onload="startupPage(); getObject('password1').focus();" onunload="unloadHandler();" onunload="unloadHandler();" onkeypress="">
<div id="wrapper">
    <jsp:include page="header-body.jsp"><jsp:param name="pwm.PageName" value="Title_ChangePassword"/></jsp:include>
    <div id="centerbody">
        <% if (passwordStatus.isExpired() || passwordStatus.isPreExpired() || passwordStatus.isViolatesPolicy()) { %>
        <h1><pwm:Display key="Display_PasswordExpired"/></h1>
        <%-- <p/>You have <pwm:LdapValue name="loginGraceRemaining"/> remaining logins. --%>
        <% } %>
        <pwm:Display key="Display_ChangePassword"/>
        <ul>
            <pwm:DisplayPasswordRequirements seperator="</li>" prepend="<li>"/>
        </ul>
        <% final String passwordPolicyChangeMessage = PwmSession.getPwmSession(session).getUserInfoBean().getPasswordPolicy().getRuleHelper().getChangeMessage(); %>
        <% if (passwordPolicyChangeMessage.length() >1 ) { %>
        <p><%= passwordPolicyChangeMessage %></p>
        <% } %>
        <%-- begin auto generate password [not shown if javascript is disabled]--%>
        <script type="text/javascript">
            document.write('<p class="nojavascript">&nbsp;»&nbsp; <a href="javascript:fetchNewRandom();"><pwm:Display key="Display_AutoGeneratedPassword"/></a></p>');
        </script>
        <%-- end auto generate password --%>
        <br/>

        <%  // if there is an error, then always show the error block if javascript is enabled.  Otherwise, only show
            // the error block if javascript is available (for ajax use). 
            if (PwmSession.getSessionStateBean(session).getSessionError() != null) {
        %>
        <span id="error_msg" class="msg-error"><pwm:ErrorMessage/>&nbsp;</span>
        <% } else { %>
        <script type="text/javascript">
            document.write('<span id="error_msg" class="msg-success">&nbsp;</span>');
        </script>
        <% } %>

        <form action="<pwm:url url='ChangePassword'/>" method="post" enctype="application/x-www-form-urlencoded" onkeyup="validatePasswords();" onkeypress="checkForCapsLock(event);" 
              onsubmit="handleChangePasswordSubmit(); handleFormSubmit('password_button');" name="changePassword" autocomplete="off">

            <%-- strength-meter [not shown if javascript is disabled; see also changepassword.js:markStrength() --%>
            <div id="strengthMeterBox" style="display:none"> <%-- by default, this section is not visable.  see changepassword.js:startupPage() --%>
                <div style="display:inherit; float: right; position: relative; top: 0; width: 25%; height: 100px; margin-top:30px;">
                    <div style="margin-left:40%; margin-right:40%">
                        <div style="height: 60px;" id="vertgraph">
                            <ul id="graph2">
                                <li class="bar" style="height: 1px;"><!--comment--></li>
                            </ul>
                        </div>
                    </div>
                    <div class="strengthdisplay">
                        <pwm:Display key="Display_StrengthMeter"/>
                    </div>
                </div>
            </div>

            <div style="width:70%">
                <h2><pwm:Display key="Field_NewPassword"/></h2>
                <input tabindex="1" type="password" name="password1" id="password1" class="inputfield"/>
                <h2><pwm:Display key="Field_ConfirmPassword"/></h2>
                <input tabindex="2" type="password" name="password2" id="password2" class="inputfield"/>
            </div>

            <div id="buttonbar">
                <span>
                    <div id="capslockwarning" style="visibility:hidden;"><pwm:Display key="Display_CapsLockIsOn"/></div>
                </span>                
                <input type="hidden" name="processAction" value="change"/>
                <input tabindex="3" type="submit" name="change" class="btn"
                       id="password_button"
                       value="    <pwm:Display key="Button_ChangePassword"/>    "/>
                <input tabindex="4" type="reset" name="reset" class="btn"
                       value="    <pwm:Display key="Button_Reset"/>    "
                       onclick="clearForm(); document.forms.changePassword.password1.focus();"/>
                <input type="hidden" name="hideButton" class="btn"
                       value="    <pwm:Display key="Button_Show"/>    "
                       onclick="toggleHide();" id="hide_button"/>
            </div>
        </form>
    </div>
    <br class="clear" />
</div>
<%-- hidden fields used by changepassword.js javascript display fields for i18n --%>
<form action="" name="hiddenForm">
    <input type="hidden" name="Js_Display_CheckingPassword" id="Js_Display_CheckingPassword" value="<pwm:Display key="Display_CheckingPassword"/>"/>
    <input type="hidden" name="Js_Display_PasswordChangedTo" id="Js_Display_PasswordChangedTo" value="<pwm:Display key="Display_PasswordChangedTo"/>"/>
    <input type="hidden" name="Js_Display_CommunicationError" id="Js_Display_CommunicationError" value="<pwm:Display key="Display_CommunicationError"/>"/>
    <input type="hidden" name="Js_Button_Hide" id="Js_Button_Hide" value="<pwm:Display key="Button_Hide"/>"/>
    <input type="hidden" name="Js_Button_Show" id="Js_Button_Show" value="<pwm:Display key="Button_Show"/>"/>
    <input type="hidden" name="Js_ChangePasswordURL" id="Js_ChangePasswordURL" value="<pwm:url url='ChangePassword'/>"/>
</form>
<%-- end hidden fields --%>
<script type="text/javascript" src="<%=request.getContextPath()%>/resources/<pwm:url url='json2.js'/>"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/resources/<pwm:url url='changepassword.js'/>"></script>
<%@ include file="footer.jsp" %>
</body>
</html>


