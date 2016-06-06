/* jl-prcdt.p
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

 * BASES
        BANK COMM
 * CHANGES
        07.12.2011 Luiza создан по подобию jl-prcd.p
        22/12/2011 Luiza перекомпиляция в связи с изменениями jl-prcdt.f
        31/10/2012 madiyar - 1858 -> 1858,1859,2858,2859
*/

{convgl.i "bank"}

def input parameter KOd  as char.
def input parameter KBe  as char.
def input parameter KNP  as char.
def input parameter s-jh as inte.

def var xin  as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "ПРИХОД ".
def var xout as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "РАСХОД  ".
def var sxin  like xin.
def var sxout like xout.
def var intot  like xin.
def var outtot like xout.

define shared temp-table wf
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif.

define shared temp-table remfile
   field rem as character.

define variable rnn      as character format "x(20)".
define variable vv-cif   like cif.cif.
define variable vv-type  like cif.type.
define variable refn     as character.
define variable dtreg    as date format "99/99/9999".
define variable drek     as character extent 16 format "x(90)".
define variable drek1    as character extent 8 format "x(90)".
define variable v_doc    as character format "x(10)".


def shared temp-table ljl like jl.
def shared var g-officer  like ofc.ofc.


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

   drek[5] = "РНН     : " + joudoc.perkod.

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
   end.


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
   if avail translat then drek[5] = "РНН :  " + translat.rnn.
   find first r-translat where r-translat.jh = jh.jh no-lock no-error.
   if avail r-translat then drek[5] = "РНН :  " + r-translat.acc.

end.

if jh.party = "" then do:
   drek[1] = "Менеджер:                  Контролер:                       Кассир:".
   drek[7] = " Подпись :" .
   drek[2] = "Внес :    " .
   drek[3] = "Получил : " .
   drek[4] = "Паспорт : " .
end.

drek[8]  = "КОД : " + KOd .
drek[9]  = "КБе : " + KBe .
drek[10] = "КНП : " + KNP .

output to vou.img page-size 0.

{jl-prcdt.f}

output close.

unix silent prit vou.img.
pause 0.
