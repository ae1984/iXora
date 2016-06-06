/* accmaint.p
 * MODULE
        Клиентские счета
 * DESCRIPTION
        Изменение статуса счета клиента (закрытие счетов)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1-6-5
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        25.02.1997 AGA     - пpинудительное закpытие овеpдpафтных счетов
        ...        marinav - выдача уведомления в налоговый комитет
        15.07.2003 nadejda - добавлен вариант печати уведомления для переоткрытия счетов
        25.08.2003 nadejda - сделан запрос на номер счета без всяких условий
        15.10.2003 sasco   - проверка на русскую букву "С" при вводе статуса счета
        19.10.2003 nadejda - добавлена группа 301 для печати уведомления
        15.12.2004 dpuchkov - добавил new shared переменные
        22.06.2005 dpuchkov - очистка уровней при закрытии счетов
        06.07.2005 dpuchkov - добавил формирование уведомления в налоговый комитет при закрытии счета
        25/07/2005 u00121   - добавил проверку на наличие спец.инструкций при закрытии счета.
                              Проверку осуществляет функция нахождения спец.инструкций по заданному счету (find_aas), передаваемый параметр функции - номер счета,
                              возвращает yes - есть спец.инструкция, no - специнструкций нет
                              ТЗ ї 86 от 22/07/05, заказчик - Операционный департамент
        01.09.2005 dpuchkov   переделал вышеуказанную проверку (добавил проверку на специнструкции депозитов)
        30.01.2006 dpuchkov   добавил принудительное проставление дат в sub-cod при закрытии счетов ТЗ 223.
        21.09.2006 u00777     добавлено формирование электрон. извещения и вывод сообщения по счету ГК 221910 при закрытии счета
        11.06.2009 galina - добавила отправку уведомлений при закрытии счета о возврате ИР, полученного по эл.каналу
                            добавила закрытие 20-тизначного счета при закрытии 9-тизначного
        08/12/2009 galina - добавила отправку сообщения о возврате РПРО при закрытии счета
        19/04/2010 galina - поправила определение наличия ИР и РПРО при закрытии счета
        28/04/2012 evseev - отструктурировал программу. Вынес проверку на наличие РПРО за транзакционный блок, заменил repeat на do transaction
        10/05/2012 dmitriy - убрал возможность закрыть счет, если имеется задолженность в 1.4.2.1 и счет открыт на ГК 220310,220420,220520,220530
        11/05/2012 evseev - убрал оповещение
        25.06.2012 evseev - добавил логирование
        24.12.2012 Lyubov - ТЗ 1598 - отменила формирование уведомления о закрытии счета
        10.06.2013 Lyubov - ТЗ №1787, при закрытии счета (sta = C) закртываем имеющиеся карточки
        28/10/2013 Luiza  - ТЗ 1937 конвертация депозит cda0003 и uni0048
*/


{mainhead.i CFSTS}  /*  ACCOUNT MANAGEMENT  */
{get-dep.i}
def new shared var ch_date as date .
  def new shared var ch_KS as char .
  def stream st1.
  define buffer b-aaa for aaa.
  def var s_aaa like aaa.aaa.
  define var grobal like aas.chkamt decimals 2.
  define var avabal like aas.chkamt decimals 2.
  define var crline like aas.chkamt decimals 2.
  define var crused like aas.chkamt decimals 2.
  define var mtddb  like aas.chkamt decimals 2.
  define var mtdcr  like aas.chkamt decimals 2.
  define var ytdint like aas.chkamt decimals 2.
  define var vdet    as log.
  define var vrel    as log.
  define var vstop   as log.
  define var vans    as log.
  def var sstop as char format "x(15)" .
  def var spnum as int format "zz9".
  def var shold as char format "x(15)" .
  def var shnum as int format "zz9".
  def buffer b-aa for aaa.
  def var vdel as char initial "^".
  def var vparam as char.
  def var v-jh like jh.jh.
  def  new shared var s-jh like jh.jh.
  def var rcode as inte.
  def var rdes as char.
  define var s-amt1 like aal.amt.
  def var v-templ as char.
  def var ja as logi.
  def var vou-count as int init 1.
  def var i as int.
  def var v-sta like aaa.sta.
  def buffer b-lgr for lgr.
  define variable old-sta as char.
  def var ourbank  as char.
  /*def var v-point like point.point.
  def var v-dep like ppoint.depart.
  def var v-email as character initial "".*/
  def buffer b-aaa20 for aaa.
  def buffer b-sub-cod for sub-cod.
  def var v-sum as deci init 0.

{accmaint.f}


/*u00121 25/07/2005 функция нахождения спец.инструкций по заданному счету, возвращает yes - есть спец.инструкция, no - специнструкций нет*/
function find_aas returns logical (input i-aaa as char):
    def var v-res as logi.
    v-res = no.

      for each aas where aas.aaa = i-aaa and aas.ln <> 7777777 no-lock:
         find first insin where insin.numr = aas.docnum and lookup(aas.aaa,insin.blkaaa) > 0 no-lock no-error.
         find first inc100 where inc100.num = integer(aas.fnum) and inc100.iik = aas.aaa no-lock no-error.
         find first aaar where aaar.a5 = aas.aaa and aaar.a4 <> "1" no-lock no-error.

         if aas.sta = 4 or aas.sta = 5 or aas.sta = 9 then do:
            if not avail inc100 or avail aaar then do:
               v-res = yes.
               leave.
            end.
         end.
         else if aas.sta = 2 or aas.sta = 16 or aas.sta = 17 then do:
            find first insin where insin.numr = aas.docnum and lookup(aas.aaa,insin.blkaaa) > 0 no-lock no-error.
            if not avail insin then do:
               v-res = yes.
               leave.
            end.
         end.
         else do:
           v-res = yes.
           leave.
         end.
      end.
      return v-res.
end.

/*repeat:*/ /*2*/
do transaction:
  clear frame aaa.
  pause 0.
  crline = 0.
  crused = 0.
  if keyfunction(lastkey) eq "end-error" then return.
  prompt-for aaa.aaa with frame aaa.

  find aaa using aaa.aaa exclusive-lock no-error.
  if substr(aaa.aaa,4,3) = "140" then do:
        message "Выбран овердрафтный счет!!!" skip "Изменение статуса категорически ЗАПРЕЩЕНО!" view-as alert-box title "Внимание!!!" .
        quit.
  end.

  find cif of aaa no-lock no-error.
  find lgr where lgr.lgr eq aaa.lgr no-lock no-error.
  if aaa.loa ne "" and lgr.led eq "DDA" then do:
         find b-aaa where b-aaa.aaa eq aaa.loa no-lock no-error.
         crline = b-aaa.dr[5] - b-aaa.cr[5].
         crused = b-aaa.dr[1] - b-aaa.cr[1].
  end.

  if lgr.led eq "DDA" or lgr.lgr eq "151" then do:
    s_aaa = aaa.craccnt.
  end.

  grobal = aaa.cr[1] - aaa.dr[1].
  avabal = aaa.cbal + crline - crused.
  ytdint = (aaa.dr[2] - aaa.idr[2]) - (aaa.cr[2] - aaa.icr[2]).
  mtddb = aaa.dr[1] - aaa.mdr[1].
  mtdcr = aaa.cr[1] - aaa.mcr[1].
  spnum = 0.
  shnum = 0.


  for each aas where aas.aaa eq aaa.aaa no-lock :
     if aas.sic = "SP" then spnum = spnum + 1. else if aas.sic = "HB" then shnum = shnum + 1.
  end.

  if spnum > 0 then sstop = string(spnum) + " STOP PAYMENT". else sstop = "NO STOP PAYMENT".
  if shnum > 0 then shold = string(shnum) + " HOLD BALANCE". else shold = "NO HOLD BALANCE".

  display
     cif.cif
     trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname aaa.aaa s_aaa
     cif.tel aaa.sta aaa.grp
     grobal shold aaa.hbal
     avabal aaa.accrued
     crline ytdint
     crused
     cif.pss
     aaa.lstdb aaa.ddt
     aaa.lstcr aaa.cdt
     aaa.regdt
     aaa.fbal
     sstop
     with frame aaa.

  update aaa.grp with frame aaa.

  if shnum > 0 then color display  messages  shold with frame aaa. else color display  input  shold with frame aaa.

  /*3*/
  if spnum > 0   then do:
     color display  messages  sstop with frame aaa.
     pause 1.
     for each aas where aas.aaa eq aaa.aaa no-lock:
         find sic of aas no-lock no-error.
         display aas.sic sic.des label "DESCRIPTION"  aas.regdt aas.chkdt aas.chkno aas.chkamt with row 9  9 down  overlay  centered
                 title " Special Instructions for (" + string(aas.aaa) + ")" frame aas.
     end.

     /*4*/
     if aaa.sta NE "C" then do:
        stma:
        /*6*/
        repeat:
           old-sta = aaa.sta.

           update  aaa.sta with no-validate frame aaa.
           if aaa.sta = "С" or aaa.sta = "с" then do:
              aaa.sta = old-sta.
              message "Измените раскладку клавиатуры на английскую!" view-as alert-box.
              next.
           end.

           if lookup(aaa.lgr, "415,413,410,411,412") <> 0 and aaa.sta = "С" then do:
              find trxbal where trxbal.sub = 'cif' and  trxbal.acc = aaa.aaa and trxbal.level = 13 no-lock no-error.
              if available trxbal then do:
                 if abs(trxbal.cam - trxbal.dam) <> 0 then do:
                    MESSAGE "Имеется остаток на уровне 13 !" VIEW-AS ALERT-BOX.
                    undo, next.
                 end.
              end.

              find trxbal where trxbal.sub = 'cif' and  trxbal.acc = aaa.aaa and trxbal.level = 10 no-lock no-error.
              if available trxbal then do:
                 if abs(trxbal.cam - trxbal.dam) <> 0 then do:
                    MESSAGE "Имеется остаток на уровне 10 !" VIEW-AS ALERT-BOX.
                    undo, next.
                 end.
              end.
           end.

           /*u00121 25/07/2005 проврека на наличие спец.инструкций*/
           if aaa.sta = "C" and find_aas(aaa.aaa) then do:
              aaa.sta = old-sta.
              MESSAGE "ЗАКРЫТИЕ СЧЕТА НЕВОЗМОЖНО, НА СЧЕТ НАЛОЖЕНЫ СПЕЦ. ИНСТРУКЦИИ!" VIEW-AS ALERT-BOX.
              next.
           end.
           /*u00121 25/07/2005 ************************************/
           /*7*/
           if frame aaa aaa.sta entered then do:
              if aaa.sta <> "C" then leave.
              if aaa.sta EQ "C" AND (aaa.cr[1] - aaa.dr[1] NE 0.0 OR  aaa.accrued NE 0.0) then do:
                 bell.
                 message "Баланс " +
                 trim(string(aaa.cr[1] - aaa.dr[1],"zzz,zzz,zzz,zz9.99")) + " Проценты " +
                 trim(string(aaa.accrued,"zzz,zzz,zzz,zz9.99")).
                 undo, retry stma.
              end.
              aaa.cltdt = g-today.
              aaa.whn = g-today.
              aaa.who = g-ofc.
              /*8*/
              if aaa.sta = "C" then do:
                 /* пpинудительно закpывать для ЛОРО и овеpдpафтные счета если они есть и не использованы */
                 find first b-aa where b-aa.aaa EQ aaa.craccnt no-lock no-error.
                 if available b-aa then do:
                    if b-aa.cbal EQ b-aa.opnamt then
                       b-aa.sta = "C".
                    else do:
                       bell.
                       message "На счете " + b-aa.aaa + " есть остаток " +
                       trim(string(b-aa.cr[1] - b-aa.dr[1])) + "  !!!".
                       pause.
                       undo, retry stma.
                    end.
                 end.
                 run subcod(aaa.aaa,"cif").
                 find first sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = aaa.aaa and sub-cod.d-cod = 'clsa' exclusive-lock no-error.
                 if avail sub-cod then do:
                    sub-cod.rdt = g-today.
                 end.
                 if aaa.aaa20 <> '' then do:
                    find first b-aaa20 where b-aaa20.aaa = aaa.aaa20 exclusive-lock no-error.
                    if avail b-aaa20 then do:
                       b-aaa20.sta = 'C'.
                       b-aaa20.cltdt = g-today.
                       b-aaa20.whn = g-today.
                       b-aaa20.who = g-ofc.
                       find first sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = b-aaa20.aaa and sub-cod.d-cod = 'clsa' exclusive-lock no-error.
                       find first b-sub-cod where b-sub-cod.sub = 'cif' and b-sub-cod.acc = aaa.aaa and b-sub-cod.d-cod = 'clsa' no-lock no-error.
                       if avail sub-cod then do:
                          sub-cod.rdt = g-today.
                          sub-cod.ccode = b-sub-cod.ccode.
                       end.
                    end.
                 end.
                 run inkaaacls(aaa.aaa).
                 /*run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "проверка на наличие РПРО при закрытии счета",
                          " раньше тут отрабатывала проверка на наличие РПРО при закрытии счета [1] " + aaa.aaa, "1", "", "").*/
                 /*run insst01(aaa.aaa).*/
               /*8*/
              end.
              /*Формирование извещения 20.09.2006 u00777*/
              if aaa.gl = 221910 and aaa.sta = "C" then do:
                 MESSAGE "При закрытии условного банковского вклада Вам необходимо предоставить копию решения налоговых органов ДНП !" VIEW-AS ALERT-BOX BUTTONS OK.
                 output stream st1 to izv.html.
                 {html-title.i
                     &stream = " stream st1 "
                     &title = " "
                     &size-add = "x-"
                 }
                 put stream st1 unformatted
                           "<HTML> <HEAD> <TITLE>TEXAKABANK</TITLE>" skip
                           "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
                           "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip.
                 put stream st1 unformatted
                           "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: xx-small;" skip
                           "</STYLE></HEAD>" skip
                           "<BODY LEFTMARGIN=""20"">" skip.
                 put stream st1 unformatted "<P align=""center"" style=""font:bold""> Извещение о закрытии условного банковского вклада" "<P align=""left"">".
                 find ofc where ofc.ofc = g-ofc no-lock no-error.
                 if avail ofc then put stream st1 unformatted   "Исполнитель: " trim(ofc.name) format "x(30)" skip.
                 put stream st1 unformatted   "<BR>" "Дата: " aaa.cltdt format "99/99/9999" "<BR>" "Счет: " aaa.aaa skip.
                 find cif where cif.cif = aaa.cif no-lock no-error.
                 if avail cif then put stream st1 unformatted " " trim(cif.name) skip.
                 put stream st1 unformatted "<BR>" "<BR>" "&nbsp;" "    В случае перечисления суммы вклада в бюджет необходимо в течение 2 рабочих дней предоставить отчет в налоговые органы." skip.
                 {html-end.i " stream st1 "}
                 output stream st1 close.
                 unix silent un-win izv.html izv1.html.
                 /*Формирование email директора подразделения, за кот. закреплен счет*/
                 /*assign v-point = integer(cif.jame) / 1000 - 0.5
                        v-dep = integer(cif.jame) - v-point * 1000
                        v-email = "".
                 for each ofc where ofc.expr[1] = 'p00082' no-lock:
                     find last ofchis where ofchis.ofc = ofc.ofc no-lock no-error.
                     if avail ofchis and ofchis.depart = v-dep then do:
                        v-email = "," +  trim(ofchis.ofc) + "@elexnet.kz".
                        leave.
                     end.
                 end.*/
                 run mail ( "id00787@metrocombank.kz",
                     "METROCOMBANK <abpk@metrocombank.kz>",
                     "Извещение о закрытии условного банковского вклада",
                     "См. вложение.",
                     "1",
                     "",
                     "izv1.html" ).
              end.
              leave.
            /*7*/
           end.
         /*6*/
        END. /*repeat 6*/

        find current aaa no-lock.
      /*4*/
     end. /* aaa.sta NE "C"   4*/
   /*3*/
  end. /*if spnum > 0     3*/
  /*9*/
  else do: /* spum <= 0 , те нет спец интструкций на счет */
     color display  input  sstop with frame aaa.
     /* {mesg.i 0916}. */
     /*10*/
     if aaa.sta NE "C" then do:
        stmb:
        /*11*/
        repeat:
           v-sta = aaa.sta.
           update  aaa.sta with no-validate frame aaa.

           /* проверка есть ли задолженность в 1-4-2-1*/
           v-sum = 0.
           if aaa.gl = 220310 or aaa.gl = 220420 or aaa.gl = 220520 or aaa.gl = 220530 then do:
               for each bxcif where bxcif.aaa = aaa.aaa no-lock:
                   v-sum = v-sum + bxcif.amount.
               end.

               if v-sum <> 0 and aaa.sta = "C" then do:
                    message "Невозможно закрыть счет: по данному счету имеется задолженность перед Банком (см. в п.м. 1.4.2.1.)" view-as alert-box.
                    undo, return.
               end.
           end.

           if aaa.sta = "С" or aaa.sta = "с" then do:
              aaa.sta = v-sta.
              message "Измените раскладку клавиатуры на английскую!" view-as alert-box.
              next.
           end.

            if lookup(aaa.lgr,"415,413,410,411,412") <> 0 and aaa.sta = "C" then do:
              find trxbal where trxbal.sub = 'cif' and  trxbal.acc = aaa.aaa and trxbal.level = 13 no-lock no-error.
              if available trxbal then do:
                 if abs(trxbal.cam - trxbal.dam) <> 0 then do:
                    MESSAGE "Имеется остаток на уровне 13 !" VIEW-AS ALERT-BOX.
                    undo, next.
                 end.
              end.
              find trxbal where trxbal.sub = 'cif' and  trxbal.acc = aaa.aaa and trxbal.level = 10 no-lock no-error.
              if available trxbal then do:
                 if abs(trxbal.cam - trxbal.dam) <> 0 then do:
                    MESSAGE "Имеется остаток на уровне 10 !" VIEW-AS ALERT-BOX.
                    undo, next.
                 end.
              end.
           end.
           /*u00121 25/07/2005 проврека на наличие спец.инструкций*/
           if aaa.sta = "C" and find_aas(aaa.aaa) then do:
              aaa.sta = v-sta.
              MESSAGE "ЗАКРЫТИЕ СЧЕТА НЕВОЗМОЖНО, НА СЧЕТ НАЛОЖЕНЫ СПЕЦ. ИНСТРУКЦИИ!" VIEW-AS ALERT-BOX.
              next.
           end.

            if lookup(aaa.lgr, "138,139,140,143,144,145") <> 0 and aaa.sta = "C" then do:
                for each pcstaff0 where pcstaff0.aaa = aaa.aaa exclusive-lock:
                    pcstaff0.sts = 'Closed'.
                end.
                for each pccards where pccards.aaa = aaa.aaa exclusive-lock:
                    pccards.sts = 'Closed'.
                end.
            end.

           /*u00121 25/07/2005 ************************************/
           /*12*/
           if frame aaa aaa.sta entered then do:
              if aaa.sta <> "C"   then leave.
              IF aaa.sta EQ "C" AND (aaa.cr[1] - aaa.dr[1] NE 0.0 OR aaa.accrued NE 0.0) then do:
                 bell.
                 message "Бал. " +
                    trim(string(aaa.cr[1] - aaa.dr[1],"zzz,zzz,zzz,zz9.99")) + " Проценты " +
                    trim(string(aaa.accrued,"zzz,zzz,zzz,zz9.99")).
                 undo, retry stmb.
              end.
              aaa.cltdt = g-today.
              aaa.whn = g-today.
              aaa.who = g-ofc.
              /*11.06/02 nataly-------*/
              v-jh = 0.
              s-amt1 = aaa.cr[2] - aaa.dr[2]. /*реально начисленных*/
              /*если на 2-ом уровне клиентского счета  есть остаток, то делает возврат %% на 492120*/
              /*13*/
              /* Сейфовые ячейки */
              if aaa.sta = "C" then do:
                 for each cellx where cellx.aaa = aaa.aaa exclusive-lock :
                     cellx.name = "".
                     cellx.aaa = "".
                     cellx.sts = "Свободна".
                 end.
              end.
              /*ДОБАВЛЕНО*/
              def buffer b-lr for lgr.
              def buffer b-cr for crc.
              find last b-lr where b-lr.lgr = aaa.lgr no-lock no-error.
              def var s-t1  as decimal.
              def var s-t2  as decimal.
              def var s-t11 as decimal.
              find last b-cr where b-cr.crc = aaa.crc no-lock no-error.
              if s-amt1 > 0 and b-lr.led = "TDA" then do:
                 aaa.sta = 'A'.
                 s-t2 = (aaa.cr[2] - aaa.dr[2]).  s-t11 = 0.
                 find first trxbal where trxbal.subled = 'cif' and trxbal.acc = aaa.aaa and trxbal.level = 11 no-lock no-error.
                 if avail trxbal then do: s-t11 = truncate((trxbal.dam - trxbal.cam) / b-cr.rate[1], 2). end. else s-t11 = 0.
                 if s-t2 > s-t11 then s-t1 = s-t2 - s-t11. else do : s-t1 = 0. s-t11 = s-t2. end.
                 v-jh = 0.
                 /*cо 2 на 11*/
                 if s-t11 > 0 then do:
                    /*vparam = string(0) + vdel + aaa.aaa + vdel + string(s-t11).*/
                    if aaa.crc = 1 then vparam = string(0) + vdel + aaa.aaa + vdel + string(0) + vdel + aaa.aaa + vdel + "0" + vdel + string(s-t11) + vdel + aaa.aaa.
                    else vparam = string(0) + vdel + aaa.aaa + vdel + string(s-t11) + vdel + aaa.aaa + vdel + string(round(s-t11 * b-cr.rate[1],2)) + vdel + string(0) + vdel + aaa.aaa.
                    run trxgen ("cda0003", vdel, vparam, "CIF" , aaa.aaa ,  output rcode, output rdes, input-output v-jh).
                    if rcode ne 0 then do: message rdes. pause 111.  end.
                    else do:
                       run trxsts(v-jh, 6, output rcode, output  rdes).
                    end.
                 end.
                 if s-t1 > 0 then do:
                    v-jh = 0.
                    /*vparam = string(s-t1) + vdel + aaa.aaa + vdel + "Возврат процентов".*/
                    if aaa.crc = 1 then vparam = string(s-t1) + vdel + aaa.aaa + vdel + "Возврат процентов" + vdel +
                                            string(0) + vdel + aaa.aaa + vdel + "" + vdel + "0".
                    else vparam = string(0) + vdel + aaa.aaa + vdel + " " + vdel +
                                    string(s-t1) + vdel + aaa.aaa + vdel + "Возврат процентов" + vdel + string(round(s-t1 * b-cr.rate[1],2)).
                    run trxgen ("uni0048", vdel, vparam, "CIF" , aaa.aaa, output rcode, output rdes, input-output v-jh).
                 end.
                 /*voucher printing nataly--------------------*/
                 if v-jh ne 0 then do:
                    find first jl where jl.jh = v-jh no-lock no-error.
                    if available jl  then do:
                       message "Печатать ваучер ?" update ja.
                       if ja   then do:
                          message "Сколько ?" update vou-count.
                          if vou-count > 0 and vou-count < 10 then do:
                             s-jh =  v-jh.
                             {mesg.i 0933} s-jh.
                             do i = 1 to vou-count:
                                run x-jlvou.
                             end.
                          end.  /* if vou-count > 0 */
                       end. /* if ja */
                       else do:
                          {mesg.i 0933} v-jh.   /* s-jh = jh.jh.*/ pause 5.
                       end. /*  if ja*/
                       pause 0.
                    end.  /* if available jl */
                    else do:
                       message "Can't find transaction " v-jh view-as alert-box.
                       return.
                    end.
                    pause 0.
                 end.
                 /*voucher printing nataly--------------------*/
                 aaa.sta = "C".
                 /*13*/
              end. /*if s-amt1 > 0  есть остаток на 2-ом уровне*/
              else
                 /*ДОБАВЛЕНО*/
                 if s-amt1 > 0 and (aaa.gl = 221520 or aaa.gl = 221720 or aaa.gl = 221130) then do:
                    aaa.sta = 'A'.
                    v-templ = 'uni0048'.
                    /*vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "Возврат процентов".*/
                    if aaa.crc = 1 then vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "Возврат процентов" + vdel +
                                            string(0) + vdel + aaa.aaa + vdel + "" + vdel + "0".
                    else vparam = string(0) + vdel + aaa.aaa + vdel + "" + vdel +
                                    string(s-amt1) + vdel + aaa.aaa + vdel + "Возврат процентов" + vdel + string(round(s-t1 * b-cr.rate[1],2)).
                    run trxgen (v-templ, vdel, vparam, "CIF" , aaa.aaa , output rcode, output rdes, input-output v-jh).
                    run trxsts(v-jh, 6, output rcode, output rdes).
                    if rcode ne 0 then do:
                       message rdes view-as alert-box title "".
                       message v-templ ' ' rdes.
                       pause.
                       message vparam.
                       pause.
                       undo,retry.
                    end.
                    /*voucher printing nataly--------------------*/
                    if v-jh ne 0 then do :
                       find first jl where jl.jh = v-jh no-lock no-error.
                       if available jl  then do:
                          message "Печатать ваучер ?" update ja.
                          if ja then do:
                             message "Сколько ?" update vou-count.
                             if vou-count > 0 and vou-count < 10 then do:
                                s-jh =  v-jh.
                                {mesg.i 0933} s-jh.
                                do i = 1 to vou-count:
                                   run x-jlvou.
                                end.
                             end.  /* if vou-count > 0 */
                          end. /* if ja */
                          else  do:
                             {mesg.i 0933} v-jh.   /* s-jh = jh.jh.*/ pause 5.
                          end. /*  if not ja*/
                          pause 0.
                       end.  /* if available jl */
                       else do:
                          message "Can't find transaction " v-jh view-as alert-box.
                          return.
                       end.
                       pause 0.
                    end.
                    /*voucher printing nataly--------------------*/
                    aaa.sta = "C".
                  /*13*/
                 end. /*if s-amt1 > 0  есть остаток на 2-ом уровне*/

              /*11/06/02 nataly-----------*/
              if aaa.sta = "C" then do:  /* пpинудительно закpывать для ЛОРО и овеpдpафтные счета если они есть и не использованы */
                 find first b-aa where b-aa.aaa EQ aaa.craccnt exclusive-lock no-error.
                 find b-lgr  where b-lgr.lgr = aaa.lgr no-lock no-error.
                 if b-lgr.led = 'DDA' then do:
                    if available b-aa   then do:
                       if b-aa.cbal EQ b-aa.opnamt then b-aa.sta = "C".
                       else do:
                          bell.
                          message "На счете " + b-aa.aaa + " есть остаток " + trim(string(b-aa.cr[1] - b-aa.dr[1])) + "  !!!".
                          pause.
                          undo, retry stmb.
                       end.
                    end. /*avail b-aa*/
                 end. /*if 'DDA'*/
                 run subcod(aaa.aaa,"cif").
                 find first sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = aaa.aaa and sub-cod.d-cod = 'clsa' exclusive-lock no-error.
                 if avail sub-cod then do:
                    sub-cod.rdt = g-today.
                 end.
                 if aaa.aaa20 <> '' then do:
                    find first b-aaa20 where b-aaa20.aaa = aaa.aaa20 exclusive-lock no-error.
                    if avail b-aaa20 then do:
                       b-aaa20.sta = 'C'.
                       b-aaa20.cltdt = g-today.
                       b-aaa20.whn = g-today.
                       b-aaa20.who = g-ofc.
                       find first sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = b-aaa20.aaa and sub-cod.d-cod = 'clsa' exclusive-lock no-error.
                       find first b-sub-cod where b-sub-cod.sub = 'cif' and b-sub-cod.acc = aaa.aaa and b-sub-cod.d-cod = 'clsa' no-lock no-error.
                       if avail sub-cod then do:
                          sub-cod.rdt = g-today.
                          sub-cod.ccod = b-sub-cod.ccod.
                       end.
                    end.
                 end.
                 run inkaaacls(aaa.aaa).
                 /*run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "проверка на наличие РПРО при закрытии счета",
                          " раньше тут отрабатывала проверка на наличие РПРО при закрытии счета [2] " + aaa.aaa, "1", "", "").*/
                 /*run insst01(aaa.aaa).*/
              end.
              /*Формирование извещения 20.09.2006 u00777*/
              if aaa.gl = 221910 and aaa.sta = "C" then do:
                 MESSAGE "При закрытии условного банковского вклада Вам необходимо предоставить копию решения налоговых органов ДНП !" VIEW-AS ALERT-BOX BUTTONS OK.
                 output stream st1 to izv.html.
                 {html-title.i
                    &stream = " stream st1 "
                    &title = " "
                    &size-add = "x-"
                 }
                 put stream st1 unformatted
                     "<HTML> <HEAD> <TITLE>TEXAKABANK</TITLE>" skip
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip.
                 put stream st1 unformatted
                     "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: xx-small;" skip
                     "</STYLE></HEAD>" skip
                     "<BODY LEFTMARGIN=""20"">" skip.
                 put stream st1 unformatted "<P align=""center"" style=""font:bold""> Извещение о закрытии условного банковского вклада" "<P align=""left"">".
                 find ofc where ofc.ofc = g-ofc no-lock no-error.
                 if avail ofc then  put stream st1 unformatted   "Исполнитель: " trim(ofc.name) format "x(30)" skip.
                 put stream st1 unformatted   "<BR>" "Дата: " aaa.cltdt format "99/99/9999" "<BR>" "Счет: " aaa.aaa skip.
                 find cif where cif.cif = aaa.cif no-lock no-error.
                 if avail cif then put stream st1 unformatted " " trim(cif.name) skip.
                 put stream st1 unformatted "<BR>" "<BR>" "&nbsp;" "    В случае перечисления суммы вклада в бюджет необходимо в течение 2 рабочих дней предоставить отчет в налоговые органы." skip.
                 {html-end.i " stream st1 "}
                 output stream st1 close.
                 unix silent un-win izv.html izv1.html.

                 /*Формирование email директора подразделения, за кот. закреплен счет*/
                 /*
                 assign v-point = integer(cif.jame) / 1000 - 0.5
                        v-dep = integer(cif.jame) - v-point * 1000
                        v-email = "".
                 for each ofc where ofc.expr[1] = 'p00082' no-lock:
                     find last ofchis where ofchis.ofc = ofc.ofc no-lock no-error.
                     if avail ofchis and ofchis.depart = v-dep then do:
                        v-email = "," + trim(ofchis.ofc) + "@elexnet.kz".
                        leave.
                     end.
                 end.*/
                 run mail ( "id00787@metrocombank.kz",
                           "METROCOMBANK <abpk@metrocombank.kz>",
                           "Извещение о закрытии условного банковского вклада",
                           "См. вложение." ,
                           "1",
                           "",
                           "izv1.html" ).
              end.
              leave.
           end. /* frame aaa aaa.sta */
        end. /*11*/ /*repeat*/
     end. /*10*/ /*aaa.sta NE "C"*/

     /*если счет гарантия, то печать отчетика*/
     if aaa.lgr = '397' or aaa.lgr = '396' or aaa.lgr = '422' or aaa.lgr = '431' or aaa.lgr = '402' or aaa.lgr = '400' or aaa.lgr = '401' or aaa.lgr = '403' or aaa.lgr = '437' or aaa.lgr = '427' then do:
        if aaa.sta = "C" then run prit_gar(aaa.aaa, 2). else run prit_gar(aaa.aaa, 3).
     end.

     find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = "clnsts" no-lock no-error.
     if (avail sub-cod and sub-cod.ccode = "0")  or aaa.lgr begins '1' or aaa.lgr = '320' or aaa.lgr = '392' or aaa.lgr = '393' or aaa.lgr = '410' or aaa.lgr = '411' or aaa.lgr = '412' or aaa.lgr = '420' or aaa.lgr = '301'    then do:
        find sysc where sysc.sysc = "ourbnk" no-lock no-error .
        if avail sysc then ourbank = sysc.chval. else ourbank = "".
        if get-dep(g-ofc, g-today) = 1 and ourbank = 'TXB00'  then  update ch_KS ch_date with frame fr_list.
        /*if aaa.sta = "C" then run prit_sch(aaa.aaa, 2).  else run prit_sch(aaa.aaa, 3).*/
     end.
  end. /*10*/

  /*leave.*/
end. /*do transaction*/
/*end.*/ /*repeat   2*/


find current aaa no-lock.

if aaa.sta = "C" then do:
   /*message "closed". pause.*/
   /*run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "проверка на наличие РПРО при закрытии счета",
            " проверка на наличие РПРО при закрытии счета " + aaa.aaa, "1", "", "").*/
   run savelog( "accmaint", " 650. " + aaa.aaa + "  Удаление РПРО").
   run insst01(aaa.aaa).
   /*run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "проверка на наличие РПРО при закрытии счета ЗАВЕРШЕНА",
            " проверка на наличие РПРО при закрытии счета " + aaa.aaa + " ЗАВЕРШЕНА", "1", "", "").*/
end.