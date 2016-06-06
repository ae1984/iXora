/* cods.p
 * MODULE
        Справочник кодов доходов/расходов операций
 * DESCRIPTION
        Справочник кодов доходов/расходов операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6-14-1
 * BASES
        BANK COMM
 * AUTHOR
        29/04/05 nataly
 * CHANGES
        29.04.05 nataly - программа переписана под jabrcods.i - добавлен поиск по коду и счету ГК, печать справочника
        16.05.05 nataly  - добавлен признак автоматического проставления кода cods.lookaaa = yes
        04.01.06 nataly -  для счетов доходов добавила проверку на код комиссии
        23/01/06 nataly -  добавлен признак архивности
        29.04.2011 damir - возможность изменения справочника только с базы ЦО, также синхронизация изменений с другими филиалами.
                           также добавление нового кода.
                           поменял jabrcods.i на apbra1.i та глючила.
        27.05.2011 damir - исправил ошибки возникшие при компиляции.
        01.06.2011 damir - RX.dbrefs изменил базу TXB на COMM.
        28.04.2012 damir - перекомпиляция.
        28.05.2012 damir - формат лог.переменных "да/нет".
        27.06.2012 damir - убрал validate для лог.переменных..
*/

{mainhead.i SSGEN}
{comm-txb.i}

for each cods where cods.code = "" exclusive-lock:
    delete cods.
end.

form cods.des VIEW-AS EDITOR SIZE 57 by 10
with frame y  overlay  row 14  centered top-only no-label.

define variable s_rowid as rowid.

define variable s-mask as character format "x(20)" initial "*".

define variable s-entries as character initial "".
define variable srch as character format "x(40)" label "Строка поиска" initial "".
define variable srch2 as character.

def temp-table t-cods like cods.

def var v-bank as char.
def var v-center as logical.
def var v-chng as logical.
def var v-txb00 as char.
def var v-del as logical init no.
def var i as integer init 0.

def buffer b-cods for cods.

/*{headln-w.i */

v-bank = comm-txb().
find first txb where txb.bank = v-bank and txb.consolid no-lock no-error.
if avail txb then  v-center = not txb.is_branch.


{apbra1.i

&start     = " "
&head      = " cods"
&headkey   = " code"
&index     = " codegl_id"
&formname  = " cods"
&framename = " cods"
&where     = " cods.code matches s-mask and (s-entries = '' or lookup(cods.code, s-entries) > 0)"
&addcon    = " true"
&deletecon = " false"
&prevdelete = " v-del = not vans."
&precreate = " "
&postadd   = " buffer-copy cods to t-cods.
               if v-center then do:
                   update
                   cods.code validate(code ne '','')
                   cods.dep  validate(can-find(codfr no-lock where codfr.codfr = 'sdep' and codfr.code = cods.dep  ) or cods.dep = '000' ,
                   'Подразделение не найдено! ')
                   cods.gl validate(can-find( gl no-lock where gl.gl = cods.gl) or cods.gl = 0   , 'Счет ГК не найден! ')
                   cods.acc validate(can-find( dfb  no-lock where dfb.dfb = cods.acc) or can-find( tarif2  no-lock where tarif2.num +
                   tarif2.kod = cods.acc) or cods.acc = ' ', ' Корр счет не найден или неверный код комиссии! ')
                   cods.lookaaa help 'да - Определить код депар-та по счету, нет - задать код с клав.' with frame cods.
                   update cods.des with frame y.
                   update cods.arc help 'да - код архивный, нет - активный' with frame cods.
               end.
               if not (cods.code = '' and t-cods.code = '') then run codsupd-after.

             "
&prechoose = " message 'F4-Выход,INS-Вставка,P-Печать,F-Поиск по коду,Ctrl-F Поиск по ГК,D-Показать все'."
&postdisplay = " "
&display   = " cods.code cods.dep cods.gl cods.acc cods.lookaaa cods.des cods.arc"
&highlight = " cods.code"
&postkey   = "
               else if keyfunction(lastkey) = 'RETURN' then do:
                   buffer-copy cods to t-cods.
                   if v-center then do:
                       update
                       cods.code validate(code ne '','')
                       cods.dep  validate (can-find(codfr no-lock where codfr.codfr = 'sdep' and codfr.code = cods.dep  ) or cods.dep = '000' ,
                       'Подразделение не найдено! ')
                       cods.gl validate (can-find( gl no-lock where gl.gl = cods.gl) or cods.gl = 0   , 'Счет ГК не найден! ')
                       cods.acc validate (can-find( dfb  no-lock where dfb.dfb = cods.acc) or can-find( tarif2  no-lock where tarif2.num +
                       tarif2.kod = cods.acc) or cods.acc = ' ', ' Корр счет не найден или неверный код комиссии! ')
                       cods.lookaaa help 'да - Определить код депар-та по счету, нет - задать код с клав.' with frame cods.
                       update cods.des with frame y.
                       update cods.arc help 'да - код архивный, нет - активный' with frame cods.
                   end.
                   if not (cods.code = '' and t-cods.code = '') then run codsupd-after.
               end.
                "

&end = "hide frame cods. hide frame y."
}

hide message.

procedure do_sysc_search.

     update srch with side-labels color messages overlay row 5 centered frame srchfr.
     hide frame srchfr.
     s-entries = ''.

     if srch <> '' then do: /* создадим строку с найденными sysc */
        srch = '*' + trim (srch) + '*'.
        for each cods no-lock:
            srch2 = ''.
            srch2 = srch2 + string(cods.gl).
            if srch2 matches srch then s-entries = s-entries + cods.code + ','.
        end.
     end.
     if s-entries = '' then message 'Не найдены записи в cods по строке ' skip srch skip
                'Возврат к default по маске~n' s-mask view-as alert-box title ''.
     else
     if s-mask <> '*' then message 'Внимание!~nНайденные записи в cods показаны~nсогласно маске~n' +
                           s-mask view-as alert-box title "".

end procedure.

procedure codsupd-after.

    v-chng = v-center and
    (cods.code <> t-cods.code or cods.dep <> t-cods.dep or cods.gl <> t-cods.gl or cods.acc <> t-cods.acc or
    cods.lookaaa <> t-cods.lookaaa or cods.des <> t-cods.des or cods.arc <> t-cods.arc).

end.

if (v-chng  or (v-del and v-center))  then do:
    if connected ("txb") then disconnect "txb".
    message 'Синхронизация изменений с филиалами...'.
    for each txb where txb.is_branch and txb.consolid no-lock:
        if connected ("txb") then  disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
        run cods2fil(cods.code).
        disconnect "txb".
    end.
end.


