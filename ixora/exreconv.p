/* exreconv.p
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
   Срочная РЕконвертация (803 - код в тарификаторе)
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
def buffer b-aaastr for aaa.

def var  tamount    as decimal    label "Сумма на реконвертацию в тенге "  format "zzz,zzz,zzz,zzz.99".
def var  vamount    as decimal    label "Сумма на реконвертацию в валюте" format "zzz,zzz,zzz,zzz.99".
def var  famount    as decimal.
def var  urg_com    as decimal    label "Комиссия за срочность        " format "zzz,zzz,zzz,zzz.99".
def var  conv_com   as decimal    label "Комиссия за реконвертацию    " format "zzz,zzz,zzz,zzz.99".
def var  birz_com   as decimal    label "Биржевая комиссия            " format "zzz,zzz,zzz,zzz.99".

def var  litems     as char.
def var  currate    as decimal label "Курс" format "zzz,zzz.9999".
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
def var cim_notusd as decimal. /*используется если валюты не доллары*/
def var urg_int as decimal  initial "0.2"  label "Процент комиссии за срочность  ".
def var birz_int as decimal initial "0.00". /*процент биржевой комиссии*/
def var conv_temp as decimal.
def var urg_temp as decimal.
def var temp_rate as decimal format "zzz,zzz.9999".
def var tfirst as logical.   /*true если сначала была введена сумма в тенге
                               false если сперва была сумма в валюте */
def shared var dType as integer.
define variable v-sts like jh.sts .

def buffer dcrc for crc.

define variable m_sub as character initial "dil".

define frame dframe1 skip(1) documN skip
                     clientno clientname skip
                     vaccno skip
                     taccno skip
                     comaccno skip (1)
/*                     currency space (5) */
                     currate skip(1)
                     vamount tamount skip(1)
                     conv_com skip
                     urg_com skip (1)
/*                     min_com    */
/*                     tamount_proc*/
             WITH /*KEEP-TAB-ORDER*/ SIDE-LABELS TITLE "Срочная реконвертация".

define frame dframe2 documN with SIDE-LABELS.

define frame dframe3 conv_int urg_int with SIDE-LABELS OVERLAY CENTERED.

SESSION:SYSTEM-ALERT-BOXES = true.

{dil_util.i}

on help of documN in frame dframe1 do:
   run help-dilnum.
end.

on help of documN in frame dframe2 do:
   run help-dilnum.
end.

on help of comaccno in frame dframe1 do:
  litems = "".
  for each aaa where aaa.cif eq clientno and aaa.sta <> 'C' and (aaa.crc = currency or aaa.crc = 1):
      find lgr where lgr.lgr = aaa.lgr no-lock no-error.
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
l-tran = false.
/*min_com = yes.*/

s-jh = 0.



tamount_proc =0.
conv_int = 0.2.
conv_int_min = 15.
urg_int = 0.2.


find first tarif2 where tarif2.num + tarif2.kod = '803'
                    and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then urg_int = tarif2.proc.

find first tarif2 where tarif2.num + tarif2.kod = '804'
                    and tarif2.stat = 'r' no-lock no-error.
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
                                         and tarifex2.str5 = '803'
                                         and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
                      urg_int = tarifex2.proc.
                      release tarifex2 no-error.
                   end.
                   else do:
	                   find first tarifex where tarifex.str5 = '803' and tarifex.cif = clientno
    	                                    and tarifex.stat = 'r' share-lock no-error.
        	           if available tarifex then urg_int = tarifex.proc.
            	       release tarifex no-error.
            	   end.

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
/*                   if min_com = no then conv_int_min = 0.*/
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
/*                      find first dcrc where dcrc.crc = currency.*/
                        conv_temp = conv_com * t_rate.
                        urg_temp = urg_com * currate.
                        temp_rate  = 1.0000.
                     end.
                   else
                     do:
                        urg_temp = urg_com.
                        conv_temp = conv_com.
                        temp_rate  = currate.
                     end.
     end.
   else do: message "Счет для снятия комиссии не найден!" view-as alert-box title "". end.

end procedure.


procedure new_doc:   /*НОВЫЙ ДОКУМЕНТ*/

do transaction:

repeat on ENDKEY UNDO , leave:

run Init_vars.
clear frame dframe1 NO-PAUSE.
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
                                         and tarifex2.str5 = '803'
                                         and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
                      urg_int = tarifex2.proc.
                      release tarifex2 no-error.
                   end.
                   else do:
	                   find first tarifex where tarifex.str5 = '803' and tarifex.cif = clientno
    	                                    and tarifex.stat = 'r' share-lock no-error.
        	           if available tarifex then urg_int = tarifex.proc.
            	       release tarifex no-error.
            	   end.

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

/*if check_acc(vaccno) then undo,retry.*/

           do:
           for each aaa where aaa.crc eq 1 and aaa.cif eq clientno and aaa.sta <> 'C' break by aaa.crc:
             find lgr where lgr.lgr = aaa.lgr no-lock no-error.
             if available lgr then if lgr.led <> 'oda' then
             if last-of(aaa.crc) then litems = litems + aaa.aaa.
                                 else litems = litems + aaa.aaa + "|".
           end.
           if litems = '' then do: message "У клиента нет счетов в такой валюте" view-as alert-box. undo,return. end.
           else
             do:
                run sel1("Выберите счет", litems).
                taccno = return-value.
                if taccno = '' then undo,retry.
                update taccno with frame dframe1.
/*                if check_acc(taccno) then undo,retry.*/
                set comaccno with frame dframe1.
                if comaccno not entered then undo,retry.
/*                if check_acc(comaccno) then undo,retry.*/
                find crc where crc.crc = currency no-lock no-error.
                case crc.crc:
                     when 2 then find sysc where sysc.sysc = 'ercusd' no-error.
                     when 4 then find sysc where sysc.sysc = 'ercrur' no-error.
                     when 3 then find sysc where sysc.sysc = 'erceur' no-error.
                end.
                currate = sysc.deval.

/*                currate = crc.rate[2].*/
                update currate with frame dframe1.



/*ЛЬГОТНЫЙ ТАРИФ */

if cif.type = "p" then do:
         if currency = 2 or currency = 3 or currency = 4 then do:

                   find first tarifex2 where tarifex2.aaa = aaa.aaa and tarifex2.cif = clientno and tarifex2.str5 = '809' and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
                      conv_int = tarifex2.proc.
                      conv_int_min = crc-crc(tarifex2.min1, tarifex2.crc, 2).

                   end.
                   else  do:
                      find first tarifex where tarifex.str5 = '809' and tarifex.cif  = clientno and tarifex.stat = 'r' share-lock no-error.
                      if available tarifex then do:
                         conv_int = tarifex.proc.
                         conv_int_min = crc-crc(tarifex.min1, tarifex.crc, 2).

                      end.
                   end.
         end.
         else
         do:

                   find first tarifex2 where tarifex2.aaa = aaa.aaa and tarifex2.cif = clientno and tarifex2.str5 = '814' and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
                      conv_int = tarifex2.proc.
                      conv_int_min = crc-crc(tarifex2.min1, tarifex2.crc, 2).

                   end.
                   else  do:
                      find first tarifex where tarifex.str5 = '814' and tarifex.cif  = clientno and tarifex.stat = 'r' share-lock no-error.
                      if available tarifex then do:
                         conv_int = tarifex.proc.
                         conv_int_min = crc-crc(tarifex.min1, tarifex.crc, 2).

                      end.
                   end.
         end.


end.
else do:

         find first tarifex2 where tarifex2.aaa = aaa.aaa and tarifex2.cif = clientno and tarifex2.str5 = '804' and tarifex2.stat = 'r' no-lock no-error.
         if available tarifex2 then do:
            conv_int = tarifex2.proc.
            conv_int_min = crc-crc(tarifex2.min1, tarifex2.crc, 2).


         end.
         else  do:
            find first tarifex where tarifex.str5 = '804' and tarifex.cif  = clientno and tarifex.stat = 'r' share-lock no-error.
            if available tarifex then do:
               conv_int = tarifex.proc.
               conv_int_min = crc-crc(tarifex.min1, tarifex.crc, 2).

            end.
         end.
end.
/*ЛЬГОТНЫЙ ТАРИФ */












 if (not avail tarifex) and (not avail tarifex2) then do:
      if cif.type = "p" then do:
         if currency = 2 or currency = 3 or currency = 4 then do:
            find first tarif2 where tarif2.num + tarif2.kod = '809' and tarif2.stat = 'r' no-lock no-error.
         end.
         else
         do:
            find first tarif2 where tarif2.num + tarif2.kod = '814' and tarif2.stat = 'r' no-lock no-error.
         end.

      end.
      else
      do:
         find first tarif2 where tarif2.num + tarif2.kod = '804' and tarif2.stat = 'r' no-lock no-error.
      end.
      if avail tarif2 then
      do:
           conv_int = tarif2.proc.
           conv_int_min = crc-crc(tarif2.min1, tarif2.crc, 2).


      end.
 end.







/*                update min_com with frame dframe1.
                if min_com = no then conv_int_min = 0.*/

                set vamount with frame dframe1.
                if vamount entered
                   then do: famount = vamount. run getperc_vamt. tfirst = false.  end.
                   else do:
                     undo,retry.
                   end.

if check_acc(vaccno,vamount,false) then undo,retry.
if check_acc(comaccno,urg_com + conv_com,true) then undo,retry.


                conv_com:SCREEN-VALUE = string(conv_temp).
                urg_com:SCREEN-VALUE = string(urg_temp).
                displ /*conv_com urg_com */vamount tamount with frame dframe1.
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
          dealing_doc.doctype = 3.
          if (vamount = ?) or (vamount = 0)
             then do:
               message "Сумма в валюте отсутствует или равна нулю" view-as alert-box.
               return.
             end.
          dealing_doc.v_amount = vamount.
          dealing_doc.t_amount = tamount.
/*          dealing_doc.t_amt_coms = tamount_proc.*/
          dealing_doc.tclientaccno = taccno.
          dealing_doc.vclientaccno = vaccno.
          dealing_doc.com_expr = urg_com.
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
    if this-procedure:private-data = ?
     then
       do:
/*          documn = ''.
          set documn with frame dframe1.*/
          if documn = '' then set documn with frame dframe1.
       end.
     else
       do:
          documn = this-procedure:private-data.
          displ documn with frame dframe1.
       end.
/*  documn = ''.*/
/*  set documn with frame dframe1.*/
  do transaction:
     find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType no-lock no-error.
     if available (dealing_doc) then
        do:
           documtype = dealing_doc.doctype.
           vamount = dealing_doc.v_amount.
           tamount = dealing_doc.t_amount.
           taccno = dealing_doc.tclientaccno.
           vaccno = dealing_doc.vclientaccno.
           urg_com = dealing_doc.com_expr.
           conv_com = dealing_doc.com_conv.
           currate = dealing_doc.rate.
           currency = dealing_doc.crc.
           comaccno = dealing_doc.com_accno.
           famount = dealing_doc.f_amount.
           run find_client.
           if this-procedure:private-data <> ?
              then do: if dealing_doc.tngtoval then tamount = famount. else vamount = famount. end.
           display vamount tamount taccno vaccno urg_com conv_com comaccno clientno clientname currate currency  with frame dframe1.
           if this-procedure:private-data <> ?
              then
                do:
                  if (dealing_doc.jh = ?) or (dealing_doc.jh = 0)
                    then
                     do:
                        find crc where crc.crc = currency no-lock no-error.
                        case crc.crc:
                          when 2 then find sysc where sysc.sysc = 'ercusd' no-error.
                          when 4 then find sysc where sysc.sysc = 'ercrur' no-error.
                          when 3 then find sysc where sysc.sysc = 'erceur' no-error.
                        end.
                        currate = sysc.deval.

                        update currate with frame dframe1.

                        find current dealing_doc exclusive-lock no-error.
                        dealing_doc.rate = currate.
                        dealing_doc.who_mod = g-ofc.
                        find current dealing_doc no-lock no-error.
                        vamount = famount.

                        run getperc_vamt.
                        find current dealing_doc exclusive-lock no-error.
                        dealing_doc.v_amount = vamount.
                        dealing_doc.t_amount = tamount.
                        dealing_doc.com_expr = urg_com.
                        dealing_doc.com_conv = conv_com.
                        find current dealing_doc no-lock no-error.
                     end.
                end.
           display vamount tamount taccno vaccno urg_com conv_com comaccno clientno clientname currate currency with frame dframe1.
        end.
      else do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
  end. /* do */
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
            if (dealing_doc.jh <> 0) and (dealing_doc.jh <> ?)
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
     clear frame dframe2.
     if documn = '' then set documn with frame dframe2.
     find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType no-lock no-error.
     if not available(dealing_doc) then do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
       else do:
         if dealing_doc.who_mod <> g-ofc
            then do:
                 message "Документ принадлежит" dealing_doc.who_mod view-as alert-box.
                 return.
            end.
         s-jh = dealing_doc.jh.
         run dvou("prit").
       end.
end procedure.


procedure create_trans:
  do transaction:
/*     documn = "".*/
     clear frame dframe2.
/*     set documn with frame dframe2.*/
     if documn = '' then set documn with frame dframe2.
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
                tamount = dealing_doc.t_amount.
                taccno = dealing_doc.tclientaccno.
/*                if check_acc(taccno) then undo,leave.*/
                vaccno = dealing_doc.vclientaccno.
/*                if check_acc(vaccno) then undo,leave.*/
                urg_com = dealing_doc.com_expr.
                conv_com = dealing_doc.com_conv.
                currency = dealing_doc.crc.
                currate = dealing_doc.rate.
                comaccno = dealing_doc.com_accno.
/*                if check_acc(comaccno) then undo,leave.  */
if check_acc(vaccno,vamount,false) then undo,leave.
if check_acc(comaccno,urg_com + conv_com,true) then undo,leave.

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

procedure delete_trans:
 do transaction on error undo, return:
/*   documn = "".*/
   clear frame dframe2.
   if documn = '' then set documn with frame dframe2.
/*   set documn with frame dframe2.*/
   find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType share-lock no-error.
   if not available(dealing_doc) then do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
     else do:
       if dealing_doc.who_mod <> g-ofc
          then do:
               message "Вы не можете удалять документы принадлежащие" dealing_doc.who_mod view-as alert-box.
               return.
          end.
        find jh where jh.jh = dealing_doc.jh no-lock no-error.
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
                                          run trxstsdel (input dealing_doc.jh, input v-sts, output rcode, output rdes).
                                          return.
                                     end.
                       else undo, return.
                   end.
                   else dealing_doc.jh = ?.
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
               message "Сумма в валюте отсутсвует или равна нулю" view-as alert-box.
               return.
             end.
          dealing_doc.v_amount = vamount.
          dealing_doc.t_amount = tamount.
          dealing_doc.com_expr = urg_com.
          dealing_doc.com_conv = conv_com.
          dealing_doc.whn_mod = g-today.
          dealing_doc.who_mod = g-ofc.
          cur_time = time.
          dealing_doc.time_mod = cur_time.
          dealing_doc.rate = currate.
       end.
  */
end procedure.


procedure open_doc: /*РЕДАКТИРОВАНИЕ*/

/*documn = "".*/

clear frame dframe1.
if documn = '' then set documn with frame dframe1.
/*set documN with frame dframe1.*/

do transaction on error undo, return:
   find dealing_doc where docno = documN and dealing_doc.doctype = dType share-lock no-error.
   if available (dealing_doc)
    then
      do:
         if (dealing_doc.jh <> ?) and (dealing_doc.jh <> 0)
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
/*         if check_acc(taccno) then undo,leave.*/
         vaccno = dealing_doc.vclientaccno.
/*         if check_acc(vaccno) then undo,leave.*/
         urg_com = dealing_doc.com_expr.
         conv_com = dealing_doc.com_conv.
         currate = dealing_doc.rate.
         currency = dealing_doc.crc.
         run find_client.
         display clientno clientname taccno vamount tamount taccno vaccno urg_com conv_com currate with frame dframe1.
         update currate with frame dframe1.
         update vamount with frame dframe1.
         run getperc_vamt.
         displ tamount conv_com urg_com with frame dframe1.
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

end procedure.


procedure getperc_vamt:
   tamount = vamount * currate.
   urg_com = get_percent(urg_int, vamount).


message conv_com.
pause 555.

   conv_com = get_percent(conv_int, vamount).

message conv_com.
pause 444.



   if currency <> 2
      then
        do:
           find first dcrc where dcrc.crc = 2 no-lock no-error.
           cim_notusd = conv_int_min * dcrc.rate[1].
           find first dcrc where dcrc.crc = currency no-lock no-error.
           cim_notusd = cim_notusd / dcrc.rate[1].
                if conv_com <= cim_notusd
                   then
                     do:
                        conv_com = cim_notusd.
                        run calc_comm(input dcrc.rate[1]).
                     end.
                   else
                     do:
                        run calc_comm(input currate).
                     end.
        end.
      else
        do:
                 if conv_com <= conv_int_min
                    then
                      do:
                         conv_com = conv_int_min.
                         find first dcrc where dcrc.crc = currency no-lock no-error.
                         run calc_comm(input dcrc.rate[1]).
                      end.
                    else
                      do:
                         run calc_comm(input currate).
                      end.
        end.
end procedure.


procedure do_trans:

{dil_acc.i}

find crc where crc.crc = currency no-lock no-error.
avg_tamount = crc.rate[1] * vamount.
avg_tamount = round(round(avg_tamount,3),2).
diff_tamount = avg_tamount - tamount.
release crc.

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

run trxgen('dil0043', dlm,

    string(vamount) + dlm +
    string(currency) + dlm +
    string(currate) + dlm +
    vaccno          + dlm +
    valacc[currency] + dlm +
    "На реконвертацию согласно заявки " + string(currate) + dlm +

/*    string(vamount) + dlm +
    string(currency) + dlm +
    string(currate) + dlm +
    valacc[currency] + dlm + */

    string(tamount) + dlm +
    arpacc          + dlm +
    taccno          + dlm +
    "Зачисление тенге на счет клиента " + string(currate) + dlm +

    string(conv_temp) + dlm +
    string(temp_rate)  + dlm +
    comaccno         + dlm +

    string(urg_temp)  + dlm +
    string(temp_rate)  + dlm +
    comaccno + dlm +

    string(vamount)     + dlm +
    string(currency)    + dlm +
    valacc[currency]    + dlm +


    string(avg_tamount) + dlm +
    arpacc,

    m_sub, documn, output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
        pause.
        undo,return.
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
           find dealing_doc where dealing_doc.docno = documn share-lock no-error.
           dealing_doc.jh = s-jh.
           find current dealing_doc no-lock no-error.
           run dvou("prit").
         end.
      end.
end.
end procedure.

procedure edit_comms:
  update conv_int skip urg_int skip conv_int_min with side-labels.
end procedure.

