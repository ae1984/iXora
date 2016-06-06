/* bknewcrd.i
 * MODULE
        Пластиковые карточки
 * DESCRIPTION
        Заказ в АБН карточек - формирование файла 
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
        17.12.05 marinav 
 * CHANGES
*/

{bk.i}

define var file-cntr as char format "x(2)".
define var file-date as char format "x(3)".
define var file-year as char format "x(4)".
define var file-month as char format "x(2)".
define var file-day as char format "x(2)".
define var file-time as char format "x(6)".
define var ln as integer init 0 format "999999".
define var file-name as char init "".
define var crlf as char.
define var s0 as char.
define var num-orders as integer init 0.
define var cur-order-num as integer init 0.

define var ClientMType as char format "x(1)"   label "Тип модификации клиента".                                            
define var ContractMType as char format "x(1)" label "Тип модификации контракта".
define var CardMType as char format "x(2)"     label "Тип модификации карточки".
define var RBScode as char                     label "RBS Код ".
define var Dep as char.
define var IsCrc as char format "x(9)"         label "Валюта".
define var IsPrivate as logical format "P/C"   label "(P)частное лицо, (C)организация".
define var IsCountry as char format "x(3)"     label "Страна" init "KAZ". 
define var IsResident as logical format "R/N"  label "Резидент(R) или нет (N)". 
define var IsContract as logical format "A/C"  label "Категория: (C)card, (A)account".
define var IsCredit as logical format "C/D"    label "(C)credit, (D)debit".
define var CrLimit as inte.
define var CrLimitSum as inte.

define var AccSch as char.
define var ServPack as char.
define var ConType as char.

define var ShortName as char format "x(20)"    label "Короткое имя"  .
define var SecName as char format "x(20)"      label "Секретная фраза" .
define var Passport as char init ''. 
define var Pass as char format "x(15)"         label "Документ #" init ' '.
define var PassType as char                    label "Тип документа"
           view-as combo-box list-items "PS", "ID" 
           format "x(2)" init "ID".
           
define var PassIssue as date                   label "Дата выдачи документа" init 01/01/01.
define var PassValid as date                   label "Документ годен до..." init 05/05/05.

define var Salutation as char format "x(4)"    label "Обращение".
define var Surname as char format "x(32)"      label "Фамилия"  init ' '.
define var Name as char format "x(32)"         label "Имя"  init ' '.
define var SurnameEmb as char format "x(32)"   label "Фамилия"  init ' '.
define var NameEmb as char format "x(32)"      label "Имя"  init ' '.
define var FatherName as char format "x(35)"   label "Отчество" .
define var MaritalStatus as char format "x(3)" label "Семейное положение" init "SIN".

define var Birthday as date                    label "Дата рождения" init 01/01/01.
define var BirthPlace as char format "x(10)"   label "Место рождения"  init ' '.
define var WorkPhone as char format "x(10)"    label "Телефон (раб)"  init ' '.
define var MobilePhone as char format "x(10)"  label "Телефон (сот)" init ' '.
define var HomePhone as char format "x(10)"    label "Телефон (дом)" init ' '.
define var WorkFax as char format "x(10)"      label "Факс (раб)" init ' '.
define var HomeFax as char format "x(10)"      label "Факс (дом)" init ' '.
define var Email as char  format "x(25)"       label "E-mail"init ' '.
define var Zipcode as char  format "x(32)"     label "Филиал"init ' '.

define var CompanyName as char label "Название фирмы" format "x(15)" init ' '.
define var Position as char label "Должность" format "x(25)" init ' '.
define var Language as char label "Язык" format "x(10)" init ' '.
define var BaseAddress as char extent 4 label "Адрес" format "x(45)" init ' '.
define var City as char label "Город" format "x(10)" init 'ALMATY'.
define var Country as char label "Страна" format "x(12)" init 'KAZAKHSTAN'.
define var ConExpDate as char init ' '. /*YYYYMMDD*/
define var CarExpDate as char init ' '. /*YYMM*/
define var ContInfo as char.
define var pvv as char init ' '.   /* заполняется если card procuction type = 10*/ 
define var cvc1 as char init ' '.  /* заполняется если card procuction type = 10*/
define var cvc2 as char init ' '. /* заполняется если card procuction type = 10*/
define var pinenc as char init ' '. /* заполняется если card procuction type = 10*/
define var pinform as char init ' '. /* заполняется если card procuction type = 10*/

define var Embossing as char label "Embossing" format "x(60)" init ' '.
define var TradeMark as char label "TradeMark" format "x(32)" init ' '.
define var vrnn as char label "РНН" format "x(12)" init ' '.

define var ContractName as char label "Контракт" format "x(35)" init ''.
define var AcntScheme as char label "Схема счета" format "x(35)" init ''.
define var AcntType as char label "Тип счета" format "x(35)" init ''.
define var AcntService as char label "Сервис" format "x(35)" init ''.
define var ContractNum as char format "x(24)" init ''.

define var CardType as char label "Тип карточки" format "x(35)" init ''.
define var CardService as char label "Сервис карточки" format "x(35)" init ''. 
define var ChekAvail as char label "Chek avail" format "x(35)" init ''.

def var bwxdir as char no-undo.
def var rcd as char.

def stream t.
function unix_s returns char (cmd as char).
    def var st as char init ''.
    input stream t through value(cmd).
    import stream t unformatted st.
    input stream t close.
    return st.
end.

crlf = chr(13) + chr(10).

procedure Put_header.

/* global counter for application files per day in CARDS database */
find counters where counters.type = "applicat_file" exclusive-lock no-error.
if not avail counters then
   do:
      create counters.
      assign counters.type = "applicat_file"
             counters.dat = g-today
             counters.counter = 1.
  end.
else do:
  if counters.dat <> g-today then
  do:
      assign counters.dat = g-today
             counters.counter = 1.
  end.
  else counters.counter = counters.counter + 1.
end.

file-cntr = string(counters.counter, "99").
file-date = string(g-today - date(01,01, year(g-today)) + 1, "999").
file-year = string(year(g-today), "9999").
file-month = string(month(g-today), "99").
file-day = string(day(g-today), "99").
file-time = string(time, "hh:mm:ss").
file-time = substr(file-time,1,2) + substr(file-time,4,2) + 
            substr(file-time,7,2).

release counters.
s0 = "a0005_" + file-cntr + "." + file-date.
file-name = s0.
output to rpt.img.


/* HEADER */
ln = ln + 1.
s0 = "FH" + string (ln, "999999") + "APPLICAT  " + "14 " + "00005 " +
    file-year + file-month + file-day + file-time + "00" + file-cntr +
    "00005 ". 
if CardMType ne '30' then s0 = s0 + "RNW" + fill (" ", 1397) + fill (" ", 1946) + "*" + crlf.
if CardMType = '30' then s0 = s0 + "CNWN" + fill (" ", 1396) + fill (" ", 1946) + "*" + crlf.

put unformatted s0.

output close.

end procedure.



procedure Put_footer.

    output to rpt.img append.

    ln = ln + 1.
    s0 = "FT" + string (ln, "999999") + string(num-orders, "999999") +
        fill (" ", 1437) + fill (" ", 1946) + "*" + crlf.
        put unformatted s0.
                         
    output close.
    num-orders = 0. ln = 0.
end procedure.


procedure Put_application.

num-orders = num-orders + 1.
cur-order-num = cur-order-num + 1. /* Вместо этого подставим RBS */

if num-orders = 1 then run Put_header.

output to rpt.img append.

ln = ln + 1.

s0 = /* 1 */ "RD" + string (ln, "999999") + string (RBScode, "9999999999") +
    /* 4 */ substr (ClientMType, 1, 1) + 
    /* 5 */ substr (ContractMType, 1, 1) +
    /* 6 */ substr (CardMType, 1, 2) +
    /* 7 */ "          " /*department */ +
    /* 8 */ string (Dep,"x(10)") /* department */ +
    /* 9 */ file-year + file-month + file-day +  /* order date */
   /* 10 */ string ('C' + RBScode,"x(32)") +   /*кодировка клиента в ТКВ*/
   /* 11 */ /* client type PNR, CNR, PR, CR */
            string(IsPrivate, "P/C") +
            string(IsResident, "R/N"). 
            if IsResident then s0 = s0 + "    " .
                          else s0 = s0 + "R   " .

s0 = /* 12 */ s0 + string (Name, "x(32)") + 
     /* 13 */      string (Surname, "x(32)"). 

put unformatted s0.

s0 =
   /* 14 */ string (FatherName, "x(32)") + 
   /* 15 */ string (Surname, "x(32)") +
   /* 16 */ string (CompanyName, "x(32)") + 
   /* 17 */ string (TradeMark, "x(32)") + 
   /* 18 */ string (ShortName, "x(32)") + 
   /* 19 */ string (SecName, "x(20)") + 
   /* 20 */ string (trim(Salutation), "x(3)") + 
   /* 21 */ " " +
   /* 22 */ string (MaritalStatus, "x(3)") +
            "   " +
   /* 24 */ string (PassType + "-" + Pass, "x(32)") +
   /* 25 */ fill (" ", 48) +
   /* 26 */ IsCountry + /* Alpha ISO-country code */
   /* 27 */ string (City, "x(15)") +
   /* 28 */ string (WorkPhone, "x(10)") +
            string (HomePhone, "x(10)") +
            string (WorkFax, "x(10)") +
   /* 31 */ "000001" +
   /* 32 */ string (BaseAddress[1], "x(48)") +
            string (BaseAddress[2], "x(48)") +
            string (BaseAddress[3], "x(48)") +
            string (BaseAddress[4], "x(48)") +
   /* 36 */ string (year(Birthday), "9999") +
            string (month(Birthday), "99") +
            string (day(Birthday), "99") +
   /* 37 */ string (BirthPlace, "x(32)") +
   /* 38 */ string (Position, "x(32)" ).

   put unformatted s0.

   /* 39 */ /* client acc = (private "PCA5", corporate "CCA5" */
   if substring(ClientMType, 1, 1) = "1" then
   do:  /* client */
      if IsPrivate then s0 = string ("PCA5", "x(24)").
                   else s0 = string ("CCA5", "x(24)").
   end.
   else /* card */ s0 = string(ConType, "x(24)").   /* вставить выбор subtypes for ...card... ???????????? */

      put unformatted s0.

   s0 =  
   /* 40 */ string (ContractNum, "x(24)") .
   
   /* 41 */ if ClientMType = "1" then s0 = s0 + string (RBScode, "x(32)").
                                 else s0 = s0 + fill (" ", 32). 

   /* 42 */ if ClientMType <> "1" then s0 = s0 + string (RBScode, "x(32)"). 
                                  else s0 = s0 + fill (" ", 32). 

   put unformatted s0.
            
   /* 43 */ /* string (AcntScheme, "x(6)")*/ /* "A03653" + */

   /*
   if ClientMType = "0" then s0 = "      ".
   else do:   
   if IsCrc = "398" then  s0 = "A03653".
       else do: 
                if IsPrivate then do:
                                    if IsResident then s0 = "A03655".
                                                  else s0 = "A03657".
                                  end.
                             else do:
                                    if IsCredit then s0 = "A03648".
                                                else s0 = "A03649".
                                  end.
            end.
   end.
   */
   s0 = string (AccSch, "x(6)").
   put unformatted s0.

   /* 44 */ /* string (CardService, "x(6)") + */ /* "S05816" + */
   /*
   if ClientMType <> "0" then
            do:
                if IsPrivate then s0 = "S05815".
                             else s0 = "S05790".
            end.
       else do:
                if IsPrivate then s0 = "S05816".
                             else s0 = "S05791".
            end.
   */
    s0 = string (ServPack, "x(6)").
   put unformatted s0.

s0 = 
   /* 45 */ "Y" + 
   /* 46 */ string (IsCrc, "x(3)").
s0 = s0 + 
   /* 47 */ string (CrLimit, "9") +
   /* 48 */ string (CrLimitSum, "99999999999999").
s0 = s0 +
   /* 49 */ string (ConExpDate, "x(8)") +
   /* 50 */ " " +
   /* 51 */ string (CarExpDate, "x(4)") +
   /* 52 */ string ("/" +
                    trim(NameEmb) + "/" +
                    trim(SurnameEmb), "x(26)") +
   /* 53 */ string (Embossing, "x(32)") + 
   /* 54 */ string (ContInfo, "x(32)") +
   /* 55 */ fill (" ", 25) +
            string (pvv, "x(4)") +
            string (cvc1, "x(3)") +
            string (cvc2, "x(3)") +
            string (pinenc, "x(16)") +
   /* 60 */ string (pinform, "x(2)") +
            "            " +
            " " +
   /* 63 */ "      " +
   /* 64 */ "  " +
            " " +
            "                " +
            string (0, "999999999999999") +
            fill (" ", 32) +
            "        " + 
            " " +
            fill (" ", 10) +
   /* 72 */ " " +
   /* 73 */ " " +
   /* 74 */ "      " +
   /* 75 */ fill ("0", 15) +
            fill ("0", 6) +
   /*    */ " " +
   /*    */ " " +
   /*    */ "      " +
   /*    */ fill ("0", 15) +
            fill ("0", 6) +
   /*    */ " " +
   /*    */ " " +
   /*    */ "      " +
   /*    */ fill ("0", 15) +
   /* 86 */ fill ("0", 6) +
            "        " +
            "        " +
            "     " +
            fill (" ", 32) +
            "   " +
            "   " +
            "   " +
   /* 94 */ "  " +
            fill (" ", 24) +
            "        " +
            "     " +
            fill (" ", 32) +
   /* 99 */ fill (" ", 50) +
            fill (" ", 7) +
   /* 102*/ string (vrnn, "x(255)") +
            fill (" ", 1067) +
   /* 121*/ string (Zipcode, "x(32)") +
            fill (" ", 623) +
            "*" + crlf.

   put unformatted s0.

end.



procedure Copyfile.

      bwxdir = "\\\\ntmain\\capital\$\\Users\\Departments\\Bwx\\Issue_in\\".
      find first bookcod where bookcod = 'cardaccs' and bookcod.code = 'bwxdira' no-lock no-error.
      if avail bookcod then bwxdir = TRIM(bookcod.name).        
      else message "Не найден код BWXDIR в справочнике CARDACCS пункт 4.6.1" view-as alert-box title "П Р Е Д У П Р Е Ж Д Е Н И Е".
    /*  bwxdir = '/home/u00118/Instant/in/'. */
      unix silent value("cat rpt.img | /pragma/bin9/koi2win >" + file-name ).
      rcd = unix_s("rcp " + file-name + " " + bwxdir).
      if rcd <> "" then message "Ошибка копирования BWX файла \n" + file-name + "\n" + rcd.
/*      unix silent value ("rm  " + file-name).*/
      run mail("instant@elexnet.kz", "", "Application file " + file-name, "Создан Application file " + file-name, "1", "", "").
      
      message skip(1) " ФАЙЛ " + file-name  + " ОТПРАВЛЕН В ABN-AMRO !" skip(1) view-as alert-box title "О Т П Р А В К А".

end.