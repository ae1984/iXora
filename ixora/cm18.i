/*  cm18.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
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
        15/05/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        21/07/2012 k.gitalov мультивалютный барабан ## и **
        22/08/2012 Luiza закомментировала вопрос "Работаем с миникассой?"
*/


def {1} shared temp-table wrk_ext no-undo
  field ind as int
  field num as char /*номер кассеты (как в сейфе)*/
  field cass as char /*Обозначение кассеты KZNA */
  field crc as char /*Валюта*/
  field nom as int /*Номинал*/
  field used as int /*занято*/
  field out as int  /*при выдаче*/
  field out_summ as int
  field summ as int. /*Сумма в кассете*/



def {1} shared temp-table wrk no-undo
  field ind as int
  field num as char /*номер кассеты (как в сейфе)*/
  field cass as char /*Обозначение кассеты KZNA */
  field type as char /*Тип кассеты N*-HA типы купюр, ## - мультивалютные, -- ветхие */
  field crc as char /*Валюта*/
  field nom as int /*Номинал*/
  field used as int /*занято*/
  field free as int /*свободно*/
  field out as int /*при выдаче*/
  field state as char /*Активность кассеты*/
  field out_summ as int
  field summ as int. /*Сумма в кассете*/

def {1} shared temp-table result no-undo
  field ind as int
  field num as char /*номер кассеты (как в сейфе)*/
  field cass as char /*Обозначение кассеты KZNA */
  field type as char /*Тип кассеты N*-HA типы купюр, ## (**) - мультивалютные, -- ветхие */
  field crc as char /*Валюта*/
  field nom as int /*Номинал*/
  field used as int /*занято*/
  field free as int /*свободно*/
  field out as int /*при выдаче*/
  field state as char /*Активность кассеты*/
  field out_summ as int
  field summ as int. /*Сумма в кассете*/

/**************************************************************************************************/
procedure SelectEndPoint :
  def button safe-button label  "  Сейф   ".
  def button tempo-button label "Миникасса".
  def button close-button label " Отмена ".
  def input param mess1 as char.
  def input param mess2 as char.
  def input param mess3 as char.
  def output param Res as int.
  def var choice_tmp as log.

    define frame Form1
     space(3) v-mess1 as char format "x(45)" no-label skip
     space(3) v-mess2 as char format "x(45)" no-label skip
     space(3) v-mess3 as char format "x(45)" no-label skip
    /* space(11) "Выберите назначение" skip*/
     space(7) safe-button tempo-button close-button
     WITH SIDE-LABELS centered overlay row 15 TITLE "Выберите назначение".

   Res = 0.

   ON CHOOSE OF safe-button
   DO:
     apply "endkey" to frame Form1.
     hide frame Form1.
     Res = 1.
     return.
   END.
   ON CHOOSE OF tempo-button
   DO:
     /*MESSAGE "Работаем с миникассой?" VIEW-AS ALERT-BOX MESSAGE BUTTONS Yes-No TITLE "Подтвердите" UPDATE choice_tmp.*/ /* Luiza */
     choice_tmp = yes.
     if choice_tmp = yes then
     do:
       apply "endkey" to frame Form1.
       hide frame Form1.
       Res = 2.
       return.
     end.
   END.

   ON CHOOSE OF close-button
   DO:
     apply "endkey" to frame Form1.
     Res = 0.
     return.
   END.

   v-mess1:SCREEN-VALUE = mess1.
   v-mess2:SCREEN-VALUE = mess2.
   v-mess3:SCREEN-VALUE = mess3.
   ENABLE safe-button tempo-button close-button WITH FRAME Form1.

   WAIT-FOR endkey of frame Form1.
   hide frame Form1.

end procedure.
/**************************************************************************************************/
function GetSafeIP returns char (input parm1 as char).
  find first comm.cslist where comm.cslist.nomer = parm1 no-lock no-error.
  if avail comm.cslist then do:
    if comm.cslist.ip = "" then do:
     message "Неверные данные в справочнике ЭК!" view-as alert-box.
     return "".
    end.
    else return comm.cslist.ip.
  end.
  else do:
    message "Вы не привязаны к ЭК!" view-as alert-box.
    return "".
  end.
end function.
/**************************************************************************************************/
function CalcNoteCount returns int (input v-crc as char, input v-summ as deci).
  def buffer b-wrk for wrk.
  def var tmp_summ as deci.
  def var tmp_used as int.
  def var full as log.
  tmp_summ = v-summ.
  for each b-wrk where crc = v-crc and b-wrk.nom > 0 by nom DESCENDING:
    tmp_used = b-wrk.used.
     if tmp_used >= 1 then
     do:
       full = false.
       repeat while full = false and tmp_used >= 1:
           if b-wrk.nom <= tmp_summ then
           do:
              b-wrk.out = b-wrk.out + 1.
              b-wrk.out_summ = b-wrk.out_summ + b-wrk.nom.
              tmp_summ = tmp_summ - b-wrk.nom.
              tmp_used = tmp_used - 1.
           end.
           else full = true.
       end.
     end.
     else next.
  end.
  if tmp_summ = v-summ then return -1.
  else return integer(tmp_summ).

end function.
/**************************************************************************************************/
function GetCassNo returns int (input parm1 as char).
       if parm1 = "A" then return 1.
       if parm1 = "B" then return 2.
       if parm1 = "C" then return 3.
       if parm1 = "D" then return 4.
       if parm1 = "E" then return 5.
       if parm1 = "F" then return 6.
       if parm1 = "G" then return 7.
       if parm1 = "H" then return 8.
       if parm1 = "I" then return 9.
       if parm1 = "J" then return 10.
       if parm1 = "K" then return 11.
       if parm1 = "L" then return 12.
       return 0.
end function.
/**************************************************************************************************/
function GetCRCcode returns char (input parm1 as char).
      if parm1 = "KZ" then return "KZT".
      if parm1 = "US" then return "USD".
      if parm1 = "EU" then return "EUR".
      if parm1 = "RU" then return "RUR".
      if parm1 = "##" then return "ALL".
      if parm1 = "**" then return "ALL".
      return "".
end function.
/**************************************************************************************************/
function GetCRInd returns int (input parm1 as char).
      if parm1 = "KZT" then return 1.
      if parm1 = "USD" then return 2.
      if parm1 = "EUR" then return 3.
      if parm1 = "RUR" then return 4.
      return 0.
end function.
/**************************************************************************************************/
function GetNominal returns integer (input parm1 as char).
        if substr(parm1,1,1) = 'A' then return 1.
        if substr(parm1,1,1) = 'B' then return 2.
        if substr(parm1,1,1) = 'C' then return 5.
        if substr(parm1,1,1) = 'D' then return 10.
        if substr(parm1,1,1) = 'E' then return 20.
        if substr(parm1,1,1) = 'F' then return 25.
        if substr(parm1,1,1) = 'G' then return 50.
        if substr(parm1,1,1) = 'H' then return 100.
        if substr(parm1,1,1) = 'I' then return 200.
        if substr(parm1,1,1) = 'J' then return 500.
        if substr(parm1,1,1) = 'K' then return 1000.
        if substr(parm1,1,1) = 'L' then return 2000.
        if substr(parm1,1,1) = 'M' then return 5000.
        if substr(parm1,1,1) = 'N' then return 10000.
        if substr(parm1,1,1) = 'O' then return 20000.
        if substr(parm1,1,1) = 'P' then return 50000.
        if substr(parm1,1,1) = 'Q' then return 100000.
        if substr(parm1,1,1) = 'R' then return 250.
        if substr(parm1,1,1) = 'S' then return 200000.
        if substr(parm1,1,1) = 'T' then return 250000.

        return 0.
end function.
/**************************************************************************************************/
function ErrorValue returns char (input parm1 as integer).
  def var Des as char.

    case parm1:
      when 1001 then do:
        Des = "Нет связи с сервисом".
      end.
      when 1002 then do:
        Des = "Обрыв связи (принудительное завершение)".
      end.
      when 1003 then do:
        Des = "Ошибка соединения сервера с сейфом".
      end.
      when 1004 then do:
        Des = "Неизвестная команда".
      end.
      when 1005 then do:
        Des = "Операция не может быть выполнена!~nОбратитесь в ДИТ". /*Результат предыдущей операции не был получен*/
      end.
      when 102 then do:
        Des = " Сейф занят".
      end.
      when 204 then do:
        Des = "Банкнота в правом выходном слоте!".
      end.
      when 205 then do:
        Des = "Банкнота в левом выходном слоте!".
      end.
      when 206 then do:
        Des = "Банкнота в центральном выходном слоте!".
      end.
      when 207 then do:
        Des = "Нет денег во входном слоте".
      end.
      when 208 then do:
        Des = "Банкнота во входном слоте!".
      end.
      when 210 then do:
        Des = "Кассета сейфа пуста".
      end.
      when 209 then do:
        Des = "Кассета сейфа заполнена".
      end.
      when 201 then do:
        Des = "Ошибка синтаксиса".
      end.
      when 213 then do:
        Des = "Ошибка синтаксиса".
      end.
      when 214 then do:
        Des = "Слишком много банкнот [>200]".
      end.
      when 401 then do:
        Des = "Проверьте банкноты во входном слоте!".
      end.
      otherwise do:
        Des = "Ошибка " + string(parm1).
      end.
    end case.

  return Des.
end function.
/***********************************************************************************************************/
function ClearData returns integer ().
   for each wrk exclusive-lock. delete wrk. end.
   for each wrk_ext exclusive-lock. delete wrk_ext. end.
   return 0.
end function.
/***********************************************************************************************************/
function ClearResult returns integer ().
   for each result exclusive-lock. delete result. end.
   return 0.
end function.
/***********************************************************************************************************/
function UsedCountExt returns integer (input parm1 as char).
   def var v-count as int.
   def buffer b-wrk_ext for wrk_ext.
   for each b-wrk_ext where b-wrk_ext.num = parm1 no-lock:
    v-count = v-count + b-wrk_ext.used.
   end.
   return v-count.
end function.
/***********************************************************************************************************/
function UsedOutExt returns integer (input parm1 as char).
   def var v-count as int.
   def buffer b-wrk_ext for wrk_ext.
   for each b-wrk_ext where b-wrk_ext.num = parm1 no-lock:
    v-count = v-count + b-wrk_ext.out.
   end.
   return v-count.
end function.
/***********************************************************************************************************/
function GetSummVal returns deci (input v-crc as char).
  def var tmp_summ as deci init 0.
  for each wrk where wrk.crc = v-crc no-lock:
   tmp_summ = tmp_summ + wrk.summ.
  end.
  for each wrk_ext where wrk_ext.crc = v-crc no-lock:
   tmp_summ = tmp_summ + wrk_ext.summ.
  end.
  return tmp_summ.
end function.
/***********************************************************************************************************/
function GetSummValRes returns deci (input v-crc as char).
  def var tmp_summ as deci init 0.
  for each result where result.crc = v-crc no-lock:
   tmp_summ = tmp_summ + result.summ.
  end.
  return tmp_summ.
end function.
/***********************************************************************************************************/
function GetOutSummVal returns deci (input v-crc as char).
  def var tmp_summ as deci init 0.
  def buffer b-wrk for wrk.
  def buffer b-wrk_ext for wrk_ext.
  for each b-wrk where b-wrk.crc = v-crc no-lock:
   tmp_summ = tmp_summ + b-wrk.out_summ.
  end.
  for each b-wrk_ext where b-wrk_ext.crc = v-crc no-lock:
   tmp_summ = tmp_summ + b-wrk_ext.out_summ.
  end.
  return tmp_summ.
end function.
/***********************************************************************************************************/
function GetParamValue returns char (input ParamData as char,input ParamName as char).
  if ParamData = "" then return "".
  def var p-int1 as int.
  def var p-int2 as int.
  def var c-par1 as char.
  def var c-par2 as char.

  c-par1 = "<" + ParamName + ">".
  c-par2 = "</" + ParamName + ">".

  p-int1 = index(ParamData,c-par1) + length(c-par1).
  p-int2 = index(ParamData,c-par2).

  if p-int1 <> 0 and p-int2 <> 0 then return substr(ParamData,p-int1,p-int2 - p-int1).
  else return "".
end function.
/**************************************************************************************************/
procedure GetNoteCount:
   def input param data as char no-undo.
   def input param v-param as char.
   def var DefData as char.
   def var i as int.
   def var z as int init 1.

   def var TmpData as char.
   def var TmpCount as int.
   def var pos as int.

   DefData =  GetParamValue(data,v-param).

   case v-param:
     when "Depo" then do:
        pos = 8.
     end.
     when "Wout" then do:
        pos = 5.
     end.
     otherwise do:
        pos = 1.
        DefData = data.
     end.
   end case.


         repeat i = pos to NUM-ENTRIES(DefData):
             TmpData = substr(entry(i,DefData),1,4).
             i = i + 1.
             TmpCount = integer(entry(i,DefData)).
             if TmpCount > 0  then do:
               if v-param = "Wout" and substr(TmpData,1,1) = substr(TmpData,2,1) and
                                       substr(TmpData,1,1) = substr(TmpData,3,1) and
                                       substr(TmpData,1,1) = substr(TmpData,4,1) then
               do:
                  run GetNoteCount( GetParamValue(data,substr(TmpData,1,1)),"").
               end.
               else do:
                  if v-param = "Depo" and (substr(TmpData,3,2) = "##" or substr(TmpData,3,2) = "--" or substr(TmpData,3,2) = "**") then next.
                  else do:
                    create result.
                    result.ind = z.
                    result.cass = TmpData.
                    result.crc  = GetCRCcode(substr(TmpData,1,2)).
                    result.nom  = GetNominal(substr(TmpData,3,2)).
                    result.used = TmpCount.
                    result.summ = result.nom * TmpCount.
                    z = z + 1.
                  end.
               end.
            end.
         end.

end procedure.
/***********************************************************************************************************/
procedure DecodeSafeData:
   def input param data as char.
   def var DefData as char.
   def var TmpData as char.
   def var TmpCount as int.
   def var i as int.
   def var z as int.

    DefData = GetParamValue(data,"GetData").
    ClearData().

         repeat i = 1 to NUM-ENTRIES(DefData):
                  create wrk.
                  wrk.cass = substr(entry(i,DefData),1,4).
                  wrk.crc  = GetCRCcode(substr(entry(i,DefData),1,2)).
                  wrk.nom  = GetNominal(substr(entry(i,DefData),3,2)).
                  wrk.type = substr(entry(i,DefData),3,2).
                  i = i + 1.
                  wrk.used = integer(entry(i,DefData)).
                  i = i + 1.
                  wrk.free = integer(entry(i,DefData)).
                  i = i + 1.
                  wrk.num = entry(i,DefData).
                  wrk.ind = GetCassNo(entry(i,DefData)).
                  i = i + 1.
                  wrk.state = entry(i,DefData).
                  wrk.summ = wrk.nom * wrk.used.
                  /*Многономинальные и мультивалютные*/
                  if wrk.type = "##" or wrk.type = "--" or wrk.type = "**" then run DecodeExtData(GetParamValue(data,wrk.num),wrk.num).
         end.
end procedure.
/***********************************************************************************************************/
procedure DecodeExtData:
   def input param data as char.
   def input param cass_num as char.
   def var TmpData as char.
   def var TmpCount as int.
   def var i as int.
   def var z as int.
   z = 1.
         repeat i = 1 to NUM-ENTRIES(data):
             TmpData = substr(entry(i,data),1,4).
             i = i + 1.
             TmpCount = integer(entry(i,data)).
             if TmpCount > 0 then do:
                create wrk_ext.
                       wrk_ext.ind = z.
                       wrk_ext.num  = cass_num.
                       wrk_ext.cass = TmpData.
                       wrk_ext.crc  = GetCRCcode(substr(TmpData,1,2)).
                       wrk_ext.nom  = GetNominal(substr(TmpData,3,2)).
                       wrk_ext.used = TmpCount.
                       wrk_ext.summ = wrk_ext.nom * TmpCount.
                       z = z + 1.
             end.
         end.
end procedure.
/***********************************************************************************************************/
/*

1001 Нет связи с сервисом
1002 Обрыв связи (принудительное завершение)
1003 Ошибка соединения с сейфом (сервиса)
1004 Неизвестная команда
102 Сейф занят
207 Нет денег во входном слоте
210 Кассета сейфа пуста

*/
