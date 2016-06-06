/* oreconv.p
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
        06.07.2005 dpuchkov - birz_int = 0.00 (т.к. кто то удалил тариф биржевой комиссии)
        25.08.2005 saltanat - Выборка льгот по счетам.
        06.10.2005 dpuchkov - добавил проверку на дебетовое сальдо при удалении транзакции.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

/*
   Обычная РЕконвертация (804 - код в тарификаторе)
*/


{global.i}
{crc-crc.i}
def var  documN     like dealing_doc.docno label "Номер документа".
def var  documType  as integer /*тип документа 1 срочная конвертация*/.
def var  vaccno     as char    label "Счет клиента для снятия средств    " format "x(9)".
def var  taccno     as char    label "Счет клиента для зачисления средств" format "x(9)".
def var  comaccno   as char    label "Счет с которого снимается комиссия " format "x(9)".
def var  currency   as integer label "Валюта" format ">9" initial 1.
def var  clientno   as char    label "ID клиента".
def var  clientname like cif.name    label "Клиент" format "x(45)".

def var  avg_tamount    as decimal  format "zzz,zzz,zzz,zzz.99".
def var  diff_tamount    as decimal  format "zzz,zzz,zzz,zzz.99".

def var  tamount    as decimal    label "Сумма на реконвертацию в тенге "  format "zzz,zzz,zzz,zzz.99".
def var  vamount    as decimal    label "Сумма на реконвертацию в валюте" format "zzz,zzz,zzz,zzz.99".
def var  famount    as decimal.
def var  urg_com    as decimal    label "Комиссия за срочность        " format "zzz,zzz,zzz,zzz.99".
def var  conv_com   as decimal    label "Комиссия за реконвертацию    " format "zzz,zzz,zzz,zzz.99".
def var  birz_com   as decimal    label "Биржевая комиссия            " format "zzz,zzz,zzz,zzz.99".
def var  litems     as char.
def var  currate    as decimal label "Курс" format "zzz,zzz.9999".
def var  currate2    as decimal label "Текущий курс" format "zzz,zzz.9999". /*Курс на момент зачисления*/
def var  l-tran     as logical. /*да сделать транзакцию*/

def new shared var s-jh like jh.jh.

def var retval as char.
def var rcode as int.
def var rdes  as cha.
def var dlm as char init "|".

def var rem as char initial "1223asfdasdfa".
def var cur_time as integer.
def var ans as logical.
/*def var min_com as logical label "Минимум при взятии комиссии" format "да/нет" init "yes".*/

def var  tamount_proc as decimal  label "Окончательная сумма в тенге  " format "zzz,zzz,zzz,zzz.99" .
/*Сумма в валюте + ком. за срочность + ком. за конвертацию + биржевая */

def var conv_int as decimal initial "0.2" label "Процент комиссии за реконвертацию".
def var conv_int_min as decimal initial "15"  label "Минимальная сумма за реконвертацию".
def var urg_int as decimal  initial "0.2"  label "Процент комиссии за срочность  ".
def var birz_int as decimal initial "0.00". /*процент биржевой комиссии*/
def var conv_temp as decimal.
def var urg_temp as decimal.
def var temp_cur  as integer format ">9" initial 1.
def var temp_rate as decimal format "zzz,zzz.9999".
def var tfirst as logical.   /*true если сначала была введена сумма в тенге
                               false если сперва была сумма в валюте */
def shared var dType as integer.
def var cim_notusd as decimal. /*используется для пересчета комиссии если валюты не доллары*/
def buffer dcrc for crc.

define variable m_sub as character initial "dil".
define variable v-sts like jh.sts.
def buffer b-aaastr for aaa.


define frame dframe1 skip(1) documN skip
                     clientno clientname skip
                     vaccno skip
                     taccno skip
                     comaccno skip (1)
/*                     currency space (5) */
                     currate skip(1)
                     vamount tamount skip(1)
                     conv_com skip
/*                     urg_com*/ skip (1)

/*                     tamount_proc*/
             WITH /*KEEP-TAB-ORDER*/ SIDE-LABELS TITLE "Обычная реконвертация".

define frame dframe2 documN with SIDE-LABELS.

define frame dframe3 conv_int urg_int with SIDE-LABELS OVERLAY CENTERED.

define frame dframe4 documN with SIDE-LABELS.

SESSION:SYSTEM-ALERT-BOXES = true.

{dil_util.i}

on help of documN in frame dframe1 do:
   run help-dilnum.
end.

on help of documN in frame dframe2 do:
   run help-dilnum2.
end.

on help of documN in frame dframe4 do:
   run help-dilnum.
end.

on help of comaccno in frame dframe1 do:
  litems = "".
  for each aaa where aaa.cif eq clientno and aaa.sta <> 'C' and (aaa.crc = currency or aaa.crc = 1):
      find lgr where lgr.lgr = aaa.lgr.
      if available lgr then if lgr.led <> 'oda' then
      litems = litems + aaa.aaa + "|".
  end.
  if litems = '' then do: message "проблема со счетами" view-as alert-box. undo,return. end.
     else
       do:
         run sel1("Выберите счет", litems).
         comaccno = return-value.
         if comaccno = '' then undo,retry.
         display comaccno with frame dframe1.
       end.
end.

procedure Init_Vars:

documN  = ''.
vaccno  = ''.
taccno  = ''.
comaccno = ''.
currency = 0.
clientno = ''.
clientname = ''.
tamount    = 0.
vamount    = 0.
urg_com    = 0.
conv_com   = 0.
birz_com   = 0.


currate = 0.
currate2 = 0.
l-tran = false.

s-jh = 0.



tamount_proc =0.
conv_int = 0.2.
conv_int_min = 15.
/*urg_int = 0.2.*/

/*find first tarif2 where tarif2.num + tarif2.kod = '803' no-lock no-error.
if avail tarif2 then urg_int = tarif2.proc.*/

find first tarif2 where tarif2.num + tarif2.kod = '804' and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then
   do:
      conv_int = tarif2.proc.
      conv_int_min = crc-crc(tarif2.min1, tarif2.crc, 2).
/*      conv_int_max = crc-crc(tarif2.min1, tarif2.crc, 2). .*/
   end.

conv_temp = 0.
urg_temp = 0.

end procedure.

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
                                         and tarifex2.str5 = '804'
                                         and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
            	         conv_int = tarifex2.proc.
                	     conv_int_min = crc-crc(tarifex2.min1, tarifex2.crc, 2).
                      release tarifex2 no-error.
                   end.
                   else do:
	                   find first tarifex where tarifex.str5 = '804' and tarifex.cif = clientno
    	                                    and tarifex.stat = 'r' share-lock no-error.
        	           if available tarifex then do:
            	         conv_int = tarifex.proc.
                	     conv_int_min = crc-crc(tarifex.min1, tarifex.crc, 2).
	                   end.
    	               release tarifex no-error.
                   end.
                 end.
          end.
end procedure.


procedure calc_comm:
define input parameter t_rate like currate.

find first aaa where aaa.aaa eq comaccno no-lock no-error.
if available aaa
   then do:
     if aaa.crc = 1 then
                     do:
/*                       find first dcrc where dcrc.crc = currency no-lock no-error.           */
                       conv_temp = conv_com * t_rate.
                     end.
                   else
                     do:
                        conv_temp = conv_com.
                     end.
     end.
   else do: message "Счет для снятия комиссии не найден!" view-as alert-box title "". end.
end procedure.

procedure new_doc:   /*НОВЫЙ ДОКУМЕНТ*/

do transaction:

repeat on ENDKEY UNDO , leave:

clear frame dframe1 NO-PAUSE.

run Init_vars.
documn = ''.
litems = "".
l-tran = false.

run generate_docno.

displ documN with frame dframe1.

set vaccno with frame dframe1.
 if vaccno entered
   then
     do:
       find aaa where aaa.aaa eq vaccno no-lock no-error.
       if not available aaa
          then do: message "Счет" vaccno "не найден" view-as alert-box. undo,retry. end.
          else do:
              currency = aaa.crc.
              if currency = 1 then do: message "Введите валютный счет!" view-as alert-box title "". undo,retry. end.
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
                                         and tarifex2.str5 = '804'
                                         and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
            	         conv_int = tarifex2.proc.
                	     conv_int_min = crc-crc(tarifex2.min1, tarifex2.crc, 2).
                      release tarifex2 no-error.
                   end.
                   else do:
	                   find first tarifex where tarifex.str5 = '804' and tarifex.cif = clientno
    	                                    and tarifex.stat = 'r' share-lock no-error.
        	           if available tarifex then do:
            	         conv_int = tarifex.proc.
                	     conv_int_min = crc-crc(tarifex.min1, tarifex.crc, 2).
	                   end.
    	               release tarifex no-error.
                   end.
                 end.
          end.
     end.
   else undo,retry.
/*   if check_acc(vaccno) then undo,retry.*/

           do:
           for each aaa where aaa.crc eq 1 and aaa.cif eq clientno and aaa.sta <> 'C' break by aaa.crc:
             find lgr where lgr.lgr = aaa.lgr.
             if available lgr then if lgr.led <> 'oda' then
             if last-of(aaa.crc) then litems = litems + aaa.aaa.
                                 else litems = litems + aaa.aaa + "|".
           end.
           if litems = '' then do: message "У клиента нет счета в такой валюте" view-as alert-box. undo,return. end.
           else
             do:
                run sel1("Выберите счет", litems).
                taccno = return-value.
                if taccno = '' then undo,retry.
                update taccno with frame dframe1.
                set comaccno with frame dframe1.
                if comaccno not entered then undo,retry.
                find crc where crc.crc = currency.
                case currency:
                     when 2 then find sysc where sysc.sysc = 'orcusd'.
                     when 4 then find sysc where sysc.sysc = 'orcrur'.
                     when 3 then find sysc where sysc.sysc = 'orceur'.
                end.
                currate = sysc.deval.

                update currate with frame dframe1.

/*********************************************/

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
      end.
 end.
/*********************************************/




                set vamount with frame dframe1.
                if vamount entered
                   then do: famount = vamount. run getperc_vamt. tfirst = false. end.
                   else do:
                     undo,retry.
                   end.

if check_acc(vaccno,vamount,false) then undo,retry.

                conv_com:SCREEN-VALUE = string(conv_temp).
                displ /*conv_com */ vamount tamount with frame dframe1.
                run create_doc.
                pause.
                run yn("","Сделать транзакцию?","","", output l-tran).
                if l-tran then do: run do_trans. return. end.
             end.
        end.
end.

end.

hide frame dframe1.

end procedure.

procedure create_doc:

  find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType share-lock no-error .
  if not available dealing_doc
     then
       do:
          create dealing_doc.
          dealing_doc.docno = DocumN.
          dealing_doc.crc = crc.crc.
          dealing_doc.doctype = 4.
          if (vamount = ?) or (vamount = 0)
             then do:
               message "Сумма в валюте отсутсвует или равна нулю" view-as alert-box.
               return.
             end.
          dealing_doc.v_amount = vamount.
          dealing_doc.t_amount = tamount.
/*          dealing_doc.t_amt_coms = tamount_proc.*/
          dealing_doc.tclientaccno = taccno.
          dealing_doc.vclientaccno = vaccno.
/*          dealing_doc.com_expr = urg_com.*/
          dealing_doc.com_conv = conv_com.
          dealing_doc.whn_cr = g-today.
          dealing_doc.who_cr = g-ofc .
          dealing_doc.whn_mod = g-today.
          dealing_doc.who_mod = g-ofc.
          cur_time = time.
          dealing_doc.time_cr = cur_time.
          dealing_doc.time_mod = cur_time.
          dealing_doc.rate = currate.
          dealing_doc.TngToVal = tfirst.
          dealing_doc.com_accno = comaccno.
          dealing_doc.f_amount = famount.
       end.
     else message substitute("Документ с номером &1 уже существует",documn) view-as alert-box.
end procedure.

procedure view_doc:
  run Init_vars.
  clear frame dframe1.
/*  documn = ''.
  set documn with frame dframe1.*/

  if this-procedure:private-data = ?
     then
       do:
          /*documn = ''.
          set documn with frame dframe1.*/
          if documn = '' then set documn with frame dframe1.
       end.
     else
       do:
          documn = this-procedure:private-data.
          displ documn with frame dframe1.
       end.

/*  do /*transaction*/:*/
     find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType no-lock no-error.
     if available (dealing_doc) then
        do:
           documtype = dealing_doc.doctype.
           vamount = dealing_doc.v_amount.
           tamount = dealing_doc.t_amount.
           taccno = dealing_doc.tclientaccno.
           vaccno = dealing_doc.vclientaccno.
/*           urg_com = dealing_doc.com_expr.*/
           conv_com = dealing_doc.com_conv.
           currate = dealing_doc.rate.
           currate2 = dealing_doc.rate2.
           currency = dealing_doc.crc.
           comaccno = dealing_doc.com_accno.
           famount = dealing_doc.f_amount.
           run find_client.
           if this-procedure:private-data <> ?
              then do: if dealing_doc.tngtoval then tamount = famount. else vamount = famount. end.
           display vamount tamount taccno vaccno conv_com comaccno clientno clientname currate currate2 currency with frame dframe1.
           if this-procedure:private-data <> ?
              then
                do:
                  if ((dealing_doc.jh = ?) or (dealing_doc.jh = 0)) and
                     ((dealing_doc.jh2 = ?) or (dealing_doc.jh2 = 0))
                    then
                     do:
                        case currency:
                            when 2 then find sysc where sysc.sysc = 'orcusd'.
                            when 4 then find sysc where sysc.sysc = 'orcrur'.
                            when 3 then find sysc where sysc.sysc = 'orceur'.
                        end.
                        currate = sysc.deval.

                        update currate with frame dframe1.
                        find current dealing_doc exclusive-lock.
                        dealing_doc.rate = currate.
                        dealing_doc.who_mod = g-ofc.
                        find current dealing_doc no-lock.

                        vamount = famount.
                        run getperc_vamt.

                        find current dealing_doc exclusive-lock.
                        dealing_doc.v_amount = vamount.
                        dealing_doc.t_amount = tamount.
                        dealing_doc.com_conv = conv_com.
                        find current dealing_doc no-lock.
                     end.
                end.
           display vamount tamount taccno vaccno conv_com comaccno clientno clientname currate currate2 currency with frame dframe1.
        end.
      else do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
/*  end. /* do */*/
end procedure.

procedure delete_doc:
  clear frame dframe2.
  set documn with frame dframe2.
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


procedure create_trans:
  do transaction:
/*     documn = "".
     clear frame dframe2.*/
     if documn = '' then set documn with frame dframe2.
     set documn with frame dframe2.
     find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType share-lock no-error.
     if not available(dealing_doc) then do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
       else do:
         if dealing_doc.who_mod <> g-ofc
            then do:
                 message "Документ принадлежит" dealing_doc.who_mod skip "Транзакция не будет сделана" view-as alert-box.
                 return.
            end.
         if dealing_doc.jh = ? or dealing_doc.jh = 0
            then
              do:
                vamount = dealing_doc.v_amount.
                taccno = dealing_doc.tclientaccno.

/*                if check_acc(taccno) then undo,leave.*/
                vaccno = dealing_doc.vclientaccno.
                if check_acc(vaccno,vamount,false) then undo,leave.
                currency = dealing_doc.crc.
                currate = dealing_doc.rate.
                run yn("","Сделать транзакцию?","","", output l-tran).
                if l-tran then do: run do_trans. return. end.
                         else do: hide all. undo,return. end.
              end.
            else
              do:
                message "Транзакция для данного документа уже существует" view-as alert-box.
                return.
              end.
       end.

  end.
end procedure.

procedure create_trans2: /*ВТОРАЯ ТРАНЗАКЦИЯ*/
  do transaction:
     run Init_Vars.
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
            end. */
         if (dealing_doc.jh <> ? and dealing_doc.jh <> 0) and (dealing_doc.jh2 = ? or dealing_doc.jh2 = 0)
            then
              do:
                vamount = dealing_doc.v_amount.
                tamount = dealing_doc.t_amount.
                taccno = dealing_doc.tclientaccno.
                vaccno = dealing_doc.vclientaccno.
/*                if check_acc(vaccno) then undo,leave.*/
                conv_com = dealing_doc.com_conv.
                currency = dealing_doc.crc.
                currate = dealing_doc.rate.
                comaccno = dealing_doc.com_accno.
/*                if check_acc(comaccno) then undo,leave.*/
/*                if dealing_doc.rate2 <> ? or dealing_doc.rate2 <> 0 then currate2 = dealing_doc.rate2.
                                          else currate2 = currate.
                case currency:
                     when 2 then find sysc where sysc.sysc = 'orcusd'.
                     when 4 then find sysc where sysc.sysc = 'orcrur'.
                     when 11 then find sysc where sysc.sysc = 'orceur'.
                end.
                currate2 = sysc.deval.

                update currate2.

                currate = currate2. */
                dealing_doc.rate2 = currate.
                run find_client.
                message "Отредактировать тарифы?" view-as alert-box BUTTONS YES-NO title "" update choice as logical.
                if choice then run edit_comms.
                run getperc_vamt.
                if check_acc(comaccno,conv_com,true) then undo,leave.
                conv_com:SCREEN-VALUE in frame dframe1 = string(conv_temp).
/*                conv_com:SCREEN-VALUE = string(conv_temp).*/
                displ clientno clientname vamount tamount taccno vaccno comaccno /*conv_com*/ currate currate2 clientno clientname with frame dframe1.
                pause.
                run yn("","Сделать транзакцию?","","", output l-tran).
                if l-tran then do: run do_trans2. return return-value. end.
                          else do: hide all. undo, return "no". end.
              end.
            else
              do:
                message "Отсутствует первая транзакция " skip "или вторая транзакция для документа" documn "уже существует" view-as alert-box title "".
                return.
              end.
       end.
  end.
end procedure.

procedure delete_trans:
 do transaction:
/*   documn = "".*/
   clear frame dframe4.
/*   set documn with frame dframe2.*/
   if documn = '' then set documn with frame dframe4.
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

                          run trxsts (input dealing_doc.jh, input 0, output rcode, output rdes).
                          if rcode ne 0 then do:
                             message rdes.
                             undo, return.
                          end.
                          run trxdel (input dealing_doc.jh, input true, output rcode, output rdes).
                          if rcode ne 0 then do:
                             message rdes.
                             if rcode = 50 then return.
                             else undo, return.
                          end.
                          else dealing_doc.jh = ?.
                       end. /*if*/
                  end.
             end.
find last b-aaastr where b-aaastr.aaa = taccno no-lock no-error.
if b-aaastr.cr[1] - b-aaastr.dr[1] < 0 then do:
   message "На счете дебетовое сальдо, удаление транзакции невозможно.".
   pause.
   undo, return.
end.

     end.
 end.
end procedure.

procedure update_doc:

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
          dealing_doc.com_conv = conv_com.
          dealing_doc.whn_mod = g-today.
          dealing_doc.who_mod = g-ofc.
          cur_time = time.
          dealing_doc.time_mod = cur_time.
          dealing_doc.rate = currate.
       end.

end procedure.


procedure open_doc: /*РЕДАКТИРОВАНИЕ*/
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
         vaccno = dealing_doc.vclientaccno.
         conv_com = dealing_doc.com_conv.
         currate = dealing_doc.rate.
         currency = dealing_doc.crc.
         run find_client.
         display clientno clientname taccno vamount tamount taccno vaccno conv_com currate with frame dframe1.
         update currate with frame dframe1.
         update vamount with frame dframe1.
         run getperc_vamt.
         displ tamount conv_com with frame dframe1.
         pause.
         run update_doc.
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


procedure getperc_vamt:
   tamount = vamount * currate.
   conv_com = get_percent(conv_int, vamount).
   if currency <> 2
     then
       do:
          find first dcrc where dcrc.crc = 2 no-lock no-error.
          cim_notusd = conv_int_min * dcrc.rate[1].
          find first dcrc where dcrc.crc = currency no-lock no-error.
          cim_notusd = cim_notusd / dcrc.rate[1].
/*             if conv_int_min <> 0 then
              do: */
                if conv_com <= cim_notusd
                  then do: conv_com = cim_notusd. run calc_comm(input dcrc.rate[1]). end.
                  else
                    do:
                       run calc_comm(input currate).
                    end.
/*              end.
             else conv_com = 0. */
       end.
     else
       do:
/*        if conv_int_min <> 0 then
          do: */
            if conv_com <= conv_int_min
               then
                 do:
                    conv_com = conv_int_min.
                    conv_temp = conv_com.
                    find first dcrc where dcrc.crc = currency no-lock no-error.
                    run calc_comm(input dcrc.rate[1]).
                 end.
               else
                 do:
                   run calc_comm(input currate).
                 end.
/*          end.
          else
            do:
               conv_com = 0. conv_temp = conv_com.

            end.*/
       end.
end procedure.


procedure do_trans:

def var temp_cur  as integer format ">9" initial 1.
def var temp_rate as decimal format "zzz,zzz.9999".

{dil_acc.i}


find crc where crc.crc = currency no-lock.
avg_tamount = crc.rate[1] * vamount.
avg_tamount = round(round(avg_tamount,3),2).
diff_tamount = avg_tamount - tamount.

do transaction:

s-jh = 0.

if diff_tamount < 0
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

run trxgen('dil0037', dlm,

    string(vamount) + dlm +
    vaccno          + dlm +
    valacc[currency] + dlm +
    "На реконвертацию соглано заявки " + string(currate) + dlm +

/*    string(vamount) + dlm +
    valacc[currency] + dlm +*/

    string(vamount)     + dlm +
    string(currency)    + dlm +
    valacc[currency]    + dlm +


    string(avg_tamount) + dlm +
    arpacc,

    m_sub , documn, output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
        pause.
/*        return "".*/
    end.
    else
      do:
         run trxsts (input s-jh, input 0, output rcode, output rdes).
         if rcode ne 0 then do:
            message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
            pause.
            undo,return.
         end.
         if diff_tamount > 0
            then
              do:
               run trxgen('dil0044', dlm,
                         string(abs(diff_tamount)) + dlm +
                         arpacc,
                         m_sub, documn, output rcode, output rdes, input-output s-jh).
              end.
          /*  else
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
         else
           do:
             run trxsts (input s-jh, input 6, output rcode, output rdes).
             if rcode ne 0 then do:
                message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
                pause.
                undo,return.
             end.
             message "Транзакция сделана" skip  "jh " s-jh view-as alert-box.
             find dealing_doc where dealing_doc.docno = documn share-lock.
             dealing_doc.jh = s-jh.
             find current dealing_doc no-lock.
             run dvou("prit").
           end.
      end.
end.


end procedure.

procedure do_trans2: /*ВТОРАЯ ТРАНЗАКЦИЯ*/

{dil_acc.i}

s-jh = 0.

run trxgen('dil0038', dlm,

    string(tamount) + dlm +
    arpacc          + dlm +
    taccno          + dlm +
    "Продажа валюты " + string(currate) + dlm +
    ""              + dlm +

    string(conv_temp) + dlm +
    comaccno + dlm + "",

    m_sub , documn, output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
        pause.
/*        return "".*/
        return string(rcode).
    end.
    else
      do:
         message "Транзакция сделана" skip  "jh " s-jh view-as alert-box.
         find dealing_doc where dealing_doc.docno = documn share-lock.
         dealing_doc.jh2 = s-jh.
         dealing_doc.whn_mod = g-today.
         find current dealing_doc no-lock.
         run dvou2("prit").
      end.
end procedure.

procedure edit_comms:
  update conv_int skip conv_int_min with side-labels.
end procedure.

