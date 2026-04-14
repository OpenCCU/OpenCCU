UserButtonClick = function(fullName, name)
{
  $("UserNameShow").value = fullName;
  $("UserName").value = name;
  $("Password").value = "";
  $("Password").focus();
}

FormSubmit = function ()
{
  if ($("UserName").value === "") {
    var tmp = $("UserNameShow").value;
    $("UserName").value = tmp.replace(' ','');
  }
  document.getElementById( 'gwlogin' ).submit();
}

PasswordKeyUp = function(e)
{
  var keycode;
  if (window.event) keycode = window.event.keyCode;
  else if (e) keycode = e.which;
  else return;

  if (keycode == 13)
  { // ENTER
    FormSubmit();
  }
}

togglePassword = function()
{
  var pw = document.getElementById('Password');
  var icon = document.getElementById('pw-icon');
  if (pw.type === 'password') {
    pw.type = 'text';
    icon.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94"/><path d="M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19"/><line x1="1" y1="1" x2="23" y2="23"/></svg>';
  } else {
    pw.type = 'password';
    icon.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>';
  }
}

gotoLoginPage = function() {
  location.href = "/login.htm";
};

loadHelp = function()
{
  var opts = {
  evalScripts: true,
  postBody: "from=login",
  sendXML: false
  };
  var url = "/config/help.cgi";
  new Ajax.Updater("content", url, opts);
};
