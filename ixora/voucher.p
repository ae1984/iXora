/* voucher.p
 * MODULE
        Формирование ордеров при разгрузки терминалов
 * DESCRIPTION
        Формирование ордеров при разгрузки терминалов 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        vou_bank3.p
 * MENU
        5-1-13
 * AUTHOR
        19.05.06 ten
 * CHANGES
        19.06.06 ten автоматическая штамповка проводок
*/

def var v-num as char no-undo. 
def var v-acc as char no-undo.
def var vdel as char init "^" no-undo.
def var v-rem as char no-undo.
def var vparam as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def new shared var s-jh as int no-undo.
def var v-sum as dec no-undo.
def var v-log as logical no-undo.
def frame fr
  v-num with row 2 column 2 centered.


on help of v-num in frame fr do: 
   run h-term.  
   v-num:screen-value = return-value.
   v-num = v-num:screen-value. 
end.


update  v-num format "x(40)" label "Выберите номер терминала" with side-labels centered frame fr.
hide frame fr.
find eterminal where eterminal.terminal-id eq v-num no-lock no-error.
if avail eterminal then do:
   v-acc = eterminal.acc.
   disp v-num format "x(12)" label "Номер терминала" v-acc format "x(12)" label "Номер счета" with side-labels centered frame fr1.
   find arp where arp.arp eq eterminal.acc no-lock no-error.
   if avail arp then disp (arp.dam[1] - arp.cam[1]) label "Сумма" with frame fr1.
   update v-sum format "z,zzz,zzz,zzz,zzz" label "Введите сумму" with side-labels centered frame ddr.
   if v-sum > 0 then do:
      message "Провести транзакцию?" update v-log.
      if v-log then do:
         v-rem  = "Разгрузка терминала N " + v-num + ", счет N " + v-acc.
         vparam = string(v-sum) + vdel + "1" + vdel + v-acc + vdel + v-rem.
         run trxgen ('vnb0042', vdel, vparam ,"", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
            message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
            pause.
            return "".
         end.
         else do: 
              find first jh where jh.jh = s-jh exclusive-lock no-error.  
              if jh.sts < 5 then jh.sts = 5.
              for each jl of jh:
                  if jl.sts < 5 then jl.sts = 5.
              end.
              message "Печатать операционный ордер?" update v-log.
              if v-log then run vou_bank3(2).
                       else run vou_bank3(1).
         end.
      end.
      else do:
         message "Проводка отменена!".
         pause.
         undo,retry.
      end.
   end.
   else do:
      message "Сумма списания должна быть больше 0!".
      pause.
      undo,retry.
   end.
end.


