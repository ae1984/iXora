/* ordconv.p
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
        31/12/99 pragma
 * CHANGES
        01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        13/05/2004 madiar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        12/07/2004 tsoy - вернул старую версию до уточненния и тестирования ТЗ
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
        06.07.2005 dpuchkov - birz_int = 0.00 (т.к. кто то удалил тариф биржевой комиссии)
        25.08.2005 saltanat - Выборка льгот по счетам.
        06.10.2005 dpuchkov - добавил проверку на дебетовое сальдо при удалении транзакции.
        17.03.2006 dpuchkov - добавил цели конвертации.
        07.04.2006 ten      - добавил цели конвертации по inbank.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

&GLOBAL-DEFINE DEB_EXL

{global.i}
{crc-crc.i}
def var  documN     like dealing_doc.docno label "Номер документа" no-undo.
def var  documType  as integer initial 2 /*тип документа 2 обычная конвертация*/ no-undo.
def var  taccno     as char    label "Счет клиента для снятия средств    " format "x(9)" no-undo.
def var  vaccno     as char    label "Счет клиента для зачисления средств" format "x(9)" no-undo.
def var  currency   as integer label "Валюта" format ">9" no-undo.
def var  clientno   as char    label "ID клиента" no-undo.
def var  clientname like cif.name    label "Клиент" format "x(45)" no-undo.
def var  tamount    as decimal    label "Сумма на конвертацию в тенге "  format "zzz,zzz,zzz,zzz.99" no-undo.
def var  vamount    as decimal    label "Сумма на конвертацию в валюте" format "zzz,zzz,zzz,zzz.99" no-undo.
def var  famount    as decimal no-undo.
def var  conv_com   as decimal    label "Комиссия за конвертацию      " format "zzz,zzz,zzz,zzz.99" no-undo.
def var  birz_com   as decimal    label "Биржевая комиссия            " format "zzz,zzz,zzz,zzz.99" no-undo.

def var  avg_tamount    as decimal  format "zzz,zzz,zzz,zzz.99" no-undo.
def var  diff_tamount    as decimal  format "zzz,zzz,zzz,zzz.99" no-undo.
def var  litems     as char no-undo.
def var  currate    as decimal label "Курс" format "zzz,zzz.9999" no-undo.
def var  currate2   as decimal label "Текущий курс" format "zzz,zzz.9999" no-undo. /*Курс на момент зачисления*/
def var  l-tran     as logical no-undo. /*да сделать транзакцию*/
def var  gcom       as logical no-undo.
def buffer b-aaastr for aaa .

def new shared var s-jh like jh.jh.

def var retval as char no-undo.
def var rcode as int no-undo.
def var rdes  as cha no-undo.
def var dlm as char init "|" no-undo.

def var rem as char initial "1223asfdasdfa" no-undo.
def var cur_time as integer no-undo.
def var ans as logical no-undo.
def var v-sts like jh.sts no-undo.

def var  tamount_proc as decimal  label "Окончательная сумма в тенге  " format "zzz,zzz,zzz,zzz.99" no-undo.
/*Сумма в валюте + ком. за срочность + ком. за конвертацию + биржевая */

def var conv_int as decimal format "zzz,zzz,zzz,zzz.9999" initial "0.25" label "Процент комиссии за конвертацию" no-undo.
def var conv_int_min as decimal format "zzz,zzz,zzz,zzz.9999" initial "15"  label "Минимальный процент по комиссии" no-undo.
def var conv_int_max as decimal format "zzz,zzz,zzz,zzz.9999" label "Максимальный процент по комиссии" no-undo.
def var cim_notusd as decimal no-undo. /*используется если валюты не доллары*/
def var birz_int as decimal initial "0.00" label "Процент биржевой комиссии" no-undo.
def var conv_temp as decimal format "zzz,zzz,zzz,zzz.9999" no-undo.
def var tfirst as logical.   /*true если сначала была введена сумма в тенге
                               false если сперва была сумма в валюте */
def shared var dType as integer.
def var vozvrat as logical no-undo. /*если true то делается проводка возврат несконвертированных средств иначе
                             зачисление недостающей суммы */
def var diff_amount as decimal format "zzz,zzz,zzz,zzz.99" initial 0 no-undo.
 /*разница между суммами в результате смены курса*/

/*def var min_com as logical label "Минимум при взятии комиссии" format "да/нет" init "yes".*/

def buffer dcrc for crc.

define variable m_sub as character initial "dil" no-undo.

define frame dframe1 documN skip
                     clientno clientname skip
                     taccno skip
                     vaccno skip
                     currency space (5) currate skip(1)
                     tamount vamount skip(1)
                     conv_com skip
                     birz_com skip(2)

                     tamount_proc skip
             WITH /*KEEP-TAB-ORDER*/ SIDE-LABELS TITLE "Обычная конвертация".

define frame dframe2 documN with SIDE-LABELS.

define frame dframe3 conv_int with SIDE-LABELS OVERLAY CENTERED.

define frame dframe4 documN with SIDE-LABELS.

SESSION:SYSTEM-ALERT-BOXES = true.

{dil_util.i}

on help of currency in frame dframe1 do:
    run help-crc1.
end.

on help of documN in frame dframe1 do:
   run help-dilnum.
end.

on help of documN in frame dframe2 do:
   run help-dilnum2.
end.

on help of documN in frame dframe4 do:
   run help-dilnum.
end.


procedure find_client:
       find aaa where aaa.aaa eq taccno no-lock no-error.
       if not available aaa
          then message "Счет" taccno "не найден" view-as alert-box.
          else do:
              find cif where cif.cif eq aaa.cif no-lock no-error.
              if not available cif
                 then message "Не найден клиент" aaa.cif.
                 else do:
                   clientname = trim(trim(cif.prefix) + " " + trim(cif.name)).
                   clientno = cif.cif.

                   /* 05/07/05 saltanat - Если у клиента есть льготы по счету, то берем тариф по счету */
                   find first tarifex2 where tarifex2.aaa = aaa.aaa
                                         and tarifex2.cif = clientno
                                         and tarifex2.str5 = '802'
                                         and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
            	         conv_int = tarifex2.proc.
                	     conv_int_min = crc-crc-date(tarifex2.min1, tarifex2.crc, 2, dealing_doc.whn_cr).
                    	 conv_int_max = crc-crc-date(tarifex2.max1, tarifex2.crc, 2, dealing_doc.whn_cr).
                      release tarifex2 no-error.
                   end.
                   else do:
	                   find first tarifex where tarifex.str5 = '802' and tarifex.cif = clientno
    	                                    and tarifex.stat = 'r' share-lock no-error.
        	           if available tarifex then do:
            	         conv_int = tarifex.proc.
                	     conv_int_min = crc-crc-date(tarifex.min1, tarifex.crc, 2, dealing_doc.whn_cr).
                    	 conv_int_max = crc-crc-date(tarifex.max1, tarifex.crc, 2, dealing_doc.whn_cr).
	                   end.
    	               release tarifex no-error.
                   end.

                   /* 05/07/05 saltanat - Если у клиента есть льготы по счету, то берем тариф по счету */
                   find first tarifex2 where tarifex2.aaa = aaa.aaa
                                         and tarifex2.cif = clientno
                                         and tarifex2.str5 = '805'
                                         and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
                      birz_int = tarifex2.proc.
                      release tarifex2 no-error.
                   end.
                   else do:
	                   find first tarifex where tarifex.str5 = '805' and tarifex.cif = clientno
    	                                    and tarifex.stat = 'r' share-lock no-error.
        	           if available tarifex then do: birz_int = tarifex.proc. end.
            	       release tarifex no-error.
                   end.

                   {tr4sign.i}
                 end.
          end.
end procedure.


procedure get_precamt:

def var delta as decimal.

repeat:
  delta = trunc( (tamount_proc - birz_com) / currate - vamount - conv_com, 8) .
  if delta < 0 then
     tamount_proc = tamount_proc + (absolute(delta) * currate).
  if delta > 0 then
     tamount_proc = tamount_proc - (delta * currate).
  if delta = 0
     then
       do:
          tamount_proc = round (tamount_proc, 3).
          tamount_proc = round (tamount_proc, 2).
          leave.
       end.
end.

end procedure.

procedure Init_Vars:

vaccno  = ''.
taccno  = ''.
currency = 0.
clientno = ''.
clientname = ''.
tamount    = 0.
vamount    = 0.
conv_com   = 0.
birz_com   = 0.


currate = 0.
currate2 = 0.
l-tran = false.

s-jh = 0.



tamount_proc =0.
conv_int = 0.25.
conv_int_min = 15.
conv_int_max = 0.
birz_int = 0.00.



if documn = "" then find dealing_doc where dealing_doc.docno = documn no-lock no-error.

/*
if dealing_doc.who_cr = "inbank" then do:
find first tarif2 where tarif2.num + tarif2.kod = '802' and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then
   do:
      conv_int = tarif2.proc.
      conv_int_min = crc-crc-date(tarif2.min1, tarif2.crc, 2, dealing_doc.whn_cr).
      conv_int_max = crc-crc-date(tarif2.max1, tarif2.crc, 2, dealing_doc.whn_cr).
   end.

end.
*/
conv_temp = 0.

end procedure.


procedure new_doc:

do transaction:

repeat on ENDKEY UNDO , leave:

clear frame dframe1 NO-PAUSE.
documn = ''.
litems = "".
l-tran = false.

run generate_docno.

run Init_vars.

displ documN with frame dframe1.

set taccno with frame dframe1.
 if taccno entered
   then
     do:
       find aaa where aaa.aaa eq taccno no-lock no-error.
       if not available aaa
          then do: message "Счет" taccno "не найден" view-as alert-box. undo,retry. end.
          else do:
              find cif where cif.cif eq aaa.cif no-lock no-error.
              if not available cif
                 then do: message "Не найден клиент" aaa.cif. undo,retry. end.
                 else do:
                   clientname = trim(trim(cif.prefix) + " " + trim(cif.name)).
                   clientno = cif.cif.
                   display clientno clientname with frame dframe1.
                   /* 05/07/05 saltanat - Если у клиента есть льготы по счету, то берем тариф по счету */

                   find first tarifex2 where tarifex2.aaa = aaa.aaa
                                         and tarifex2.cif = clientno
                                         and tarifex2.str5 = '802'
                                         and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
            	         conv_int = tarifex2.proc.
                         conv_int_min = crc-crc(tarifex2.min1, tarifex2.crc, 2).
                         conv_int_max = crc-crc(tarifex2.max1, tarifex2.crc, 2).
                      release tarifex2 no-error.
                   end.
                   else do:
	                   find first tarifex where tarifex.str5 = '802' and tarifex.cif = clientno
    	                                    and tarifex.stat = 'r' share-lock no-error.
        	           if available tarifex then do:
            	        conv_int = tarifex.proc.
                        conv_int_min = crc-crc(tarifex.min1, tarifex.crc, 2).
                        conv_int_max = crc-crc(tarifex.max1, tarifex.crc, 2).
	                   end.
    	               release tarifex no-error.
                   end.

                   /* 05/07/05 saltanat - Если у клиента есть льготы по счету, то берем тариф по счету */
                   find first tarifex2 where tarifex2.aaa = aaa.aaa
                                         and tarifex2.cif = clientno
                                         and tarifex2.str5 = '805'
                                         and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
                      birz_int = tarifex2.proc.
                      release tarifex2 no-error.
                   end.
                   else do:
	                   find first tarifex where tarifex.str5 = '805' and tarifex.cif = clientno
    	                                    and tarifex.stat = 'r' share-lock no-error.
        	           if available tarifex then do: birz_int = tarifex.proc. end.
            	       release tarifex no-error.
                   end.

                   {tr4sign.i}
                 end.
          end.
     end.
   else undo,retry.
/*   if check_acc(taccno) then undo,retry.*/


set currency with frame dframe1.
if currency entered
   then do:
     find crc where crc.crc eq currency no-lock no-error.
     if not available crc then do: message "Валюта" currency "не найдена" view-as alert-box. undo, retry. end.
        else do:


/*ЛЬГОТНЫЙ ТАРИФ*/
if cif.type = "p" then do:
   if currency = 2 or currency = 3 or currency = 4 then do:
       find first tarifex2 where tarifex2.aaa = aaa.aaa and tarifex2.cif = clientno and tarifex2.str5 = '810' and tarifex2.stat = 'r' no-lock no-error.
       if available tarifex2 then do:
            conv_int = tarifex2.proc.
            conv_int_min = crc-crc(tarifex2.min1, tarifex2.crc, 2).
       end.

       find first tarifex where tarifex.str5 = '810' and tarifex.cif  = clientno and tarifex.stat = 'r' share-lock no-error.
       if available tarifex then do:
            conv_int = tarifex.proc.
            conv_int_min = crc-crc(tarifex.min1, tarifex2.crc, 2).
       end.
   end.
   else do:
      find first tarifex2 where tarifex2.aaa = aaa.aaa and tarifex2.cif = clientno and tarifex2.str5 = '815' and tarifex2.stat = 'r' no-lock no-error.
      if available tarifex2 then do:
           conv_int = tarifex2.proc.
           conv_int_min = crc-crc(tarifex2.min1, tarifex2.crc, 2).
      end.

      find first tarifex where tarifex.str5 = '815' and tarifex.cif  = clientno and tarifex.stat = 'r' share-lock no-error.
      if available tarifex then do:
         conv_int = tarifex.proc.
         conv_int_min = crc-crc(tarifex.min1, tarifex2.crc, 2).
      end.

   end.
end.
else
do:
   find first tarifex2 where tarifex2.aaa = aaa.aaa and tarifex2.cif = clientno and tarifex2.str5 = '802' and tarifex2.stat = 'r' no-lock no-error.
       if available tarifex2 then do:
            conv_int = tarifex2.proc.
            conv_int_min = crc-crc(tarifex2.min1, tarifex2.crc, 2).
       end.

   find first tarifex where tarifex.str5 = '802' and tarifex.cif  = clientno and tarifex.stat = 'r' share-lock no-error.
       if available tarifex then do:
            conv_int = tarifex.proc.
            conv_int_min = crc-crc(tarifex.min1, tarifex2.crc, 2).
       end.
end.
/*ЛЬГОТНЫЙ ТАРИФ*/


 if (not avail tarifex) and (not avail tarifex2) then do:
      if cif.type = "p" then do:
         if currency = 2 or currency = 3 or currency = 4 then do:
            find first tarif2 where tarif2.num + tarif2.kod = '810' and tarif2.stat = 'r' no-lock no-error.
         end.
         else
         do:
            find first tarif2 where tarif2.num + tarif2.kod = '815' and tarif2.stat = 'r' no-lock no-error.
         end.

      end.
      else
      do:
         find first tarif2 where tarif2.num + tarif2.kod = '802' and tarif2.stat = 'r' no-lock no-error.
      end.
      if avail tarif2 then
      do:
           conv_int = tarif2.proc.
           conv_int_min = crc-crc(tarif2.min1, tarif2.crc, 2).
           conv_int_max = crc-crc(tarif2.max1, tarif2.crc, 2).
      end.
 end.



           for each aaa where aaa.crc eq currency and aaa.cif eq clientno and aaa.sta <> 'C' break by aaa.crc:
             find lgr where lgr.lgr = aaa.lgr.
             if available lgr then if lgr.led <> 'oda' then
             if last-of(aaa.crc) then litems = litems + aaa.aaa.
                                 else litems = litems + aaa.aaa + "|".
           end.
           if litems = '' then do: message "У клиента нет счета в такой валюте" view-as alert-box. undo,return. end.
           else
             do:
                run sel1("Выберите счет", litems).
                vaccno = return-value.
                if vaccno = '' then undo,retry.
                update vaccno with frame dframe1.

                case currency:
                     when 2 then find sysc where sysc.sysc = 'ocusd'.
                     when 4 then find sysc where sysc.sysc = 'ocrur'.
                     when 3 then find sysc where sysc.sysc = 'oceur'.
                end.
                currate = sysc.deval.

                update currate with frame dframe1.
                set tamount with frame dframe1.
                if tamount entered
                   then do: famount = tamount. tfirst = true. run getperc_tamt. end.
                   else do:
                     set vamount with frame dframe1.
                     if vamount entered
                        then do: famount = vamount. tfirst = false. run getperc_vamt. end.
                   end.
if check_acc(taccno,tamount_proc,false) then undo,retry.
                displ vamount conv_com birz_com tamount tamount_proc with frame dframe1.
                run create_doc.
                pause.
                run yn("","Сделать транзакцию?","","", output l-tran).
                if l-tran then do:
                   {cnv.i}
                   run do_trans1.
                   create trgt.
                          trgt.jh = s-jh.
                          trgt.rem1 = v-sln1.
                          trgt.rem2 = v-sln2.

                   return.
                end.
             end.
        end.
   end.
end.

end. /*end transaction*/

hide frame dframe1.

end procedure.

procedure open_doc:
/*
documn = "".

clear frame dframe1.
set documN with frame dframe1.

do transaction on error undo, return:
   find dealing_doc where docno = documN and dealing_doc.doctype = dType share-lock no-error.
   if available (dealing_doc)
    then
      do:
         if ((dealing_doc.jh <> ?) and (dealing_doc.jh <> 0)) or ((dealing_doc.jh2 <> ?) and (dealing_doc.jh2 <> 0))
           then
             do:
                message "Вы не можете редактировать документы" skip "с существующей транзакцией" view-as alert-box.
                hide all.
                undo, return.
             end.
         if dealing_doc.who_cr <> g-ofc
           then
             do:
                message "Вы не можете редактировать документы принадлежащие" skip dealing_doc.who_cr view-as alert-box.
                hide all.
                undo,return.
             end.
         documtype = dealing_doc.doctype.
         vamount = dealing_doc.v_amount.
         tamount = dealing_doc.t_amount.
         taccno = dealing_doc.tclientaccno.
         if check_acc(taccno) then undo,leave.
         vaccno = dealing_doc.vclientaccno.
         conv_com = dealing_doc.com_conv.
         birz_com = dealing_doc.com_bourse.
         currate = dealing_doc.rate.
         currency = dealing_doc.crc.
         documtype = dealing_doc.doctype.
         run find_client.
         display clientno clientname taccno vamount tamount taccno vaccno conv_com birz_com currate currency tamount_proc with frame dframe1.
         update currate with frame dframe1.
         update tamount with frame dframe1.
         if tfirst
            then run getperc_tamt.
            else
              do:
                update vamount with frame dframe1.
                run getperc_vamt.
              end.
              if currency = 4 then birz_com = 0.
              displ conv_com birz_com tamount_proc with frame dframe1.
              pause.
              message "Отредактировать проценты по комиссии?" view-as alert-box buttons yes-no title "" update wahl as log.
              if wahl then
                   do:
                      update conv_int with frame dframe3.
                      if tfirst then run getperc_tamt.
                                else run getperc_vamt.
                   end.
              displ conv_com.
              run update_doc.
              pause.
         hide frame dframe1.
      end.
    else
      do:
         message "Документа с таким номером не существует" view-as alert-box.
         undo,retry.
      end.

end.
*/
end procedure.

procedure view_doc:

  clear frame dframe1.
/*  documn = ''.
  set documn with frame dframe1.*/
  if this-procedure:private-data = ?
     then
       do:
         /* documn = ''.
          set documn with frame dframe1.*/
          if documn = '' then set documn with frame dframe1.
       end.
     else
       do:
          documn = this-procedure:private-data.
          displ documn with frame dframe1.
       end.
  do transaction:
     find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType no-lock no-error.
     if available (dealing_doc) then
        do:
           run Init_Vars.
           documtype = dealing_doc.doctype.
           vamount = dealing_doc.v_amount.
           tamount = dealing_doc.t_amount.
           taccno = dealing_doc.tclientaccno.
           vaccno = dealing_doc.vclientaccno.
           conv_com = dealing_doc.com_conv.
           birz_com = dealing_doc.com_bourse.
           currate = dealing_doc.rate.
           currate2 = dealing_doc.rate2.
           currency = dealing_doc.crc.

tamount_proc = dealing_doc.t_amt_coms.
           famount = dealing_doc.f_amount.
           run find_client.
           if this-procedure:private-data <> ?
              then do: if dealing_doc.tngtoval then tamount = famount. else vamount = famount. end.
           display vamount tamount taccno vaccno conv_com birz_com currate currate2 currency clientno clientname tamount_proc with frame dframe1.
           if this-procedure:private-data <> ?
              then
                do:
                  if ((dealing_doc.jh = ?) or (dealing_doc.jh = 0)) and
                     ((dealing_doc.jh2 = ?) or (dealing_doc.jh2 = 0))
                    then
                     do:
                        update currate with frame dframe1.
                        find current dealing_doc exclusive-lock.
                        dealing_doc.rate = currate.
                        dealing_doc.who_mod = g-ofc.
                        if dealing_doc.tngtoval
                          then
                            do:
                              tamount = famount.
                              run getperc_tamt.
                              dealing_doc.t_amt_coms = tamount_proc.
                              dealing_doc.t_amount = tamount.
                            end.
                          else
                           do:
                             vamount = famount.
                             run getperc_vamt.
                             dealing_doc.t_amount = tamount.
                             dealing_doc.t_amt_coms = tamount_proc.
                           end.
                        dealing_doc.v_amount = vamount.
                        dealing_doc.com_conv = conv_com.
                        dealing_doc.com_bourse = birz_com.
                        find current dealing_doc no-lock.
                     end.
                end.
           display vamount tamount taccno vaccno conv_com birz_com currate currate2 currency clientno clientname tamount_proc with frame dframe1.
        end.
      else do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
  end. /* do */
end procedure.

procedure delete_doc:
  clear frame dframe4.
/*  set documn with frame dframe2.*/
  if documn = '' then set documn with frame dframe4.
  do transaction:
     find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType share-lock no-error.
     if available (dealing_doc) then
        do:
            if dealing_doc.who_mod <> g-ofc
              then do:
                  message "Вы не можете удалять документы принадлежащие" dealing_doc.who_mod view-as alert-box.
                  return.
              end.
            if ((dealing_doc.jh <> ?) and (dealing_doc.jh <> 0)) or ((dealing_doc.jh2 <> ?) and (dealing_doc.jh2 <> 0))
              then do:
                  message "Вы не можете удалить документ с существующей транзакцией" skip "Удалите сначала транзакцию" view-as alert-box.
                  return.
              end.
            run yn("", "Вы уверены что хотите удалить документ?", "","" ,output ans).
            if ans then delete dealing_doc. else return.
        end.
      else do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
  end. /* do */
end procedure.

procedure create_trans:
  do transaction:
/*     documn = "".*/
     clear frame dframe4.
/*     set documn with frame dframe2.*/
     if documn = '' then set documn with frame dframe4.
     find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType share-lock no-error.
     if not available(dealing_doc) then do: message "Документа с таким номером не существует" view-as alert-box. undo,retry. end.
       else do:
         if dealing_doc.who_mod <> g-ofc
            then do:
                 message "Документ принадлежит" dealing_doc.who_mod skip "Транзакция не будет сделана" view-as alert-box.
                 return.
            end.
         if (dealing_doc.jh = ? or dealing_doc.jh = 0) and (dealing_doc.jh2 = ? or dealing_doc.jh2 = 0)
            then
              do:
                vamount = dealing_doc.v_amount.
                tamount = dealing_doc.t_amount.
                tamount_proc = dealing_doc.t_amt_coms.
                taccno = dealing_doc.tclientaccno.
/*                if check_acc(taccno) then undo,leave.*/
if check_acc(taccno,tamount_proc,false) then undo,leave.
                vaccno = dealing_doc.vclientaccno.
                conv_com = dealing_doc.com_conv.
                birz_com = dealing_doc.com_bourse.
                currency = dealing_doc.crc.
                currate = dealing_doc.rate.
            run yn("","Сделать транзакцию?","","", output l-tran).
            if l-tran then do:
               if dealing_doc.who_cr <> "inbank" then do:
                  {cnv.i}
                  run do_trans1.
                  create trgt.
                         trgt.jh = s-jh.
                         trgt.rem1 = v-sln1.
                         trgt.rem2 = v-sln2.
                  return.
               end.
               else do:
                  find trgt where trgt.jh eq int(dealing_doc.docno) exclusive-lock no-error.
                  if avail trgt then do:
                     s-jh = 0.
                     run do_trans1.
                     if s-jh <> 0 then trgt.jh = s-jh.
                  end.
               end.
            end.
            else do: hide all. undo,return. end.
              end.
            else
              do:
                message "Первая или вторая транзакция" skip "для документа" documn "уже существует" view-as alert-box title "".
                return.
              end.
       end.
  end.
end procedure.

procedure create_trans2: /*ВТОРАЯ ТРАНЗАКЦИЯ*/
  do transaction:
     diff_amount = 0.
     documn = "".
     clear frame dframe2.
     set documn with frame dframe2.
     find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType share-lock no-error.
     if not available(dealing_doc) then do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
       else do:
        /* if dealing_doc.who_mod <> g-ofc
            then do:
                 message "Документ принадлежит" dealing_doc.who_mod skip "Транзакция не будет сделана" view-as alert-box.
                 return.
            end.*/
         if (dealing_doc.jh <> ? and dealing_doc.jh <> 0) and (dealing_doc.jh2 = ? or dealing_doc.jh2 = 0)
            then
              do:
                run Init_vars.
                vamount = dealing_doc.v_amount.
                tamount = dealing_doc.t_amount.
/*              tamount_proc = dealing_doc.t_amt_coms.*/
                taccno = dealing_doc.tclientaccno.
/*                if check_acc(taccno) then undo,leave.*/
                vaccno = dealing_doc.vclientaccno.
/*                if check_acc(vaccno) then undo,leave.*/
/*              conv_com = dealing_doc.com_conv.
                birz_com = dealing_doc.com_bourse.*/
                currency = dealing_doc.crc.
                currate = dealing_doc.rate.
                tfirst  = dealing_doc.TngToVal.
/*                if tfirst then run getperc_tamt. else run getperc_vamt.*/
                if dealing_doc.rate2 <> ? or dealing_doc.rate2 <> 0 then currate2 = dealing_doc.rate2.
                                          else currate2 = currate.
                run find_client.
                case currency:
                     when 2 then find sysc where sysc.sysc = 'ocusd'.
                     when 4 then find sysc where sysc.sysc = 'ocrur'.
                     when 3 then find sysc where sysc.sysc = 'oceur'.
                end.
                currate2 = sysc.deval.

                update currate2.

                if currate2 > currate then vozvrat = false. else vozvrat = true.
                currate = currate2.
                dealing_doc.rate2 = currate.
                if tfirst then run getperc_tamt.
                          else
                            do:
                               vamount = vamount - dealing_doc.com_conv.
                               run getperc_vamt.
/*                               diff_amount = abs((dealing_doc.t_amt_coms + dealing_doc.com_bourse) - (tamount_proc + birz_com)).*/
                               tamount_proc = round (tamount_proc,3).
                               tamount_proc = round (tamount_proc,2).
                               diff_amount = dealing_doc.t_amt_coms - tamount_proc.
                               if diff_amount < 0 then vozvrat = false. else vozvrat = true.
                               diff_amount = abs(diff_amount) .

                            end.
                displ clientno clientname vamount tamount taccno vaccno conv_com birz_com currate2 currency clientno clientname tamount_proc with frame dframe1.
                currate = dealing_doc.rate.
                displ currate with frame dframe1.
                pause.
/*        message diff_amount tamount_proc birz_com view-as alert-box.*/
/*                message diff_amount view-as alert-box title "".*/
                run yn("","Сделать транзакцию?","","", output l-tran).
                if l-tran then
                            do:
                               if diff_amount = 0
                                  then
                                     do:
                                       run do_trans3.
                                       return return-value.
                                    end.
                                  else
                                    do:

                                       run do_trans2.
                                       return return-value.
                                    end.
                            end.
                          else do: hide all. undo, return. end.
              end.
            else
              do:
                message "Отсутствует первая транзакция " skip "или вторая транзакция для документа" documn "уже существует" view-as alert-box title "".
                return.
              end.
       end.
  end.
end procedure.


procedure print_doc.
     clear frame dframe4.
     if documn = '' then set documn with frame dframe4.
     find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType no-lock no-error.
     if not available(dealing_doc) then do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
       else do:
         if ((dealing_doc.jh <> ?) and (dealing_doc.jh <> 0))
            then
              do:
                 if dealing_doc.who_cr <> g-ofc and dealing_doc.who_cr <> 'inbank'
                    then do:
                         message "Документ принадлежит" dealing_doc.who_cr view-as alert-box.
                         return.
                    end.
                s-jh = dealing_doc.jh.
                run dvou("prit").
              end.
         if ((dealing_doc.jh2 <> ?) and (dealing_doc.jh2 <> 0))
            then
              do:
                 if dealing_doc.who_mod <> g-ofc
                    then do:
                         message "Документ принадлежит" dealing_doc.who_mod view-as alert-box.
                         return.
                    end.
                s-jh = dealing_doc.jh2.
                run dvou2("prit").
              end.
       end.
end procedure.

procedure create_doc:
  find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType share-lock no-error .
  if not available dealing_doc
     then
       do:
          create dealing_doc.
          dealing_doc.docno = DocumN.
          dealing_doc.crc = crc.crc.
          dealing_doc.doctype = dType.
          if (vamount = ?) or (vamount = 0)
             then do:
               message "Сумма в валюте отсутсвует или равна нулю" view-as alert-box.
               return.
             end.
          dealing_doc.v_amount = vamount.
          dealing_doc.t_amount = tamount.
          dealing_doc.t_amt_coms = tamount_proc.
          dealing_doc.tclientaccno = taccno.
          dealing_doc.vclientaccno = vaccno.
          dealing_doc.com_conv = conv_com.
          dealing_doc.com_bourse = birz_com.
          dealing_doc.whn_cr = g-today.
          dealing_doc.who_cr = g-ofc .
          dealing_doc.whn_mod = g-today.
          dealing_doc.who_mod = g-ofc.
          cur_time = time.
          dealing_doc.time_cr = cur_time.
          dealing_doc.time_mod = cur_time.
          dealing_doc.rate = currate.
          dealing_doc.TngToVal = tfirst.
          dealing_doc.f_amount = famount.
       end.
     else message substitute("Документ с номером &1 уже существует",documn) view-as alert-box.
end procedure.


procedure do_trans1:

s-jh = 0.

{dil_acc.i}

run trxgen('dil0004', dlm,
    string(tamount_proc) + dlm +
    taccno + dlm +
    arpacc + dlm +
    string(currate),
    m_sub, documn, output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
        pause.
    end.
    else
      do:
         message "Транзакция сделана" skip  "jh " s-jh view-as alert-box.
         find dealing_doc where dealing_doc.docno = documn share-lock.
         dealing_doc.jh = s-jh.
         find current dealing_doc no-lock.
         run dvou("prit").
      end.
end procedure.

procedure do_trans2:

{dil_acc.i}

find crc where crc.crc = currency  no-lock no-error.
avg_tamount = crc.rate[1] * vamount.
avg_tamount = round(round(avg_tamount,3),2).
diff_tamount = avg_tamount - tamount_proc.
release crc.

do transaction:

s-jh = 0.

if diff_tamount > 0
   then
     do:
      run trxgen('dil0045', dlm,

                string(abs(diff_tamount)) + dlm +
                arpacc  ,

                m_sub, documn, output rcode, output rdes, input-output s-jh).
       if rcode ne 0 then do:
          message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
          pause.
          undo,return.
       end.
       run trxsts (input s-jh, input 0, output rcode, output rdes).
       if rcode ne 0 then do:
          message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
          pause.
          undo,return.
       end.
     end.

if vozvrat
  then
    run trxgen('dil0041', dlm,

        string(vamount) + dlm +
        string(currency) + dlm +
        string(currate) + dlm +
        valacc[currency] + dlm +
        vaccno          + dlm +
        "Зачисление купленной валюты на счет клиента " + string(currate2) + dlm +

        string(conv_com) + dlm +
        string(currency) + dlm +
        string(currate)  + dlm +

        string(birz_com) + dlm +
        taccno           + dlm +

        string(diff_amount) + dlm +
        "arp"               + dlm +
        arpacc         + dlm +
        "cif"               + dlm +
        taccno              + dlm +
        "Возврат несконвертированных средств" + dlm +

        string(avg_tamount) + dlm +
        arpacc              + dlm +

        string(vamount)     + dlm +
        string(currency)    + dlm +
        valacc[currency]     ,

        m_sub, documn, output rcode, output rdes, input-output s-jh).
    else
      run trxgen('dil0041', dlm,

        string(vamount) + dlm +
        string(currency) + dlm +
        string(currate) + dlm +
        valacc[currency] + dlm +
        vaccno          + dlm +
        "Зачисление купленной валюты на счет клиента " + string(currate2) + dlm +

        string(conv_com)  + dlm +
        string(currency) + dlm +
        string(currate)  + dlm +

        string(birz_com) + dlm +
        taccno           + dlm +

        string(diff_amount) + dlm +
        'cif'       + dlm +
        taccno + dlm +
        'arp' + dlm +
        arpacc + dlm +
        'Снятие недостающих средств средств' + dlm +

        string(avg_tamount) + dlm +
        arpacc              + dlm +

        string(vamount)     + dlm +
        string(currency)    + dlm +
        valacc[currency]     ,

        m_sub, documn, output rcode, output rdes, input-output s-jh).

    if rcode ne 0 then do:
        message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
        pause.
        undo, return string(rcode).
    end.
    else
      do:
         run trxsts (input s-jh, input 0, output rcode, output rdes).
         if rcode ne 0 then do:
            message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
            pause.
            undo,return.
         end.
         if diff_tamount < 0
            then
              do:
               run trxgen('dil0044', dlm,

                         string(abs(diff_tamount)) + dlm +
                         arpacc  ,

                         m_sub, documn, output rcode, output rdes, input-output s-jh).
              end.
/*            else
              do:
               run trxgen('dil0045', dlm,
                         string(avg_tamount) + dlm +
                         arpacc               + dlm +
                         string(abs(diff_tamount)),
                         m_sub, documn, output rcode, output rdes, input-output s-jh).
              end.*/
         if rcode ne 0 then do:
            message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
            pause.
            undo,return.
         end.
         else do:
           run trxsts (input s-jh, input 6, output rcode, output rdes).
           if rcode ne 0 then do:
              message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
              pause.
              undo,return.
           end.
           message "Транзакция сделана" skip  "jh " s-jh view-as alert-box.
           find dealing_doc where dealing_doc.docno = documn share-lock.
           dealing_doc.jh2 = s-jh.
           dealing_doc.whn_mod = g-today.
           dealing_doc.who_mod = g-ofc.
           dealing_doc.v_amount = vamount.
           dealing_doc.com_conv = conv_com.
           find current dealing_doc no-lock.
           run dvou2("prit").
         end.
      end.
end.
end procedure.

procedure do_trans3:

{dil_acc.i}

find crc where crc.crc = currency  no-lock no-error.
avg_tamount = crc.rate[1] * vamount.
avg_tamount = round(round(avg_tamount,3),2).
diff_tamount = avg_tamount - tamount_proc.
release crc.


do transaction:

s-jh = 0.

if diff_tamount > 0
   then
     do:
      run trxgen('dil0045', dlm,

                string(abs(diff_tamount)) + dlm +
                arpacc  ,

                m_sub, documn, output rcode, output rdes, input-output s-jh).
       if rcode ne 0 then do:
          message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
          pause.
          undo,return.
       end.
       run trxsts (input s-jh, input 0, output rcode, output rdes).
       if rcode ne 0 then do:
          message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
          pause.
          undo,return.
       end.
     end.

    run trxgen('dil0042', dlm,

        string(vamount) + dlm +
        string(currency) + dlm +
        string(currate) + dlm +
        valacc[currency] + dlm +
        vaccno          + dlm +
        "Зачисление купленной валюты на счет клиента " + string(currate2) + dlm +

        string(conv_com) + dlm +
        string(currency) + dlm +
        string(currate)  + dlm +

        string(birz_com) + dlm +

        taccno + dlm +

        string(avg_tamount) + dlm +
        arpacc              + dlm +

        string(vamount)     + dlm +
        string(currency)    + dlm +
        valacc[currency],

        m_sub,documn, output rcode, output rdes, input-output s-jh).

    if rcode ne 0 then do:
        message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
        pause.
        return string(rcode).
    end.
    else
      do:
         run trxsts (input s-jh, input 0, output rcode, output rdes).
         if rcode ne 0 then do:
            message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
            pause.
            undo,return.
         end.
         if diff_tamount < 0
            then
              do:
               run trxgen('dil0044', dlm,

                         string(abs(diff_tamount)) + dlm +
                         arpacc,

                         m_sub, documn, output rcode, output rdes, input-output s-jh).
              end.
/*            else
              do:
               run trxgen('dil0045', dlm,
                         string(avg_tamount) + dlm +
                         arpacc               + dlm +
                         string(abs(diff_tamount)),
                         m_sub, documn, output rcode, output rdes, input-output s-jh).
              end.*/
         if rcode ne 0 then do:
            message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
            pause.
            undo,return.
         end.
         else do:
           run trxsts (input s-jh, input 6, output rcode, output rdes).
           if rcode ne 0 then do:
              message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
              pause.
              undo,return.
           end.
           message "Транзакция сделана" skip  "jh " s-jh documn view-as alert-box.
           find dealing_doc where dealing_doc.docno = documn share-lock no-error.
           dealing_doc.jh2 = s-jh.
           dealing_doc.whn_mod = g-today.
           dealing_doc.who_mod = g-ofc.
           find current dealing_doc no-lock.
           run dvou2("prit").
         end.
      end.
end.

end procedure.

procedure delete_trans:
 do transaction:
   documn = "".
   clear frame dframe4.
   set documn with frame dframe4.
   find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType share-lock no-error.
   if not available(dealing_doc) then do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
     else do:
        find jh where jh.jh = dealing_doc.jh2 no-lock no-error.
        if available jh
           then
             do:
                if dealing_doc.who_mod <> g-ofc
                   then do:
                     message "Вы не можете удалять документы принадлежащие" dealing_doc.who_mod view-as alert-box.
                     return.
                   end.
                message "Удаляется вторая транзакция" view-as alert-box title "".
                if jh.jdt < g-today
                   then do:
                     run yn("","Дата транзакции. Сторно?",
                     string(jh.jdt),"",output ans).
                     if not ans then undo, return.
                     run trxstor(input dealing_doc.jh2, input 6,
                     output s-jh, output rcode, output rdes).
                     if rcode ne 0 then do:
                        message rdes.
                        undo, return.
                     end.
                     else
                       do:
                          dealing_doc.jh2 = ?.
                          run x-jlvo.
                       end.
                   end.
                   else do:
                      run yn("","Вы уверены ?","","", output ans).
                      if not ans then undo, return.
                      v-sts = jh.sts.
                      run trxsts (input dealing_doc.jh2, input 0, output rcode, output rdes).
                      if rcode ne 0 then do:
                         message rdes.
                         undo, return.
                      end.
                      run trxdel (input dealing_doc.jh2, input true, output rcode, output rdes).
                      if rcode ne 0 then do:
                         message rdes.
                         if rcode = 50 then do:
                                            run trxstsdel (input dealing_doc.jh2, input v-sts, output rcode, output rdes).
                                            return.
                                       end.
                         else undo, return.
                      end.
                      else dealing_doc.jh2 = ?.
                   end. /*if*/
             end.
           else
             do:
                find jh where jh.jh = dealing_doc.jh no-lock no-error.
                if not available jh then do: message "У документа отсутствует транзакция" view-as alert-box title "". undo,return. end.
                  else do:
                   if dealing_doc.who_mod <> g-ofc
                      then do:
                        message "Вы не можете удалять документы принадлежащие" dealing_doc.who_cr view-as alert-box.
                        return.
                      end.

                   if jh.jdt < g-today
                       then do:
                         run yn("","Дата транзакции. Сторно?",
                         string(jh.jdt),"",output ans).
                         if not ans then undo, return.
                         run trxstor(input dealing_doc.jh, input 6,
                         output s-jh, output rcode, output rdes).
                         if rcode ne 0 then do:
                            message rdes.
                            undo, return.
                         end.
                         else
                             do:
                                dealing_doc.jh = ?.
                                run x-jlvo.
                             end.
                       end.
                       else do:
                          run yn("","Вы уверены ?","","", output ans).
                          if not ans then undo, return.
                          v-sts = jh.sts.
                          run trxsts (input dealing_doc.jh, input 0, output rcode, output rdes).
                          if rcode ne 0 then do:
                             message rdes.
                             undo, return.
                          end.
                          run trxdel (input dealing_doc.jh, input true, output rcode, output rdes).
                          if rcode ne 0 then do:
                             message rdes.
                             if rcode = 50 then do:
                                                run trxstsdel (input dealing_doc.jh, input 0, output rcode, output rdes).
                                                return.
                                           end.
                             else undo, return.
                          end.
                          else dealing_doc.jh = ?.
                       end. /*if*/
                  end.
             end.
find last b-aaastr where b-aaastr.aaa = vaccno no-lock no-error.
if b-aaastr.cr[1] - b-aaastr.dr[1] < 0 then do:
   message "На счете дебетовое сальдо, удаление транзакции невозможно.".
   pause.
   undo, return.
end.

     end.
 end.
end procedure.

procedure getperc_tamt:
   if currency = 4 then birz_com = 0. else birz_com = get_percent(birz_int, tamount).
   tamount_proc = tamount - birz_com.
   vamount = round (tamount_proc / currate, 2).
   displ tamount_proc with frame dframe1.
   conv_com = get_percent(conv_int, vamount).
   if currency <> 2
     then
       do:
          if conv_int_min <> 0 then
             do:
                  find first dcrc where dcrc.crc = 2 no-lock no-error.
                  cim_notusd = conv_int_min * dcrc.rate[1].
                  find first dcrc where dcrc.crc = currency no-lock no-error.
                  cim_notusd = cim_notusd / dcrc.rate[1].
                  release dcrc.
                  if conv_com < cim_notusd then conv_com = cim_notusd.
                  /*message conv_com view-as alert-box. */
             end.
          if conv_int_max <> 0 then
             do:
                  find first dcrc where dcrc.crc = 2 no-lock no-error.
                  cim_notusd = conv_int_max * dcrc.rate[1].
                  find first dcrc where dcrc.crc = currency no-lock no-error.
                  cim_notusd = cim_notusd / dcrc.rate[1].
                  release dcrc.
                  if conv_com > cim_notusd then conv_com = cim_notusd.
/*                 message conv_com view-as alert-box. */
             end.
       end.
     else
       do:
          if conv_int_min <> 0 then
             if conv_com < conv_int_min then conv_com = conv_int_min.
          if conv_int_max <> 0 then
             if conv_com > conv_int_max then conv_com = conv_int_max.
       end.
   display vamount with frame dframe1.
end procedure.

procedure getperc_vamt:
   gcom = true.
   tamount = vamount * currate.
   conv_temp = get_percent(conv_int, vamount).
   if currency <> 2
     then
       do:
          find first dcrc where dcrc.crc = 2 no-lock no-error.
          cim_notusd = conv_int_min * dcrc.rate[1].
          find first dcrc where dcrc.crc = currency no-lock no-error.
          cim_notusd = cim_notusd / dcrc.rate[1].
          release dcrc.
          if conv_temp <= cim_notusd
             then do: conv_temp = cim_notusd. conv_com = cim_notusd. gcom = false. end.
          if conv_int_max <> 0 then
             do:
                find first dcrc where dcrc.crc = 2 no-lock no-error.
                cim_notusd = conv_int_max * dcrc.rate[1].
                find first dcrc where dcrc.crc = currency no-lock no-error.
                cim_notusd = cim_notusd / dcrc.rate[1].
                release dcrc.
                if conv_temp >= cim_notusd then do: conv_temp = cim_notusd. conv_com = cim_notusd. gcom = false. end.
             end.
          if gcom then conv_com = get_percent(conv_int, (vamount + conv_temp)).
       end.
     else
       do:
           if conv_temp <= conv_int_min then
              do:
                 conv_temp = conv_int_min.
                 conv_com = conv_int_min.
                 gcom = false.
              end.
           if conv_int_max <> 0 then do:
              if conv_temp >= conv_int_max then
                 do:
                    conv_temp = conv_int_max.
                    conv_com = conv_int_max.
                    gcom = false.
                 end.
              end.
           if gcom then conv_com = get_percent(conv_int, (vamount + conv_temp)).
       end.
   tamount_proc = (vamount + conv_com) * currate.
   if currency = 4 then birz_com = 0. else birz_com = get_percent(birz_int, tamount_proc).
   tamount_proc = tamount_proc + birz_com.
   if currency = 4 then birz_com = 0. else birz_com = get_percent(birz_int, tamount_proc).
   run get_precamt.
/*   conv_com = round (conv_com,2).*/
   vamount = vamount + conv_com.
   tamount_proc = tamount_proc - birz_com.
end procedure.

procedure update_doc:
/*
  find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType share-lock no-error .
  if not available dealing_doc
     then
       do:
          message substitute("Документ с номером &1 не существует",documn) view-as alert-box.
       end.
     else
       do transaction:
          if (vamount = ?) or (vamount = 0)
             then do:
               message "Сумма в валюте отсутствует или равна нулю" view-as alert-box.
               return.
             end.
          dealing_doc.v_amount = vamount.
          dealing_doc.t_amount = tamount.
          dealing_doc.t_amt_coms = tamount_proc.
          dealing_doc.com_conv = conv_com.
          dealing_doc.com_bourse = birz_com.
          dealing_doc.whn_mod = g-today.
          dealing_doc.who_mod = g-ofc.
          cur_time = time.
          dealing_doc.time_mod = cur_time.
          dealing_doc.rate = currate.
       end.
  */
end procedure.

procedure edit_comms:
  update conv_int skip conv_int_min skip birz_int with side-labels.
end procedure.

