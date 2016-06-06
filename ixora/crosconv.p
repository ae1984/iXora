/* crosconv.p
 * MODULE
        Дилинг
 * DESCRIPTION
        Кросс конвертация (806 - код в тарификаторе, если сумма меньше 1000USD
        согласно распоряжения ї44 от 05.06.2003г)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        13.8
 * BASES
        BANK COMM
 * AUTHOR
        09.06.03 timur
 * CHANGES
        29.12.2003 nadejda  - добавлены счета ГК депозитов в связи с переходом на новый план счетов
        08.01.2004 suchkov  - еще добавлены счета ГК депозитов в другом месте
        14.01.2004 sasco    - добавил формирование линии по курсовой разнице на доходы/расходы с 185800
        22.01.2004 sasco    - исправил расчет сумм на доходы / расходы
        10.02.2004 nadejda  - добавлена конвертация 2 уровня и перенос 11 уровня - линии в шаблоне DIL0063
        26.02.2004 nataly   - добавлена кросс-конвертация из любой валюты в любую
        13.04.2004 nadejda  - комиссия за клнвертацию депозита "Звезда" не снимается - настройка в sub-cod
        13/05/2004 madiar   - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        22.06.2004 dpuchkov - добавил поиск валюты счета для списания при просмотре документа.
        16.08.2004 suchkov  - исправлена ошибка при расчете курса кросс-конвертации
        02.09.2004 tsoy     - Размораживаем средства для конвертации
        23.11.2004 dpuchkov - заморозка только начальной суммы открытие нового счета для депозита Dallas (ТЗ 1222)
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        24.02.2005 dpuchkov - ограничил количество конвертаций по депозитам до 2-х
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        28.04.2005 dpuchkov - запретил конвертацию депозитов звезда и пенсионный(новый)  в п 13.8
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
        20.05.2005 dpuchkov - Добавил отображение доп соглашений при конвертации депозитов.
        06.06.2005 dpuchkov - Дополнительное окно - продупреждение для менеджеров для проверки правильности сумм.
        06.07.2005 dpuchkov - birz_int = 0.00 (т.к. кто то удалил тариф биржевой комиссии)
        06.10.2005 dpuchkov - добавил проверку на дебетовое сальдо при удалении транзакции.
        07.11.2006 dpuchkov - добавил проверку на ошибочно проставленные группы
        24.05.2011 evseev - добавил проверку bf-lgr.feensf = 6
        03/08/2011 evseev - на основании С.З. запрет конвертации 478,479,480,481,482,483
        04/08/2011 evseev - исправил синтаксическую ошибку
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        20.05.2013 evseev - tz1828
        24.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
*/


{global.i}
{crc-crc.i}
{w-2-u.i}
{comm-txb.i}

def new shared var v-accusd like aaa.aaa.
def new shared var s-opnamt like aaa.opnamt.
def new shared var s-cif as char.

def buffer t-aaa_conv for aaa_conv.
def var t-cnv as integer.


def var  documN     like dealing_doc.docno label "Номер документа".
def var  documType  as integer /*тип документа 1 срочная конвертация*/.
def var  taccno     as char    label "Счет клиента для снятия средств    " format "x(9)".
def var  vaccno     as char    label "Счет клиента для зачисления средств" format "x(9)".
def var  v-sysc     as  char.

def var  currency   as integer label "Валюта" format ">9".
def var  curtacc   as integer label "Валюта" format ">9".
def var  clientno   as char    label "ID клиента".
def var  clientname like cif.name    label "Клиент" format "x(45)".
def var  tamount    as decimal    label "Сумма на конвертацию начальная "  format "zzz,zzz,zzz,zzz.99".
def var  vamount    as decimal    label "Сумма на конвертацию конечная    " format "zzz,zzz,zzz,zzz.99".
def var  tamount%    as decimal    label "Сумма на конвертацию начальная "  format "zzz,zzz,zzz,zzz.99".
def var  vamount%    as decimal    label "Сумма на конвертацию конечная    " format "zzz,zzz,zzz,zzz.99".
def var  tamount11    as decimal    label "Сумма на конвертацию начальная "  format "zzz,zzz,zzz,zzz.99".
def var  avg_tamount    as decimal  format "zzz,zzz,zzz,zzz.99".
def var  diff_tamount    as decimal  format "zzz,zzz,zzz,zzz.99".

def var  famount    as decimal.
def var  urg_com    as decimal    label "Комиссия за срочность        " format "zzz,zzz,zzz,zzz.99".
def var  conv_com   as decimal    label "Комиссия за конвертацию      " format "zzz,zzz,zzz,zzz.99".
def var  birz_com   as decimal    label "Биржевая комиссия            " format "zzz,zzz,zzz,zzz.99".

def var  litems     as char.
def var  currate    as decimal label "Курс" format "zzz,zzz.9999".
def var  l-tran     as logical. /*да сделать транзакцию*/
def var  gcom      as logical.

def new shared var s-jh like jh.jh.

def var retval as char.
def var rcode as int.
def var rdes  as cha.
def var dlm as char init "|".

def var rem as char initial "1223asfdasdfa".
def var cur_time as integer.
def var ans as logical.
/*def var min_com as logical label "Брать минимум при взятии комиссии" format "да/нет" init "yes".*/

def var  tamount_proc as decimal  label "Окончательная сумма в тенге  " format "zzz,zzz,zzz,zzz.99" .
/*Сумма в валюте + ком. за срочность + ком. за конвертацию + биржевая */

def var conv_int as decimal initial "0.25"    label "Процент комиссии за конвертацию ".
def var conv_int_min as decimal initial "15"  label "Минимальная сумма за конвертацию".
def var conv_int_max as decimal label "Максимальная сумма за конвертацию".
def var cim_notusd as decimal. /*используется если валюты не доллары*/
def var urg_int as decimal  initial "0.2"     label "Процент комиссии за срочность   ".
def var birz_int as decimal initial "0.00"    label "Процент по биржевой комиссии    ".
def var conv_temp as decimal.
def var urg_temp as decimal.
def var tfirst as logical.   /*true если сначала была введена сумма в тенге
                               false если сперва была сумма в валюте */
def var v-dlgr as char.
def buffer dcrc for crc.
def buffer bcrc for crc.

def shared var dType as integer.


define variable m_sub as character initial "dil".

define variable conv_gl as integer.

 def buffer bcif for cif.
 def buffer bzaaa     for aaa.  /* старый счет */
 def buffer bz1aaa    for aaa.  /* новый счет  */
 def buffer bzaad     for aad.
 def var v-valut      as char.
 def var v-valut1     as char.
 def var v-valuta     as char.
 def var v-valut1a    as char.

 def var sumchartmp1  as char.

 def var sumchartmp1a as char.

 def var sumchartmp   as char.
 def var sumchartmpa  as char.
 def var s-okn        as char.
 def var sumchartmp2  as char.
 def var sumchartmp2a as char.


 def var sumdec      as decimal.
 def stream v-out.
 def var v-str       as char.
 def buffer bfcrccnv for crc.





define variable mustrate as decimal.
define variable mustamt  as decimal.
define variable musts1   as decimal.
define variable musts2   as decimal.

/* 03.11.02 timur*/

define variable DebSubled as character.
define variable CredSubled as character.

/* 03.11.02 timur*/

define frame dframe1 documN skip
                     clientno clientname skip
                     taccno skip
                     vaccno skip
                     currency space (5) currate skip(1)
                     tamount vamount skip(1)
                     conv_com skip(2)
             WITH /*KEEP-TAB-ORDER*/ SIDE-LABELS TITLE "Кросс-конвертация для депозитов".

define frame dframe2 documN with SIDE-LABELS.

define frame dframe3 conv_int urg_int with SIDE-LABELS OVERLAY CENTERED.

def buffer b-aaa for aaa.

def buffer bf-lgr for lgr .

define variable v-sts like jh.sts .
define buffer b-aaastr for aaa.

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

procedure Check_Deposit_Acc:
  if lookup(substring(string(aaa.gl),1,4), "2215,2217,2219,2206,2207,2208") = 0
     then
       do:
          message "Введите депозитный счет!!!" view-as alert-box.
          undo,retry.
       end.
end procedure.

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
                       DebSubled = "ARP".
                       clientname = arp.des.
                       clientno = "ARP".
                    end.
            end.
          else do:
              DebSubled = "CIF".
              find cif where cif.cif eq aaa.cif no-lock no-error.
              if not available cif
                 then message "Не найден клиент" aaa.cif.
                 else do:
                   clientname = trim(trim(cif.prefix) + " " + trim(cif.name)).
                   clientno = cif.cif.
                 end.
          end.
    if can-find(aaa where aaa.aaa = vaccno) then CredSubled = "CIF".
    if can-find(arp where arp.arp = vaccno) then CredSubled = "ARP".
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

documN  = "".
vaccno  = "".
taccno  = "".
currency = 0.
clientno = "".
clientname = "".
tamount    = 0.
vamount    = 0.
tamount%    = 0.
vamount%    = 0.
tamount11    = 0.
urg_com    = 0.
conv_com   = 0.
birz_com   = 0.

currate = 0.
l-tran = false.

s-jh = 0.



tamount_proc =0.

conv_int = 0.
conv_int_min = 0.
conv_int_max= 0.
urg_int = 0.
birz_int = 0.


find first tarif2 where tarif2.num + tarif2.kod = "806"
                    and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then
                  do:
                     conv_int = tarif2.ost.
                     conv_gl  = tarif2.kont.
                  end.
conv_temp = 0.
urg_temp = 0.

end procedure.


procedure new_doc:   /*НОВЫЙ ДОКУМЕНТ*/

do transaction:


repeat on ENDKEY UNDO , leave:

run Init_vars.
clear frame dframe1 NO-PAUSE.
documn = "".
litems = "".
l-tran = false.

run generate_docno.

displ documN with frame dframe1.

set taccno with frame dframe1.
 if taccno entered then do:
       find aaa where aaa.aaa eq taccno no-lock no-error.
       if not available aaa then do:
                  find arp where arp.arp eq taccno no-lock no-error.
                  if avail arp then do:
                            find crc where crc.crc = arp.crc no-lock.
                            if crc.crc <> 1 then do:
                               message "Введите тенговый счет" view-as alert-box.
                               undo,retry.
                            end.
                            release crc.
                            DebSubled = "ARP".
                            clientname = arp.des.
                            clientno = "ARP".
                         end.
                   else do:
                            message "Счет" taccno "не найден" skip
                                    "Счет может быть CIF или ARP" view-as alert-box.
                                     undo,retry.
                   end.
       end.
       else do:

find last bf-lgr where bf-lgr.lgr = aaa.lgr no-lock no-error.

if (bf-lgr.feensf = 1 or bf-lgr.feensf = 2 or bf-lgr.feensf = 3 or bf-lgr.feensf = 4 or bf-lgr.feensf = 6 or lookup(bf-lgr.lgr, "A38,A39,A40") > 0)  then
do:
    message "Внимание: Конвертация данного счета производится в пункте 2-3-7" . pause.
    return.
end.

if lookup(bf-lgr.lgr,"478,479,480,481,482,483,B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B15,B16,B17,B18,B19,B20") > 0  then do:
   message "Внимание: Конвертация данного счета запрещена" view-as alert-box buttons OK .
   return.
end.


         t-cnv = 0.
         find last t-aaa_conv where t-aaa_conv.aaa = aaa.aaa no-error.
         if not avail t-aaa_conv then
            t-cnv = 0.
         else
            t-cnv = t-aaa_conv.conv.
/*         if t-cnv >= 2 then do:
           message "Внимание! по счету исчерпан лимит конвертаций." . pause.
           return.
           end.*/

              DebSubled = "CIF".
              if lookup(substring(string(aaa.gl),1,4), "2215,2217,2219,2206,2207,2208") = 0 then do:
                      message "Введите депозитный счет!!!" view-as alert-box.
                      undo,retry.
              end.

              tamount = aaa.cr[1] - aaa.dr[1].
              /* 10.02.2004 nadejda - сумма процентов */
              tamount% = aaa.cr[2] - aaa.dr[2].

              /* 10.02.2004 nadejda - сумма процентов в нацвалюте */
              tamount11 = 0.
              find trxbal where trxbal.sub = "cif" and trxbal.acc = aaa.aaa and trxbal.lev = 11 no-lock no-error.
              if avail trxbal and trxbal.dam <> trxbal.cam then tamount11 = trxbal.dam - trxbal.cam.

              find bcrc where bcrc.crc =  aaa.crc no-lock no-error. /*валюта счета для списания*/
              curtacc = bcrc.crc. /*валюта счета для списания*/

              /* группа счета */
              v-dlgr = aaa.lgr.

              find cif where cif.cif eq aaa.cif no-lock no-error.
              if not available cif
                 then do: message "Не найден клиент" aaa.cif. undo,retry. end.
                 else do:
                   clientname = trim(trim(cif.prefix) + " " + trim(cif.name)).
                   clientno = cif.cif.
                   display clientno clientname with frame dframe1.
                 end.
        end.
 end.

case DebSubled:
when "CIF" then
  do:
     set currency with frame dframe1.
     if currency entered
        then do:
          find crc where crc.crc eq currency no-lock no-error.
          if not available crc then do: message "Валюта" currency "не найдена" view-as alert-box. undo, retry. end.
             else do:

find last lgr where lgr.lgr = aaa.lgr no-lock no-error.

       do:
           v-sysc = string(curtacc) + "to" + string(currency) + "c".
           find sysc where sysc.sysc = v-sysc no-lock no-error.
           currate = decimal(sysc.chval).

           def var d_sm as decimal.
           if (curtacc = 2 and currency = 11) or (curtacc = 1 and currency = 2) or (curtacc = 1 and currency = 11) then
               do:
                 d_sm = tamount / currate.
               end.
           else
               do:
                 d_sm = tamount * currate.
               end.


s-cif = aaa.cif.
s-opnamt = d_sm.
v-accusd = aaa.aaa.
run converta.
                end.

                for each aaa where aaa.crc eq currency and aaa.cif eq clientno and aaa.sta <> "C" /*and lookup(substring(string(aaa.gl),1,4), "2215,2217,2219") = 0*/ break by aaa.crc:
                  find lgr where lgr.lgr = aaa.lgr.
                  if available lgr then if lgr.led <> "oda" then
                  if last-of(aaa.crc) then litems = litems + aaa.aaa. else litems = litems + aaa.aaa + "|".
                end.

             if litems = "" then do: message "У клиента нет счета в такой валюте" view-as alert-box. undo,return. end.
             else
               do:
                  run sel1("Выберите счет", litems).
                  vaccno = return-value.
                  if vaccno = "" then undo,retry.
                  update vaccno with frame dframe1.
               end.
          end.
     CredSubled = "CIF".
     end.
  end.
end case.

 currency = crc.crc. /*валюта счета для зачисления*/
 displ currency with frame dframe1.
/* case crc.crc:
      when 2 then find sysc where sysc.sysc = "11to2c".
      when 11 then find sysc where sysc.sysc = "11to2c".
 end.*/
  v-sysc = string(curtacc) + "to" + string(currency) + "c".
  find sysc where sysc.sysc = v-sysc no-lock no-error.
 currate = decimal(sysc.chval).
 display currate with frame dframe1.

 display tamount + tamount% @ tamount with frame dframe1.

 if (tamount <= 1000 and curtacc <> 1) or (tamount <= 150000  and curtacc = 1)  then do:
         find dcrc where dcrc.crc = curtacc no-lock no-error.

         /* 13.04.2004 nadejda - снимать/не снимать комиссию определить по настройке группы депозита */
         find sub-cod where sub-cod.sub = "lgr" and sub-cod.d-cod = "lgrcomis" and sub-cod.acc = v-dlgr no-lock no-error.
         if avail sub-cod and sub-cod.ccode = "0" then conv_com = 0.
                                                  else conv_com = round(round(conv_int / dcrc.rate[1],3),2).
         tamount = tamount - conv_com.
 end.
 if (curtacc = 2 and currency = 11) or  (curtacc = 1 and currency = 2)
  or (curtacc = 1 and currency = 11) then do:
     vamount = round(round(tamount / currate,3),2).
     vamount% = round(round(tamount% / currate,3),2).
 end.
 else do:
     vamount = round(round(tamount * currate,3),2).
     vamount% = round(round(tamount% * currate,3),2).
 end.
 displ conv_com tamount + tamount% @ tamount vamount + vamount% @ vamount with frame dframe1.

 if check_acc(taccno, tamount_proc, false) then undo,retry.
 run create_doc.
 pause.
 run yn("","Сделать транзакцию?","","", output l-tran).
 if l-tran then do: run do_exprtrans. return. end.

end. /*end repeat */
end. /*end transaction*/

hide frame dframe1.

end procedure.

procedure open_doc:
end procedure.

procedure do_exprtrans:

do transaction:

/*Размораживаем для конвертации*/
find b-aaa where b-aaa.aaa = taccno no-error.
if avail  b-aaa then
   b-aaa.hbal = 0.
release b-aaa.

s-jh = 0.

/* sasco - правильный кросскурс */
find crc where crc.crc = /*11*/ currency no-lock.
mustrate = crc.rate[1].
find crc where crc.crc = /* 2*/ curtacc  no-lock.
/*
mustrate = mustrate / crc.rate[1].
mustamt = round(round((tamount + tamount%)/ mustrate,3),2).*/

/* if (curtacc = 2 and currency = 11) or  (curtacc = 1 and currency = 2)
  or (curtacc = 1 and currency = 11) then do: */
     mustrate = mustrate / crc.rate[1].
     mustamt = round(round((tamount + tamount%)/ mustrate,3),2).
/* end.
 else do:
     mustrate = mustrate * crc.rate[1].
     mustamt = round(round((tamount + tamount%) * mustrate,3),2).
 end. */

if mustamt >= vamount + vamount% then
  /* учетный курс меньше коммерческого */
  assign musts1 = mustamt - (vamount + vamount%)
         musts2 = 0.
else
  /* учетный курс больше коммерческого */
  assign musts1 = 0
         musts2 = (vamount + vamount%) - mustamt.
/* tsoy остаток переводим в тенге, для проводки */
   find crc where crc.crc = currency no-lock.
   musts2 = musts2 * crc.rate[1].
   musts1 = musts1 * crc.rate[1].

find aaa where aaa.aaa = taccno no-lock no-error.
if aaa.lgr matches "d*" then run tdaremholda(aaa.aaa).


/* 10.02.2004 nadejda - добавлен перенос процентов */
run trxgen("dil0063", dlm,
    string(tamount)      + dlm +
    string(aaa.crc)      + dlm +
    taccno               + dlm +
    "На конвертацию согласно заявке " + string(currate) + dlm +

    string(vamount)      + dlm +
    string(currency)     + dlm +
    vaccno               + dlm +
    "Зачисление на валютный счет " + string(currate) + dlm +

    string(conv_com)  + dlm +
    string(aaa.crc)   + dlm +
    string(conv_gl)   + dlm +

    string(musts1)    + dlm +
    string(musts2)    + dlm +

    string(tamount%)  + dlm +
    string(aaa.crc)   + dlm +
    "На конвертацию согласно заявке (проценты) " + string(currate) + dlm +

    string(vamount%)  + dlm +
    string(currency)  + dlm +
    "Зачисление на валютный счет (проценты) " + string(currate) + dlm +

    string(tamount11) + dlm +
    "Зачисление на валютный счет (проценты в нац.валюте)"
    ,
    m_sub, documn, output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        message "000" view-as alert-box.
        message " Ошибка проводки rcode = " string(rcode) ":" rdes  " " s-jh.
        pause.
        undo,return.
    end.
    else
    do:
       find aaa where aaa.aaa = taccno exclusive-lock.
       aaa.sta = "E".
for each t-cnv exclusive-lock:
    delete t-cnv.
end.
create aaa_conv.
       aaa_conv.aaa = vaccno.
       aaa_conv.conv = t-cnv + 1.
       aaa_conv.aaaold = taccno.
       aaa_conv.dt = g-today.


       release aaa.
       message "Транзакция сделана" skip  "jh " s-jh view-as alert-box.
       find dealing_doc where dealing_doc.docno = documn share-lock.
       dealing_doc.jh = s-jh.
       find current dealing_doc no-lock.
       /* run dvou("prit"). */
    end.



    find b-aaa where b-aaa.aaa = taccno no-error.           /* старый счет */
    find aaa where aaa.aaa = vaccno  no-error.              /* новый счет  */
    if avail aaa then do:

       do:
           if (curtacc = 2 and currency = 11) or (curtacc = 1 and currency = 2) or (curtacc = 1 and currency = 11) then
           do:
              aaa.opnamt = b-aaa.opnamt / currate.
              aaa.accrued = b-aaa.accrued / currate.
              run tdaremholda(aaa.aaa).
              run tdasethold(aaa.aaa, aaa.opnamt).
if bf-lgr.feensf = 6 then do:
   aaa.stmgbal = b-aaa.stmgbal / currate.
   run tdasethold(aaa.aaa, aaa.stmgbal).
end.

           end.
           else
           do:
              aaa.opnamt = b-aaa.opnamt * currate.
              aaa.accrued = b-aaa.accrued * currate.
              run tdaremholda(aaa.aaa).
              run tdasethold(aaa.aaa, aaa.opnamt).

if bf-lgr.feensf = 6 then do:
   aaa.stmgbal = b-aaa.stmgbal * currate.
   run tdasethold(aaa.aaa, aaa.stmgbal).
end.

           end.
       end.
    end.



if (lookup(b-aaa.lgr, "D08,D09,D15,D25,D38,D39,D40,D41,D42,D43,D44,D45,D47,D48,D71,D72,D73,D80,D81,D82,E08,E09,E25,E39,E41,E42,I19,I20,I21,I22,I23,I24") <> 0) or lgr.feensf = 6 then
do:
   /*добавлено*/

if comm-cod() = 0 then do:

   def var sum1 as decimal decimals 2.
   def var sum11 as decimal decimals 2.

   find last bz1aaa where bz1aaa.aaa = vaccno no-error.  /*новый счет*/
   sum1 = 0.
   sum1 = bz1aaa.opnamt.

   for each aad where aad.aaa = vaccno no-lock.
       sum1 = sum1 + aad.sumg.
   end.

   sum11 = bz1aaa.cr[2] - bz1aaa.dr[2].

   sum11 = sum11 + ((bz1aaa.cr[1] - bz1aaa.dr[1]) - bz1aaa.opnamt).
/* 1 уровень */
                   if bz1aaa.crc = 1  then do: v-valut = "тенге". v-valut1 = "тиын.".        end.
                   if bz1aaa.crc = 2  then do: v-valut = "доллары США". v-valut1 = "цента.". end.
                   if bz1aaa.crc = 11 then do: v-valut = "евро". v-valut1 = "".              end.
                   if bz1aaa.crc = 4  then do: v-valut = "рублей". v-valut1 = "копеек".      end.
                   run Sm-vrd(sum1, output sumchartmp).
                   if sumchartmp = "Ноль" then do:
                      s-okn = substr(string(sum1), length(string(truncate(sum1, 0))), 1) .
                      if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then do:
                         if bz1aaa.crc = 2 then  v-valut = "долларов США".
                         if bz1aaa.crc = 4 then  v-valut = "рублей." .
                      end.
                      sumchartmp1 = "".
                      v-valut1 = "".
                      sumchartmp2 = "0.00".
                      sumchartmp = "".
                   end.
                   else
                   do:
                       run frac (sum1, output sumdec).
                       if sumdec = 0.0 then sumchartmp1 = "00".
                       else sumchartmp1 = string(sumdec * 100).
                       s-okn = substr(string(sumdec), length(string(truncate(sumdec, 2))), 1).
                       if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then do:
                          if bz1aaa.crc = 2  then v-valut = "центов" .
                          if bz1aaa.crc = 4  then v-valut = "копеек" .
                          if bz1aaa.crc = 11 then v-valut = "центов" .
                          if bz1aaa.crc = 2  then v-valut1 = "центов".
                          if bz1aaa.crc = 4  then v-valut1 = "копеек".
                          if bz1aaa.crc = 11 then v-valut1 = "центов".
                       end.
                       if s-okn = "1" then do:
                          if bz1aaa.crc = 2  then v-valut = "цент"   .
                          if bz1aaa.crc = 4  then v-valut = "копейка".
                          if bz1aaa.crc = 11 then v-valut = "цент"   .
                          if bz1aaa.crc = 2  then v-valut1 = "цент"  .
                          if bz1aaa.crc = 4  then v-valut1 = "копейка".
                          if bz1aaa.crc = 11 then v-valut1 = "цент"  .
                       end.
                       if s-okn = "2" or s-okn = "3" or s-okn = "4" then do:
                          if bz1aaa.crc = 2  then v-valut = "цента"   .
                          if bz1aaa.crc = 4  then v-valut = "копейки" .
                          if bz1aaa.crc = 11 then v-valut = "цента"   .
                          if bz1aaa.crc = 2  then v-valut1 = "цента"  .
                          if bz1aaa.crc = 4  then v-valut1 = "копейки".
                          if bz1aaa.crc = 11 then v-valut1 = "цента"  .
                       end.
                       s-okn = substr(string(sum1), length(string(truncate(sum1, 0))), 1) .
                       if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then do:
                          if bz1aaa.crc = 2 then  v-valut = "долларов США".
                          if bz1aaa.crc = 4 then  v-valut = "рублей." .
                       end.
                       if s-okn = "1" then do:
                          if bz1aaa.crc = 2 then v-valut = "доллар США".
                          if bz1aaa.crc = 4 then v-valut = "рубль.".
                       end.
                       if s-okn = "2" or s-okn = "3" or s-okn = "4" then do:
                          if bz1aaa.crc = 2 then v-valut = "доллара США".
                          if bz1aaa.crc = 4 then v-valut = "рубля." .
                       end.
                       sumchartmp2 = string(sum1).
                       if sumchartmp = "" then do:
                          sumchartmp = "Ноль".
                          sumchartmp2 = "0" + sumchartmp2.
                          if bz1aaa.crc = 2 then  v-valut = "долларов США".
                          if bz1aaa.crc = 4 then  v-valut = "рублей" .
                          if bz1aaa.crc = 11 then  v-valut = "евро" .
                       end.
                   end.

/*2 уровень*/
                   if bz1aaa.crc = 1 then do: v-valuta = "тенге". v-valut1a = "тиын.". end.
                   if bz1aaa.crc = 2 then do: v-valuta = "доллары США". v-valut1a = "цента.". end.
                   if bz1aaa.crc = 11 then do: v-valuta = "евро". v-valut1a = "". end.
                   if bz1aaa.crc = 4 then do: v-valuta = "рублей". v-valut1a = "копеек". end.
                   run Sm-vrd(sum11, output sumchartmpa).
                   if sumchartmp = "Ноль" then do:
                      s-okn = substr(string(sum11), length(string(truncate(sum11, 0))), 1) .
                      if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then do:
                         if bz1aaa.crc = 2 then  v-valuta = "долларов США".
                         if bz1aaa.crc = 4 then  v-valuta = "рублей." .
                      end.
                      sumchartmp1a = "".
                      v-valut1a = "".
                      sumchartmp2a = "0.00".
                      sumchartmpa = "".
                   end.
                   else
                   do:
                       run frac (sum11, output sumdec).
                       if sumdec = 0.0 then sumchartmp1a = "00".
                       else sumchartmp1a = string(sumdec * 100).
                       s-okn = substr(string(sumdec), length(string(truncate(sumdec, 2))), 1).
                       if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then do:
                          if bz1aaa.crc = 2  then v-valuta = "центов" .
                          if bz1aaa.crc = 4  then v-valuta = "копеек" .
                          if bz1aaa.crc = 11 then v-valuta = "центов" .
                          if bz1aaa.crc = 2  then v-valut1a = "центов".
                          if bz1aaa.crc = 4  then v-valut1a = "копеек".
                          if bz1aaa.crc = 11 then v-valut1a = "центов".
                       end.
                       if s-okn = "1" then do:
                          if bz1aaa.crc = 2  then v-valuta = "цент"   .
                          if bz1aaa.crc = 4  then v-valuta = "копейка".
                          if bz1aaa.crc = 11 then v-valuta = "цент"   .
                          if bz1aaa.crc = 2  then v-valut1a = "цент"  .
                          if bz1aaa.crc = 4  then v-valut1a = "копейка".
                          if bz1aaa.crc = 11 then v-valut1a = "цент"  .
                       end.
                       if s-okn = "2" or s-okn = "3" or s-okn = "4" then do:
                          if bz1aaa.crc = 2  then v-valuta = "цента"   .
                          if bz1aaa.crc = 4  then v-valuta = "копейки" .
                          if bz1aaa.crc = 11 then v-valuta = "цента"   .
                          if bz1aaa.crc = 2  then v-valut1a = "цента"  .
                          if bz1aaa.crc = 4  then v-valut1a = "копейки".
                          if bz1aaa.crc = 11 then v-valut1a = "цента"  .
                       end.
                       s-okn = substr(string(sum11), length(string(truncate(sum11, 0))), 1).
                       if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then do:
                          if bz1aaa.crc = 2 then  v-valuta = "долларов США".
                          if bz1aaa.crc = 4 then  v-valuta = "рублей." .
                       end.
                       if s-okn = "1" then do:
                          if bz1aaa.crc = 2 then v-valuta = "доллар США".
                          if bz1aaa.crc = 4 then v-valuta = "рубль.".
                       end.
                       if s-okn = "2" or s-okn = "3" or s-okn = "4" then do:
                          if bz1aaa.crc = 2 then v-valuta = "доллара США".
                          if bz1aaa.crc = 4 then v-valuta = "рубля." .
                       end.
                       sumchartmp2a = string(sum11).
                       if sumchartmpa = "" then do:
                          sumchartmpa = "Ноль".
                          sumchartmp2a = "0" + sumchartmp2a.
                          if bz1aaa.crc = 2 then  v-valuta = "долларов США".
                          if bz1aaa.crc = 4 then  v-valuta = "рублей" .
                          if bz1aaa.crc = 11 then  v-valuta = "евро" .

                       end.
                   end.


  /* message "счет" vaccno "  вал1" curtacc  "   вал2"  currency "   курс" currate "  ставка%" bf-accno.rate tamount vamount tamount% vamount%.
     pause 444. */
     find last bcif where bcif.cif = bz1aaa.cif no-lock no-error.
     output stream v-out to value("tst.htm").

if curtacc = 1 then
     input from value("/data/9/export/xstg.htm").
else
if curtacc =  2 and currency = 11 then
     input from value("/data/9/export/xstg.htm").
else
     input from value("/data/9/export/xs.htm").




     repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        repeat:
          if v-str matches "*\{\&clienfio\}*" then do:
             v-str = replace (v-str, "\{\&clienfio\}", bcif.name).
             next.
          end.
          if v-str matches "*\{\&clienaddres\}*" then do:
             v-str = replace (v-str, "\{\&clienaddres\}", cif.addr[1] + " " + cif.addr[2]).
             next.
          end.
          if v-str matches "*\{\&clientpss\}*" then do:
             v-str = replace (v-str, "\{\&clientpss\}", cif.pss).
             next.
          end.
          if v-str matches "*\{\&clientjss\}*" then do:
             v-str = replace (v-str, "\{\&clientjss\}",	 cif.jss).
             next.
          end.



          if v-str matches "*\{\&clientiikold\}*" then do:
             v-str = replace (v-str, "\{\&clientiikold\}", taccno).
             next.
          end.
          if v-str matches "*\{\&clientiik\}*" then do:
             v-str = replace (v-str, "\{\&clientiik\}", vaccno).
             next.
          end.
          if v-str matches "*\{\&regdt\}*" then do:
             v-str = replace (v-str, "\{\&regdt\}", string(aaa.regdt)).
             next.
          end.

          if v-str matches "*\{\&sum11\}*" then do:
             v-str = replace (v-str, "\{\&sum11\}",  trim(string(sum11,'zzz,zzz,zzz,zz9.99'))).
             next.
          end.

          if sumchartmp2a = "0.00" then do:
             if v-str matches "*\{\&sumletter11\}*" then do:
                v-str = replace (v-str, "\{\&sumletter11\}", string(sumchartmp2a) + " " + string(sumchartmpa) + " " + string(v-valuta)).
                next.
             end.
          end.
          else do:
             if v-str matches "*\{\&sumletter11\}*" then do:
                v-str = replace (v-str, "\{\&sumletter11\}", string(sumchartmpa) + " " + string(v-valuta) + " " + string(sumchartmp1a) + " " + string(v-valut1a)).
                next.
             end.
          end.
          if v-str matches "*\{\&expdt\}*" then do:
             v-str = replace (v-str, "\{\&expdt\}", string(aaa.expdt)).
             next.
          end.
          if v-str matches "*\{\&valut1\}*" then do:
             find last bfcrccnv where bfcrccnv.crc = curtacc no-lock no-error.
             if avail bfcrccnv then do:
                v-str = replace (v-str, "\{\&valut1\}", bfcrccnv.des).
                next.
             end.
          end.
          if v-str matches "*\{\&valut2\}*" then do:
             find last bfcrccnv where bfcrccnv.crc = currency no-lock no-error.
             if avail bfcrccnv then do:
                v-str = replace (v-str, "\{\&valut2\}", bfcrccnv.des).
                next.
             end.
          end.
          if v-str matches "*\{\&sum1\}*" then do:
             v-str = replace (v-str, "\{\&sum1\}", trim(string(sum1,'zzz,zzz,zzz,zz9.99'))).
             next.
          end.
          if sumchartmp2 = "0.00" then do:

          if v-str matches "*\{\&sumletter\}*" then do:
             v-str = replace (v-str, "\{\&sumletter\}", string(sumchartmp2) + " " + string(sumchartmp) + " " + string(v-valut)).
             next.
          end.
          end.
          else do:
              if v-str matches "*\{\&sumletter\}*" then do:
                 v-str = replace (v-str, "\{\&sumletter\}", string(sumchartmp) + " " + string(v-valut) + " " + string(sumchartmp1) + " " + string(v-valut1)).
                 next.
              end.
          end.
          if v-str matches "*\{\&sum2\}*" then do:
             v-str = replace (v-str, "\{\&sum2\}", string(bz1aaa.accrued)).
             next.
          end.
          if v-str matches "*\{\&kurs1\}*" then do:
             v-str = replace (v-str, "\{\&kurs1\}", "1 ").
             next.
          end.
          if v-str matches "*\{\&kurs2\}*" then do:
             v-str = replace (v-str, "\{\&kurs2\}", string(currate) + " ").
             next.
          end.

          if v-str matches "*\{\&prsent\}*" then do:
             v-str = replace (v-str, "\{\&prsent\}", string(bz1aaa.rate)).
             next.
          end.

          leave.
        end.
        put stream v-out unformatted v-str skip.
    end.
    input close.
    output stream v-out close.
    unix silent cptwin value("tst.htm") winword.
    message  "  ВНИМАНИЕ! "
    skip(5) "   ПРОВЕРЬТЕ ТЕКСТ ДОПОЛНИТЕЛЬНОГО СОГЛАШЕНИЯ!  "
    skip "       При обнаружении ошибок сообщите в ДИТ.    "
    skip(5)  view-as alert-box question buttons ok title "" .

end. /*com-txb*/
 /*добавлено*/
end.

       /* find aaa where aaa.aaa = vaccno no-lock no-error.
          message aaa.aaa vamount view-as alert-box.
          if aaa.lgr matches "d*" then run tdasethold(aaa.aaa,vamount). */
end.   /* transaction */


end procedure.

procedure create_doc:

  find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType share-lock no-error .
  if not available dealing_doc
     then
       do:
          create dealing_doc.
          dealing_doc.docno = DocumN.
          dealing_doc.crc = crc.crc.
          dealing_doc.doctype = 5. /*кросс-конвертация для депозитов*/
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
  if documn = "" then set documn with frame dframe2.
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
          if documn = "" then set documn with frame dframe1.
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

       /*Поиск валюты счета для списания*/
       find aaa where aaa.aaa eq taccno no-lock no-error.
       if available aaa then do:
         find bcrc where bcrc.crc =  aaa.crc no-lock no-error. /*валюта счета для списания*/
         curtacc = bcrc.crc. /*валюта счета для списания*/
       end.


           run find_client.
           if this-procedure:private-data <> ?
              then do: if dealing_doc.tngtoval then tamount = famount. else vamount = famount. end.
           display vamount tamount taccno vaccno conv_com currate currency clientno clientname with frame dframe1.
           if this-procedure:private-data <> ?
              then
                do:
                  if (dealing_doc.jh = ?) or (dealing_doc.jh = 0)
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
           display vamount tamount taccno vaccno conv_com currate currency clientno clientname with frame dframe1.
        end.
      else do: message "Документа с таким номером не существует" view-as alert-box.  undo,retry. end.
  end. /* do */
end procedure.

procedure delete_trans:
 do transaction:
/*   documn = "".*/
   clear frame dframe2.
/*   set documn with frame dframe2.*/
   if documn = "" then set documn with frame dframe2.
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
             message "Транзакция не может быть сторнирована!!!." view-as alert-box.
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
                   else
                     do:
                        dealing_doc.jh = ?.
                        find aaa where aaa.aaa = dealing_doc.tclientaccno exclusive-lock no-error.
                        aaa.sta = "A".
                        release aaa.
                        run tdasethold(dealing_doc.tclientaccno,dealing_doc.t_amount).
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
     if documn = "" then set documn with frame dframe2.
 /*    set documn with frame dframe2.*/
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
                if l-tran then do: run do_exprtrans. return. end.
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

procedure print_doc.
     clear frame dframe2.
     if documn = "" then set documn with frame dframe2.
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

procedure edit_comms.
end procedure.

