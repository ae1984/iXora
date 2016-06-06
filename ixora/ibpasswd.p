/* ibpasswd.p
 * MODULE
        Internet Office
 * DESCRIPTION
        1. Установка паролей по умолчанию для пользователей Internet Office
        2. Снятие блокировки (если есть)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        nmenu.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.8.8
 * BASES
        BANK COMM IB
 * AUTHOR
        29/12/03 sasco
 * CHANGES
        05/10/04 tsoy создать запись в журнале и послать письмо аудиторам.
        14/10/04 tsoy изменить адрес на audit 
        19/10/04 tsoy добавил сохранение ip_name
        16/01/06 tsoy изменил 001122 на абракадбру
        02/02/06 tsoy для otp нельзя сбрасывать паролл для утверждения и конфигурационный

*/

{yes-no.i}
{global.i}

define variable v-usr like ib.usr.id.
define variable v-p as char.
define variable v-s as char.
define variable v-ask as character.
define variable v-login as character.

def stream rep. 

define temp-table tmp  
       field idx as integer
       field chg as logical format " X /   "
       field des as character 
       index idx_tmp is primary idx.

create tmp.
assign tmp.idx = 1
       tmp.chg = FALSE
       tmp.des = "Пароль для входа".

create tmp.
assign tmp.idx = 2
       tmp.chg = FALSE
       tmp.des = "Пароль для утверждения".

create tmp.
assign tmp.idx = 3
       tmp.chg = FALSE
       tmp.des = "Конфигурационный пароль".



define query qt for tmp.
define browse bt query qt
       displ tmp.chg format ' X /   '
             tmp.des format 'x(23)'
             with row 1 centered 3 down no-label title "Обнуление паролей".
define frame ft 
             "Клиент: " v-ask format "x(70)" view-as text skip(1)
             "Login : " v-login format "x(70)" view-as text skip(1)
             "Филиал: " ib.usr.bnkplc format "x(5)" view-as text skip(1)
             bt at 20 help "ENTER - отметить/снять отметку; F1 - установить пароли"
             skip(2)
             with row  2 overlay no-label.

update v-usr column-label "Регистрационный номер" with row 1 centered frame fin.
hide frame fin.


find first ib.usr where ib.usr.id = v-usr no-error.
if not available ib.usr then do:
   message "Нет пользователя с номером " v-usr "!" view-as alert-box title ''.
   return.
end.

if usr.authptype = 'otp' then do:

    find  tmp where tmp.idx = 2. delete  tmp.
    find  tmp where tmp.idx = 3. delete  tmp.

end.

v-login = ib.usr.login.
v-ask = ib.usr.contact[1].

displ v-login v-ask ib.usr.bnkplc with frame ft.

on "return" of browse bt do:
   if not available tmp then leave.
   tmp.chg = not tmp.chg.
   browse bt:refresh().
end.

open query qt for each tmp.
enable all with frame ft.
wait-for window-close of current-window or "go" of browse bt focus browse bt.

hide frame ft.

if ib.usr.perm[3] > 0 then 
if yes-no ("", "Клиент блокирован. Разблокировать?") then 
do:
        create ib.hist.
        assign
            ib.usr.perm[3] = 0
            ib.hist.type1 = 2
            ib.hist.type2 = 12
            ib.hist.procname = "IB_Platon_Menu"
            ib.hist.ip_addr = "platon"
            ib.hist.ip_name = g-ofc
            ib.hist.idusraff = ib.usr.id.
        release ib.hist.
        run savelog ("i-office", "Снятие блокировки с клиента N " + string(v-usr) + ", CIF " + usr.cif + ", Филиал " + usr.bnkplc).
end.

find first tmp where chg no-error.
if not available tmp then do:
   message "Вы не выбрали ни один пароль!" view-as alert-box title ''.
   return.
end.

v-ask = "Вы выбрали: ~n".
for each tmp where tmp.chg:
v-ask = v-ask + "~n" + tmp.des.
end.
v-ask = v-ask + "~n~nУстановить пароли по-умолчанию?".

if yes-no ("", v-ask) then do:

    v-p = substring(encode(usr.login + string(time)), 1,6) + substring(string(time),4,2).

    input through value("genkey.exe -p " + v-p ) no-echo.
    repeat:
       import unformatted v-s.
    end.

   for each tmp where tmp.chg:
       ib.usr.passwd[tmp.idx] = v-s.
       run savelog ("i-office", "Установка пароля по-умолчанию (" + tmp.des + "), клиент N " + string(v-usr) + ", CIF " + usr.cif + ", Филиал " + usr.bnkplc).
   end.


     output stream rep to value("ibpasswd.html").

     {html-title.i &stream = "stream rep" &title = " " &size-add = "x"}

     put stream rep unformatted 
        "<center><h1> Измененные данные </h1><br>"                              skip
        "<TABLE width=""50%"" border=""1"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
        "<TR><TD>Входное имя </TD><TD>" string(usr.login) "</TD></TR>"                            skip.

     for each tmp where tmp.chg.
     put stream rep unformatted 
          "<TR><TD>" tmp.des "</TD><TD>" v-p "</TD></TR>"                          skip.
     end.

     put stream rep unformatted
        "</TABLE>"                                                                                skip.

     {html-end.i "stream rep"}

     output stream rep close.

     unix silent cptwin value("ibpasswd.html") winword.
     unix silent value("rm ibpasswd.html") .


           create ib.hist.
           assign
                   ib.hist.type1    = 2
                   ib.hist.type2    = 15
                   ib.hist.id_usr   = ib.usr.id
                   ib.hist.login    = ib.usr.login
                   ib.hist.procname = "IB_PRAGMA_MENU"
                   ib.hist.idusraff = 0.
                   ib.hist.ip_name  = g-ofc.

            run mail( "audit@elexnet.kz","TEXAKABANK <abpk@elexnet.kz>","Установка пароля по-умолчанию ",
                        "Установка пароля по-умолчанию "    + g-ofc         + "\n" + 
                        "Дата     " + string (ib.hist.wdate , "99.99.9999") + "\n" + 
                        "Время    " + string (ib.hist.wtime)                 + "\n" +
                        "ID       " + string (ib.hist.id)                   + "\n" +
                        "ID_USR   " + string (ib.hist.id_usr)               + "\n" +
                        "ID_SES   " + string (ib.hist.id_ses)               + "\n" +
                        "LOGIN    " + ib.hist.login                         + "\n" +
                        "PROCNAME " + ib.hist.procname                      + "\n" +
                        "TYPE1    " + string (ib.hist.type1)                + "\n" +
                        "TYPE2    " + string (ib.hist.type2)                + "\n" +
                        "IP_NAME  " + string (ib.hist.ip_name)              + "\n" ,                   
                        "1", "",  "").



end.

