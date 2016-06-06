/* comregall.p
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
        21.10.2010 k.gitalov
 * CHANGES
       
*/

/* Формирование сводного реестра для старшего кассира */


{classes.i}

def input param v-dt0 as char.
DEFINE BUFFER b-compaydoc FOR comm.compaydoc.

def var v-dt as date init today label "С".   /* дата отбора с */
def var v-dt2 as date init today label "ПО". /* дата отбора по */ 


/*****************************************************************************************************/
function GetFilName returns char ( input txb_val as char ):
 def var ListCod as char init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
 def var ListBank as char format "x(25)" extent 17 init  ["ЦО","Актобе","Костанай","Тараз","Уральск","Караганда","Семипалатинск","Кокшетау","Астана","Павлодар",
                                     "Петропавловск","Атырау","Актау","Жезказган","Усть-Каменогорск","Шымкент","Алматинский филиал"].
   if txb_val = "" then return "".
   return  ListBank[LOOKUP(txb_val , ListCod)].
end function.
/*****************************************************************************************************/
function GetSuppName returns char ( input txb_val as int ):
  DEFINE BUFFER b-suppcom FOR comm.suppcom.
  find first b-suppcom where b-suppcom.supp_id = txb_val no-lock no-error.
  if avail b-suppcom then
  do:
    return b-suppcom.name.
  end.
  else return "".
end function.
/*****************************************************************************************************/

/**************************************************************************************/
function GetNormSumm returns char (input summ as deci ):
   def var ss1 as deci.
   def var ret as char.
   if summ >= 0 then 
   do:
    ss1 = summ.
    ret = string(ss1,"->>>>>>>>>>>>>>>>9.99").
   end. 
   else do:
    ss1 = - summ.
   ret = "-" + trim(string(ss1,"->>>>>>>>>>>>>>>>9.99")).
   end.
  
   return trim(replace(ret,".",",")). 
end function.
/****************************************************************************************************************/
function GetState returns char (input val as int ):
  def var State as char.
  case val:
    when -3 then do: State = "НЕ ПРОВЕДЕН (ПОМЕЧЕН НА ОТМЕНУ)". end.
    when -1 then do: State = "НЕ ПРОВЕДЕН".  end.
    when  0 then do: State = "НЕ ОТПРАВЛЕН". end.
    when  1 then do: State = "ОТПРАВЛЕН В ОБРАБОТКУ".  end.
    when  2 then do: State = "ПРОВЕДЕН".  end.
    when  3 then do: State = "ПРОВЕДЕН (ПОМЕЧЕН НА ОТМЕНУ)". end.
    when  4 then do: State = "ОТМЕНЕН (СТОРНИРОВАНИЕ)". end.
    when  5 then do: State = "ОТМЕНЕН (СТОРНИРОВАНИЕ)". end.
    when  6 then do: State = "ПРОВЕДЕН СТОРНИРОВАН".  end.
    when  7 then do: State = "НЕ ПРОВЕДЕН СТОРНИРОВАН".  end.
  end case.
  return State.
end function.  
/****************************************************************************************************************/
function GetDate returns char ( input dt as date):
  return replace(string(dt,"99/99/9999"),"/",".").
end function.
/****************************************************************************************************************/

 /*Форма выбора диапазона */ 
   if v-dt0 = "" then
   do:
     def frame f-dep v-dt v-dt2 with side-label centered row 15 title "Параметры отбора".
     repeat:
      v-dt  = g-today.
      v-dt2 = g-today.
      display v-dt v-dt2 with frame f-dep.
      update v-dt with frame f-dep.
      update v-dt2 with frame f-dep.
      if v-dt2 < v-dt then do: message "Неверный диапазон дат!" view-as alert-box. undo. end.
      else leave.
     end.
     hide frame f-dep.
   end.
   else do:
     v-dt = date(v-dt0).
     v-dt2 = date(v-dt0).
   end.
/*     
  for each b-compaydoc where  b-compaydoc.whn_cr >= v-dt and b-compaydoc.whn_cr <= v-dt2 break by b-compaydoc.txb:
    displ b-compaydoc.
  end. 
*/

   run ExportExcel.

/***************************************************************************************************************/
procedure ExportExcel. 
    output to report.html.
    {html-title.i}
   
    def var OKsumm as deci.
    def var FAILsumm as deci.
    def var XZsumm as deci.
    def var STORNsumm as deci.
    def var COMsumm as deci.
    
    def var OKsumm_All as deci init 0.
    def var FAILsumm_All as deci init 0.
    def var XZsumm_All as deci init 0.
    def var STORNsumm_All as deci init 0.
    def var COMsumm_All as deci init 0.
    
    def var Mess as char.
    def var I as int init 0.
    def var I_all as int init 0.
     
    def var Caption as char init "Отчет по принятым платежам Авангард-Plat".
    Caption = Caption + " c " + GetDate(v-dt) + " по " + GetDate(v-dt2).
    
    put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.
    
    put unformatted "<tr><td align=center colspan=8><font size=""5""><b><a name="" ""></a>" Caption "</b></font></td></tr>" skip.
    
    for each b-compaydoc where b-compaydoc.state <> -2 and (b-compaydoc.jh <> ? and b-compaydoc.jh <> 0) and b-compaydoc.whn_cr >= v-dt and b-compaydoc.whn_cr <= v-dt2 no-lock break by b-compaydoc.txb by b-compaydoc.state :
       /* put unformatted "<tr><td colspan=2><font size=""6""><b><a name=""" "D1" """></a>" "D2" "</b></font></td></tr>" skip.*/
        
        if FIRST-OF(b-compaydoc.txb) then
        do:
           put unformatted "<TR style=""font:bold;font-size:12pt"">" skip
                            "<TD align=center colspan=8> Филиал: " GetFilName(b-compaydoc.txb) "</TD></TR>" skip.
           put unformatted "<TR style=""font:bold;font-size:11pt"">" skip
                                "<TD>" "№" "</TD>" skip
                                "<TD>" "Провайдер" "</TD>" skip
                                "<TD>" "Номер документа" "</TD>" skip
                                "<TD>" "Сумма платежа" "</TD>" skip
                                "<TD>" "Комиссия" "</TD>" skip
                                "<TD>" "Кассир" "</TD>" skip
                                "<TD>" "Номер транзакции" "</TD>" skip
                                "<TD>" "Статус" "</TD>" skip. 
           I = 0.    
           OKsumm = 0.
           FAILsumm = 0.
           XZsumm = 0.  
           STORNsumm = 0.                       
           COMsumm = 0.                                                 
        end.
        
                I = I + 1.
                I_all = I_all + 1.
                
            
                put unformatted "<TR style=""font-size:10pt"">" skip
                                "<TD>" string(I) "</TD>" skip
                                "<TD>" GetSuppName( b-compaydoc.supp_id ) "</TD>" skip
                                "<TD>"  string(b-compaydoc.docno) "</TD>" skip
                                "<TD>" GetNormSumm( b-compaydoc.summ )  "</TD>" skip
                                "<TD>" GetNormSumm( b-compaydoc.comm_summ )  "</TD>" skip
                                "<TD>" b-compaydoc.who_cr "</TD>" skip
                                "<TD>" string(b-compaydoc.jh) "</TD>" skip
                                "<TD>" GetState( b-compaydoc.state ) "</TD>" skip.
           
                        
                        if b-compaydoc.state = 2 then
                        do:
                          OKsumm = OKsumm + b-compaydoc.summ.
                          COMsumm = COMsumm + b-compaydoc.comm_summ.
                        end.
                        else if b-compaydoc.state = -1 then 
                        do:
                          FAILsumm = FAILsumm + b-compaydoc.summ.
                          COMsumm = COMsumm + b-compaydoc.comm_summ.
                        end. 
                        else if b-compaydoc.state = 7 or b-compaydoc.state = 6 then
                        do:
                          STORNsumm = STORNsumm + b-compaydoc.summ.
                        end.
                        else 
                        do:
                          XZsumm = XZsumm + b-compaydoc.summ.
                          COMsumm = COMsumm + b-compaydoc.comm_summ.
                        end.     
        
                       
        
        if LAST-OF(b-compaydoc.txb) then
        do:
            put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD>ИТОГО:</TD>" skip
                                "<TD> </TD>" skip
                                "<TD>" string(I) "</TD>" skip
                                "<TD>" GetNormSumm(OKsumm + FAILsumm + XZsumm  )  "</TD>" skip
                                "<TD>" GetNormSumm( COMsumm )  "</TD>" skip
                                "<TD> </TD>" skip
                                "<TD> </TD>" skip
                                "<TD> </TD>" skip.
         
           OKsumm_All = OKsumm_All + OKsumm.
           FAILsumm_All = FAILsumm_All + FAILsumm.
           XZsumm_All = XZsumm_All + XZsumm.  
           STORNsumm_All = STORNsumm_All + STORNsumm.                       
           COMsumm_All = COMsumm_All + COMsumm.
         
           I = 0.    
           OKsumm = 0.
           FAILsumm = 0.
           XZsumm = 0.  
           STORNsumm = 0.                       
           COMsumm = 0.    
                                      
        end.
        
        
        /*"<TD align=left>&nbsp;"*/
               
        
    end.
    
      
       
    put unformatted "<tr><td align=left colspan=8><font size=""2""><b><a name="" ""></a>ИТОГО ПО БАНКУ:</b></font></td></tr>" skip.
    
    put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD>" "Всего платежей:" "</TD>" skip
                                "<TD>" string(I_all) "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip. 
    put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD>" "Проведенных платежей:" "</TD>" skip
                                "<TD>" GetNormSumm(OKsumm_All) "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip. 
    put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD>" "Непроведенных платежей:" "</TD>" skip
                                "<TD>" GetNormSumm(FAILsumm_All) "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip.
    put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD>" "Сторнированных платежей:" "</TD>" skip
                                "<TD>" GetNormSumm(STORNsumm_All) "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip.
    put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD>" "Необработанных платежей:" "</TD>" skip
                                "<TD>" GetNormSumm(XZsumm_All) "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip. 
    put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD>" "Комиссии:" "</TD>" skip
                                "<TD>" GetNormSumm(COMsumm_All) "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip.                                                                                                                                
                                
    put unformatted "</table>" .
    {html-end.i}
    output close.
   /* unix silent cptwin report.html iexplore.*/
    unix silent cptwin report.html excel.
end procedure.
/***************************************************************************************************************/