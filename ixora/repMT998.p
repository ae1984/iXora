/* repMT998.p
 * MODULE
       Платежная система
 * DESCRIPTION
        отчеты по уведомлениям и подтверждениям по откр/закр счетов ЮЛ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER

 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        23/07/2008 galina
 * BASES
        BANK COMM
 * CHANGES
    25.07.2008 galina - добавлен консолидированный отчет
    16.04.2009 galina - формирования отчета по изменению номера счета
    27.01.10 marinav - расширение поля счета до 20 знаков
    25/02/2013 zhasulan - ТЗ 1505 Добавлен подпункт "Консолидированный отчет по ЦОКам" для Алматы
*/
def input parameter p-reptype as integer.
def new shared var hasAccess as logical.
{global.i}

def var v-banks as char.
def new shared var v-bank as char.
def var v-bankname as char.
def var v-dep as char.
def var v-dep1 as integer.
def var v-departch as char.
def var v-sel as integer.
def var v-dat1 as date.
def var v-dat2 as date.
def var v-acc as char.
def var msg-err as char.

function chk-dep returns logical (p-dep as integer).
def var v-deplist as char.
  if connected ("txb") then disconnect "txb".
    find txb where txb.bank = v-bank and txb.consolid = true no-lock.
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') +  " -ld txb -U " + txb.login + " -P " + txb.password).
    run deplist(output v-deplist).
    disconnect "txb".
  if hasAccess and v-bank = "TXB16" then v-deplist = v-deplist + ",99".
  if p-dep = 0 then do:
     msg-err = "Необходимо выбрать структурное подразделение!".
     return false.
  end.
  if (p-dep > 0 and lookup(string(p-dep),v-deplist,',') = 0) then do:
      msg-err = " Неверный код структурного подразделения ".
      return false.
  end.
  return true.
end.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if sysc.chval = 'TXB00' then do:
/*выбор филиала банка*/
  if v-banks = " " then do:
      for each txb where txb.consolid = true no-lock:
        if v-banks <> " " then v-banks = v-banks + "|".
        v-banks = v-banks + txb.bank + " " + txb.info.
      end.
      v-banks = v-banks + "|ALL " + "Консолидировано".
  end.
  v-sel = 0.
  run sel2 (" ВЫБЕРИТЕ ФИЛИАЛ БАНКА ", v-banks, output v-sel).
  if v-sel = 0  then return.
  v-bank = trim(entry(1,(entry(v-sel,v-banks, '|')),' ')).
  v-bankname = trim(entry(2,(entry(v-sel,v-banks, '|')),' ')).
end.
else v-bank = sysc.chval.

v-dat1 = g-today.
v-dat2 = g-today.
v-dep1 = 0.
v-departch = " ".
v-acc = " ".

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then do:
   if lookup("p00136",trim(ofc.expr[1])) > 0 or lookup("p00121",trim(ofc.expr[1])) > 0 or lookup("p00171",trim(ofc.expr[1])) > 0 then hasAccess = true.
end.

if v-bank = "ALL" then do:
    form
      skip(1)
      v-dat1 label " Дата с" format "99/99/99"
      validate (v-dat1 <= g-today and v-dat1 <> ?, " Дата не может быть больше " + string (g-today) + " и не может быть пустой!")
      v-dat2 label " по " format "99/99/99"
      validate (v-dat2 <= g-today and v-dat2 <> ?, " Дата не может быть больше " + string (g-today) + " и не может быть пустой!") skip
      v-acc label " ИИК" format "x(20)"
      skip (1)
    with centered side-label width 70 row 5 title "ПАРАМЕТРЫ" frame f-par1.
    /*v-dep1 = 0.    */
    display v-dat1 v-dat2 with frame f-par1.
    update v-dat1 v-dat2 v-acc with frame f-par1.
end.

else do:
    form
      skip(1)
      v-dat1 label " Дата с" format "99/99/99"
      validate (v-dat1 <= g-today and v-dat1 <> ?, " Дата не может быть больше " + string (g-today) + " и не может быть пустой!")
      v-dat2 label " по " format "99/99/99"
      validate (v-dat2 <= g-today and v-dat2 <> ?, " Дата не может быть больше " + string (g-today) + " и не может быть пустой!") skip
      v-dep1 label " Департамент" format ">9"  help "F2 - справочник"
      validate (chk-dep(v-dep1),msg-err)
      v-departch format "x(50)" no-label skip
      v-acc label " ИИК" format "x(20)"
      skip (1)
    with centered side-label width 70 row 5 title "ПАРАМЕТРЫ" frame f-par.

/*    v-dep1 = 0.
    v-departch = " ".
    v-acc = " ".*/

    on help of v-dep1 in frame f-par do:
        if connected ("txb") then disconnect "txb".
        find txb where txb.bank = v-bank and txb.consolid = true no-lock.
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') +  " -ld txb -U " + txb.login + " -P " + txb.password).
        /**выбор СПФ соотвествующего филиала**/
        run dep(output v-dep1, output v-departch).
        disconnect "txb".
        display v-dep1 v-departch with frame f-par.
    end.

    display v-dat1 v-dat2 v-dep1 v-departch v-acc with frame f-par.
    update v-dat1 v-dat2 v-dep1 with frame f-par.

    if v-dep1 entered then do:
       if v-dep1 <> 99 then do:
          if connected ("txb") then disconnect "txb".
          find txb where txb.bank = v-bank and txb.consolid = true no-lock.
          connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') +  " -ld txb -U " + txb.login + " -P " + txb.password).
          run depch(v-dep1, output v-departch).
          disconnect "txb".
       end.
       else v-departch = "Консолидированный отчет по ЦОКам".
       display  v-departch with frame f-par.
    end.
    update v-acc with frame f-par.
end.
if v-dep1 = 99 then v-dep1 = 0.
case p-reptype:
  when 1 then run repMT998_in(v-bank,v-bankname, v-dep1, v-departch, v-dat1, v-dat2, trim(v-acc)).
  when 2 then run repMT998_out(p-reptype,v-bank,v-bankname, v-dep1, v-departch, v-dat1, v-dat2, trim(v-acc),"1").
  when 3 then run repMT998_out(p-reptype,v-bank,v-bankname, v-dep1, v-departch, v-dat1, v-dat2, trim(v-acc),"2").
  when 4 then run repMT998_out(4,v-bank,v-bankname, v-dep1, v-departch, v-dat1, v-dat2, trim(v-acc),"3").
end.
hide all no-pause.