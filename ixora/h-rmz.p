/* h-rmz.p
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
*/

/* h-remtrz.p */
{global.i}
{lgps.i }
def var h as int .
h = 12 .

def shared var s-remtrz like que.remtrz .
def var v-amt like remtrz.amt .
def var v-cif like cif.cif .
def var v-date as  date .
def var v-ref like remtrz.ref.
def var ourbank like remtrz.sbank.
def var v-sqn like remtrz.sqn  .

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись OURBANK в таблице SYSC!".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.


if m_pid ne "R" then do:

       {browpnp.i
        &h = "h"
        &where = "m_pid = que.pid and que.con ne ""F"" use-index fprc "
        &frame-phrase = "row 1 centered scroll 1 h down
/*        title ' Search: [A]mount,[R]eference,s[Q]n ---' +
        ' repeat [L]ast amount search ' overlay */ "
         &predisp = "find remtrz where remtrz.remtrz = que.remtrz
          no-lock no-error .
          /*
          display remtrz.sbank remtrz.rbank
          with row 17 . pause 0 .
          if avail que then display que.pid que.rcod que.con
          with row 17 . pause 0  . */ "

        &seldisp = "que.remtrz"
        &file = "que"
        &disp = "que.remtrz column-label ""Платеж""
         remtrz.source column-label ""Источник""
         remtrz.sqn format ""x(20)"" column-label ""Nr.""
         remtrz.ptype column-label ""Тип""
         remtrz.rdt column-label ""Рег.дата""
         remtrz.valdt1 column-label ""1Дата""
         remtrz.valdt2 column-label ""2Дата"" "
        &addupd = " que.remtrz "
        &upd    = "  "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &befret = " s-remtrz = que.remtrz .
                    frame-value = que.remtrz .
                    hide all . "
        &action = "
        if keylabel(lastkey) = 'a' or
          keylabel(lastkey) = 'l' then
        do:
        if keylabel(lastkey) = 'a' then do:
         update v-amt label ' Amount '
          with overlay centered side-label row 10 frame aa .
         hide frame aa .   end.
         find next remtrz where remtrz.amt = v-amt
        use-index amt
          no-lock no-error .
         if not avail remtrz then
          find first remtrz where remtrz.amt = v-amt
          use-index amt
          no-lock no-error .
         if avail remtrz
         then
         do:
          find first que where remtrz.remtrz = que.remtrz  no-lock .
          if m_pid = que.pid and que.con ne ""F""  then do:
          cur = recid(que) . leave . end .  end .
        end.

        else
        if keylabel(lastkey) = 'r' or
           keylabel(lastkey) = 'q'  then
        do:
        if keylabel(lastkey) = 'r'  then
         do:
         update v-cif validate( v-cif ne '','') label 'CIF '
         v-date  label 'DATA '
         v-ref label 'REFEF '
         with overlay centered side-label 1 column row 10 frame rr .
         v-sqn =
         v-cif + '.' + string(v-date,'99/99/9999') + '.' + v-ref .
         end.
         else
         update v-sqn validate( v-sqn ne '','') label 'SQN '
         with overlay centered side-label 1 column row 10 frame rr .
         hide frame rr .
         find first remtrz where remtrz.sbank =
         trim(ourbank) and remtrz.sqn = v-sqn
         use-index sbnksqn no-lock no-error .
         if avail remtrz then
         do:
          find first que where remtrz.remtrz = que.remtrz  no-lock .
          if m_pid = que.pid and que.con ne ""F""  then do:
          cur = recid(que) . leave . end .  end.
         else
         do:
          bell.
          message ' Record wasn''t found ' . pause .
         end.
        end .
        "
       }

end.
else if m_pid = "R" then
   do:
    run h-remtrzR.
   end.
