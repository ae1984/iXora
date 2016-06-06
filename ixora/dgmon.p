/* dgmon.p
 * MODULE
        Мониторинг договоров - интерфейс
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
        23/10/2007 madiyar
 * BASES
        bank comm
 * CHANGES
        24/10/2007 madiyar - подправил размер фрейма - при компиляции портился
*/

{mainhead.i}

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

define query qt for dgmon.
define buffer b-dgmon for dgmon.
def var v-rid as rowid.
def var v-id as integer no-undo.

def var v-mlist as char no-undo.
def var v-remind as integer no-undo.
def var v-ok as logical no-undo.

def browse bt
    query qt no-lock
    display
        dgmon.id           label "nn" format ">>>9"
        dgmon.dt           label "ДатаДог" format "99/99/99"
        dgmon.contractor   label "Контрагент" format "x(22)"
        dgmon.subject      label "Предмет договора" format "x(41)"
        dgmon.deadline_dt  label "СрокДата" format "99/99/99"
        dgmon.deadline_day label "День" format ">>>>"
        dgmon.resp_person  label "Ответст" format "x(7)"
        dgmon.sts          label "Стс" format "x(1)"
        with 25 down centered title "ДОГОВОРА" no-labels /* no-box */.

define frame ft
    bt help " <Enter>-Редакт, <Ins>-Новый, <Ctrl+D>-Удалить, <F4>-Выход"
    skip(1)
with row 3 size 110 by 29 overlay no-label no-box.


define frame par
    skip(1)
    "Список рассылки:" v-mlist format "x(300)" help "Список вида 'idxxxxx,idyyyyy,idzzzzz,...'" view-as fill-in size 90 by 1 skip
    "Сообщение-напоминание за " v-remind format ">9" " дн. до срока" skip(1)
    with row 32 width 110 overlay no-label.


on "return" of bt in frame ft do:
   
    do transaction:
        if not avail dgmon then do:
            create dgmon.
            dgmon.id = 1.
            dgmon.bank = s-ourbank.
            
            v-mlist = ''.
            v-remind = 0.
            display v-mlist v-remind with frame par.
        end.
        
        bt:set-repositioned-row(bt:focused-row, "conditional").
        v-rid = rowid(dgmon).
        
        find first b-dgmon where b-dgmon.id = dgmon.id exclusive-lock.
        displ b-dgmon.id format ">>>9"
            b-dgmon.dt format "99/99/99"
            b-dgmon.contractor format "x(100)" view-as fill-in size 22 by 1
            b-dgmon.subject format "x(100)" view-as fill-in size 41 by 1
            b-dgmon.deadline_dt format "99/99/99"
            b-dgmon.deadline_day format ">>>>"
            b-dgmon.resp_person format "x(7)"
            b-dgmon.sts format "x(1)"
            with no-label overlay row bt:focused-row + 5 column 4 width 102 no-box frame fr2.
        
        
        update b-dgmon.dt with frame fr2.
        update b-dgmon.contractor with frame fr2.
        update b-dgmon.subject with frame fr2.
        update b-dgmon.deadline_dt with frame fr2.
        update b-dgmon.deadline_day with frame fr2.
        update b-dgmon.resp_person with frame fr2.
        update b-dgmon.sts help "Статус: (A)ctive или (I)dle" validate(b-dgmon.sts = 'A' or b-dgmon.sts = 'I',"Некорректный статус!") with frame fr2.
        update v-mlist with frame par.
        update v-remind with frame par.
        b-dgmon.mailing_list = v-mlist.
        b-dgmon.reminder = v-remind.
        b-dgmon.rdt = g-today.
        b-dgmon.rwho = g-ofc.
        hide frame fr2.
        
        find current b-dgmon no-lock.
        
        open query qt for each dgmon where dgmon.bank = s-ourbank no-lock.
        
        reposition qt to rowid v-rid no-error.
        bt:refresh().
    end.
   
end. /* on "return" of bt */

on "insert-mode" of bt in frame ft do:
    find last b-dgmon use-index id no-lock no-error.
    if avail b-dgmon then v-id = b-dgmon.id + 1.
    else v-id = 1.
    
    do transaction:
        create dgmon.
        dgmon.id = v-id.
        dgmon.bank = s-ourbank.
        dgmon.sts = 'A'.
        
        bt:set-repositioned-row(bt:focused-row, "conditional").
        v-rid = rowid(dgmon).
        
        open query qt for each dgmon where dgmon.bank = s-ourbank no-lock.
        
        reposition qt to rowid v-rid no-error.
        bt:refresh().
        
        v-mlist = ''.
        v-remind = 0.
        display v-mlist v-remind with frame par.
        
    end.
    
    apply "return" to browse bt.
    
end.

on "delete-line" of bt in frame ft do:
    if avail dgmon then do:
        
        v-ok = no.
        message "Договор~n[контрагент]='" + dgmon.contractor + "'~n[предмет]='" + dgmon.subject + "'~nбудет удален. Продолжить?"
              view-as alert-box question buttons ok-cancel title "Внимание" update v-ok.
        if v-ok then do:
            
            v-id = dgmon.id.
            find first dgmon where dgmon.id > v-id no-lock no-error.
            if not avail dgmon then find last dgmon where dgmon.id < v-id no-lock no-error.
            if not avail dgmon then find first dgmon no-lock no-error.
            v-rid = rowid(dgmon).
            
            find first b-dgmon where b-dgmon.id = v-id.
            delete b-dgmon.
            
            find first dgmon no-lock no-error.
            if avail dgmon then do:
                open query qt for each dgmon where dgmon.bank = s-ourbank no-lock.
                reposition qt to rowid v-rid no-error.
                bt:refresh().
            end.
            else bt:refresh().
            
            if avail dgmon then do:
                v-mlist = dgmon.mailing_list.
                v-remind = dgmon.reminder.
            end.
            display v-mlist v-remind with frame par.
        end.
    end.
end.

on value-changed of bt in frame ft do:
    if avail dgmon then do:
        v-mlist = dgmon.mailing_list.
        v-remind = dgmon.reminder.
    end.
    display v-mlist v-remind with frame par.
end.

open query qt for each dgmon where dgmon.bank = s-ourbank no-lock.
enable bt with frame ft.
apply "value-changed" to browse bt.

wait-for window-close of current-window.
pause 0.

