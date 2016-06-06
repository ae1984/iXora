/* crosconv.p
 * MODULE
        Дилинг
 * DESCRIPTION
        Кросс конвертация (806 - код в тарификаторе, если сумма меньше 1000USD
        согласно распоряжения _44 от 05.06.2003г)
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
 * AUTHOR
        09.06.03 timur
 * BASES
        BANK COMM
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
        24.11.2004 dpuchkov - предварительная проверка записей aad
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        04.02.2005 dpuchkov - сделал ограничение конвертации по депозитам физ лиц до 2х
        25.02.2005 dpuchkov - добавил историю курсов конвертации (т.к иногда не соответствуют курсам нац банка в 9.1.2.2.1 )
        10.03.2005 dpuchkov - при конвертации старые aad не удаляем
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        28.04.2005 dpuchkov - Если депозит пенсионный то конвертируем в этой программе.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
        20.05.2005 dpuchkov - Добавил отображение доп соглашений при конвертации депозитов.
        06.06.2005 dpuchkov - Добавил окно-предупреждение для менеджеров.
        10.06.2005 dpuchkov - перекомпиляция
        23.11.2005 dpuchkov - запретил конвертацию на счета открытые в другой день
        17.05.2006 dpuchkov - устранил ошибку в договорах не печатался вкладчик
        18.10.2006 u00124   - добавил проверку на закрытый счет.
        13.08.2008 alex     - добавил проверку даты открытия счета (до 13.08.08 - доп соглашение №1, после - доп соглашение №2)
        01.02.10 marinav - расширение поля счета до 20 знаков
        09.02.2011 Luiza  -  добавила режим поиска клиента в on help .....
        10.02.2011 Luiza  -  добавила update для клиента  .....
        24.05.2011 evseev - запрет конвертации по схемам 1 (c 1/06/2011) и 6
        03/08/2011 evseev - на основании С.З. запрет конвертации 478,479,480,481,482,483
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        20.05.2013 evseev - tz1828
        24.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
*/


{global.i}
{crc-crc.i}
{w-2-u.i}
{comm-txb.i}
{u-2-w.i}
{sysc.i}


def new shared var v-accusd like aaa.aaa.
def new shared var s-opnamt like aaa.opnamt.
def new shared var s-cif as char.

def buffer t-aaa_conv for aaa_conv.
def var t-cnv as integer.

def var  documN     like dealing_doc.docno label "Номер документа".
def var  documType  as integer /*тип документа 1 срочная конвертация*/.
def var  taccno     as char    label "Счет клиента для снятия средств    " format "x(20)".
def var  vaccno     as char    label "Счет клиента для зачисления средств" format "x(20)".
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
def var birz_int as decimal initial "0.05"    label "Процент по биржевой комиссии    ".
def var conv_temp as decimal.
def var urg_temp as decimal.
def var tfirst as logical.   /*true если сначала была введена сумма в тенге
                               false если сперва была сумма в валюте */
def var v-dlgr as char.
def buffer dcrc for crc.
def buffer bcrc for crc.
def buffer b-trxaaad for aad.

def var vrate as decimal.
define variable v-sts like jh.sts .

def shared var dType as integer.


                           def buffer bzaaa for aaa.  /* старый счет */
                           def buffer bz1aaa for aaa. /* новый счет  */
                           def buffer bzaad for aad.


define variable m_sub as character initial "dil".

define variable conv_gl as integer.

 def var v-valut as char.
 def var v-valut1 as char.
 def var sumchartmp1 as char.
 def var sumchartmp as char.
 def var s-okn as char.
 def var sumchartmp2 as char.
 def var sumdec as decimal.
 def stream v-out.
 def var v-str as char.
 def buffer bfcrccnv for crc.

define buffer sysc-star   for sysc.
define buffer sysc-zvezda for sysc.
define buffer sysc-juldiz for sysc.
find last sysc-star   where sysc-star.sysc   = "STAR"   no-lock no-error.
find last sysc-zvezda where sysc-zvezda.sysc = "ZVEZDA" no-lock no-error.
find last sysc-juldiz where sysc-juldiz.sysc = "JULDIZ" no-lock no-error.



define variable mustrate as decimal.
define variable mustamt as decimal.
define variable musts1 as decimal.
define variable musts2 as decimal.
def buffer bf-lgr for lgr .

/* help for cif */
DEFINE VARIABLE phand AS handle.
DEFINE VARIABLE v-cif1 AS char.
DEFINE QUERY q-help FOR aaa, lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.
/* help for cif */

/* 03.11.02 timur*/

define variable DebSubled as character.
define variable CredSubled as character.

/* 03.11.02 timur*/

define frame dframe1 documN skip
                     clientno  validate(can-find(first cif where cif.cif = clientno no-lock),"Нет такого ID клиента! F2-помощь")
                     clientname skip
                     taccno skip
                     vaccno skip
                     currency space (5) currate skip(1)
                     tamount vamount skip(1)
                     conv_com skip(2)
             WITH /*KEEP-TAB-ORDER*/ SIDE-LABELS TITLE "Кросс-конвертация для депозитов".

define frame dframe2 documN with SIDE-LABELS.

define frame dframe3 conv_int urg_int with SIDE-LABELS OVERLAY CENTERED.

def buffer b-aaa for aaa.

SESSION:SYSTEM-ALERT-BOXES = true.

{dil_util.i}

/*SESSION:DATA-ENTRY-RETURN = TRUE.*/

/* help for cif */
on help of clientno in frame dframe1 do:
    run h-cif PERSISTENT SET phand.
    hide frame xf.
    clientno = frame-value.
    displ  clientno with frame dframe1.
    DELETE PROCEDURE phand.
end.
/*  help for cif */

on help of currency in frame dframe1 do:
    run help-crc1.
end.

on help of documN in frame dframe1 do:
   run help-dilnum.
end.

on help of documN in frame dframe2 do:
   run help-dilnum.
end.

Function rDAY returns integer (input dt1 as date, input dt2 as date, input dt3 as date).
def var i as date.
def var f as integer.
do i = dt1 to dt3:
   if day(dt1) = 31 and  i >= dt2 then do:
     if lookup(string(month(i)),"3,5,10,12") <> 0 and day(i) = 1 then do:
        f = f + 1.
     end.
   end.

   if i >= dt2 and (day(dt1) = 30 or day(dt1) = 29) then do:
      if month(i) = 2 and day(i) = 28 then do: f = f + 1.  end.
   end.

   if i >= dt2 and day(i) = day(dt1) then
   do:
      f = f + 1.
   end.
end.
   if f < 0 then f = 0.
   return f - 1.
End Function.




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

/*set taccno with frame dframe1.
 if taccno entered then do:*/
    hide frame f-help.
    update clientno with frame dframe1.
    find first cif where cif.cif  =  trim(clientno) no-lock no-error.
    if available cif then do:
        clientname =  cif.sname.
        displ clientname with frame dframe1.
        pause 0.
    end.
    find first aaa where aaa.cif = clientno and aaa.sta <> "C" and aaa.sta <> "E" and length(aaa.aaa) >= 20 no-lock no-error.
    if available aaa then do:
        OPEN QUERY  q-help FOR EACH aaa where aaa.cif = clientno and aaa.sta <> "C" and aaa.sta <> "E" and length(aaa.aaa) >= 20 no-lock,
                    each lgr where aaa.lgr = lgr.lgr no-lock.
        ENABLE ALL WITH FRAME f-help.
        wait-for return of frame f-help
        FOCUS b-help IN FRAME f-help.
        taccno = aaa.aaa.
        hide frame f-help.
        displ taccno with frame dframe1.
    end.
    else do:
        taccno = "".
        MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
        undo.
    end.
/*------------------*/
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
       else do: find last bf-lgr where bf-lgr.lgr = aaa.lgr.

        if ((bf-lgr.feensf = 1 and aaa.regdt >= 06/01/2011) or bf-lgr.feensf = 6 or lookup(bf-lgr.lgr, "A38,A39,A40") > 0)  then do:
            message "Внимание: Конвертация данного счета запрещена" view-as alert-box buttons OK .
            return.
        end.

        if lookup(aaa.lgr,"478,479,480,481,482,483,B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B15,B16,B17,B18,B19,B20") > 0  then do:
            message "Внимание: Конвертация данного счета запрещена" view-as alert-box buttons OK .
            return.
        end.

/*     if lookup(aaa.lgr,"I01,I02,I03,I04,I05,I06,I13,I14,I15,I16,I17,I18") = 0 and bf-lgr.feensf <> 7 and bf-lgr.feensf <> 9  then
       do:
          message "Внимание счет не является депозитом Звезда или Пенсионный ." . pause.
          return.
       end.
*/

       t-cnv = 0.
       find last t-aaa_conv where t-aaa_conv.aaa = aaa.aaa no-error.
       if not avail t-aaa_conv then
          t-cnv = 0.
       else
          t-cnv = t-aaa_conv.conv.

/*        if t-cnv >= 2 then do:
          message "Внимание! по счету исчерпан лимит конвертаций." . pause.
          return.
        end.
*/
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

case DebSubled:
when "CIF" then
  do:
     set currency with frame dframe1.
     if currency entered
        then do:
          find crc where crc.crc eq currency no-lock no-error.
          if not available crc then do: message "Валюта" currency "не найдена" view-as alert-box. undo, retry. end.
             else do:

  do:
           v-sysc = string(curtacc) + "to" + string(currency) + "c".
           find sysc where sysc.sysc = v-sysc no-lock no-error.
           currate = decimal(sysc.chval).

           def var d_sm as decimal.
           if (curtacc = 2 and currency = 3) or (curtacc = 1 and currency = 2) or (curtacc = 1 and currency = 3) then
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
                if last-of(aaa.crc) then litems = litems + aaa.aaa.
                                    else litems = litems + aaa.aaa + "|".
             end.
             if litems = "" then do: message "У клиента нет счета в такой валюте" view-as alert-box. undo,return. end.
             else
               do:
                  run sel1("Выберите счет", litems).
                  vaccno = return-value.
                  if vaccno = "" then undo,retry.

def buffer bv-aaa for aaa.
def buffer bz-aaa for aaa.
def buffer bv-aas for aas.
def buffer bvl-lgr for lgr.
def buffer btg-lgr for lgr.
             find last bv-aaa where bv-aaa.aaa = vaccno no-lock no-error.
             find last bz-aaa where bz-aaa.aaa = taccno no-lock no-error.
if avail bv-aaa then do:
   if bv-aaa.regdt <> bz-aaa.regdt then do:
       message "Вы выбрали неверный счет! Продолжение невозможно. ". pause. return.
   end.
end.

find last bvl-lgr where bvl-lgr.lgr = bv-aaa.lgr no-lock no-error.
find last btg-lgr where btg-lgr.lgr = bz-aaa.lgr no-lock no-error.

if ((btg-lgr.feensf = 1 and bvl-lgr.feensf <> 1) or (btg-lgr.feensf <> 1 and bvl-lgr.feensf = 1)) or
   ((btg-lgr.feensf = 2 and bvl-lgr.feensf <> 2) or (btg-lgr.feensf <> 2 and bvl-lgr.feensf = 2)) or
   ((btg-lgr.feensf = 3 and bvl-lgr.feensf <> 3) or (btg-lgr.feensf <> 3 and bvl-lgr.feensf = 3)) or
   ((btg-lgr.feensf = 4 and bvl-lgr.feensf <> 4) or (btg-lgr.feensf <> 4 and bvl-lgr.feensf = 4)) or
   ((btg-lgr.feensf = 7 and bvl-lgr.feensf <> 7) or (btg-lgr.feensf <> 7 and bvl-lgr.feensf = 7)) or
   ((btg-lgr.feensf = 5 and bvl-lgr.feensf <> 5) or (btg-lgr.feensf <> 5 and bvl-lgr.feensf = 5))
then do:
   message "Вы ошиблись, выберите соответствующий тип депозита для конветрации". pause. return.
end.



if (bvl-lgr.feensf = 9) then do:
   if lookup(bvl-lgr.lgr, sysc-star.chval) <> 0 then do:
      if lookup(btg-lgr.lgr, sysc-star.chval) = 0 then do:
         message "Один тип депозита не соответствует другому. Продолжение невозможно!". pause. return.
      end.
   end. else
   if lookup(bvl-lgr.lgr, sysc-zvezda.chval) <> 0 then do:
      if lookup(btg-lgr.lgr, sysc-zvezda.chval) = 0 then do:
         message "Один тип депозита не соответствует другому. Продолжение невозможно!". pause. return.
      end.
   end. else
   if lookup(bvl-lgr.lgr, sysc-juldiz.chval) <> 0 then do:
      if lookup(btg-lgr.lgr, sysc-juldiz.chval) = 0 then do:
         message "Один тип депозита не соответствует другому. Продолжение невозможно!". pause. return.
      end.
   end.
end.

if (btg-lgr.feensf = 9) then do:
   if lookup(btg-lgr.lgr, sysc-star.chval) <> 0 then do:
      if lookup(bvl-lgr.lgr, sysc-star.chval) = 0 then do:
         message "Один тип депозита не соответствует другому. Продолжение невозможно!". pause. return.
      end.
   end. else
   if lookup(btg-lgr.lgr, sysc-zvezda.chval) <> 0 then do:
      if lookup(bvl-lgr.lgr, sysc-zvezda.chval) = 0 then do:
         message "Один тип депозита не соответствует другому. Продолжение невозможно!". pause. return.
      end.
   end. else
   if lookup(btg-lgr.lgr, sysc-juldiz.chval) <> 0 then do:
      if lookup(bvl-lgr.lgr, sysc-juldiz.chval) = 0 then do:
         message "Один тип депозита не соответствует другому. Продолжение невозможно!". pause. return.
      end.
   end.
end.





find last bv-aas where bv-aas.aaa = taccno and bv-aas.ln <> 7777777 and bv-aas.chkamt <> 0 no-lock no-error.
if avail bv-aas then do:
   message "На счете имеются специнструкции! Продолжение невозможно. ". pause. return.
end.



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

 if   (curtacc = 1 and currency = 2) or (curtacc = 1 and currency = 3) then do:
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


    create t-cnv.
    t-cnv.aaa =  vaccno.


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
       find last bf-lgr where bf-lgr.lgr = aaa.lgr.
       aaa.sta = "E".
                       /*депозит звезда*/
                       if bf-lgr.feensf = 1 or bf-lgr.feensf = 2 or bf-lgr.feensf = 3 or bf-lgr.feensf = 4 or bf-lgr.feensf = 5 or bf-lgr.feensf = 7 then
                       do:

          def var v-aadsm as decimal.
          for each aad where aad.aaa = vaccno exclusive-lock:
              delete aad.
          end.

          for each t-cnv exclusive-lock:
              delete t-cnv.
          end.

          find last bz1aaa where bz1aaa.aaa = vaccno no-error.  /*новый счет*/


def buffer b1-sub-cod for sub-cod.
find b1-sub-cod where b1-sub-cod.sub = 'cif' and b1-sub-cod.acc = taccno and b1-sub-cod.d-cod = 'prlng' exclusive-lock no-error.
if avail b1-sub-cod then do:
   find sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = vaccno and sub-cod.d-cod = 'prlng' exclusive-lock no-error.
   if avail sub-cod then do:
      sub-cod.ccod = b1-sub-cod.ccod.
   end.
end.


          create aaa_conv.
                 aaa_conv.aaa = vaccno.
                 aaa_conv.conv = t-cnv + 1.
                 aaa_conv.aaaold = taccno.
                 aaa_conv.aaac = string(currate).
                 aaa_conv.dt = g-today.
                 aaa_conv.aaac = string(currate).

                          for each bzaad where bzaad.aaa = taccno  no-lock : /* Цикл по старому счету */
                               create aad.
                               aad.aaa = vaccno.
                               aad.gl  = bz1aaa.gl.
                               aad.lgr = bz1aaa.lgr.
                               aad.crc = bz1aaa.crc.
                               aad.regdt = bzaad.regdt.
                               aad.who = bzaad.who.
                               aad.rem = bzaad.rem.
                               aad.pri = bz1aaa.pri.
                               aad.k  =  bzaad.k.
                               if (curtacc = 2 and currency = 3) or  (curtacc = 1 and currency = 2)
                                or (curtacc = 1 and currency = 3) then do:
                                       aad.cam =  bzaad.cam / currate.
                                       aad.dam =  bzaad.dam / currate.
                                       aad.sum =  bzaad.sum / currate.
                                       aad.sumg = bzaad.sumg / currate.
                                       aad.cam1 = bzaad.cam1 / currate.
                                       v-aadsm = v-aadsm +  bzaad.sumg / currate.
                               end.
                               else do:
                                       aad.cam =  bzaad.cam * currate.
                                       aad.dam =  bzaad.dam * currate.
                                       aad.sum =  bzaad.sum * currate.
                                       aad.sumg = bzaad.sumg * currate.
                                       aad.cam1 = bzaad.cam1 * currate.
                                       v-aadsm = v-aadsm +  bzaad.sumg * currate.
                               end.

                               if bzaad.who = "bankadm" then
                               do:
                                  aad.rate =  bz1aaa.rate.
                               end.
else do:
                                 aad.rate =  bz1aaa.rate.
end.
                           end.


                               if (curtacc = 2 and currency = 3) or  (curtacc = 1 and currency = 2)
                                or (curtacc = 1 and currency = 3) then do:
                                    bz1aaa.opnamt = (tamount / currate) - (aaa.stmgbal / currate)  -  v-aadsm.
                                    bz1aaa.stmgbal = (aaa.stmgbal / currate).
if bf-lgr.feensf = 9 and lookup(bf-lgr.lgr, sysc-star.chval) <> 0 then do: /*star*/
   find last b-aaa where b-aaa.aaa = taccno no-error.
   bz1aaa.opnamt = b-aaa.opnamt / currate.
end.
if bf-lgr.feensf = 7 then do:
   find last b-aaa where b-aaa.aaa = taccno no-error.
   bz1aaa.opnamt = b-aaa.opnamt / currate.
end.
if (bf-lgr.feensf = 1 or bf-lgr.feensf = 2 or bf-lgr.feensf = 3 or bf-lgr.feensf = 4 or bf-lgr.feensf = 5 or bf-lgr.feensf = 7) then do:
   find last b-aaa where b-aaa.aaa = taccno no-error.
   bz1aaa.opnamt = b-aaa.opnamt / currate.
end.


                               end.
                               else do:
                                    bz1aaa.opnamt = (tamount * currate) - (aaa.stmgbal * currate)  -  v-aadsm.
                                    bz1aaa.stmgbal = (aaa.stmgbal * currate).
if bf-lgr.feensf = 9 and lookup(bf-lgr.lgr, sysc-star.chval) <> 0 then do: /*star*/
   find last b-aaa where b-aaa.aaa = taccno no-error.
   bz1aaa.opnamt = b-aaa.opnamt * currate.
end.

if  bf-lgr.feensf = 7 then do: /*star*/
   find last b-aaa where b-aaa.aaa = taccno no-error.
   bz1aaa.opnamt = b-aaa.opnamt * currate.
end.
if (bf-lgr.feensf = 1 or bf-lgr.feensf = 2 or bf-lgr.feensf = 3 or bf-lgr.feensf = 4 or bf-lgr.feensf = 5 or bf-lgr.feensf = 7) then do:
   find last b-aaa where b-aaa.aaa = taccno no-error.
   bz1aaa.opnamt = b-aaa.opnamt * currate.
end.


                               end.

                              bz1aaa.accrued = bz1aaa.stmgbal + (bz1aaa.cr[2] - bz1aaa.dr[2]) .

if bf-lgr.feensf = 1 or bf-lgr.feensf = 3 or bf-lgr.feensf = 4 or bf-lgr.feensf = 5 or bf-lgr.feensf = 7 then do:
   if (curtacc = 2 and currency = 3) or  (curtacc = 1 and currency = 2) or (curtacc = 1 and currency = 3) then do:
      find last b-aaa where b-aaa.aaa = taccno no-error.
      bz1aaa.accrued = b-aaa.accrued / currate.
   end.
   else do:
     find last b-aaa where b-aaa.aaa = taccno no-error.
     bz1aaa.accrued = b-aaa.accrued * currate.
   end.
end.


def buffer b-acvolt for acvolt.


if bf-lgr.feensf = 1 then do:
   def var d_fsum as decimal . d_fsum = 0.
   d_fsum = bz1aaa.opnamt.


   find last acvolt where acvolt.aaa = vaccno exclusive-lock no-error.
   if not avail acvolt then do:
      create acvolt.
             acvolt.aaa = vaccno.
   end.



   run tdaremholda(bz1aaa.aaa).
   run tdasethold(bz1aaa.aaa, d_fsum).
end.

if bf-lgr.feensf = 2 or bf-lgr.feensf = 3 or bf-lgr.feensf = 4 or bf-lgr.feensf = 5 or bf-lgr.feensf = 7 then do:
   find last b-acvolt where b-acvolt.aaa = taccno no-lock no-error.
   find last acvolt where acvolt.aaa = vaccno exclusive-lock no-error.
   if not avail acvolt then do:
      create acvolt.
             acvolt.aaa = vaccno.
   end.
   if (curtacc = 2 and currency = 11) or  (curtacc = 1 and currency = 2) or (curtacc = 1 and currency = 11) then do:
       acvolt.bonusopnamt = b-acvolt.bonusopnamt / currate.
   end.
   else do:
       acvolt.bonusopnamt = b-acvolt.bonusopnamt * currate.
   end.

   def var d_xsum as decimal . d_xsum = 0.


   for each b-trxaaad where b-trxaaad.aaa = bz1aaa.aaa and b-trxaaad.who <> "bankadm":
       d_xsum = d_xsum + b-trxaaad.sumg.
   end.

   d_xsum = d_xsum + bz1aaa.opnamt + bz1aaa.stmgbal.


   run tdaremholda(bz1aaa.aaa).
   run tdasethold(bz1aaa.aaa, d_xsum).
end.





/*  добавлено */
/*  if comm-cod() = 0 then */ do:


def var sum1 as decimal decimals 2.
sum1 = 0.
sum1 = bz1aaa.opnamt.
for each aad where aad.aaa = vaccno no-lock.
    sum1 = sum1 + aad.sumg.
end.

sum1 = bz1aaa.cr[1] - bz1aaa.dr[1].

                   if bz1aaa.crc = 1 then do: v-valut = "тенге". v-valut1 = "тиын.". end.
                   if bz1aaa.crc = 2 then do: v-valut = "доллары США". v-valut1 = "цента.". end.
                   if bz1aaa.crc = 3 then do: v-valut = "евро". v-valut1 = "". end.
                   if bz1aaa.crc = 4 then do: v-valut = "рублей". v-valut1 = "копеек". end.
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
                          if bz1aaa.crc = 2 then  v-valut = "центов".
                          if bz1aaa.crc = 4 then  v-valut = "копеек" .
                          if bz1aaa.crc = 3 then  v-valut = "центов".
                          if bz1aaa.crc = 2 then  v-valut1 = "центов".
                          if bz1aaa.crc = 4 then  v-valut1 = "копеек" .
                          if bz1aaa.crc = 3 then  v-valut1 = "центов".
                       end.

                       if s-okn = "1" then do:
                          if bz1aaa.crc = 2 then v-valut = "цент".
                          if bz1aaa.crc = 4 then v-valut = "копейка".
                          if bz1aaa.crc = 3 then v-valut = "цент".
                          if bz1aaa.crc = 2 then v-valut1 = "цент".
                          if bz1aaa.crc = 4 then v-valut1 = "копейка".
                          if bz1aaa.crc = 3 then v-valut1 = "цент".

                       end.

                       if s-okn = "2" or s-okn = "3" or s-okn = "4" then do:
                          if bz1aaa.crc = 2 then v-valut = "цента".
                          if bz1aaa.crc = 4 then v-valut = "копейки" .
                          if bz1aaa.crc = 3 then v-valut = "цента".
                          if bz1aaa.crc = 2 then v-valut1 = "цента".
                          if bz1aaa.crc = 4 then v-valut1 = "копейки" .
                          if bz1aaa.crc = 3 then v-valut1 = "цента".
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
                          if bz1aaa.crc = 3 then  v-valut = "евро" .

                       end.
                   end.





def buffer bmm for sysc.
find last bmm where bmm.sysc = "OURBNK" no-lock no-error.
def buffer bcit for sysc.
find last bcit where bcit.sysc = "citi" no-lock no-error.

def var vr-mes as char.
def var vk-mes as char.
def var v-sumletter as char.
def var v-sumpersentrus as char.
def var v-oofile as char.

def var v-bickfiliala as char.
def var v-bickfilialakz as char.
find last cmp no-lock no-error.
def buffer bss for sysc.




 find bss where bss.sysc = "bnkadr" no-lock no-error.
 if num-entries(bss.chval,"|") > 13 then
    v-bickfilialakz = entry(14, bss.chval,"|") + ", " .
    v-bickfilialakz = v-bickfilialakz + "СТТН " + cmp.addr[2] + ", ЖИК " + get-sysc-cha ("bnkiik") + ", БИК " + get-sysc-cha ("clecod") + ", " .

 if num-entries(bss.chval,"|") > 10 then
 v-bickfilialakz = v-bickfilialakz +  entry(11, bss.chval,"|").



 v-bickfiliala = cmp.name + ", " + "РНН " + cmp.addr[2] + ", ИИК " + get-sysc-cha ("bnkiik") + ", БИК " + get-sysc-cha ("clecod") + ", " + cmp.addr[1].

if bmm.chval = "TXB00" then v-bickfilialakz = "".
if bmm.chval = "TXB00" then v-bickfiliala = "".







run defdts(g-today, output vr-mes, output vk-mes).



   v-oofile = "vvk.htm" .

   output stream v-out to value(v-oofile).

/*
message sum1 (bz1aaa.cr[1] - bz1aaa.dr[1]) + (bz1aaa.cr[2] - bz1aaa.dr[2]) - sum1.
pause 888. */


   if bmm.chval = "TXB00" then
       if aaa.regdt > 08/13/2008 then input from value("/data/export/convert.htm"). else input from value("/data/export/convert_old.htm").
   else
       if aaa.regdt > 08/13/2008 then input from value("/data/export/op_convert.htm"). else input from value("/data/export/op_convert_old.htm").

     repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        repeat:
          if v-str matches "*accnrdt*" then do:
             v-str = replace (v-str, "accnrdt", string(aaa.regdt)).
             next.
          end.
          if v-str matches "*rcity*" then do:
             v-str = replace (v-str, "rcity", bcit.chval).
             next.
          end.
          if v-str matches "*rvyears*" then do:
             v-str = replace (v-str, "rvyears", string(year(g-today))).
             next.
          end.
          if v-str matches "*rchs*" then do:
             v-str = replace (v-str, "rchs", string(day(g-today))).
             next.
          end.
          if v-str matches "*rmes*" then do:
             v-str = replace (v-str, "rmes", vr-mes).
             next.
          end.
          if v-str matches "*kmes*" then do:
             v-str = replace (v-str, "kmes", vk-mes).
             next.
          end.
          if v-str matches "*nameofclient*" then do:
             v-str = replace (v-str, "nameofclient", cif.name).
             next.
          end.
          if v-str matches "*frval*" then do:
             find last bfcrccnv where bfcrccnv.crc = curtacc no-lock no-error.
             if avail bfcrccnv then do:
                v-str = replace (v-str, "frval", bfcrccnv.des).
                next.
             end.
             next.
          end.
          if v-str matches "*toval*" then do:
             find last bfcrccnv where bfcrccnv.crc = currency no-lock no-error.
             if avail bfcrccnv then do:
                v-str = replace (v-str, "toval", bfcrccnv.des).
                next.
             end.
             next.
          end.

          if v-str matches "*frkz*" then do:
             find last bfcrccnv where bfcrccnv.crc = curtacc no-lock no-error.
             if avail bfcrccnv then do:
                if bfcrccnv.crc = 2 then
                   v-str = replace (v-str, "frkz", "А&#1178;Ш доллары").
                else
                   v-str = replace (v-str, "frkz", bfcrccnv.des).
                next.
             end.
             next.
          end.
          if v-str matches "*tolkz*" then do:
             find last bfcrccnv where bfcrccnv.crc = currency no-lock no-error.
             if avail bfcrccnv then do:
                if bfcrccnv.crc = 2 then
                   v-str = replace (v-str, "tolkz", "А&#1178;Ш доллары").
                else
                   v-str = replace (v-str, "tolkz", bfcrccnv.des).
                next.
             end.
             next.
          end.



          if v-str matches "*iikclienta*" then do:
             v-str = replace (v-str, "iikclienta", vaccno).
             next.
          end.



          if v-str matches "*efstavka*" then do:
             v-str = replace (v-str, "efstavka", string(acvolt.x2)).
             next.
          end.



          if v-str matches "*dstavka*" then do:
             v-str = replace (v-str, "dstavka", string(bz1aaa.rate)).
             next.
          end.
          if v-str matches "*frkrs*" then do:
             v-str = replace (v-str, "frkrs", "1").
             next.
          end.
          if v-str matches "*tokrs*" then do:
             v-str = replace (v-str, "tokrs", string(currate)).
             next.
          end.
          if v-str matches "*sumrus*" then do:
             v-str = replace (v-str, "sumrus", string(sum1)).
             next.
          end.
          if v-str matches "*sumletterrus*" then do:
             run getsumtext(sum1, "ru", currency, output v-sumletter).
             v-str = replace (v-str, "sumletterrus", v-sumletter).
             next.
          end.
          if v-str matches "*sumletterkaz*" then do:
             run getsumtext(sum1, "kz", currency, output v-sumletter).
             v-str = replace (v-str, "sumletterkaz", v-sumletter).
             next.
          end.

          if v-str matches "*rnnclienta*" then do:
             v-str = replace (v-str, "rnnclienta", cif.jss ).
             next.
          end.






        if v-str matches "*adresclienta*" then do:
             v-str = replace(v-str, "adresclienta", string(cif.addr[1] + " " + cif.addr[2]) ).
             next.
          end.


         if v-str matches "*telclienta*" then do:
             v-str = replace (v-str, "telclienta", cif.tel ).
             next.
          end.
          if v-str matches "*passportclienta*" then do:
             v-str = replace (v-str, "passportclienta", string(cif.pss) ).
             next.
          end.
          if v-str matches "*faxclienta*" then do:
             v-str = replace (v-str, "faxclienta", u-2-w("       ")).
             next.
          end.

          if v-str matches "*sumnoletterrus*" then do:
             v-str = replace (v-str, "sumnoletterrus", string(bz1aaa.cr[2] - bz1aaa.dr[2])).
             next.
          end.






          if v-str matches "*sumpersentrus*" then do:
             run getsumtext((bz1aaa.cr[2] - bz1aaa.dr[2]), "ru", currency, output v-sumpersentrus).
             v-str = replace (v-str, "sumpersentrus", v-sumpersentrus).
             next.
          end.


          if v-str matches "*sumpersentkaz*" then do:
             run getsumtext((bz1aaa.cr[2] - bz1aaa.dr[2]), "kz", currency, output v-sumpersentrus).
             v-str = replace (v-str, "sumpersentkaz", v-sumpersentrus).
             next.
          end.


/*Данные филиала*/
 if v-str matches "*danniefil*" then do:
    v-str = replace (v-str, "danniefil", v-bickfiliala).
    next.
 end.


 if v-str matches "*bickfilialakz*" then do:
    v-str = replace (v-str, "bickfilialakz", v-bickfilialakz).
    next.
 end.







          leave.
        end.
        put stream v-out unformatted v-str skip.
    end.
    input close.
    output stream v-out close.
/*  unix silent cptwin value("xs.htm") winword. */


    unix silent cptunkoi value(v-oofile) winword.

    message  "  ВНИМАНИЕ! "
    skip(5) "   ПРОВЕРЬТЕ ТЕКСТ ДОПОЛНИТЕЛЬНОГО СОГЛАШЕНИЯ!  "
    skip "       При обнаружении ошибок сообщите в ДИТ.    "
    skip(5)  view-as alert-box question buttons ok title "" .

end. /* comm-cod() = 0 */
 /*добавлено*/

                       end.

       release aaa.
       message "Транзакция сделана" skip  "jh " s-jh view-as alert-box.
       find dealing_doc where dealing_doc.docno = documn share-lock.
       dealing_doc.jh = s-jh.
       find current dealing_doc no-lock.
       run dvou("prit").
    end.

   /* find aaa where aaa.aaa = vaccno no-lock no-error.
   message aaa.aaa vamount view-as alert-box.
   if aaa.lgr matches "d*" then run tdasethold(aaa.aaa,vamount). */
end. /*transaction*/


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
                        find aaa where aaa.aaa = dealing_doc.tclientaccno exclusive-lock.
                        aaa.sta = "A".
                        release aaa.
                        run tdasethold(dealing_doc.tclientaccno,dealing_doc.t_amount).
                     end.
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







procedure defdts:
def input parameter p-dt as date.
def output parameter p-datastr as char.
def output parameter p-datastrkz as char.

def var v-monthname as char init
   "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".

def var v-monthnamekz as char init
   "&#1179;а&#1187;тар,а&#1179;пан,наурыз,с&#1241;уiр,мамыр,маусым,шiлде,тамыз,&#1179;ырк&#1199;йек,&#1179;азан,&#1179;араша,желто&#1179;сан".
p-datastr = entry(month(p-dt), v-monthname).
p-datastrkz = entry(month(p-dt), v-monthnamekz).

end.



procedure getsumtext:
  def input  parameter  in_sum as decimal.
  def input parameter  in_prm as char.     /* ru-русский    kz-казахский */
  def input parameter  in_val as integer.     /* Валюта */
  def output parameter  out_letter as char.

  def var v-per1 as char.
  def var v-per2 as char.
  def var v-per3 as char.
  def var summdec as decimal format "9.99" no-undo.

  if in_prm = "ru" then do:
     s-okn = substr(string(in_sum), length(string(truncate(in_sum, 0))), 1).


     run Sm-vrd(in_sum, output v-per1).
     if in_val = 1 then v-per1 = v-per1 + " тенге " . else
     if in_val = 2 then do:
        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then v-per1 = v-per1 + " долларов США ".
        if s-okn = "1" then v-per1 = v-per1 + " доллар США ".
        if s-okn = "2" or s-okn = "3" or s-okn = "4" then v-per1 = v-per1 + " доллара США ".
     end.
     else
     if in_val = 3 then v-per1 = v-per1 + " евро "  . else
     if in_val = 4 then do:
        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then v-per1 = v-per1 + " рублей ".
        if s-okn = "1" then v-per1 = v-per1 + " рубль ".
        if s-okn = "2" or s-okn = "3" or s-okn = "4" then v-per1 = v-per1 + " рубля ".
     end.


/*   s-okn =  substr(string(int((in_sum - int(in_sum)) * 100)), length(string(int((in_sum - int(in_sum)) * 100))),1). */
     s-okn = substr(string(in_sum), length(string(truncate(in_sum, 2))), 1).

     run frac (input in_sum, output summdec).
     summdec = summdec * 100.
     run Sm-vrd(summdec, output v-per2).
     if in_val = 1 then v-per2 = v-per2 + " тиын" . else
     if in_val = 2 then do:
        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then v-per2 = v-per2 + " центов".
        if s-okn = "1" then v-per2 = v-per2 + " цент".
        if s-okn = "2" or s-okn = "3" or s-okn = "4" then v-per2 = v-per2 + " цента".
     end. else
     if in_val = 3 then do:
        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then v-per2 = v-per2 + " центов".
        if s-okn = "1" then v-per2 = v-per2 + " цент".
        if s-okn = "2" or s-okn = "3" or s-okn = "4" then v-per2 = v-per2 + " цента".
     end.
     if in_val = 4 then do:
        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then v-per2 = v-per2 + " копеек".
        if s-okn = "1" then v-per2 = v-per2 + " копейка".
        if s-okn = "2" or s-okn = "3" or s-okn = "4" then v-per2 = v-per2 + " копейки".
     end.
      out_letter = v-per1 + v-per2.
   end.






  if in_prm = "kz" then do:
     s-okn = substr(string(in_sum), length(string(truncate(in_sum, 0))), 1).
     run Sm-vrd-kzopti(in_sum, output v-per1).

     if in_val = 1 then v-per1 = v-per1 + "тенге " . else
     if in_val = 2 then do:
        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then v-per1 = v-per1 + "А&#1178;Ш доллары ".
        if s-okn = "1" then v-per1 = v-per1 + "А&#1178;Ш доллары ".
        if s-okn = "2" or s-okn = "3" or s-okn = "4" then v-per1 = v-per1 + "А&#1178;Ш доллары ".
     end.
     else
     if in_val = 3 then v-per1 = v-per1 + "евро "  . else
     if in_val = 4 then do:
        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then v-per1 = v-per1 + "рублей ".
        if s-okn = "1" then v-per1 = v-per1 + "рубль ".
        if s-okn = "2" or s-okn = "3" or s-okn = "4" then v-per1 = v-per1 + "рубля ".
     end.



/*   s-okn =  substr(string(int((in_sum - int(in_sum)) * 100)), length(string(int((in_sum - int(in_sum)) * 100))),1). */

     run frac (input in_sum, output summdec).
     summdec = summdec * 100.


     s-okn = substr(string(in_sum), length(string(truncate(in_sum, 2))), 1).
     run Sm-vrd-kzopti(summdec, output v-per2).
     if in_val = 1 then v-per2 = v-per2 + "тиын" . else
     if in_val = 2 then do:
        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then v-per2 = v-per2 + "цент".
        if s-okn = "1" then v-per2 = v-per2 + "цент".
        if s-okn = "2" or s-okn = "3" or s-okn = "4" then v-per2 = v-per2 + "цент".
     end. else
     if in_val = 3 then do:
        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then v-per2 = v-per2 + "цент".
        if s-okn = "1" then v-per2 = v-per2 + "цент".
        if s-okn = "2" or s-okn = "3" or s-okn = "4" then v-per2 = v-per2 + "цент".
     end.
     if in_val = 4 then do:
        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then v-per2 = v-per2 + "копеек".
        if s-okn = "1" then v-per2 = v-per2 + "копейка".
        if s-okn = "2" or s-okn = "3" or s-okn = "4" then v-per2 = v-per2 + "копейки".
     end.
      out_letter = v-per1 + v-per2.
   end.

end.
