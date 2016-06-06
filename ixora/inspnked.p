/* inspnked.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        редактирование справочника инспекторов НК
 * RUN
                      Способ вызова программы, описание параметров, примеры вызова.
        из меню
 * CALLER

 * SCRIPT
        Список скриптов, вызывающих этот файл
        нет
 * INHERIT
        Список вызываемых процедур
        нет
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        6.06.2003 u00568 evgeniy
 * CHANGES
        16.08.2003 u00568 evgeniy - выкладываю
*/


{comm-txb.i}
{yes-no.i}

define variable seltxb as integer init 0 no-undo.
seltxb = comm-cod ().

def var nk_name as char format "x(30)" no-undo.


define query q_inspectors_nk for inspectors_nk, taxnk.
def var rid as rowid no-undo.

def browse bq_inspectors_nk
     query q_inspectors_nk no-lock
     displ inspectors_nk.fio label "ФИО"
           inspectors_nk.num_certificate label "серт N"
           taxnk.name label "НК"
           with 13 down title "Редактирование".


/*----------------------*/
procedure open_query:
  DEFINE INPUT PARAMETER  vlocate as log no-undo.
  open query q_inspectors_nk for each inspectors_nk  where inspectors_nk.txb = seltxb and inspectors_nk.deluid = ? no-lock , first taxnk OUTER-JOIN where taxnk.rnn = inspectors_nk.rnn_nk no-lock  by inspectors_nk.num_certificate.
  if vlocate then
    find first inspectors_nk where ROWID(inspectors_nk) = rid no-lock no-error.
end.

/*----------------------*/

define frame fedit
             inspectors_nk.num_certificate label "Серт. N    " skip
             inspectors_nk.fio             label "ФИО        " skip
             inspectors_nk.rnn_nk          label "РНН НК     " skip
             nk_name                       label "Название НК" skip
             with centered row 1 side-labels.


on help of inspectors_nk.rnn_nk in frame fedit do:
  run taxnkall.
  if return-value <> "" then
  do:
    inspectors_nk.rnn_nk = return-value.
    display inspectors_nk.rnn_nk WITH FRAME fedit.
    apply "value-changed" to inspectors_nk.rnn_nk in frame fedit.
  end.
end.

on value-changed of inspectors_nk.rnn_nk in frame fedit do:
  inspectors_nk.rnn_nk = inspectors_nk.rnn_nk:screen-value no-error.
  find first taxnk where  taxnk.rnn = inspectors_nk.rnn_nk no-lock no-error.
  if avail  taxnk then
    nk_name =  taxnk.name.
  else
    nk_name = "".
  displ nk_name WITH FRAME fedit.
end.


/*-----------------*/

def frame frbq_inspectors_nk
     bq_inspectors_nk
     help "F8-убрать, F1-новый, ENTER-просмотреть"
     with centered overlay no-label no-box.


/*F8-убрать*/
on "clear" of bq_inspectors_nk in frame frbq_inspectors_nk do:
   if not yes-no ("", "Убрать инспектора ?") then leave.
   rid = ROWID(inspectors_nk).
   do transaction:
     find first inspectors_nk where ROWID(inspectors_nk) = rid exclusive-lock no-error.
     assign
       inspectors_nk.deluid = userid('bank')
       inspectors_nk.deldate = today.
   end. /*transaction*/
   release inspectors_nk.
   run open_query(true).
end.

/*F1*/
on "go" of bq_inspectors_nk in frame frbq_inspectors_nk do:
  if not yes-no ("", "Завести нового инспектора?") then leave.
  do transaction:
    create inspectors_nk.
    update inspectors_nk.num_certificate inspectors_nk.fio inspectors_nk.rnn_nk with frame fedit.
    assign
     inspectors_nk.uid = userid('bank')
     inspectors_nk.cdate = today.
     rid = ROWID(inspectors_nk).
    release inspectors_nk.
  end. /*transaction*/
  hide frame fedit.
  run open_query(true).
end.

on "return" of bq_inspectors_nk in frame frbq_inspectors_nk do:
  displ inspectors_nk.num_certificate inspectors_nk.fio inspectors_nk.rnn_nk with frame fedit.
  apply "value-changed" to inspectors_nk.rnn_nk in frame fedit.
  pause.
  hide frame fedit.
end.

run open_query(false).
enable all with frame frbq_inspectors_nk.
apply "value-changed" to bq_inspectors_nk in frame frbq_inspectors_nk.
wait-for window-close of frame frbq_inspectors_nk focus browse bq_inspectors_nk.
