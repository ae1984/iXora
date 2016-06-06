/* vcvstran.p
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
        11.04.2011 damir программа полностью изменена, с возможностью редактирования и синхронизацией с филиалами.

*/

/* vcvknp.p Валютный контроль
   Просмотр справочника кодов стран
* BASES
        COMM BANK


   18.10.2002 nadejda создан

*/

{vc.i}
{mainhead.i}
{comm-txb.i}
def buffer b_codfr for codfr.
def var v-codfr as char.
def var codemask as char.
def var codific-name as char.
def var v-name as char.
def var v-title as char init "Country ( Territories ) Codes".

v-codfr = "iso3166".
codemask = "*".

def var v-bank as char.
def var v-center as logical.
def var v-chng as logical.
def var v-del as logical.
def temp-table t-codfrold like codfr.
define variable s_rowid as rowid.

/*find first codific where codific.codfr = v-codfr no-lock no-error.
if available codific then codific-name = codific.name.*/

/*def temp-table t-ctry
  field code as char
  field name as char
  index main is primary unique name.

for each codfr where codfr.codfr = s-codfr and codfr.child = false
            and codfr.code <> "msc" and codfr.code matches codemask no-lock:
  create t-ctry.
  t-ctry.code = codfr.code.
  t-ctry.name = codfr.name[1].
end.*/

v-bank = comm-txb().

find first txb where txb.bank = v-bank and txb.consolid no-lock no-error.
v-center = not txb.is_branch.

{jabrw.i
&start       = " displ with title 'Country ( Territories ) Codes' /*format 'x(50)'*/ /*at 15 with row 4 no-box no-label*/ frame uni_help1."
&head        = " codfr"
&headkey     = " code"
&index       = " main"

&formname    = " vcvstran"
&framename   = " uni_help1"
&where       = " codfr.codfr = v-codfr and codfr.code <> 'msc' "
&addcon      = " v-center"
&deletecon   = " v-center"
&prevdelete  = " v-del = not vans."
&postcreate  = " codfr.codfr = v-codfr. codfr.level = 1."
&prechoose   = " displ '<F4>- выход,  <INS>- вставка,  <Ctrl+D>- удалить,  <P>- печать'
                 with centered row 22 no-box frame vcfooter."
&postdisplay = " "
&display     = " codfr.code codfr.name[1] "
&highlight   = " codfr.code  "
&preupdate   = " buffer-copy codfr to t-codfrold.
                 if v-center then repeat:"
&update      = " codfr.code codfr.name[1]"
&postupdate  = " if codfr.code <> '' then leave.
                 else message 'Нельзя вводить пустое значение!' view-as alert-box. end.
                 codfr.codfr = v-codfr. codfr.level = 1.
                 codfr.tree-node = codfr.codfr + codfr.name[2] + codfr.name[1].
                 if not (codfr.code = '' and  t-codfrold.code = '') then run upd-after. "
&postkey     = " else if keyfunction(lastkey) = 'P' then do:
                    s_rowid = rowid(codfr).
                    output to vcdata.img .
                    for each codfr where codfr.codfr = v-codfr no-lock:
                        display codfr.code codfr.name[1].
                    end.
                    output close.
                    output to terminal.
                    run menu-prt('vcdata.img').
                    find codfr where rowid(codfr) = s_rowid no-lock.
                 end. "
&end         =   "hide frame uni_help1."
}
hide message.

/* переписать важные изменения с головного на филиалы */
if(v-chng or (v-del and v-center)) then do:
    if connected ("txb") then disconnect "txb".
    hide message no-pause.
    message "Синхронизация изменений с филиалами...".
    for each txb where txb.is_branch and txb.consolid no-lock:
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
        run vcstran(v-codfr).
        disconnect "txb".
    end.
end.

procedure upd-after.
    v-chng = v-center and
    (codfr.code <> t-codfrold.code or codfr.name[1] <> t-codfrold.name[1]).
end procedure.



