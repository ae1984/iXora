/* vceddoc.p
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
        26.05.2008 galina - автоматическая прогрузка изменений в ЦО на филиалы
                            удалеие сочитание клавишь Ctrl+D
        27.05.2008 galina - перекопеляция
        30.05.2008 galina - исправлена ошибка при синхронизации изменений на филиалы                              
*/

/* vceddoc.p Валютный контроль 
   Редактирование справочника типов документов

   18.10.2002 nadejda создан
*/

{mainhead.i VCEDFSOB}
/*26.05.2008*/
{comm-txb.i}

define variable s_rowid as rowid.
def var v-title as char init 'ТИПЫ ДОКУМЕНТОВ'.
def var v-codif as char init 'vcdoc'.

/*26.05.2008*/
def var v-bank as char.
def var v-center as logical.
def temp-table t-codfrold like codfr.
def var v-chng as logical.
def var v-del as logical init no.

v-bank = comm-txb().
find txb where txb.bank = v-bank and txb.consolid no-lock no-error.
v-center = not txb.is_branch.

{jabrw.i
&start     = "displ v-title format 'x(50)' at 16 with row 4 no-box no-label frame vcheader."
&head      = "codfr"
&headkey   = "code"
&index     = "codfr"

&formname  = "vceddoc"
&framename = "vced"
&where     = " codfr.codfr = v-codif and codfr.code <> 'msc' "

&addcon    = "true"
&deletecon = "true"
&prevdelete = " v-del = not vans."
&postcreate = "codfr.codfr = v-codif. codfr.level = 1."
&prechoose = "displ '<F4> - выход,  <INS> - вставка,  <Ctrl+D> - удалить,  <P> - печать' 
  with centered row 22 no-box frame vcfooter.
  on help of codfr.name[5] in frame vced do: run uni_help1('vctdoc', '*'). end.  "

&postdisplay = " "

&display   = " codfr.code codfr.name[2] codfr.name[1] codfr.name[5]"

&highlight = " codfr.code  "
/**26.05.2008*/
&preupdate = "buffer-copy codfr to t-codfrold. repeat: "
&update   = "  codfr.code codfr.name[2] codfr.name[1] codfr.name[5]"
&postupdate = " if codfr.code <> '' then leave. else message 'Нельзя вводиь пустое занчение!' view-as alert-box. end.  
          codfr.codfr = v-codif. codfr.level = 1. 
         codfr.tree-node = codfr.codfr + CHR(255) + codfr.code. 
         /*26.05.2008*/
          if not (codfr.code = '' and  t-codfrold.code = '') then run upd-after.
         "

&postkey   = "else if keyfunction(lastkey) = 'P' then 
                      do:
                         s_rowid = rowid(codfr).
                         output to vcdata.img .
                         for each codfr where codfr.codfr = v-codif no-lock:
                             display codfr.code codfr.name[1] codfr.name[5].
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('vcdata.img').
                         find codfr where rowid(codfr) = s_rowid no-lock.
                      end. "

&end = "hide frame vced. hide frame vcheader. hide frame vcfooter."
}
hide message.
/*26.05.2008*/
procedure upd-after.
  v-chng = v-center and
    (codfr.code <> t-codfrold.code or codfr.name[1] <> t-codfrold.name[1] or codfr.name[2] <> t-codfrold.name[2] or codfr.name[5] <> t-codfrold.name[5] ).
end procedure.

/* переписать важные изменения с головного на филиалы */ 
  if (v-chng or (v-del and v-center)) then do:
     hide message no-pause.
     message "Синхронизация изменений с филиалами...".
    if connected ("txb") then disconnect "txb".
    for each txb where txb.is_branch and txb.consolid  no-lock:
      connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password). 
      run vcfil1(v-codif).
      disconnect "txb".
    end.
  end.

  