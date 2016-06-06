/* pshact.p
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

def shared var v-amt like remtrz.amt .
def shared var v-cif like cif.cif .
def shared var v-date as  date .
def shared var v-ref like remtrz.ref.
def shared var v-sqn like remtrz.sqn  .
def shared var ourbank as cha .
def input-output paramet  v-cur as int .
{global.i}
{lgps.i}
        find remtrz where recid(remtrz) = v-cur .
        v-cur = 0 .
        if keylabel(lastkey) = 'С' or
          keylabel(lastkey) = 'П' then
        do:
        if keylabel(lastkey) = 'С' then do:
         update v-amt label ' Сумма '
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
          if ( m_pid = que.pid or m_pid = "PS_" ) and que.con ne "F"  then do:
          v-cur = recid(que) . return . end .  end .
        end.

        else
        if keylabel(lastkey) = 'К' or
           keylabel(lastkey) = 'Н'  then
        do:
        if keylabel(lastkey) = 'К'  then
         do:
         update v-cif validate( v-cif ne '','') label 'Клиент '
         v-date  label 'Дата '
         v-ref label 'Ссыл.Номер '
         with overlay centered side-label 1 column row 10 frame rr .
         v-sqn =
         v-cif + '.' + string(v-date,'99/99/9999') + '.' + v-ref .
         end.
         else
         update   
          v-sqn  format "x(40)" 
          validate( v-sqn ne '','') label 'Nr. '
         with overlay centered side-label 1 column row 10 frame rr .
         hide frame rr .
         find first remtrz where remtrz.sbank =
         substr(v-sqn,1,5) and remtrz.sqn = v-sqn
         use-index sbnksqn no-lock no-error .
         if avail remtrz then
         do:
          find first que where remtrz.remtrz = que.remtrz  no-lock .
          if ( m_pid = que.pid or m_pid = "PS_" ) and que.con ne "F"  then do:
          v-cur = recid(que) . return . end .  end.
         else
         do:
          bell.
          message 'Платеж не найден!' . pause .
         end.
        end .
        else
        if keylabel(lastkey) = 'Д'
         then do:
          if v-date eq ? then
          v-date = g-today .
         update
          v-date  label 'Дата '
          with overlay centered side-label 1 column row 10 frame rrd .

         if remtrz.rdt <= v-date then
         find next remtrz where remtrz.rdt >= v-date
          use-index rdt no-lock no-error .
         else
         find first remtrz where remtrz.rdt >= v-date
          use-index rdt no-lock no-error .
         if avail remtrz then do:
          find first que where remtrz.remtrz = que.remtrz  no-lock .
          if ( m_pid = que.pid or m_pid = "PS_" ) and que.con ne "F"  then do:
          v-cur = recid(que) . return . end .  end.
         else do: bell. message 'Платеж не найден!' . pause .
         end.
         end.
