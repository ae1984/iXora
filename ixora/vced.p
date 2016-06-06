/* vced.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        26.05.2008 galina - автоматическая прогрузка изменений в ЦО на филиалы
                             удалеие сочитание клавишь Ctrl+D
        27.05.2008 galina - перекопеляция
        30.05.2008 galina - исправлена ошибка при синхронизации изменений на филиалы
        02/11/2010 galina - редактирование стправочников только из ЦО
        12.04.2011 damir  - добавил message "Синхронизация"
*/

/* vced.p Валютный контроль
   Редактирование разных справочников

   18.10.2002 nadejda создан
*/

{global.i}
{comm-txb.i}

def input parameter v-title as char.
def input parameter v-codif as char.

define variable s_rowid as rowid.
def temp-table t-codfrold like codfr.
def var v-chng as logical.
def var v-bank as char.
def var v-center as logical.
def var v-del as logical init no.

v-bank = comm-txb().

find txb where txb.bank = v-bank and txb.consolid no-lock no-error.
v-center = not txb.is_branch.

{jabrw.i
&start     = "displ v-title format 'x(50)' at 15 with row 4 no-box no-label frame vcheader."
&head      = "codfr"
&headkey   = "code"
&index     = "cdco_idx"

&formname  = "vced"
&framename = "vced"
&where     = " codfr.codfr = v-codif and codfr.code <> 'msc' "

&addcon    = "v-center"
&deletecon = "v-center"
&prevdelete = " v-del = not vans."
&postcreate = "codfr.codfr = v-codif. codfr.level = 1."
&prechoose = "displ '<F4>- выход,  <INS>- вставка,  <Ctrl+D>- удалить,  <P>- печать'
  with centered row 22 no-box frame vcfooter."

&postdisplay = " "
&display   = " codfr.code codfr.name[1] "
&highlight = " codfr.code  "
&preupdate = " buffer-copy codfr to t-codfrold.
               if v-center then repeat:"
&update   = "  codfr.code codfr.name[1]"
&postupdate = " if codfr.code <> '' then leave.
         else message 'Нельзя вводить пустое значение!' view-as alert-box. end.
         codfr.codfr = v-codif. codfr.level = 1.
         codfr.tree-node = codfr.codfr + CHR(255) + codfr.code.
         if not (codfr.code = '' and  t-codfrold.code = '') then run upd-after. "

&postkey   = "else if keyfunction(lastkey) = 'P' then
                      do:
                         s_rowid = rowid(codfr).
                         output to vcdata.img .
                         for each codfr where codfr.codfr = v-codif no-lock:
                             display codfr.code codfr.name[1].
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('vcdata.img').
                         find codfr where rowid(codfr) = s_rowid no-lock.
                      end. "

&end = "hide frame vced. hide frame vcheader. hide frame vcfooter."
}
hide message.

/* переписать важные изменения с головного на филиалы */
  if(v-chng or (v-del and v-center)) then do:
    if connected ("txb") then disconnect "txb".
     hide message no-pause.
     message "Синхронизация изменений с филиалами...".
    for each txb where txb.is_branch and txb.consolid no-lock:
      connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
      run vcfil1(v-codif).
      disconnect "txb".
    end.
  end.


procedure upd-after.
  v-chng = v-center and
    (codfr.code <> t-codfrold.code or codfr.name[1] <> t-codfrold.name[1]).
end procedure.





