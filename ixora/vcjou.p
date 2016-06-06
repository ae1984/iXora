/*vcjou.p
 * MODULE
        Акцепт валютного контроля для внутренних платежей
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        19/03/2009 galina
 * BASES
        BANK
 * CHANGES
        17/11/2011 evseev - переход на ИИН/БИН. Кр и Др вывод бин у счетов
*/

{global.i}
{chbin.i}

define variable d_cif   like cif.cif.
define variable c_cif   like cif.cif.
define variable d_avail as character format "x(25)".
define variable c_avail as character format "x(25)".
define variable m_avail as character format "x(25)".
define variable d_atl   as character.
define variable c_atl   as character.
define variable m_atl   as character.
define variable d_lab   as character.
define variable d_izm   as character format "x(25)".
define variable dname_1 as character format "x(38)".
define variable dname_2 as character format "x(38)".
define variable dname_3 as character format "x(38)".
define variable cname_1 as character format "x(38)".
define variable cname_2 as character format "x(38)".
define variable cname_3 as character format "x(38)".

define variable db_com  as character format "x(10)".
define variable cr_com  as character format "x(10)".
define variable com_com as character format "x(10)".
define variable m_sub   as character initial "jou".
def buffer b-crc for crc.
def buffer bb-crc for crc.
define shared variable s-docnum   like joudoc.docnum.

define variable locrc1 as character format "x(3)".
define variable locrc2 as character format "x(3)".
define variable f-code  like crc.code.
define variable t-code  like crc.code.
def var v-cifname like cif.name no-undo.
def var v-njss as char no-undo.
def var v-nname as char no-undo.
def var v-nacc as char no-undo.
def var v-act as logical.
def var v_dres as integer.
def var v_cres as integer.
def var v_dresch as char format "x(38)".
def var v_cresch as char format "x(38)".
def var result as integer.
define variable pbal     like jl.dam no-undo.   /*Full balance*/
define variable pavl     like jl.dam no-undo.   /*Available balnce*/
define variable phbal    like jl.dam no-undo.   /*Hold balance*/
define variable pfbal    like jl.dam no-undo.   /*Float balance*/
define variable pcrline  like jl.dam no-undo.   /*Credit line*/
define variable pcrlused like jl.dam no-undo.   /*Used credit line*/
define variable pooo     like aaa.aaa no-undo.



define  frame f_main
"__________________ДЕБЕТ______________________________КРЕДИТ____________________" skip
    s-docnum label "ДОКУМЕНТ " help "SPACE BAR, ENTER - новый документ   "
    joudoc.num label "ДОК.Nr." at 23
    joudoc.chk at 48 label "ЧЕК  Nr." format "9999999"
    joudoc.jh label "ТРН" at 66
        skip
    db_com no-label
    help "СТРЕЛКА ВНИЗ/ВВЕРХ - выбор, ENTER - дальше "
    joudoc.dracc at 16 no-label
    d_cif at 33 no-label
    cr_com at 41 no-label
    help "СТРЕЛКА ВНИЗ/ВВЕРХ - выбор, ENTER - дальше "
    joudoc.cracc at 56 no-label
    c_cif at 72 no-label skip
    d_atl no-label d_avail at 13 no-label skip
    d_lab no-label d_izm at 13 no-label skip
    dname_1 no-label  cname_1 at 41 no-label skip
    dname_2 no-label  cname_2 at 41 no-label skip
    dname_3 no-label  cname_3 at 41 no-label skip
    v_dresch no-label   v_cresch at 41 no-label skip
    joudoc.drcur label "ВАЛЮТА"
        validate (can-find (crc where crc.crc eq joudoc.drcur),
        "КОД ВАЛЮТЫ НЕ НАЙДЕН.")
    crc.des format "x(27)" no-label
    joudoc.crcur  at 41 label "ВАЛЮТА"
        validate (can-find (b-crc where b-crc.crc eq joudoc.crcur),
        "КОД ВАЛЮТЫ НЕ НАЙДЕН.")
    b-crc.des format "x(24)" no-label                                skip
    joudoc.dramt format "zzz,zzz,zzz,zz9.99" label "СУММА"
    joudoc.cramt format "zzz,zzz,zzz,zz9.99" at 41 label "СУММА"    skip
    joudoc.brate format "999.9999" label "КУРС ПОКУП"
    locrc1 no-label
    "/" joudoc.bn format "zzzzzzz" no-label space(1) f-code no-label
    joudoc.srate format "999.9999" at 41 label "КУРС ПРОД."
    locrc2 no-label
    "/" joudoc.sn format "zzzzzzz" no-label space(1) t-code no-label
    joudoc.remark[1] label "ПРИМЕЧ."
    joudoc.remark[2] no-label at 10
"______________________________________________________________________________"
    skip
    joudoc.comcode label "КОД КОМИССИИ  "
    tarif2.pakalp no-label format "x(54)" skip
    com_com no-label
    help "СТРЕЛКА ВНИЗ/ВВЕРХ - выбор, ENTER - дальше "
    joudoc.comacc  at 16 /*format "x(16)"*/ no-label
    joudoc.comcur at 41 label "ВАЛЮТА"
    bb-crc.des format "x(24)"
    no-label skip
    m_atl no-label m_avail at 13 no-label
    joudoc.comamt format "z,zzz,zzz,zz9.99" at 41 label "СУММА" skip
    "ПЛАТА ЗА ОбНАЛИЧИВАНИЕ:" joudoc.nalamt no-label
    format "z,zzz,zzz,zz9.99" "(код тарифа 409)"
     with row 4 side-labels no-box.


find joudoc where joudoc.docnum eq s-docnum no-lock no-error.
if not available joudoc then do:
   message "ДОКУМЕНТ НЕ НАЙДЕН.".
   pause 3.
   undo, return.
end.

run chk_valcon(joudoc.docnum, output v_dres, output v_cres, output result).
if v_dres > 1 then v_dresch = "Нерезидент".
else v_dresch = "Резидент".
if v_cres > 1 then v_cresch = "Нерезидент".
else v_cresch = "Резидент".

display s-docnum joudoc.num joudoc.jh joudoc.chk with frame f_main.

if joudoc.drcur ne 0 then do:
   find crc where crc.crc eq joudoc.drcur no-lock  no-error.
   display crc.des with frame f_main.
end.
if joudoc.crcur ne 0 then do:
   find b-crc where b-crc.crc eq joudoc.crcur no-lock  no-error.
   display b-crc.des with frame f_main.
end.

find jounum where jounum.num eq joudoc.dracctype no-lock no-error.
if available jounum then db_com = jounum.num + "." + jounum.des.

find jounum where jounum.num eq joudoc.cracctype no-lock no-error.
if available jounum then cr_com = jounum.num + "." + jounum.des.

d_cif = "". c_cif = "".
dname_1 = "". dname_2 = "". dname_3 = "".
cname_1 = "". cname_2 = "". cname_3 = "".
if joudoc.dracc ne "" then do:
  find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
  if available aaa then do:
    find cif where cif.cif eq aaa.cif no-lock no-error.
    d_cif = cif.cif.
    v-cifname = trim(trim(cif.prefix) + " " + trim(cif.name)).
    dname_1 = substring(v-cifname,  1, 38).
    dname_2 = substring(v-cifname, 39, 38).
    if v-bin then dname_3 = substring(v-cifname, 77, 17) + " (" + cif.bin + ")".
    else dname_3 = substring(v-cifname, 77, 17) + " (" + cif.jss + ")".
    run aaa-bal777 (input aaa.aaa, output pbal, output pavl, output phbal, output pfbal, output pcrline, output pcrlused, output pooo).
    d_avail = string (pbal, "z,zzz,zzz,zzz,zzz.99").
    d_izm   = string (pavl, "z,zzz,zzz,zzz,zzz.99").
    d_atl = "СЧТ-ОСТ".
    d_lab = "ИСП-ОСТ".
    display d_avail d_izm d_atl d_lab with frame f_main.
  end.
end.
if joudoc.cracc ne "" then do:
  find aaa where aaa.aaa eq joudoc.cracc no-lock no-error.
  if available aaa then do:
     find cif where cif.cif eq aaa.cif no-lock.
     c_cif = cif.cif.
     v-cifname = trim(trim(cif.prefix) + " " + trim(cif.name)).
     cname_1 = substring(v-cifname,  1, 38).
     cname_2 = substring(v-cifname, 39, 38).
     if v-bin then cname_3 = substring(v-cifname, 77, 17) + " (" + cif.bin + ")".
     else cname_3 = substring(v-cifname, 77, 17) + " (" + cif.jss + ")".
  end.
end.

display joudoc.dramt joudoc.dracc joudoc.drcur joudoc.cramt
        joudoc.cracc joudoc.crcur locrc1 locrc2 joudoc.brate
        joudoc.bn joudoc.remark[1] joudoc.chk joudoc.srate joudoc.sn
        joudoc.remark[2] db_com cr_com joudoc.num d_cif dname_1
        dname_2 dname_3 c_cif cname_1 cname_2 cname_3 v_dresch v_cresch
        with frame f_main.
color display input dname_1 dname_2 dname_3 cname_1 cname_2 cname_3 v_dresch v_cresch with frame f_main.
if joudoc.comcode ne "" then do:
  find jounum where jounum.num eq joudoc.comacctype no-lock no-error.
  if available jounum then com_com = jounum.num + "." + jounum.des.

  if joudoc.comcur ne 0 then do:
    find bb-crc where bb-crc.crc eq joudoc.comcur no-lock no-error.
    display bb-crc.des with frame f_main.
  end.

  find tarif2 where tarif2.num + tarif2.kod eq joudoc.comcode and tarif2.stat = 'r' no-lock no-error.
  display joudoc.comcode tarif2.pakalp com_com joudoc.comacc joudoc.comcur joudoc.comamt joudoc.nalamt with frame f_main.
end.
else do:
  display joudoc.comcode "" @ tarif2.pakalp com_com "" @ crc.des joudoc.comacc joudoc.comcur joudoc.comamt joudoc.nalamt  with frame f_main.
end.


define button b1 label "Акцепт".
define frame a b1 with side-labels row 3 centered no-box.
on choose of b1 in frame a do:
   find joudoc where joudoc.docnum eq s-docnum no-lock no-error.
   if avail joudoc then do:

     if joudoc.rescha[2] <> "" then
       message skip "Палетеж уже акцептован!"
       view-as alert-box title " ВНИМАНИЕ ! ".
     else do:
       v-act = false.
       message skip "Акцептовать платеж?"
       view-as alert-box error buttons yes-no title " ВНИМАНИЕ ! " update v-act.
       if v-act then do:
         find current joudoc exclusive-lock.
         joudoc.rescha[2] = g-ofc + "," + string(g-today,'99/99/9999').
        find current joudoc no-lock.
        message "Платеж акцептован!" view-as alert-box.
       end.
     end.

   end.
end.
view frame a.
enable b1 with frame a.
wait-for choose of b1 or window-close of current-window.