/* comstat.p
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
        26/03/09 id00205
        13.10.2010 k.gitalov перекомпиляция
 * CHANGES

*/

{classes.i}
def var e-addr as char.
def var v-mess as char.
def var err as int.
def var errdes as char.

DEFINE  BUFFER b-sysc FOR comm.pksysc.
/************************************************************************************/
find first b-sysc where b-sysc.sysc = "comadm" no-lock no-error.
if avail b-sysc then
do:
 e-addr = b-sysc.chval.
end.
else do:
  message "comstat - Не найден адрес старшего кассира Авангард-Plat!" view-as alert-box.
  return.
end.
/************************************************************************************/
function GetState returns int ( input p_txb as char , input p_jh as int ):
  def var jhstat as int init 0.
  find first comm.txb where comm.txb.bank = p_txb no-lock no-error.
  if avail comm.txb then
  do:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run trxstatxb (p_txb ,p_jh , output  jhstat ).
    if connected ("txb") then disconnect "txb".
  end.
  return jhstat.
end function.
/************************************************************************************/

DEFINE  BUFFER b-compaydoc FOR comm.compaydoc.
def var Doc as class COMPAYDOCClass.  /* Класс документов коммунальных платежей*/


for each b-compaydoc where ((b-compaydoc.state = 0) or (b-compaydoc.state = 1)) and ((b-compaydoc.jh <> ?) and (b-compaydoc.jh <> 0)) no-lock:

  if GetState( b-compaydoc.txb , b-compaydoc.jh ) <> 6 then next.

  find first compaydoc where rowid(compaydoc) = rowid(b-compaydoc) exclusive-lock no-error no-wait.
  if not avail compaydoc then next.
  else find current compaydoc no-lock.

  Doc = NEW COMPAYDOCClass(Base).
  if Doc:FindDocNo(string(b-compaydoc.docno)) then
  do:
    case Doc:state:
       when  0 then
       do:
          err = 0.
          run ap_trx( Doc ,output err, output errdes).
          if err <> 0 then
          do:
             v-mess = errdes.
             v-mess = v-mess + "~n Номер документа:" + string(Doc:docno).
             v-mess = v-mess + "~n Платежи: " + Doc:suppname.
             run mail("id00205@metrocombank.kz", "bankadm@metrocombank.kz", "Ошибка при автоматической отправке платежа", v-mess, "", "", "").
          end.
       end.
       when  1 then
       do:
          err = 0.
          run ap_trxsts(Doc, output err, output errdes).
          if err <> 0 then
          do:
             v-mess = errdes.
             v-mess = v-mess + "~n Номер документа:" + string(Doc:docno).
             v-mess = v-mess + "~n Платежи: " + Doc:suppname.
             run mail("id00205@metrocombank.kz", "bankadm@metrocombank.kz", "Ошибка при проверке статуса документа", v-mess, "", "", "").
          end.
          else do:
             if Doc:state = -1 then
             do:
               v-mess = " Номер документа:" + string(Doc:docno).
               v-mess = v-mess + "~n Платежи: " + Doc:suppname.
               v-mess = v-mess + "~n Описание: " + Doc:note.
               run mail(e-addr, "bankadm@metrocombank.kz", "Ошибка при проведении платежа", v-mess, "", "", "").
             end.


             if Doc:state = 2 then
             do:
               v-mess = " Номер документа:" + string(Doc:docno).
               v-mess = v-mess + "~n Платежи: " + Doc:suppname.
               run mail("id00205@metrocombank.kz", "bankadm@metrocombank.kz", "Успешно проведеный платеж", v-mess, "", "", "").
             end.

          end.
       end.
    end case.
  end.
  else do:
   output to "/drbd/data/log/comstat_err.log".
   put unformatted "Не найден документ " string(b-compaydoc.docno).
   output close.
  end.

  if VALID-OBJECT(Doc) then DELETE OBJECT Doc NO-ERROR.

end.


