function sendgmail(to,subject,message,attachments,gmail,password)
% SENDGMAIL(TO,SUBJECT,MESSAGE,ATTACHMENTS,FROM,PASSWORD) sends an e-mail.  
%    TO is either a string specifying a single address, or a cell array of 
%    addresses.  SUBJECT is a string.  MESSAGE is either a string or a 
%    cell-array.  If it is a string, the text will automatically wrap at 75 
%    characters.  If it is a cell array, it won't wrap, but each cell 
%    starts a new line.  In either case, use char(10) to explicitly specify 
%    a new line.  ATTACHMENTS is a string or a cell array of strings 
%    listing files to send along with the message.  Only TO and SUBJECT are 
%    required. PASSWORD is your GMAIL password. Uses smtp.gmail.com SMTP server.
%
% Example 1.: user
% >> sendgmail('to@example.com','Hello World','See attached files','stuff.m','user','foobar');
%
% Example 2.: user@example.com
% >> sendgmail('to@example.com','Hello World','See attached files','stuff.m','user@example.com','foobar');
%
% See also: sendmail, web, ftp.

% $Revision: 1.2 $ $Date: 2008/12/04 07:19:54 $ $Author: Tim Gebbie $

% Define to account variables
if any(ismember(gmail,'@'))
else
    gmail = sprintf('%s@gmail.com',gmail); %Your GMail email address
end

% Then this code will set up the preferences properly:
% see: mathworks work around for R2006a
setpref('Internet','E_mail',gmail);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',gmail);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

% Send the email
if isempty(attachments)
    sendmail(to,subject,message);
else
    sendmail(to,subject,message,attachments);
end