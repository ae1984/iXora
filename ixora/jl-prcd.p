/* jl-prcd.p
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
        25.08.2003 sasco Печать менеджер, контроллер, кассир, клиент для пл. карточек (jh.party = "bwx")
        03.02.2004 sasco Печать внес, менеджер, контроллер, кассир для подотчетов кассиров (jh.party = "cas")
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        30.07.2004 saltanat Внесены передаваемые параметры KOd,KBe,KNP.
        11.07.2005 dpuchkov- добавил формирование корешка
        17.10.2005 dpuchkov добавил дату выдачи паспорта.
        29.09.09 marinav - при метроэкспресс добавлен вывод РНН
        06.01.10   marinav - вывод фамилии РНН паспорта КНП
        20.04.2010 marinav -  на печать выводить jh.jdt вместо jh.whn
        27.05.2011 damir - проверил.
        18/11/2011 evseev  - переход на ИИН/БИН
        31/10/2012 madiyar - 1858 -> 1858,1859,2858,2859
*/
{chbin.i}
{convgl.i "bank"}

def input parameter KOd as char.
def input parameter KBe as char.
def input parameter KNP as char.

define variable v_doc as character format "x(10)".

def shared var s-jh like jh.jh.
def var xin  as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "ПРИХОД ".
def var xout as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "РАСХОД  ".
def var sxin  like xin.
def var sxout like xout.
def var intot  like xin.
def var outtot like xout.
{global.i}


define shared temp-table wf
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif.

define shared temp-table remfile
   field rem as character.

define variable rnn    as character format "x(20)".
define variable vv-cif like cif.cif.
define variable vv-type like cif.type.
define variable refn   as character.
define variable dtreg  as date format "99/99/9999".
define variable drek   as character extent 10 format "x(90)".
define variable drek1  as character extent 8 format "x(90)".

define shared temp-table ljl like jl.


find jh where jh.jh eq s-jh no-lock no-error.
dtreg = jh.jdt.

xin  = 0.
xout = 0.
vv-type = "".

define variable conve as logical.

conve = false.
for each ljl of jh no-lock:
    if isConvGL(ljl.gl) then do:
       conve = true.
       leave.
    end.
end.

if jh.sub eq "jou" then do:
   v_doc = jh.ref.
   find joudoc where joudoc.docnum eq v_doc no-lock no-error.
   refn  = joudoc.num.
   dtreg = joudoc.whn.
   find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
   if available aaa then do:
      find cif of aaa no-lock.
      vv-cif = cif.cif.
      vv-type = cif.type.
   end.
   else do:
      vv-cif = "".
   end.

   drek[1] = "Менеджер:                  Контролер:                       Кассир:".
   drek[2] = "Внес :    " + joudoc.info.
   drek[3] = "Получил : " + joudoc.info.
   if joudoc.passp eq ? then drek[4] = "Паспорт : ".
   else do:
        if string(joudoc.passpdt) = ? then
           drek[4] = "Паспорт : " + joudoc.passp.
        else
           drek[4] = "Паспорт : " + joudoc.passp + "  " + string(joudoc.passpdt).
   end.

   if v-bin then drek[5] = "ИИН     : " + joudoc.perkod.
   else drek[5] = "РНН     : " + joudoc.perkod.

   if vv-type = 'P' then do:
   drek[6] = "Подтверждаю: данная операция не связана с предпринимательской деятельностью, ".
   drek1[1] = "осуществлением мною валютных операций, требующих получения лицензии, " .
   drek1[2] = "регистрационного свидетельства, свидетельства об уведомлении, оформления " .
   drek1[3] = "паспорта сделки. " .
   drek1[4] = "Я согласен с предоставлением информации о данном платеже в " .
   drek1[5] = "правоохранительные органы и  Национальный Банк по их требованию. ".
   end.
   else drek[6] = "".
   drek[7] = "Подпись : ".

   /**************************************************************************/
   if conve = true then do:
      drek[1] = "Кассир:".
      drek[5] = "".
      drek[7] = "".
      if joudoc.info = "" then assign drek[2] = "" drek[3] = "" drek[4] = "".
   end.


end.

if jh.sub eq "rmz" then do:
   v_doc = jh.ref.

   find remtrz where remtrz.remtrz eq v_doc no-lock no-error.
   dtreg = remtrz.rdt.
   refn = substring (remtrz.sqn, 19).
   find aaa where aaa.aaa eq remtrz.dracc no-lock no-error.
   if available aaa then do:
      find cif of aaa no-lock.
      vv-cif = cif.cif.
   end.
   else vv-cif = "".

   drek[1] =
       "Менеджер:                  Контролер:                       Кассир:".
   drek[2] = "Внес :     " + remtrz.ord.

   if v-bin then drek[5] = "ИИН   " + substring(remtrz.ord, index(remtrz.ord, "/RNN/") + 5).
   else drek[5] = "РНН   " + substring(remtrz.ord, index(remtrz.ord, "/RNN/") + 5).
   drek[4] = "Паспорт : " .
   drek[7] = " Подпись :".
   drek[6] = "".
end.


/* sasco - для пополнений пластиковых карточек */
if jh.party = "BWX" then do:
   drek[1] = "".
   drek[4] = "Менеджер:                  Контролер:                       Кассир:".
   drek[5] = "." .   /* не стирать точку!  а то карточники растерзают из-за отсутствия пустой строчки*/
   drek[6] = "Клиент:     " .
   drek[7] = "".
end.

if jh.party = "CAS" then do:
   drek[1] = "".
   drek[4] = "Менеджер:                  Контролер:                       Кассир:".
   drek[5] = "." .   /* не стирать точку!  а то кассиры растерзают из-за отсутствия пустой строчки*/
   drek[6] = "Внес:     " .
   drek[4] = "Паспорт : " .
   drek[7] = "".
end.

if jh.party = "MXP" then do:
   drek[1] = "Менеджер:                  Контролер:                       Кассир:".
   drek[7] = " Подпись :".
   find first remfile. find next remfile. find next remfile.
   drek[2] = "Внес :    " + remfile.rem.
   drek[3] = "Получил : " + remfile.rem.
   find next remfile.
   drek[4] = "Паспорт : " + remfile.rem.
   find first translat where translat.jh = jh.jh no-lock no-error.
   if avail translat then do:
      if v-bin then drek[5] = "ИИН :  " + translat.rnn.
      else drek[5] = "РНН :  " + translat.rnn.
   end.
   find first r-translat where r-translat.jh = jh.jh no-lock no-error.
   if avail r-translat then do:
      if v-bin then drek[5] = "ИИН :  " + r-translat.acc.
      else drek[5] = "РНН :  " + r-translat.acc.
   end.

end.

if jh.party = "" then do:
   drek[1] = "Менеджер:                  Контролер:                       Кассир:".
   drek[7] = " Подпись :" .
   drek[2] = "Внес :    " .
   drek[3] = "Получил : " .
   drek[4] = "Паспорт : " .

end.

drek[8] = "КОД : " + KOd  .
drek[9] = "КБе : " + KBe .
drek[10] = "КНП : " + KNP .

output to vou.img page-size 0.

{jl-prcd.f}

output close.

    unix silent prit vou.img. /*-t vou.img.*/

    /* unix silent joe vou.img. */
    pause 0.
