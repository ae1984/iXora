/* kaztelexp.p
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
 * CHANGES

*/

/* Экспорт реестра для АО Казахтелеком*/

{classes.i}

if not connected("comm") then run conncom.

def var rez as log.
def stream m-out.
def stream m-dbf.
def var Doc as class COMPAYDOCClass.  /* Класс документов коммунальных платежей*/
def var SP  as class SUPPCOMClass.    /* Класс данных поставщиков */
Doc = NEW COMPAYDOCClass(Base).
SP  = NEW SUPPCOMClass(Base).
SP:txb = Doc:b-txb.
/***************************************************************************************************************/
function GetFileName returns char (input PR as char,  input DT as date):
  /* формирует имя файла с префиксом PR и датой DT для АО Казахтелеком */
  def var m as int.
  def var ret as char.
  ret = PR.
  m = month(DT).

  if m > 9 then
  do:
   if m = 10 then ret = ret + "A".
   if m = 11 then ret = ret + "B".
   if m = 12 then ret = ret + "C".
  end.
  else do:
   ret = ret + string(m).
  end.

  ret = ret + string(day(DT),'99').
  return ret.
end function.
/***************************************************************************************************************/

function gen_reg_kztlk returns log ( input Doc as Class COMPAYDOCClass, input p-no as int, input v-pdt as date):
 /* Формирование реестра принятых платежей для АО Казахтелеком */
 def var Line as class COMPAYDOCClass.
 def var summa AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-"  DECIMALS 2 init 0. /* Сумма реестра */
 def var sborbank AS decimal FORMAT "->>,>>>,>>9.99"  DECIMALS 2 init 0.     /* Cбор в банке */
 def var i as int.
 def var v as char init "" no-undo.
 def var S as char init "".
 def var v-text as char init "".
 def var L as char init "---------------------------------------------------------------------------".
 def var s-date as char.
 def var d-date as char. /* Дата в формате dbf */

 if VALID-OBJECT(Doc)  then
 do:
   Line = NEW COMPAYDOCClass(Base).
   Doc:ElementBy(1).
   Line:FindDocNo(string(Doc:docno)).
   s-date = string(Line:whn_cr). /*string(day(Doc:whn_cr),'99') + "." + string(month(Doc:whn_cr),'99') + "." + string(year(Doc:whn_cr),'9999').*/
   output stream m-out to regfile.tmp.
   output stream m-dbf to regdb.tmp.

   v-text = "РЕЕСТР ПЕРЕДАННЫХ ЛИЦЕВЫХ СЧЕТОВ".
   put stream m-out unformatted  v-text skip.

   v-text = "ПРИНЯТЫХ: " + s-date.
   put stream m-out unformatted  v-text skip.

   find first cmp no-lock no-error.
   v-text =  cmp.name.
   put stream m-out unformatted  v-text skip.

   v-text = "ПЛАТЕЖИ, ПОСТУПИВШИЕ ДЛЯ ПРЕДПРИЯТИЯ ".
   put stream m-out unformatted  v-text skip.

   v-text = Line:suppname + "БИК " + Line:suppbik + ", ИИК " + Line:suppiik.
   put stream m-out unformatted  v-text skip.

   v-text = "К ПЛАТЕЖНОМУ ПОРУЧЕНИЮ № " + string(p-no) + " ОТ " + string(v-pdt).
   put stream m-out unformatted  v-text skip.

   put stream m-out unformatted  L skip.
   v-text = "|ЛИЦЕВОЙ СЧЕТ     |СУММА ОПЛАТЫ     |".
   put stream m-out unformatted  v-text skip.
   put stream m-out unformatted  L skip.

   /***********************************************************************************************/
   repeat i = 1 to Doc:Count:
     Doc:ElementBy(i).
     Line:FindDocNo(string(Doc:docno)).
     /*
     find first comm.account where comm.account.acc_id = Doc:acc_id and comm.account.supp_id = Doc:supp_id.
     if not avail comm.account then do: message "Не найден плательщик в таблице ACCOUNT !" view-as alert-box. leave. end.
     */
     v-text = string(Line:payacc,"99999999") + "         \t" + string(Line:summ,"99999999.99").
     put stream m-out unformatted  v-text skip.

     d-date = string(year(Line:whn_cr),'9999') + string(month(Line:whn_cr),'99') + string(day(Line:whn_cr),'99').


      if Line:note = ? then Line:note = " ".
       S = d-date + "|" + Line:who_cr + "|" + string(Line:payacc,"x(8)") + "|" + string(Line:payphone,"x(8)") + "|" + string(1 /*Line:cod*/) + "|" +
          string(Line:summ,">>>>>>>9.99") + "|" + string(Line:docno,"999999") + "|" + string(Line:note,"x(32)").


     put stream m-dbf unformatted  S skip.

     summa = summa + Line:summ.
   end.
   /***********************************************************************************************/

   Doc:ElementBy(1).
   Line:FindDocNo(string(Doc:docno)).

   put stream m-out unformatted  L skip.

   v-text = "СУММА РЕЕСТРА ЗА " + s-date + ": " + string(round(summa,2),">>>>>>>9.99") + " ТЕНГЕ".
   put stream m-out unformatted  v-text skip.

   v-text = "КОЛИЧЕСТВО ДОКУМЕНТОВ    : " + string(Doc:Count,">>>9").
   put stream m-out unformatted  v-text skip.
   put stream m-out unformatted  L skip.

   v-text = "ИТОГО ПО ПРЕДПРИЯТИЮ  " + Line:suppname + "БИК " + Line:suppbik + ", ИИК " + Line:suppiik.
   put stream m-out unformatted  v-text skip.

   v-text = "КОЛИЧЕСТВО ДОКУМЕНТОВ : " + string(Doc:Count,">>>9").
   put stream m-out unformatted  v-text skip.

   v-text = "СУММА ПЛАТЕЖЕЙ        : " + string(round(summa,2),">>>>>>>9.99") + " ТЕНГЕ".
   put stream m-out unformatted  v-text skip.

   sborbank = (summa * Line:supp_proc) / 100.
   v-text = "СБОР В БАНКЕ          : " + string(round(sborbank,2),">>>>>>>9.99") + " ТЕНГЕ".
   put stream m-out unformatted  v-text skip.

   v-text = "СУММА К ПЕРЕЧИСЛЕНИЮ  : " + string(round(summa - sborbank,2),">>>>>>>9.99") + " ТЕНГЕ".
   put stream m-out unformatted  v-text skip.

   put stream m-out unformatted  L  skip(2).

   find sysc where sysc.sysc = 'DKPODP' no-lock no-error.
    if avail sysc then do:
     v-text = "ДИРЕКТОР ФИЛИАЛА " +  sysc.chval + "_____________".
    end.
   else do:
     message "Отсутствует переменная DKPODP" view-as alert-box.
     v-text = "ДИРЕКТОР ФИЛИАЛА ________________________".
   end.
   put stream m-out unformatted  v-text skip(2).

   find sysc where sysc.sysc = 'MAINBK' no-lock no-error.
    if avail sysc then do:
     v-text = "ГЛ. БУХГАЛТЕР    " +  sysc.chval + "_____________".
    end.
   else do:
     message "Отсутствует переменная MAINBK" view-as alert-box.
     v-text = "ГЛ. БУХГАЛТЕР    ________________________".
   end.
   put stream m-out unformatted  v-text skip.

   output stream m-out close.
   output stream m-dbf close.

   input through value("scp regfile.tmp  Administrator@`askhost`:c:\\\\tmp\\\\" + GetFileName("kstr_tb.",Doc:whn_cr) + " ;echo $?").
   repeat:
	import unformatted v.
   end.
   if v <> "0" then do: message "Ошибка при копировании regfile.tmp " + v view-as alert-box. return false. end.
   /**********************************************************************/
   v = "".
   input through value("compay_dbf.pl regdb.tmp").
   repeat:
    import unformatted v.
   end.
   if v <> "" then do: message "Ошибка при конвертации regdb.tmp " + v view-as alert-box. return false. end.
   v = "".
   input through value("scp regdb.tmp  Administrator@`askhost`:c:\\\\tmp\\\\" + GetFileName("kztk_tb.",Doc:whn_cr) + " ;echo $?").
   repeat:
    import unformatted v.
   end.
   if v <> "0" then do: message "Ошибка при копировании regdb.tmp " + v view-as alert-box. return false. end.
   /**********************************************************************/

   /*
    run yn("","Печатать реестр?","","", output rez).
    if rez then unix silent prit -t regfile.tmp.
   */
   if VALID-OBJECT(Line)  then DELETE OBJECT Line NO-ERROR.
   message "Экспорт реестра завершен!" view-as alert-box.
   return true.
 end.
 else do: message "Нет активного документа!" view-as alert-box. return false. end.


end function.
/***************************************************************************************************************/

/* Формирование реестра принятых платежей для АО Казахтелеком */

 run help-suppay(SP,"pay").
 if SP:name = ? or SP:name = "" then
 do:
   run yn("","Выйти из программы?","","", output rez).
   if rez then  return.
   else do: run kaztelexp. end.
 end.
 else do:
   /*Форма выбора диапазона */
   def var v-dt as date  label "С".   /* дата отбора с */
   def var v-dt2 as date  label "ПО". /* дата отбора по */
   def var p-no as int format ">>>>>>9" label "№".
   def var v-pdt as date init today label "ОТ".
   def var real-day as date.                    /* Текущая дата реестра */
   def var days as int init 0.                  /* Разница в днях между v-dt и v-dt2 */
   def frame f-dep v-dt v-dt2 skip "  ПЛАТЕЖНОЕ ПОРУЧЕНИЕ:" skip p-no v-pdt with side-label centered row 5 title "Параметры отбора".
   v-dt  = g-today.
   v-dt2 = g-today.
   display v-dt v-dt2 p-no v-pdt with frame f-dep.
   update v-dt with frame f-dep.
   update v-dt2 with frame f-dep.
   update p-no with frame f-dep.
   update v-pdt with frame f-dep.
   hide frame f-dep.
   /*********************************************************************************************************************/


         days = v-dt2 - v-dt.
         if days < 0 then do: message "Неверно указан диапазон выбора!" view-as alert-box title "Ошибка". run comreg. end.

         real-day = v-dt.
         days = days + 1.
         def var i as int.
         do i = 1 to days:
           if Doc:Find-All("whn_cr = " + string(real-day) + " and supp_id = " + string(SP:supp_id) + " and jh <> ? no-lock" ) > 0 then
           do:
            if not gen_reg_kztlk(Doc,p-no,v-pdt) then do: message "Ошибка формирования реестра!!" view-as alert-box. leave. end.
           end.
           else do: message "Нет документов за " string(real-day) view-as alert-box. end.
           real-day = real-day + 1.
         end.
         run yn("","Выйти из программы?","","", output rez).
         if not rez then run kaztelexp.


 end.

 if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR.
 if VALID-OBJECT(SP)   then DELETE OBJECT SP  NO-ERROR .
 if connected("comm") then disconnect "comm".