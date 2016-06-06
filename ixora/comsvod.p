/* comsvod.p
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
        27/10/09 id00205
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/
{nbankBik.i}
{classes.i}


define temp-table wrk
                       field txb AS char
                       field rmz AS char
                       field summ AS deci
                       field des AS char
                       field stat AS log.

def var v-dt as date no-undo.
def var rez as log.
/* v-dt = g-today - 1. */

find last cls where cls.del no-lock no-error.
v-dt = cls.whn.




   find first comm.pksysc where comm.pksysc.sysc = "comadm" no-lock no-error.
   if avail comm.pksysc then
   do:
     if comm.pksysc.daval = v-dt then
     do:
       message "За " + string(v-dt) + " свод ком. платежей уже запускался!" view-as alert-box.
       return.
     end.
   end.
   else do:
     message "Нет переменной comadm!!!" view-as alert-box.
     return.
   end.
/*******************************************************************************************************/


   run comregall ( string(v-dt) ).
   run yn("","Отчет проверен?","Запустить процесс свода?","", output rez).
   if not rez then return.


/*******************************************************************************************************/

def var FILACC as char.
def var XZACC as char init "KZ31470142870A023100". /*до выяснения*/
def var ALLACC as char init "KZ47470142870A023200". /*свод*/
def var DFRZM as char init "".
DEFINE BUFFER b-compaydoc FOR comm.compaydoc.

 find sysc where sysc.sysc = 'OURBNK' no-lock no-error.
 if avail sysc then
 do:
   if sysc.chval <> "TXB00" then
   do:
      message "Программа может быть запущена только в ЦО!" view-as alert-box.
      return.
   end.
 end.
 else do: message "Нет переменной OURBNK" view-as alert-box. return. end.

/**************************************************************************************************************/
function GetAccName returns char (input supp_id as int , input acc_id as int ):
   def var RetValue as char.
   find first comm.account where comm.account.acc_id = acc_id and comm.account.supp_id = supp_id no-lock no-error.
   if avail comm.account then RetValue = comm.account.payname.
   if RetValue = "NO NAME" then return "".
   else return RetValue.
end function.
/**************************************************************************************************************/
function GetAccNum returns char (input supp_id as int , input acc_id as int ):
   def var RetValue as char.
   find first comm.account where comm.account.acc_id = acc_id and comm.account.supp_id = supp_id no-lock no-error.
   if avail comm.account then RetValue = comm.account.acc.
   else RetValue = "ERROR".
   return RetValue.
end function.
/**************************************************************************************/
function GetDate returns char ( input dt as date):
  return replace(string(dt,"99/99/9999"),"/",".").
end function.
/****************************************************************************************************************/
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
/**************************************************************************************************************/
function GetProvName returns char (input ctxb as char, input prov_id as int ):
   find first comm.suppcom where comm.suppcom.txb = ctxb and comm.suppcom.supp_id = prov_id no-lock no-error.
   if avail comm.suppcom then return comm.suppcom.name.
   else return "".
end function.
/**************************************************************************************************************/

function GetFilialSumm returns log (input ctxb as char, output OK_summ as deci , output FAIL_summ as deci ):

    def var OKsumm as deci init 0.
    def var FAILsumm as deci init 0.
    def var XZsumm as deci init 0.
    def var STORNsumm as deci init 0.
    def var COMsumm as deci init 0.

    for each b-compaydoc where b-compaydoc.txb = ctxb and b-compaydoc.state <> -2 and (b-compaydoc.jh <> ? and b-compaydoc.jh <> 0) and b-compaydoc.whn_cr = v-dt no-lock by b-compaydoc.state :


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

    end.

    OK_summ = OKsumm.
    FAIL_summ = FAILsumm + XZsumm.

    if OK_summ > 0 or FAIL_summ > 0 then return true.
    else return false.

end function.
/**************************************************************************************************************/



def var OKsumm as deci init 0.
def var FAILsumm as deci init 0.

  OKsumm = 0.
  FAILsumm = 0.

for each comm.txb where comm.txb.bank <> "TXB00" and comm.txb.txb > 0 no-lock:

  case comm.txb.bank:
    when "TXB01" then do: FILACC = "KZ34470142870A014801". end. /*Актобе*/
    when "TXB02" then do: FILACC = "KZ73470142870A014002". end. /*Кустанай*/
    when "TXB03" then do: FILACC = "KZ31470142870A013303". end. /*Тараз*/
    when "TXB04" then do: FILACC = "KZ21470142870A012804". end. /*Уральск*/
    when "TXB05" then do: FILACC = "KZ73470142870A013905". end. /*Караганда*/
    when "TXB06" then do: FILACC = "KZ14470142870A013706". end. /*Семипалатинск*/
    when "TXB07" then do: FILACC = "KZ36470142870A013407". end. /*Кокчетав*/
    when "TXB08" then do: FILACC = "KZ23470142870A014708". end. /*Астана*/
    when "TXB09" then do: FILACC = "KZ30470142870A013709". end. /*Павлодар*/
    when "TXB10" then do: FILACC = "KZ68470142870A013510". end. /*Петропавловск*/
    when "TXB11" then do: FILACC = "KZ25470142870A013411". end. /*Атырау*/
    when "TXB12" then do: FILACC = "KZ30470142870A013612". end. /*Актау*/
    when "TXB13" then do: FILACC = "KZ84470142870A013513". end. /*Жезказган*/
    when "TXB14" then do: FILACC = "KZ56470142870A014114". end. /*Устькаменогорск*/
    when "TXB15" then do: FILACC = "KZ44470142870A014815". end. /*Чимкент*/
    when "TXB16" then do: FILACC = "KZ48470142870A025316". end. /*АФ*/
  end case.



  if GetFilialSumm( comm.txb.bank , OKsumm , FAILsumm ) then
  do:

    message "Обработка платежей в филиале " comm.txb.info.
    pause 1.

    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

    if OKsumm > 0 then
    do:

      /* message "RMZ OKsumm "  string(OKsumm)view-as alert-box.*/
               DFRZM = "".

               run rmzcretxb (
                1    ,
                OKsumm,
                FILACC ,
                ""    ,
                ""    ,
                "TXB00"   ,
                ALLACC    ,
                v-nbankru   ,
                "600400585309"   ,
                ''      ,
                no ,
                "856"  , /*кнп*/
                "14"  ,  /*код*/
                "14"  ,  /*кбе*/
                "Перевод денег Филиала " + comm.txb.info + " для осуществления взаиморасчетов сис. Авангард Плат" ,
                '2T'     ,
                1     ,
                5     ,
                g-today,
                'arp'    ).

              DFRZM = return-value.
              create wrk.
               wrk.txb = comm.txb.info.
               wrk.rmz = DFRZM.
               wrk.summ = OKsumm.
               wrk.des = "Перевод денег Филиала " + comm.txb.info + " для осуществления взаиморасчетов сис. Авангард Плат".
               wrk.stat = true.
             /*   message "Сформирован ОК = " return-value view-as alert-box.*/


    end.
    if FAILsumm > 0 then
    do:
      /*********************************************************************/
      def buffer b-com for comm.compaydoc.
      for each b-com where b-com.txb = comm.txb.bank
                       and (b-com.jh <> ? and b-com.jh <> 0)
                       and b-com.whn_cr = v-dt
                       and b-com.state <> -2
                       and b-com.state <> 2
                       and b-com.state <> 6
                       and b-com.state <> 7
                       no-lock:


           /*  message "RMZ FAILsumm " string(b-com.summ) view-as alert-box. */

                DFRZM = "".

                run rmzcretxb (
                1    ,
                b-com.summ,
                FILACC ,
                ""    ,
                ""    ,
                "TXB00"   ,
                XZACC    ,
                v-nbankru   ,
                "600400585309"   ,
                ''      ,
                no ,
                "856"  , /*кнп*/
                "14"  ,  /*код*/
                "14"  ,  /*кбе*/
                "Непроведенные платежи Филиала " + comm.txb.info + " Дос.No " + string(b-com.docno) + " " + GetAccName(b-com.supp_id , b-com.acc_id ) + " счет/тел." + GetAccNum(b-com.supp_id , b-com.acc_id ) + " Платежи:" + GetProvName( comm.txb.bank , b-com.supp_id) ,
                '2T'     ,
                1     ,
                5     ,
                g-today,
                'arp'    ).

              DFRZM = return-value.
              create wrk.
               wrk.txb = comm.txb.info.
               wrk.rmz = DFRZM.
               wrk.summ = b-com.summ.
               wrk.des = "Непроведенные платежи Филиала " + comm.txb.info + " Дос.No " + string(b-com.docno) + " " + GetAccName(b-com.supp_id , b-com.acc_id ) + " счет/тел." + GetAccNum(b-com.supp_id , b-com.acc_id ) + " Платежи:" + GetProvName( comm.txb.bank , b-com.supp_id).
               wrk.stat = false.
            /*  message "Сформирован FAIL = " return-value view-as alert-box.*/


      end.
      /*********************************************************************/

     end.
     if connected ("txb") then disconnect "txb".

  end. /*not GetFilialSumm*/
  else do:
    message "Нет платежей в филиале " comm.txb.info.
    pause 1.
  end.

end. /*for each*/


 do transaction:
   find first comm.pksysc where comm.pksysc.sysc = "comadm" exclusive-lock.
   comm.pksysc.daval = v-dt.
   release comm.pksysc.
 end. /*transaction*/


 run ExportExcel.

hide message no-pause.
/***************************************************************************************************************/
procedure ExportExcel.

   def var V as int init 0.
   for each wrk no-lock:
    V = V + 1.
   end.
   if V = 0 then return.

    output to svod.html.
    {html-title.i}

    def var OKsumm as deci.
    def var FAILsumm as deci.

    def var OKsumm_All as deci init 0.
    def var FAILsumm_All as deci init 0.

    def var I as int init 0.
    def var I_all as int init 0.

    def var Caption as char init "Результат работы процесса свода Авангард-Plat".
    Caption = Caption + " за " + GetDate(v-dt).

    put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.

    put unformatted "<tr><td align=center colspan=4><font size=""5""><b><a name="" ""></a>" Caption "</b></font></td></tr>" skip.

    for each wrk break by wrk.txb :
       /* put unformatted "<tr><td colspan=2><font size=""6""><b><a name=""" "D1" """></a>" "D2" "</b></font></td></tr>" skip.*/

        if FIRST-OF(wrk.txb) then
        do:
           put unformatted "<TR style=""font:bold;font-size:12pt"">" skip
                            "<TD align=center colspan=4> Филиал: " wrk.txb "</TD></TR>" skip.
           put unformatted "<TR style=""font:bold;font-size:11pt"">" skip
                                "<TD>" "№" "</TD>" skip
                                "<TD>" "Номер документа" "</TD>" skip
                                "<TD>" "Сумма платежа" "</TD>" skip
                                "<TD>" "Назначение" "</TD>" skip.
           I = 0.
           OKsumm = 0.
           FAILsumm = 0.
        end.

                I = I + 1.
                I_all = I_all + 1.


                put unformatted "<TR style=""font-size:10pt"">" skip
                                "<TD>" string(I) "</TD>" skip
                                "<TD>" wrk.rmz "</TD>" skip
                                "<TD>" GetNormSumm(wrk.summ) "</TD>" skip
                                "<TD>" wrk.des  "</TD>" skip.


                        if wrk.stat = true then
                        do:
                          OKsumm = OKsumm + wrk.summ.
                        end.
                        else if wrk.stat = false then
                        do:
                          FAILsumm = FAILsumm + wrk.summ.
                        end.



        if LAST-OF(wrk.txb) then
        do:

           OKsumm_All = OKsumm_All + OKsumm.
           FAILsumm_All = FAILsumm_All + FAILsumm.


           I = 0.
           OKsumm = 0.
           FAILsumm = 0.


        end.


        /*"<TD align=left>&nbsp;"*/


    end.



    put unformatted "<tr><td align=left colspan=4><font size=""2""><b><a name="" ""></a>ИТОГО ПО БАНКУ:</b></font></td></tr>" skip.

    put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD>" "Всего платежей:" "</TD>" skip
                                "<TD>" string(I_all) "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip.
    put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD>" "KZ47470142870A023200" "</TD>" skip
                                "<TD>" GetNormSumm(OKsumm_All) "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip.
    put unformatted "<TR style=""font:bold;font-size:10pt"">" skip
                                "<TD>" "KZ31470142870A023100" "</TD>" skip
                                "<TD>" GetNormSumm(FAILsumm_All) "</TD>" skip
                                "<TD>" "" "</TD>" skip
                                "<TD>" "" "</TD>" skip.


    put unformatted "</table>" .
    {html-end.i}
    output close.
   /* unix silent cptwin report.html iexplore.*/
    unix silent cptwin svod.html excel.
end procedure.
/***************************************************************************************************************/




