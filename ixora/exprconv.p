/* exprconv.p
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
        Срочная конвертация (801 - код в тарификаторе)
        03.11.02 timur Добавлена возможность делать конвертацию ARP-CIF, ARP-ARP
        13/05/2004 madiar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        12/07/2004 tsoy - вернул старую версию до уточненния и тестирования ТЗ
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
        06.07.2005 dpuchkov - birz_int = 0.00 (т.к. кто то удалил тариф биржевой комиссии)
        25.08.2005 saltanat - Выборка льгот по счетам.
        06.10.2005 dpuchkov - добавил проверку на дебетовое сальдо при удалении транзакции.
        17.03.2006 dpuchkov - добавил цели конвертации
        07.04.2006 ten      - добавил цели конвертации по inbank.
        11.04.2006 u00121   - убрал no-undo  у "шаренных" переменных, а то ругалось жутков о не совпадении статусов
        30/04/2008 madiyar - перекомпиляция
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/


{global.i}
{crc-crc.i}

def var  documN     like dealing_doc.docno label "Номер документа" no-undo.
def var  documType  as integer /*тип документа 1 срочная конвертация*/ no-undo.
def var  taccno     as char    label "Счет клиента для снятия средств    " format "x(9)" no-undo.
def var  vaccno     as char    label "Счет клиента для зачисления средств" format "x(9)" no-undo.

def var  currency   as integer label "Валюта" format ">9" no-undo.
def var  clientno   as char    label "ID клиента" no-undo.
def var  clientname like cif.name    label "Клиент" format "x(45)" no-undo.
def var  tamount    as decimal    label "Сумма на конвертацию в тенге "  format "zzz,zzz,zzz,zzz.99" no-undo.
def var  vamount    as decimal    label "Сумма на конвертацию в валюте" format "zzz,zzz,zzz,zzz.99" no-undo.
def var  avg_tamount    as decimal  format "zzz,zzz,zzz,zzz.99" no-undo.
def var  diff_tamount    as decimal  format "zzz,zzz,zzz,zzz.99" no-undo.
def var  famount    as decimal no-undo.
def var  urg_com    as decimal    label "Комиссия за срочность        " format "zzz,zzz,zzz,zzz.99" no-undo.
def var  conv_com   as decimal    label "Комиссия за конвертацию      " format "zzz,zzz,zzz,zzz.99" no-undo.
def var  birz_com   as decimal    label "Биржевая комиссия            " format "zzz,zzz,zzz,zzz.99" no-undo.

def var  litems     as char no-undo.
def var  currate    as decimal label "Курс" format "zzz,zzz.9999" no-undo .
def var  l-tran     as logical no-undo. /*да сделать транзакцию*/
def var  gcom      as logical no-undo.

def new shared var s-jh like jh.jh.

def var retval as char no-undo.
def var rcode as int no-undo.
def var rdes  as cha no-undo.
def var dlm as char init "|" no-undo.

def var rem as char initial "1223asfdasdfa" no-undo.
def var cur_time as integer no-undo.
def var ans as logical no-undo.
/*def var min_com as logical label "Брать минимум при взятии комиссии" format "да/нет" init "yes".*/

def var  tamount_proc as decimal  label "Окончательная сумма в тенге  " format "zzz,zzz,zzz,zzz.99"  no-undo.
/*Сумма в валюте + ком. за срочность + ком. за конвертацию + биржевая */

def var conv_int as decimal initial "0.25"    label "Процент комиссии за конвертацию " no-undo.
def var conv_int_min as decimal initial "15"  label "Минимальная сумма за конвертацию" no-undo.
def var conv_int_max as decimal label "Максимальная сумма за конвертацию" no-undo.
def var cim_notusd as decimal no-undo. /*используется если валюты не доллары*/
def var urg_int as decimal  initial "0.2"     label "Процент комиссии за срочность   " no-undo.
def var birz_int as decimal initial "0.00"    label "Процент по биржевой комиссии    " no-undo.
def var conv_temp as decimal no-undo.
def var urg_temp as decimal no-undo.
def var tfirst as logical no-undo.   /*true если сначала была введена сумма в тенге
                               false если сперва была сумма в валюте */
def buffer dcrc for crc.
def shared var dType as integer .
def var v-sts like jh.sts no-undo.
def buffer b-aaastr for aaa.

define variable m_sub as character initial "dil" no-undo.

/* 03.11.02 timur*/

define variable DebSubled as character no-undo.
define variable CredSubled as character no-undo.

/* 03.11.02 timur*/

define frame dframe1 documN skip
                     clientno clientname skip
                     taccno skip
                     vaccno skip
                     currency space (5) currate skip(1)
                     tamount vamount skip(1)
                     conv_com skip
                     urg_com skip
                     birz_com skip(2)

                     tamount_proc skip
                   /*  min_com*/
             WITH /*KEEP-TAB-ORDER*/ SIDE-LABELS TITLE "Срочная конвертация".

define frame dframe2 documN with SIDE-LABELS.

define frame dframe3 conv_int urg_int with SIDE-LABELS OVERLAY CENTERED.

SESSION:SYSTEM-ALERT-BOXES = true.

{dil_util.i}

/*SESSION:DATA-ENTRY-RETURN = TRUE.*/

on help of currency in frame dframe1 do:
    run help-crc1.
end.

on help of documN in frame dframe1 do:
   run help-dilnum.
end.

on help of documN in frame dframe2 do:
   run help-dilnum.
end.

procedure find_client:
       find aaa where aaa.aaa eq taccno no-lock no-error.
       if not available aaa
          then
            do:
               find arp where arp.arp eq taccno no-lock no-error.
               if not avail arp
                  then
                    do:
                       message "Счет" taccno "не найден" skip
                               "Счет может быть CIF или ARP" view-as alert-box.
                               undo,retry.
                    end.
                  else
                    do:
                       DebSubled = 'ARP'.
                       clientname = arp.des.
                       clientno = 'ARP'.
                    end.
            end.
          else do:
              DebSubled = 'CIF'.
              find cif where cif.cif eq aaa.cif no-lock no-error.
              if not available cif
                 then message "Не найден клиент" aaa.cif.
                 else do:
                   clientname = trim(trim(cif.prefix) + " " + trim(cif.name)).
                   clientno = cif.cif.


/*
find first tarif2 where tarif2.num + tarif2.kod = '802'
                    and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then
   do:
      conv_int = tarif2.proc.
      conv_int_min = crc-crc(tarif2.min1, tarif2.crc, 2).
      conv_int_max = crc-crc(tarif2.max1, tarif2.crc, 2).
   end.
*/


                   /* 05/07/05 saltanat - Если у клиента есть льготы по счету, то берем тариф по счету */
                   find first tarifex2 where tarifex2.aaa = aaa.aaa
                                         and tarifex2.cif = clientno
                                         and tarifex2.str5 = '801'
                                         and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
                      urg_int = tarifex2.proc.
                      release tarifex2 no-error.
                   end.
                   else do:
	                   find first tarifex where tarifex.str5 = '801'
    	                                    and tarifex.cif  = clientno
        	                                and tarifex.stat = 'r' share-lock no-error.
            	       if available tarifex then urg_int = tarifex.proc.
                	   release tarifex no-error.
                   end.

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
	                   find first tarifex where tarifex.str5 = '802'
    	                                    and tarifex.cif  = clientno
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
	                   find first tarifex where tarifex.str5 = '805'
    	                                    and tarifex.cif  = clientno
        	                                and tarifex.stat = 'r' share-lock no-error.
            	       if available tarifex then do:
                	     birz_int = tarifex.proc.
	                   end.
    	               release tarifex no-error.
    	            end.
        	        {tr4sign.i}
/*                   if min_com = no then conv_int_min = 0.*/
                 end.
          end.
    if can-find(aaa where aaa.aaa = vaccno) then CredSubled = 'CIF'.
    if can-find(arp where arp.arp = vaccno) then CredSubled = 'ARP'.
end procedure.

procedure get_precamt:

def var delta as decimal.

repeat:
  delta = trunc( (tamount_proc - birz_com) / currate - vamount - conv_com - urg_com, 8).
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

documN  = ''.
vaccno  = ''.
taccno  = ''.
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

conv_int = 0.00.
conv_int_min = 0.
conv_int_max= 0.
urg_int = 0.0.
birz_int = 0.00.


/*   find first tarif2 where tarif2.num + tarif2.kod = '801' and tarif2.stat = 'r' no-lock no-error.
     if avail tarif2 then urg_int = tarif2.proc.   */
/*
find first tarif2 where tarif2.num + tarif2.kod = '802'
                    and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then
   do:
      conv_int = tarif2.proc.
      conv_int_min = crc-crc(tarif2.min1, tarif2.crc, 2).
      conv_int_max = crc-crc(tarif2.max1, tarif2.crc, 2).
   end.

find first tarif2 where tarif2.num + tarif2.kod = '805'
                    and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then birz_int = tarif2.proc.
*/






conv_temp = 0.
urg_temp = 0.

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

set taccno with frame dframe1.
 if taccno entered
   then
     do:
       find aaa where aaa.aaa eq taccno no-lock no-error.
       if not available aaa
          then
               do:
                  find arp where arp.arp eq taccno no-lock no-error.
                  if avail arp
                     then
                         do:
                            find crc where crc.crc = arp.crc no-lock no-error.
                            if crc.crc <> 1 then
                            do:
                               message "Введите тенговый счет" view-as alert-box.
                               undo,retry.
                            end.
                            release crc.
                            DebSubled = 'ARP'.
                            clientname = arp.des.
                            clientno = 'ARP'.
                         end.
                     else
                         do:
                            message "Счет" taccno "не найден" skip
                                    "Счет может быть CIF или ARP" view-as alert-box.
                                     undo,retry.
                         end.
               end.
          else do:
              DebSubled = 'CIF'.
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
                                         and tarifex2.str5 = '801'
                                         and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
                      urg_int = tarifex2.proc.
                      release tarifex2 no-error.
                   end.
                   else do:
	                   find first tarifex where tarifex.str5 = '801'
    	                                    and tarifex.cif  = clientno
        	                                and tarifex.stat = 'r' share-lock no-error.
            	       if available tarifex then urg_int = tarifex.proc.
                	   release tarifex no-error.
                   end.

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
	                   find first tarifex where tarifex.str5 = '802'
    	                                    and tarifex.cif  = clientno
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
	                   find first tarifex where tarifex.str5 = '805'
    	                                    and tarifex.cif  = clientno
        	                                and tarifex.stat = 'r' share-lock no-error.
            	       if available tarifex then do:
                	     birz_int = tarifex.proc.
	                   end.
    	               release tarifex no-error.
    	            end.

                   {tr4sign.i}
                 end.
          end.
     end.
   else undo,retry.


case DebSubled:
when 'CIF' then
  do:




     set currency with frame dframe1.
     if currency entered
        then do:


          find crc where crc.crc eq currency no-lock no-error.
          if not available crc then do: message "Валюта" currency "не найдена" view-as alert-box. undo, retry. end.
             else do:

if cif.type = "p" then do:
         if currency = 2 or currency = 3 or currency = 4 then do:

                   find first tarifex2 where tarifex2.aaa = aaa.aaa and tarifex2.cif = clientno and tarifex2.str5 = '809' and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
                      conv_int = tarifex2.proc.
                      conv_int_min = crc-crc(tarifex2.min1, tarifex2.crc, 2).
                      conv_int_max = crc-crc(tarifex2.max1, tarifex2.crc, 2).
                   end.
                   else  do:
                      find first tarifex where tarifex.str5 = '809' and tarifex.cif  = clientno and tarifex.stat = 'r' share-lock no-error.
                      if available tarifex then do:
                         conv_int = tarifex.proc.
                         conv_int_min = crc-crc(tarifex.min1, tarifex.crc, 2).
                         conv_int_max = crc-crc(tarifex.max1, tarifex.crc, 2).
                      end.
                   end.
         end.
         else
         do:

                   find first tarifex2 where tarifex2.aaa = aaa.aaa and tarifex2.cif = clientno and tarifex2.str5 = '814' and tarifex2.stat = 'r' no-lock no-error.
                   if available tarifex2 then do:
                      conv_int = tarifex2.proc.
                      conv_int_min = crc-crc(tarifex2.min1, tarifex2.crc, 2).
                      conv_int_max = crc-crc(tarifex2.max1, tarifex2.crc, 2).
                   end.
                   else  do:
                      find first tarifex where tarifex.str5 = '814' and tarifex.cif  = clientno and tarifex.stat = 'r' share-lock no-error.
                      if available tarifex then do:
                         conv_int = tarifex.proc.
                         conv_int_min = crc-crc(tarifex.min1, tarifex.crc, 2).
                         conv_int_max = crc-crc(tarifex.max1, tarifex.crc, 2).
                      end.
                   end.
         end.


end.
else do:

         find first tarifex2 where tarifex2.aaa = aaa.aaa and tarifex2.cif = clientno and tarifex2.str5 = '804' and tarifex2.stat = 'r' no-lock no-error.
         if available tarifex2 then do:
            conv_int = tarifex2.proc.
            conv_int_min = crc-crc(tarifex2.min1, tarifex2.crc, 2).
            conv_int_max = crc-crc(tarifex2.max1, tarifex2.crc, 2).

         end.
         else  do:
            find first tarifex where tarifex.str5 = '804' and tarifex.cif  = clientno and tarifex.stat = 'r' share-lock no-error.
            if available tarifex then do:
               conv_int = tarifex.proc.
               conv_int_min = crc-crc(tarifex.min1, tarifex.crc, 2).
               conv_int_max = crc-crc(tarifex.max1, tarifex.crc, 2).
            end.
         end.
end.







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
           conv_int_max = crc-crc(tarif2.max1, tarif2.crc, 2).
      end.
 end.























               for each aaa where aaa.crc eq currency and aaa.cif eq clientno and aaa.sta <> 'C' no-lock break by aaa.crc:
                  find lgr where lgr.lgr = aaa.lgr no-lock no-error.
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
               end.
          end.
     CredSubled = 'CIF'.
     end.
  end.
when 'ARP' then
  do:
     set vaccno with frame dframe1.
     if vaccno entered then
        do:
           find aaa where aaa.aaa = vaccno no-lock no-error.
           if avail aaa
             then
               do:
                  CredSubled = 'CIF'.
                  find crc where crc.crc = aaa.crc no-lock no-error.
                  if crc.crc = 1 then
                       do:
                          message "Введите валютный счет" view-as alert-box.
                                   undo,retry.
                       end.
               end.
             else
               do:
                  find arp where arp.arp = vaccno no-lock no-error.
                  if avail arp
                     then
                       do:
                          CredSubled = 'ARP'.
                          find crc where crc.crc = arp.crc no-lock no-error.
                          if crc.crc = 1 then
                          do:
                             message "Введите валютный счет" view-as alert-box.
                                      undo,retry.
                          end.
                       end.
                     else
                       do:
                          message "Счет" vaccno "не найден" skip
                                  "Счет может быть CIF или ARP" view-as alert-box.
                                   undo,retry.
                       end.
               end.
        end.
  end.
end case.

 currency = crc.crc.

 displ currency with frame dframe1.

 case crc.crc:
      when 2 then find sysc where sysc.sysc = 'ecusd' no-lock no-error.
      when 4 then find sysc where sysc.sysc = 'ecrur' no-lock no-error.
      when 3 then find sysc where sysc.sysc = 'eceur' no-lock no-error.
 end.
 currate = sysc.deval.
 update currate with frame dframe1.








 set tamount with frame dframe1.
 if tamount entered
    then do: famount = tamount. run getperc_tamt. tfirst = true. end.
    else do:
             set vamount with frame dframe1.
             if vamount entered
                then do: famount = vamount. run getperc_vamt. tfirst = false. end.
         end.
 displ conv_com urg_com birz_com tamount_proc tamount vamount with frame dframe1.

 if check_acc(taccno, tamount_proc, false) then undo,retry.
 run create_doc.
 pause.

 run yn("","Сделать транзакцию?","","", output l-tran).
 if l-tran then do:
   {cnv.i}
    run do_exprtrans.
    create trgt.
           trgt.jh = s-jh.
           trgt.rem1 = v-sln1.
           trgt.rem2 = v-sln2.
    return.
 end.

end. /*end repeat */
end. /*end transaction*/

hide frame dframe1.

end procedure.

procedure open_doc: /*РЕДАКТИРОВАНИЕ*/
/*
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
         birz_com = dealing_doc.com_bourse.
         currate = dealing_doc.rate.
         currency = dealing_doc.crc.
         tamount_proc = dealing_doc.t_amt_coms.
         tfirst = dealing_doc.TngtoVal.
         run find_client.
         display clientno clientname taccno vamount tamount taccno vaccno urg_com conv_com birz_com currate currency tamount_proc with frame dframe1.
         update currate with frame dframe1.



         update tamount with frame dframe1.
         if tfirst
            then run getperc_tamt.
            else
              do:
                update vamount with frame dframe1.
                run getperc_vamt.
              end.
/*       run yn("","Сделать транзакцию?","","", output l-tran).
         if l-tran then do: run do_exprtrans. return. end.
                   else do: hide all. undo,return. end. */

              if currency = 4 then birz_com = 0.
              displ conv_com urg_com birz_com tamount_proc with frame dframe1.
              pause.
              message "Отредактировать проценты по комиссии?" view-as alert-box buttons yes-no title "" update wahl as log.
              if wahl then
                   do:
                      update conv_int urg_int with frame dframe3.
                      if tfirst then run getperc_tamt.
                                else run getperc_vamt.
                   end.
              displ conv_com urg_com.
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

procedure do_exprtrans:

{dil_acc.i}

find crc where crc.crc = currency no-lock no-error.
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



run trxgen('dil0040', dlm,

    string(tamount_proc) + dlm +
    DebSubled            + dlm +
    taccno               + dlm +
    arpacc               + dlm +
    "На конвертацию соглано заявке " + string(currate) + dlm +

    string(vamount)      + dlm +
    string(currency)     + dlm +
    string(currate)      + dlm +
    valacc[currency]     + dlm +
    CredSubled           + dlm +
    vaccno               + dlm +
    "Зачисление на валютный счет " + string(currate) + dlm +

    string(conv_com)  + dlm +
    string(currency) + dlm +
    string(currate)  + dlm +

    string(urg_com)  + dlm +
    string(currency) + dlm +
    string(currate)  + dlm +

    string(birz_com) + dlm +

    string(avg_tamount) + dlm +
    arpacc              + dlm +

    string(vamount)     + dlm +
    string(currency)    + dlm +
    valacc[currency]

/*  substring(rem,1  ,55) + dlm +
    substring(rem,56 ,55) + dlm +
    substring(rem,111,55) + dlm +
    substring(rem,166,55) + dlm +
    substring(rem,221,55)*/
    ,
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
         if diff_tamount < 0
            then
              do:
               run trxgen('dil0044', dlm,

                         string(abs(diff_tamount)) + dlm +
                         arpacc  ,

                         m_sub, documn, output rcode, output rdes, input-output s-jh).
              end.
           /* else
              do:
               run trxgen('dil0045', dlm,

                         string(abs(diff_tamount)) + dlm +
                         arpacc ,
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

procedure create_doc:

  find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType share-lock no-error .
  if not available dealing_doc
     then
       do:
          create dealing_doc.
          dealing_doc.docno = DocumN.
          dealing_doc.crc = crc.crc.
          dealing_doc.doctype = 1. /*срочная конвертация*/
          if (vamount = ?) or (vamount = 0)
             then do:
               message "Сумма в валюте отсутствует или равна нулю" view-as alert-box.
               return.
             end.
          dealing_doc.v_amount = vamount.
          dealing_doc.t_amount = tamount.
          dealing_doc.t_amt_coms = tamount_proc.
          dealing_doc.tclientaccno = taccno.
          dealing_doc.vclientaccno = vaccno.
          dealing_doc.com_expr = urg_com.
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
          dealing_doc.t_amt_coms = tamount_proc.
          dealing_doc.com_expr = urg_com.
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

procedure delete_doc:
  clear frame dframe2.
/*  set documn with frame dframe2.*/
  if documn = '' then set documn with frame dframe2.
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

procedure view_doc:
  run Init_Vars.
  clear frame dframe1.

  if this-procedure:private-data = ?
     then
       do:
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
           documtype = dealing_doc.doctype.
           taccno = dealing_doc.tclientaccno.
           vaccno = dealing_doc.vclientaccno.
           urg_com = dealing_doc.com_expr.
           conv_com = dealing_doc.com_conv.
           birz_com = dealing_doc.com_bourse.
           currate = dealing_doc.rate.
           currency = dealing_doc.crc.
           tamount_proc = dealing_doc.t_amt_coms.
           tamount = dealing_doc.t_amount.
           vamount = dealing_doc.v_amount.
           famount = dealing_doc.f_amount.
           run find_client.
           if this-procedure:private-data <> ?
              then do: if dealing_doc.tngtoval then tamount = famount. else vamount = famount. end.
           display vamount tamount taccno vaccno urg_com conv_com birz_com currate currency clientno clientname tamount_proc with frame dframe1.
           if this-procedure:private-data <> ?
              then
                do:
                  if (dealing_doc.jh = ?) or (dealing_doc.jh = 0)
                    then
                     do:
                      update currate with frame dframe1.
                      find current dealing_doc exclusive-lock.

/*
if dealing_doc.who_cr = "inbank" then do:
find first tarif2 where tarif2.num + tarif2.kod = '804' and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then
   do:
      conv_int = tarif2.proc.
      conv_int_min = crc-crc-date(tarif2.min1, tarif2.crc, 2, dealing_doc.whn_cr).
      conv_int_max = crc-crc-date(tarif2.max1, tarif2.crc, 2, dealing_doc.whn_cr).
   end.
end.
*/

                      dealing_doc.rate = currate.
                      dealing_doc.who_mod = g-ofc.
                      if dealing_doc.tngtoval
                         then
                           do:
                             tamount = famount.
                             run getperc_tamt.
                             dealing_doc.t_amt_coms = tamount_proc.
                           end.
                         else
                           do:
                             vamount = famount.
                             run getperc_vamt.
                             dealing_doc.t_amount = tamount.
                             dealing_doc.t_amt_coms = tamount_proc.
                           end.
                      dealing_doc.v_amount = vamount.
                      dealing_doc.com_expr = urg_com.
                      dealing_doc.com_conv = conv_com.
                      dealing_doc.com_bourse = birz_com.

                      find current dealing_doc no-lock.
                     end.
                end.
           display vamount tamount taccno vaccno urg_com conv_com birz_com currate currency clientno clientname tamount_proc with frame dframe1.
        end.
      else do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
  end. /* do */
end procedure.

procedure delete_trans:
 do transaction on error undo, return:
/*   documn = "".*/
   clear frame dframe2.
/*   set documn with frame dframe2.*/
   if documn = '' then set documn with frame dframe2.
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
                     find trgt where trgt.jh eq jh.jh exclusive-lock no-error.
                     if avail trgt then trgt.jh = int(dealing_doc.docno).
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
                   else do:
                     find trgt where trgt.jh eq jh.jh exclusive-lock no-error.
                     if avail trgt then trgt.jh = int(dealing_doc.docno).
                     dealing_doc.jh = ?.
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

procedure create_trans:
  do transaction:
     clear frame dframe2.
     if documn = '' then set documn with frame dframe2.
 /*    set documn with frame dframe2.*/
     find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType share-lock no-error.
     if not available(dealing_doc) then do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
       else do:
         if dealing_doc.who_mod <> g-ofc
            then do:
                 message "Документ принадлежит" dealing_doc.who_mod skip "Транзакция не будет сделана" view-as alert-box.
                 return.
            end.
         if dealing_doc.jh = ? or dealing_doc.jh = 0 then do:
            vamount = dealing_doc.v_amount.
            tamount = dealing_doc.t_amount.
            tamount_proc = dealing_doc.t_amt_coms.
            taccno = dealing_doc.tclientaccno.
            if check_acc(taccno, tamount_proc, false) then undo,leave.
            vaccno = dealing_doc.vclientaccno.
/*                if check_acc(vaccno) then undo,leave.*/
            urg_com = dealing_doc.com_expr.
            conv_com = dealing_doc.com_conv.
            birz_com = dealing_doc.com_bourse.
            currency = dealing_doc.crc.
            currate = dealing_doc.rate.

            run yn("","Сделать транзакцию?","","", output l-tran).
            if l-tran then do:
               if dealing_doc.who_cr <> "inbank" then do:
                  {cnv.i}
                  run do_exprtrans.
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
                     run do_exprtrans.
                     if s-jh <> 0 then trgt.jh = s-jh.
                  end.
               end.
            end.
            else do: hide all. undo,return. end.
         end.
         else do:
              message "Транзакция для данного документа уже существует" view-as alert-box.
              return.
         end.
     end.
  end.
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

procedure getperc_tamt:
   if currency = 4 then birz_com = 0. else birz_com = get_percent(birz_int, tamount).
   birz_com = round (birz_com,3). birz_com = round (birz_com,2).
   tamount_proc = tamount - birz_com.
   vamount = round (tamount_proc / currate, 2).
   displ tamount_proc with frame dframe1.
   urg_com = get_percent(urg_int, vamount).
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
             end.
          if conv_int_max <> 0 then
             do:
                  find first dcrc where dcrc.crc = 2 no-lock no-error.
                  cim_notusd = conv_int_max * dcrc.rate[1].
                  find first dcrc where dcrc.crc = currency no-lock no-error.
                  cim_notusd = cim_notusd / dcrc.rate[1].
                  release dcrc.
                  if conv_com > cim_notusd then conv_com = cim_notusd.
             end.
      end.
    else
      do:
         if conv_int_min <> 0
            then
              if conv_com < conv_int_min
                 then
                   conv_com = conv_int_min.

         if conv_int_max <> 0
            then
              if conv_com > conv_int_max
                 then
                   conv_com = conv_int_max.

      end.
   display vamount with frame dframe1.
end procedure.

procedure getperc_vamt:
   gcom = true.
   tamount = vamount * currate.
   urg_temp = get_percent(urg_int, vamount).
   conv_temp = get_percent(conv_int, vamount).
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
               if conv_temp <= cim_notusd then do: conv_temp = cim_notusd. conv_com = cim_notusd. gcom = false. end.
            end.
         if conv_int_max <> 0 then
            do:
               find first dcrc where dcrc.crc = 2 no-lock no-error.
               cim_notusd = conv_int_max * dcrc.rate[1].
               find first dcrc where dcrc.crc = currency no-lock no-error.
               cim_notusd = cim_notusd / dcrc.rate[1].
               release dcrc.
               if conv_temp >= cim_notusd then do: conv_temp = cim_notusd. conv_com = cim_notusd. gcom = false. end.
            end.
        if gcom = true then conv_com = get_percent(conv_int, (vamount + conv_temp + urg_temp)).
      end.
    else
      do:
        if conv_int_min <> 0 then
             if conv_temp <= conv_int_min
                then do: conv_com = conv_int_min. conv_temp = conv_int_min. gcom = false. end.

        if conv_int_max <> 0 then
           do:
             if conv_temp >= conv_int_max
                then do: conv_com = conv_int_max. conv_temp = conv_int_max. gcom = false. end.
           end.
        if gcom = true then conv_com = get_percent(conv_int, (vamount + conv_temp + urg_temp)).
      end.
   urg_com = get_percent(urg_int, (vamount + conv_temp + urg_temp)).
   tamount_proc = (vamount + urg_com + conv_com) * currate.
   if currency = 4 then birz_com = 0. else birz_com = get_percent(birz_int, vamount + urg_com + conv_com) * currate.
   tamount_proc = tamount_proc + birz_com.
   if currency = 4 then birz_com = 0. else birz_com = get_percent(birz_int, tamount_proc).
   run get_precamt.
   birz_com = round (birz_com,3). birz_com = round (birz_com,2).
   conv_com = round (conv_com,3). conv_com = round (conv_com,2).
   urg_com = round(urg_com, 3). urg_com = round(urg_com, 2).
   vamount = vamount + conv_com + urg_com.
   tamount_proc = tamount_proc - birz_com.
end procedure.

procedure edit_comms:
  update conv_int skip urg_int skip birz_int skip conv_int_min with side-labels.
end procedure.



