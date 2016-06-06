/* jl-prcd1.p
 * MODULE
        Формирование ордеров при разгрузки терминалов
 * DESCRIPTION
        Формирование ордеров при разгрузки терминалов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        vou_bank3.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        jl-prcd1.f
 * MENU
        5-1-13
 * AUTHOR
        19.05.06 ten
 * CHANGES
        18/11/2011 evseev  - переход на ИИН/БИН
*/
{chbin.i}
def input parameter KOd as char.
def input parameter KBe as char.
def input parameter KNP as char.

define variable v_doc as character format "x(10)" no-undo.

def shared var s-jh like jh.jh no-undo.
def var xin  as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "ПРИХОД " no-undo.
def var xout as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "РАСХОД  " no-undo.
def var sxin  like xin no-undo.
def var sxout like xout no-undo.
def var intot  like xin no-undo.
def var outtot like xout no-undo.
{global.i}


define shared temp-table wf no-undo
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif.

define shared temp-table remfile no-undo
   field rem as character.

define variable rnn    as character format "x(20)".
define variable vv-cif like cif.cif.
define variable vv-type like cif.type.
define variable refn   as character.
define variable dtreg  as date format "99/99/9999".
define variable drek   as character extent 8 format "x(90)".
define variable drek1  as character extent 8 format "x(90)".

define shared temp-table ljl like jl.


find jh where jh.jh eq s-jh no-lock no-error.
dtreg = jh.whn.

xin  = 0.
xout = 0.
vv-type = "".
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

   drek[1] =
       "Менеджер:                  Контролер:                       Кассир:".
   drek[2] = "Внес :    " + joudoc.info.
   drek[3] = "Получил : " + joudoc.info.
   if joudoc.passp eq ? then drek[4] = "Паспорт : ".
   else do:
        if string(joudoc.passpdt) = ? then
           drek[4] = "Паспорт : " + joudoc.passp.
        else
           drek[4] = "Паспорт : " + joudoc.passp + "  " + string(joudoc.passpdt).
   end.

  /* if (joudoc.dracctype eq "1" and joudoc.cracctype eq "2") or
      (joudoc.cracctype eq "1" and
      (joudoc.dracctype eq "2" or joudoc.dracctype eq "3")) then do:

      drek[5] = "Персон. код:  " + joudoc.perkod.
   end.
   else if (joudoc.dracctype eq "1" and joudoc.cracctype eq "4") or
                 (joudoc.cracctype eq "1" and joudoc.dracctype eq "4") then do:

      drek[5] = "РНН   " + joudoc.perkod.
   end.*/
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
   /*if joudoc.passp eq ? then drek[4] = "Пасп. ".
   else drek[4] = "Пасп. " + joudoc.passp.*/


   if v-bin then drek[5] = "ИИН   " + substring(remtrz.ord, index(remtrz.ord, "/RNN/") + 5).
   else drek[5] = "РНН   " + substring(remtrz.ord, index(remtrz.ord, "/RNN/") + 5).
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
   drek[7] = "".
end.

drek[8] = "КОД = " + KOd + "     КБе = " + KBe + "     КНП = " + KNP .

output to vou.img page-size 0.

{jl-prcd1.f}

output close.

    unix silent prit vou.img. /*-t vou.img.*/

    /* unix silent joe vou.img. */
    pause 0.
