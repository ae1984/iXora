/* q-reject.p
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
        23.08.04 sasco оптимизировал инклюдники из-за переполнения препроцессора
*/

{global.i}
{ps-prmt.i}
{lgps.i }
def var tra as cha .
def var i as int .
def var h as int .
def var v-tim as cha .
def var v-sqn like reject.t_sqn .
def var st-sqn like reject.t_sqn .
def new shared var v-ref like reject.ref .
def new shared var m-sqn like reject.t_sqn.

h = 16 .

def var v-cif like cif.cif .
def var v-date as  date .
def var s-ref like remtrz.ref.
def var s-sqn like remtrz.sqn  .



find first reject no-lock no-error .
if not avail reject then do:
display
" Нет отвергнутых платежей ! " with centered row 10 frame qq .
pause .
end.

  do:
  form
        reject.ref format 'x(35)' label " Ссылочный номер "
        reject.t_sqn  column-label "L_SQN" format 'x(8)'
         reject.whn label "Дата"
          v-tim label "Время"  reject.who LABEL "Исп." with title
          'Отвергнутые платежи' frame frm .
       {browpnp.i
        &h = "h"
        &where = "use-index rdt"
        &frame-phrase = "row 0 centered scroll 1 h down overlay "
        &first = "find last reject use-index rdt no-lock no-error .
         if not avail reject then cur = 0 . else do:
         cur = recid(reject) . i = 0 . repeat:
          find prev reject use-index rdt no-lock no-error . i = i + 1 .
          if avail reject then cur = recid(reject) .
          if i > 10 or not avail reject then leave .
         end. end. if cur = 0 then  return . "
        &predisp =
        " display  '<SPACE>-просмотр  <H>- история  F10 - удалить ' +
        ' < R,Q > - поиск по ссылке,L_SQN ' with centered row 21 no-box  .
        v-tim = string(reject.tim,'HH:MM') . "
        &seldisp = "reject.ref reject.t_sqn "
        &file = "reject"
        &disp = " reject.ref reject.t_sqn v-tim reject.whn reject.who  "
        &predelete = "
        color display message reject.t_sqn with frame frm  .
        v-sqn = reject.t_sqn . v-ref = reject.ref . {ps-prmtk.i} "
        &posdelete = " v-text = ' REJECT запись LASKA SQN = '
        + string(v-sqn) + ' из ' + v-ref + ' удалена . '. run lgps .  "

        &action = "   if keylabel(lastkey) = 'r' then do:
         update v-cif validate( v-cif ne '','') label 'Клиент'
         v-date  label 'Дата ' s-ref label 'Ссылка'
         with overlay centered side-label 1 column row 10 frame rr .
         s-sqn = v-cif + '.' + string(v-date,'99/99/9999') + '.' + s-ref .
         hide frame rr .
         find first reject where reject.ref = s-sqn no-lock no-error .
         if avail reject then do:
          cur = recid(reject) . leave . end . 
          else
         do: bell. message ' Запись не найдена ' . pause . end.
        end . 
        else if keylabel(lastkey) = 'q' then
        do: update st-sqn label ' SQN '
          with overlay centered side-label row 10 frame aa . hide frame aa .
         find first reject where reject.t_sqn = st-sqn no-lock no-error .
         if avail reject then do: cur = recid(reject) . leave. end.
         else do: bell. message ' Запись не найдена ' . pause . end.
       end. 
       else run ch__keys. "
        &addcon = "false"
        &updcon = "false"
        &delcon = "true"
        &retcon = "false"
       }
 end.

procedure ch__keys.
if keylabel(lastkey)  = ' ' then do:
         if reject.ref begins 'IBNK' then do :
          find sysc where sysc.sysc = 'IBHOST' no-lock no-error .
          if not avail sysc or sysc.chval = '' then do :
           message 'Ошибка ! Нет IBHOST записи в sysc файле ! ' .
           pause .
           return .
          end .
         if not connected('ib') then
          connect value(sysc.chval) no-error .
         if not connected('ib') then do :
          message 'Нет доступа к Inernet-Bank базе данных !' .
          pause .
         end .
         else do :
          run IBHview_ps(integer(reject.t_sqn)) .
         end .
        end .
        else
         if reject.ref begins 'BRANCH' then do:
         m-sqn = reject.t_sqn. run SVL_view. 
         end.
         else  do:
           if reject.ref  matches ('*rkb*') then do:
           m-sqn = reject.t_sqn. 
           run A_view.
           end.
          else do:
           tra = trim(reject.t_sqn).
           display ' Ж д и т е '
           with overlay row 19 centered frame www . pause 0 .
           unix silent value('larc -s ' + tra + ' -F f >  tmpqq_ps.img ').
           hide frame www. unix ps_less tmpqq_ps.img.
          end.
         end.
  end. 
  else if keylabel(lastkey)  = 'h'
   then     do: v-ref = reject.ref . run rejhis. end.   
end procedure.

