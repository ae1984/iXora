/* comreg.p
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

/* Формирование реестра для старшего кассира */


{classes.i}


def var Doc as class COMPAYDOCClass.         /* Класс документов коммунальных платежей */
def var SP  as class SUPPCOMClass.           /* Класс данных поставщиков */
def var v-dt as date init today label "С".   /* дата отбора с */
def var v-dt2 as date init today label "ПО". /* дата отбора по */
def var real-day as date.                    /* Текущая дата реестра */
def var days as int init 0.                  /* Разница в днях между v-dt и v-dt2 */
def var allsumm as deci init 0.
def var allcomm_sum as deci init 0.
def var tmpsumm as deci.
def var tmpcomm_sum as deci.
def var dcount as int init 1.
def var alldcount as int init 0.

def stream m-out.
def var v-text as char init "".
def var v as char init "" no-undo.
def var L as char init "------------------------------------------------------------------------------".
def var rez as log.

 Doc = NEW COMPAYDOCClass(Base).
 SP  = NEW SUPPCOMClass(Base).
 SP:txb = Doc:b-txb.

/*********************************************************************************************************************/
 function GenFooter returns log ( input Doc as date ):
   put stream m-out unformatted L skip.
   v-text = "ИТОГО ПО ВСЕМ ВИДАМ ПЛАТЕЖЕЙ ЗА " + string(Doc) + ":".
   put stream m-out unformatted  v-text skip.
   v-text = "КОЛ-ВО ДОКУМЕНТОВ      :  " + string(alldcount,">>>>>>>>.").
   put stream m-out unformatted  v-text skip.
   v-text = "СУММА ОСНОВНЫХ ПЛАТЕЖЕЙ:" + string(allsumm,">>,>>>,>>>.99").  /*99999999.99*/
   put stream m-out unformatted  v-text skip.
   v-text = "СУММА КОМИССИИ         :" + string(allcomm_sum,">>,>>>,>>>.99").
   put stream m-out unformatted  v-text skip.

   put stream m-out unformatted L skip(2).
   allsumm = 0.
   allcomm_sum = 0.
   alldcount = 0.

 end function.
/*********************************************************************************************************************/
 function GenRez returns log ():
   if tmpsumm > 0 then
   do:
     v-text = "                                           Итого: " +
     string(tmpsumm,">>>,>>>.99") + "|" +  string(tmpcomm_sum,">,>>>.99").
     put stream m-out unformatted  v-text skip(1).
     allsumm = allsumm + tmpsumm.
     allcomm_sum = allcomm_sum + tmpcomm_sum.
     return true.
   end.
   else return false.
 end function.
/*********************************************************************************************************************/
 function GenReg returns log ( input Doc as Class COMPAYDOCClass):
    def var Line as class COMPAYDOCClass.
    Line = NEW COMPAYDOCClass(Base).
    def var y as int.
    def var tmpx as int.
    def var tmpd as date.
    tmpx = 0.
    Doc:ElementBy(1).
    tmpd = Doc:whn_cr.
    allsumm = 0.
    allcomm_sum = 0.
    tmpsumm = 0.
    tmpcomm_sum = 0.

    REPEAT y = 1 to Doc:Count:
     Doc:ElementBy(y).
       if tmpx <> Doc:supp_id or tmpd <> Doc:whn_cr then
       do:
        /*******************************************************************************************/
        GenRez().
        if tmpd <> Doc:whn_cr  then do: GenFooter(tmpd).  end.
        /*******************************************************************************************/

         Line:FindDocNo(string(Doc:docno)).
         put stream m-out unformatted  L skip.
         v-text = "Платежи поступившие для " + Line:suppname + " за " + string(Line:whn_cr).
         put stream m-out unformatted  v-text skip.
         put stream m-out unformatted  L skip.
         v-text = "| № | Док.№ |          Назначение платежа          | Сумма  |Комиссия|Кассир |".
         put stream m-out unformatted  v-text skip.
         put stream m-out unformatted  L skip.
         tmpx = Doc:supp_id.
         tmpd = Doc:whn_cr.
         tmpsumm = 0.
         tmpcomm_sum = 0.
         dcount = 1.
       end.

        Line:FindDocNo(string(Doc:docno)).
        v-text = "|" + string(dcount,"999") + "|" +  string(Line:docno,"9999999") + "| " +
        string( Line:payacc + " " + Line:payname ,"x(37)" ) + "|" + string(Line:summ,">>>>>.99") + "|" + string(Line:comm_summ,">>>>>.99") + "|" + Line:who_cr + "|".
        put stream m-out unformatted  v-text skip.
        tmpd = Doc:whn_cr.
        tmpsumm = tmpsumm + Line:summ.
        tmpcomm_sum = tmpcomm_sum + Line:comm_summ.

        alldcount = alldcount + 1.
        dcount = dcount + 1.

        if y = Doc:Count then
        do:
          GenRez().
          GenFooter(tmpd).
        end.

    END.

    if VALID-OBJECT(Line)  then DELETE OBJECT Line NO-ERROR.
 end function.
/*********************************************************************************************************************/
 function GenHeader returns log ( input Doc as Class COMPAYDOCClass):
   /* put stream m-out unformatted L skip.*/
   v-text = g-comp.
   put stream m-out unformatted  v-text skip(2).
   v-text = "                РЕЕСТР ПРИНЯТЫХ КОММУНАЛЬНЫХ ПЛАТЕЖЕЙ".
   put stream m-out unformatted  v-text skip.
   v-text = "                        " + string(v-dt) + "-" + string(v-dt2).
   put stream m-out unformatted  v-text skip(2).

 end function.
/*********************************************************************************************************************/
/* ОСНОВНАЯ ЧАСТЬ ПРОГРАММЫ */


 run help-suppay(SP,"reg").
 if SP:name = ? or SP:name = "" then
 do:
   run yn("","Выйти из программы?","","", output rez).
   if rez then  return.
   else do: run comreg. end.
 end.
 else do:
     /*Форма выбора диапазона */
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

     /*********************************************************************************************************************/
     if SP:type = 0 then SP:Find-All("type > 0 and txb = '"+ SP:txb + "' no-lock").
     else SP:Find-All("supp_id = " + string(SP:supp_id) + " no-lock").

     SP:ElementBy(1).
     def var supp_txt as char.
     supp_txt = " and ( supp_id = " + string(SP:supp_id).
     def var x as int.
     if SP:Count > 1 then
     do:
       REPEAT x = 2 to SP:Count:
         SP:ElementBy(x).
         supp_txt = supp_txt + " or supp_id = " + string(SP:supp_id).
       END.
     end.

                                                                                               /*and note = ?  b-compaydoc.state <> -2*/
       if Doc:Find-All(" whn_cr >= " + string(v-dt) + " and whn_cr <= " + string(v-dt2) + supp_txt + " ) and jh <> ? and state <> -2 and state <> 7 no-lock BY whn_cr BY supp_id") > 0 then
       do:
         output stream m-out to regfile.tmp.
         GenHeader(Doc).
         GenReg(Doc).
         output stream m-out close.
         /*
         input through value("scp regfile.tmp  Administrator@`askhost`:c:\\\\tmp\\\\regfile.doc ;echo $?").
         repeat:
	       import unformatted v.
         end.
         if v <> "0" then do: message "Ошибка при копировании regfile.tmp " + v view-as alert-box. end.
        */
         unix silent value( 'cptwin regfile.tmp winword.exe').

       end.
       else message "Записи не найдены!" view-as alert-box.
 end.

 if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR.
 if VALID-OBJECT(SP)   then DELETE OBJECT SP  NO-ERROR .

/*********************************************************************************************************************/



/*

procedure man-expexc. /* -------------- Экспорт вопросов в EXCEL ---------------------- */
    output to call_center.html.
    {html-title.i}
    for each them where them.sid <> 0 no-lock .
        put unformatted "<font size=""6""><b><a href=""\#" them.nu """>" them.them "</a></b></font><br>" skip.
    end.
    put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.
    for each them where them.sid <> 0 no-lock .
        put unformatted "<tr><td colspan=2><font size=""6""><b><a name=""" them.nu """></a>" them.them "</b></font></td></tr>" skip.
        for each sthem where sthem.them = them.nu and sthem.sid <> 0 no-lock .
            put unformatted "<TR style=""font:bold;font-size:12pt"">" skip
                            "<TD colspan=2>" sthem.sub "</TD></TR>" skip.
            for each ques where ques.sub = sthem.nu and ques.sid <> 0 no-lock.
                put unformatted "<TR style=""font-size:10pt"">" skip
                                "<TD>" ques.ques "</TD>" skip
                                "<TD>" ques.answ "</TD>" skip.
            end.
        end.
    end.
    put unformatted "</table>" .
    {html-end.i}
    output close.
    unix silent cptwin call_center.html iexplore.
/*    unix silent cptwin value(v-file) excel.*/
end procedure.

*/