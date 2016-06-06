/* mail.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        16.01.2004 nadejda - если отправитель письма не указан, то ставить общий адрес abpk@elexnet.kz, а не юзера
        02/11/2005 madiar  - если получатель письма не указан, то ничего не делать
        19/11/08   marina
        02.11.2011 damir - не корректно отображалась тема - subj
        13/09/2012 madiyar - миграция на новый сервер - корректировка разделителей адресов получателей
*/

/* mail.p */
/* run mail("Получатель", "Отправитель", "Тема", "Сообщение", "Важность", "Уведомление", "Файл1;Файл2;...;ФайлN") */

define input parameter addr as char.
define input parameter fr   as char.
define input parameter subj as char.
define input parameter msg  as char.
define input parameter pr   as char.
define input parameter ref  as char.
define input parameter file as char.
define var bnd as char initial "--------=PART.BOUNDARY".

if trim(addr) = '' then return.

/* корректировка разделителей адресов */
if index(addr,";") > 0 then addr = replace(addr,";",",").

def var fs as char.
def var fn as char.

if fr = "" then fr = "abpk@metrocombank.kz".
/* output through value("/usr/lib/sendmail -oi -t -odq"). */
output through value("/usr/lib/sendmail -t").
put unformatted
'Return-Path: ' fr skip
'From: ' fr skip
'To: ' addr skip
'Subject: ' '=?windows-1251?Q?' subj '?=' /*'?==??Q?'*/ skip
'Content-type: multipart/mixed\; boundary="' bnd '"' skip
if ref <> '' then 'Disposition-Notification-To: ' + ref + '~n' else ''
'X-Priority: ' if pr = '' then '3' else pr skip
skip(1).

if msg <> "" then
    put unformatted
    '--' bnd skip
    'Content-Type: text/plain; charset="windows-1251"' skip(1)
    msg skip(1).

do while length(file) > 0:
    fs = SUBSTRING( file, r-index(file,";") + 1, length(file) -         r-index(file,";")).
    file = SUBSTRING( file, 1, length(file) - length(fs)).
    file = right-trim(file, ";").
    fn = SUBSTRING( fs, r-index(fs,"/") + 1, length(fs) - r-index(fs,"/")).
    put unformatted
    '--' bnd skip
    'Content-Type: application/octet-stream; name="' fn '"' skip
    "Content-Transfer-Encoding: Base64" skip
    'Content-Disposition: attachment\; filename="' fn '"' skip(1).
    unix silent value("cat " + fs + " | mimencode").
end.
put unformatted
'--' bnd "--".
output close.
