unit ISWinInetErrors;

{$I InnovaLibDefs.inc}

interface

Uses
{$IFDEF ISXE2_DELPHI}
  WinApi.Windows,  System.SysUtils;
{$ELSE}
  windows,Sysutils;
{$ENDIF}

Function WinINetErrorString(AError:DWord):AnsiString;

implementation

Function WinINetErrorString(AError:DWord):AnsiString;

Begin
  Result:='';
  if (AError<12000) or (AError>12175) then  Exit;


{  Error Messages

The WinINet functions return error codes where appropriate. The following errors are specific to the WinINet functions.

ERROR_FTP_DROPPED

    12111

    The FTP operation was not completed because the session was aborted.

ERROR_FTP_NO_PASSIVE_MODE

    12112

    Passive mode is not available on the server.

ERROR_FTP_TRANSFER_IN_PROGRESS

    12110

    The requested operation cannot be made on the FTP session handle because an operation is already in progress.

ERROR_GOPHER_ATTRIBUTE_NOT_FOUND

    12137

    The requested attribute could not be located.

    Note  Windows XP and Windows Server 2003 R2 and earlier only.

ERROR_GOPHER_DATA_ERROR

    12132

    An error was detected while receiving data from the Gopher server.

    Note  Windows XP and Windows Server 2003 R2 and earlier only.

ERROR_GOPHER_END_OF_DATA

    12133

    The end of the data has been reached.

    Note  Windows XP and Windows Server 2003 R2 and earlier only.

ERROR_GOPHER_INCORRECT_LOCATOR_TYPE

    12135

    The type of the locator is not correct for this operation.

    Note  Windows XP and Windows Server 2003 R2 and earlier only.

ERROR_GOPHER_INVALID_LOCATOR

    12134

    The supplied locator is not valid.

    Note  Windows XP and Windows Server 2003 R2 and earlier only.

ERROR_GOPHER_NOT_FILE

    12131

    The request must be made for a file locator.

    Note  Windows XP and Windows Server 2003 R2 and earlier only.

ERROR_GOPHER_NOT_GOPHER_PLUS

    12136

    The requested operation can be made only against a Gopher+ server, or with a locator that specifies a Gopher+ operation.

    Note  Windows XP and Windows Server 2003 R2 and earlier only.

ERROR_GOPHER_PROTOCOL_ERROR

    12130

    An error was detected while parsing data returned from the Gopher server.

    Note  Windows XP and Windows Server 2003 R2 and earlier only.

ERROR_GOPHER_UNKNOWN_LOCATOR

    12138

    The locator type is unknown.

    Note  Windows XP and Windows Server 2003 R2 and earlier only.

ERROR_HTTP_COOKIE_DECLINED

    12162

    The HTTP cookie was declined by the server.

ERROR_HTTP_COOKIE_NEEDS_CONFIRMATION

    12161

    The HTTP cookie requires confirmation.

    Note  Windows Vista and Windows Server 2008 and earlier only.

ERROR_HTTP_DOWNLEVEL_SERVER

    12151

    The server did not return any headers.

ERROR_HTTP_HEADER_ALREADY_EXISTS

    12155

    The header could not be added because it already exists.

ERROR_HTTP_HEADER_NOT_FOUND

    12150

    The requested header could not be located.

ERROR_HTTP_INVALID_HEADER

    12153

    The supplied header is invalid.

ERROR_HTTP_INVALID_QUERY_REQUEST

    12154

    The request made to HttpQueryInfo is invalid.

ERROR_HTTP_INVALID_SERVER_RESPONSE

    12152

    The server response could not be parsed.

ERROR_HTTP_NOT_REDIRECTED

    12160

    The HTTP request was not redirected.

ERROR_HTTP_REDIRECT_FAILED

    12156

    The redirection failed because either the scheme changed (for example, HTTP to FTP) or all attempts made to redirect failed (default is five attempts).

ERROR_HTTP_REDIRECT_NEEDS_CONFIRMATION

    12168

    The redirection requires user confirmation.

ERROR_INTERNET_ASYNC_THREAD_FAILED

    12047

    The application could not start an asynchronous thread.

ERROR_INTERNET_BAD_AUTO_PROXY_SCRIPT

    12166

    There was an error in the automatic proxy configuration script.

ERROR_INTERNET_BAD_OPTION_LENGTH

    12010

    The length of an option supplied to InternetQueryOption or InternetSetOption is incorrect for the type of option specified.

ERROR_INTERNET_BAD_REGISTRY_PARAMETER

    12022

    A required registry value was located but is an incorrect type or has an invalid value.

ERROR_INTERNET_CANNOT_CONNECT

}
  If AError=12029 Then Result:='The attempt to connect to the server failed.'
  else
{
ERROR_INTERNET_CHG_POST_IS_NON_SECURE

    12042

    The application is posting and attempting to change multiple lines of text on a server that is not secure.

ERROR_INTERNET_CLIENT_AUTH_CERT_NEEDED

    12044

    The server is requesting client authentication.

ERROR_INTERNET_CLIENT_AUTH_NOT_SETUP

    12046

    Client authorization is not set up on this computer.

ERROR_INTERNET_CONNECTION_ABORTED

    12030

    The connection with the server has been terminated.

ERROR_INTERNET_CONNECTION_RESET

    12031

    The connection with the server has been reset.

ERROR_INTERNET_DECODING_FAILED

    12175

    WinINet failed to perform content decoding on the response. For more information, see the Content Encoding topic.

ERROR_INTERNET_DIALOG_PENDING

    12049

    Another thread has a password dialog box in progress.

ERROR_INTERNET_DISCONNECTED

    12163

    The Internet connection has been lost.

ERROR_INTERNET_EXTENDED_ERROR

    12003

    An extended error was returned from the server. This is typically a string or buffer containing a verbose error message. Call InternetGetLastResponseInfo to retrieve the error text.

ERROR_INTERNET_FAILED_DUETOSECURITYCHECK

    12171

    The function failed due to a security check.

ERROR_INTERNET_FORCE_RETRY

    12032

    The function needs to redo the request.

ERROR_INTERNET_FORTEZZA_LOGIN_NEEDED

    12054

    The requested resource requires Fortezza authentication.

ERROR_INTERNET_HANDLE_EXISTS

    12036

    The request failed because the handle already exists.

ERROR_INTERNET_HTTP_TO_HTTPS_ON_REDIR

    12039

    The application is moving from a non-SSL to an SSL connection because of a redirect.

ERROR_INTERNET_HTTPS_HTTP_SUBMIT_REDIR

    12052

    The data being submitted to an SSL connection is being redirected to a non-SSL connection.

ERROR_INTERNET_HTTPS_TO_HTTP_ON_REDIR

    12040

    The application is moving from an SSL to an non-SSL connection because of a redirect.

ERROR_INTERNET_INCORRECT_FORMAT

    12027

    The format of the request is invalid.

ERROR_INTERNET_INCORRECT_HANDLE_STATE

    12019

    The requested operation cannot be carried out because the handle supplied is not in the correct state.

ERROR_INTERNET_INCORRECT_HANDLE_TYPE

    12018

    The type of handle supplied is incorrect for this operation.

ERROR_INTERNET_INCORRECT_PASSWORD

    12014

    The request to connect and log on to an FTP server could not be completed because the supplied password is incorrect.

ERROR_INTERNET_INCORRECT_USER_NAME

    12013

    The request to connect and log on to an FTP server could not be completed because the supplied user name is incorrect.

ERROR_INTERNET_INSERT_CDROM

    12053

    The request requires a CD-ROM to be inserted in the CD-ROM drive to locate the resource requested.

    Note  Windows Vista and Windows Server 2008 and earlier only.

ERROR_INTERNET_INTERNAL_ERROR

    12004

    An internal error has occurred.

ERROR_INTERNET_INVALID_CA

    12045

    The function is unfamiliar with the Certificate Authority that generated the server's certificate.

ERROR_INTERNET_INVALID_OPERATION

    12016

    The requested operation is invalid.

ERROR_INTERNET_INVALID_OPTION

    12009

    A request to InternetQueryOption or InternetSetOption specified an invalid option value.

ERROR_INTERNET_INVALID_PROXY_REQUEST

    12033

    The request to the proxy was invalid.

ERROR_INTERNET_INVALID_URL

    12005

    The URL is invalid.

ERROR_INTERNET_ITEM_NOT_FOUND

    12028

    The requested item could not be located.

ERROR_INTERNET_LOGIN_FAILURE

    12015

    The request to connect and log on to an FTP server failed.

ERROR_INTERNET_LOGIN_FAILURE_DISPLAY_ENTITY_BODY

    12174

    The MS-Logoff digest header has been returned from the website. This header specifically instructs the digest package to purge credentials for the associated realm. This error will only be returned if INTERNET_ERROR_MASK_LOGIN_FAILURE_DISPLAY_ENTITY_BODY option has been set; otherwise, ERROR_INTERNET_LOGIN_FAILURE is returned.

ERROR_INTERNET_MIXED_SECURITY

    12041

    The content is not entirely secure. Some of the content being viewed may have come from unsecured servers.

ERROR_INTERNET_NAME_NOT_RESOLVED

    12007

    The server name could not be resolved.

ERROR_INTERNET_NEED_MSN_SSPI_PKG

    12173

    Not currently implemented.

ERROR_INTERNET_NEED_UI

    12034

    A user interface or other blocking operation has been requested.

    Note  Windows Vista and Windows Server 2008 and earlier only.

ERROR_INTERNET_NO_CALLBACK

    12025

    An asynchronous request could not be made because a callback function has not been set.

ERROR_INTERNET_NO_CONTEXT

    12024

    An asynchronous request could not be made because a zero context value was supplied.

ERROR_INTERNET_NO_DIRECT_ACCESS

    12023

    Direct network access cannot be made at this time.

ERROR_INTERNET_NOT_INITIALIZED

    12172

    Initialization of the WinINet API has not occurred. Indicates that a higher-level function, such as InternetOpen, has not been called yet.

ERROR_INTERNET_NOT_PROXY_REQUEST

    12020

    The request cannot be made via a proxy.

ERROR_INTERNET_OPERATION_CANCELLED

    12017

    The operation was canceled, usually because the handle on which the request was operating was closed before the operation completed.

ERROR_INTERNET_OPTION_NOT_SETTABLE

    12011

    The requested option cannot be set, only queried.

ERROR_INTERNET_OUT_OF_HANDLES

    12001

    No more handles could be generated at this time.

ERROR_INTERNET_POST_IS_NON_SECURE

    12043

    The application is posting data to a server that is not secure.

ERROR_INTERNET_PROTOCOL_NOT_FOUND

    12008

    The requested protocol could not be located.

ERROR_INTERNET_PROXY_SERVER_UNREACHABLE

    12165

    The designated proxy server cannot be reached.

ERROR_INTERNET_REDIRECT_SCHEME_CHANGE

    12048

    The function could not handle the redirection, because the scheme changed (for example, HTTP to FTP).

ERROR_INTERNET_REGISTRY_VALUE_NOT_FOUND

    12021

    A required registry value could not be located.

ERROR_INTERNET_REQUEST_PENDING

    12026

    The required operation could not be completed because one or more requests are pending.

ERROR_INTERNET_RETRY_DIALOG

    12050

    The dialog box should be retried.

ERROR_INTERNET_SEC_CERT_CN_INVALID

    12038

    SSL certificate common name (host name field) is incorrect—for example, if you entered www.server.com and the common name on the certificate says www.different.com.

ERROR_INTERNET_SEC_CERT_DATE_INVALID

    12037

    SSL certificate date that was received from the server is bad. The certificate is expired.

ERROR_INTERNET_SEC_CERT_ERRORS

    12055

    The SSL certificate contains errors.

ERROR_INTERNET_SEC_CERT_NO_REV

    12056

    The SSL certificate was not revoked.

ERROR_INTERNET_SEC_CERT_REV_FAILED

    12057

    Revocation of the SSL certificate failed.

ERROR_INTERNET_SEC_CERT_REVOKED

    12170

    The SSL certificate was revoked.

ERROR_INTERNET_SEC_INVALID_CERT

    12169

    The SSL certificate is invalid.

ERROR_INTERNET_SECURITY_CHANNEL_ERROR

    12157

    The application experienced an internal error loading the SSL libraries.

ERROR_INTERNET_SERVER_UNREACHABLE

    12164

    The website or server indicated is unreachable.

ERROR_INTERNET_SHUTDOWN

    12012

    WinINet support is being shut down or unloaded.

ERROR_INTERNET_TCPIP_NOT_INSTALLED

    12159

    The required protocol stack is not loaded and the application cannot start WinSock.

ERROR_INTERNET_TIMEOUT

    12002

    The request has timed out.

ERROR_INTERNET_UNABLE_TO_CACHE_FILE

    12158

    The function was unable to cache the file.

ERROR_INTERNET_UNABLE_TO_DOWNLOAD_SCRIPT

    12167

    The automatic proxy configuration script could not be downloaded. The INTERNET_FLAG_MUST_CACHE_REQUEST flag was set.

ERROR_INTERNET_UNRECOGNIZED_SCHEME

    12006

    The URL scheme could not be recognized, or is not supported.

}
   Result:='Add Error To WinINetErrorString:'+ IntToStr(AError);
End;

end.
