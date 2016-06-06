/* jl-prcdl.p
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
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        30.07.2004 saltanat Внесены передаваемые параметры KOd,KBe,KNP.
        18/11/2011 evseev  - переход на ИИН/БИН
*/

/** jl-prcd.p **/

{chbin.i}
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
def var v-ind1 as int.
def var v-ind2 as int.
def var v-ind3 as int.
{global.i}


define shared temp-table wf
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif.

define shared temp-table remfile
   field rem as character.

define variable rnn    as character format "x(20)".
define variable vv-cif like cif.cif.
define variable refn   as character.
define variable dtreg  as date format "99/99/9999".
define variable drek   as character extent 8 format "x(60)".
def var v-margin as char.

define shared temp-table ljl like jl.


find jh where jh.jh eq s-jh no-lock.
xin  = 0.
xout = 0.

if jh.sub eq "jou" then do:
   v_doc = jh.ref.
   find joudoc where joudoc.docnum eq v_doc no-lock no-error.
   refn  = joudoc.num.
   dtreg = joudoc.whn.
   find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
   if available aaa then do:
      find cif of aaa no-lock.
      vv-cif = cif.cif.
   end.
   else vv-cif = "".

   drek[1] =
       "Менеджер:                  Контролер:                       Кассир:".
   drek[2] = "Внес :     " + joudoc.info.
   drek[3] = "Получил  : " + joudoc.info.
   if joudoc.passp eq ? then drek[4] = "Пасп. ".
   else drek[4] = "Пасп. " + joudoc.passp.

   if (joudoc.dracctype eq "1" and joudoc.cracctype eq "2") or
      (joudoc.cracctype eq "1" and
      (joudoc.dracctype eq "2" or joudoc.dracctype eq "3")) then do:

      drek[5] = " Персон. код   " + joudoc.perkod.
   end.
   else if (joudoc.dracctype eq "1" and joudoc.cracctype eq "4") or
                (joudoc.cracctype eq "1" and joudoc.dracctype eq "4") then do:

      if v-bin then drek[5] = "ИИН   " + joudoc.perkod.
      else drek[5] = "РНН   " + joudoc.perkod.
   end.

   drek[6] = " Подпись :".
   drek[7] = "".
end.

if jh.sub eq "lon" then do:
    v_doc = jh.ref.
    find lon where lon.lon eq v_doc no-lock no-error.
    refn  = "".
    dtreg = jh.jdt.
    if available lon then do:
        find cif of lon no-lock.
        vv-cif = cif.cif.
        refn  = lon.lon.
    end.
    else vv-cif = "".

    drek[1] =
       "Менеджер:                  Контролер:                       Кассир:".
    find jl where jl.jh eq jh.jh and jl.ln eq 1 no-lock no-error.
    if index(jl.rem[5],"/ПОЛУЧАТЕЛЬ/") ne 0 then do:
        v-ind1 = index(jl.rem[5],"/ПОЛУЧАТЕЛЬ/") + 12.
        if index(jl.rem[5],"/ПАСПОРТ/") ne 0 then
        v-ind2 = index(jl.rem[5],"/ПАСПОРТ/"). else v-ind2 = 0.
        if index(jl.rem[5],"/ПЕРС.КОД/") ne 0 then
        v-ind3 = index(jl.rem[5],"/ПЕРС.КОД/"). else v-ind3 = 0.
        if v-ind2 gt v-ind1 then
        drek[3] = "Получил : " + substring(jl.rem[5],v-ind1, v-ind2 - v-ind1).
        else
        if v-ind3 gt v-ind1 then
        drek[3] = "Получил : " + substring(jl.rem[5],v-ind1, v-ind3 - v-ind1).
        else
        drek[3] = "Получил : " + substring(jl.rem[5],v-ind1).

        if v-ind2 ne 0 then do:
            v-ind2 = v-ind2 + 9.
            if v-ind3 gt v-ind2 then
            drek[4] = "Паспорт : " +
            substring(jl.rem[5],v-ind2, v-ind3 - v-ind2).
            else
            drek[4] = "Паспорт  :" + substring(jl.rem[5],v-ind2).
        end.
        if v-ind3 ne 0 and length(jl.rem[5]) ge v-ind3 + 10 then
        drek[5] = "Перс.код: " +
        substring(jl.rem[5],v-ind3 + 10).
        else drek[5] = "".
        /*
        drek[5] = "РНН   " + joudoc.perkod.
        */
    end.

    if index(jl.rem[5],"/ПЛАТЕЛЬЩИК/") ne 0 then do:
        v-ind1 = index(jl.rem[5],"/ПЛАТЕЛЬЩИК/") + 12.
        if index(jl.rem[5],"/ПАСПОРТ/") ne 0 then
        v-ind2 = index(jl.rem[5],"/ПАСПОРТ/"). else v-ind2 = 0.
        if index(jl.rem[5],"/ПЕРС.КОД/") ne 0 then
        v-ind3 = index(jl.rem[5],"/ПЕРС.КОД/"). else v-ind3 = 0.
        if v-ind2 gt v-ind1 then
        drek[2] = "Внес    : " + substring(jl.rem[5],v-ind1, v-ind2 - v-ind1).
        else
        if v-ind3 gt v-ind1 then
        drek[2] = "Внес    : " + substring(jl.rem[5],v-ind1, v-ind3 - v-ind1).
        else
        drek[2] = "Внес    : " + substring(jl.rem[5],v-ind1).

        if v-ind2 ne 0 then do:
            v-ind2 = v-ind2 + 9.
            if v-ind3 gt v-ind2 then
            drek[4] = "Паспорт : " +
            substring(jl.rem[5],v-ind2, v-ind3 - v-ind2).
            else
            drek[4] = "Паспорт  :" + substring(jl.rem[5],v-ind2).
        end.
        if v-ind3 ne 0 and length(jl.rem[5]) ge v-ind3 + 10 then
        drek[5] = "Перс.код: " +
        substring(jl.rem[5],v-ind3 + 10).
        else drek[5] = "".
        /*
        drek[5] = "РНН   " + joudoc.perkod.
        */
    end.

   drek[6] = "Подпись :".
   drek[7] = "".
end.


if jh.sub eq "rmz" then do:
   v_doc = jh.ref.

   find remtrz where remtrz.remtrz eq v_doc no-lock.
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
   drek[6] = " Подпись :".
   drek[7] = "".
end.


drek[8] = "КОД = " + KOd + "     КБе = " + KBe + "     КНП = " + KNP .

output to vou.img page-size 0.

{jl-prcdl.f}

output close.


    unix silent prit /*-t*/ vou.img.

    /*
    unix joe vou.img.
    */
    pause 0.

