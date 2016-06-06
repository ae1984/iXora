/* 2ltrx.p
 * MODULE
        Платежная система
 * DESCRIPTION
        ручная генерация 2-ой проводки для входящих переводов
 * RUN
        верхнее меню 5-9-3
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        5-9-3 2ПровГен
 * AUTHOR
        31/12/99 pragma
  * BASES
        BANK COMM
 * CHANGES
        16.03.2001          - дополнено назначение платежа, разбор полочки valcon
        13.12.2001 sasco    - описание проводки берется из remtrz (вместо "... 2L ручная проводка ...")
        28.09.2002 sasco    - отправка реестров для KMobile
        21.11.2002 kanat    - добавление обработки fun счетов с полки dil.
        15.09.2003 nadejda  - добавлены вторая и третья стррки в комментарий к проводке - отправитель и ЕКНП платежа
        16.09.2003 nadejda  - создание проводки вынесено в 2ltrx.i
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        19.03.2004 isaev    - автом. пополнение карт.счетов с филиалов
        27.12.2005 nataly - для валютных переводов ФЛ добавила проверку на заполнение справочников zdcavail,zsgavail.
        29.12.2005 nataly -  2-я запись любая .
        02.05.2006 u00600 - добавила в фрейм remtrz поле valdt2
        26/05/2006 nataly добавила обработку счета TSF
	    24.06.2006 tsoy     - перекомпиляция
	    02.12.2008 galina - если необходим валютный контроль, то отправляем на полочку valcon
	    06.04.2009 galina - проверка соответствия валют при зачислении на arp или на cif счет для valcon
	    10.04.2009 galina - не зачислять на полочку valcon погашение кредитов по физ.лиц
	    06.08.2009 galina - записываем в историю платежа перенос на полочку valcon
        30/03/2010 galina - обработка для фин.мониторинга согласно ТЗ 623 от 19/02/2010
        19/04/2010 - добавила для фин.мониторинга согласно ТЗ 650 от 19/02/2010
        12/05/2010 galina - добавила пополнение счета на сумму >= 7000000 для фин.мониторинга
        24/06/2010 galina - добавила определение страны резиденства для нерезидента
        03/07/2010 galina - поправила declcparam
        15/07/2010 galina - передаем ОКПО филиала
        22/07/2010 galina - добавила парметр kfmprt_cre
        28/07/2010 galina - добавила переводы благотвор.организаций для фин.мониторинга
        08/09/2010 galina - предаем БИК филиала  для фин.мониторинга
        22/09/2010 galina - online запрос по спискам террористов
        24/09/2010 galina - поправила проверку счета при зачислении с полочки valcon
        09/11/2010 madiyar - отключаем фин. мониторинг (пока только закомментил, на всякий случай)
        01/02/2011 madiyar - поправки по фин. мониторингу
        18.05.2012 aigul - тз962 - ПОДТЯГИВАТЬ АРП СЧЕТА
        11/10/2012 Luiza - ТЗ изменение пороговых сумм c 2000000 до 6000000
        12/10/2012 madiyar - обработка статуса 2 kfmAMLOnline
        07.02.2013 evseev - tz-1633
        14/05/2013 Luiza -  ТЗ № 1838 все проверки по финмон отключаем, будут проверяться в AML
*/


{comm-txb.i}
{findstr.i}
{kfm.i "new"}
def var seltown as char.
seltown = comm-txb().
def shared var g-today as date.
def shared var g-ofc as char.
def new shared var s-jh like jh.jh .
def new shared var s-consol like jh.consol.
def new shared var vdt as date.
def shared frame remtrz.
def shared var s-remtrz like remtrz.remtrz .
def var ourbank as cha .
def var v-arp like arp.arp label "Введите номер счета/карточки ".
def var vv-arp like aaa.aaa label "Введите номер счета ".
def var l-cif as log initial true format "1-Счет/2-Карточка" label "".
def var ll-cif as log initial true format "1-Клиент/2-До выяснения" label "".
def var v-cif as cha.
def var vc-fun as char.
def var vc-tsf as char.
def var vdel as cha initial "^" .
def var vparam as cha .
def var shcode as cha .
def var rcode   as int .
def var rdes   as cha .
def var      ii         as integer init 0.
def var  rr     as char.
def var  rr1     as char.
def buffer tgl for gl.
def buffer b-rmz for remtrz.
def var acode like crc.code.
def var bcode like crc.code.
def var oldpid like que.pid .
def var prilist as cha.
def var v-text1 as character init "" .
def var tt1 as char format "x(60)".
def var tt2 as char format "x(60)".
def var vpname as char.
def var vpoint as inte.
def var vdep as inte.
def var ss as integer.
def var v-name as char.
def var v-dt as date format "99/99/99" no-undo.

def temp-table temp1
    field   crc  like crc.crc
    field   acc  like aaa.aaa.

def var v-fun like fun.fun label "Введите номер счета".
def var lll-cif as log initial true format "1-Fun/2-Карточка" label "".
def var llll-cif as log initial true format "1-Tsf/2-Карточка" label "".

def buffer sub-cod2 for sub-cod.

def var v-type as char.
{lgps.i}
{rmz.f}

/* - - - - - - - - - - - - - - - - - - - - - - - - - */

def var icnt as integer.
def var scnt as char.
def var v-vcarp as char.

define frame upa  ll-cif help "1 - Клиент  2 - До выяснения"
                  vv-arp validate(vv-arp = remtrz.racc or  lookup(vv-arp,v-vcarp) > 0, "Неверный счет!")
                         help "Нажмите F2 для выбора счета"
                  with side-label row 5 centered overlay.

define frame upa1  ll-cif help "1 - Клиент  2 - До выяснения"
                   /*vv-arp validate(vv-arp = remtrz.racc or  lookup(vv-arp,v-vcarp) > 0, "Неверный счет!")*/
                   vv-arp validate(vv-arp = temp1.acc ,"Неверный счет!")
                          help "Нажмите F2 для выбора счета"
                   with side-label row 5 centered overlay.

define frame upa2  l-cif help "1 - Cчет   2 - Карточка"
                   v-arp validate (true, "Введите верно номер счета/карточки")
                         help "Нажмите F2 для выбора счета"
                   with side-label row 5 centered overlay.

define frame upa3  lll-cif help "1 - Fun  2 - Карточка"
                   v-arp validate (true, "Введите верно номер счета Fun/карточки")
                   help "Нажмите F2 для выбора счета"
                   with side-label row 5 centered overlay.

define frame upa4  llll-cif help "1 - Tsf  2 - Карточка"
                   v-arp validate (true, "Введите верно номер счета Tsf/карточки")
                   help "Нажмите F2 для выбора счета"
                   with side-label row 5 centered overlay.

/* sasco - выбор счета по F2 */
on help of vv-arp in frame upa
do:
    icnt = 0.
    scnt = "".

    vv-arp = vv-arp:screen-value.

    icnt = icnt + 1.
    scnt = " 1) " + vv-arp.

    if l-cif then /* cif -> aaa */
    do:
       find aaa where aaa.aaa = vv-arp no-lock no-error.
       find cif where cif.cif = aaa.cif no-lock no-error.
       for each aaa where aaa.cif = cif.cif and substring(aaa.aaa,4,3) <> "140"
           and aaa.sta <> "C" and aaa.crc = remtrz.tcrc no-lock:
           if aaa.aaa <> vv-arp then
           do:
               icnt = icnt + 1.
               scnt = scnt + "|" + string (icnt, "z9") + ") " + aaa.aaa + " " + aaa.cif.
           end.
       end.
       run sel ("", scnt).
       vv-arp:screen-value = substr (entry (int(return-value), scnt, "|"), 5, 9).
    end.
    else do:
       find arp where arp.arp = vv-arp no-lock no-error.
       find cif where cif.cif = arp.cif no-lock no-error.
       for each arp where arp.cif = cif.cif and arp.crc = remtrz.tcrc no-lock:
           if arp.arp <> vv-arp then
           do:
               icnt = icnt + 1.
               scnt = scnt + "|" + string (icnt, "z9") + ") " + arp.arp  + " " + arp.cif.
           end.
       end.
       run sel ("", scnt).
       vv-arp:screen-value = substr (entry (int(return-value), scnt, "|"), 5, 9).
    end.
end.


on help of vv-arp in frame upa1
do:
    icnt = 0.
    scnt = "".

    vv-arp = vv-arp:screen-value.

    icnt = icnt + 1.
    scnt = " 1) " + vv-arp.

    if l-cif then /* cif -> aaa */
    do:
       find aaa where aaa.aaa = vv-arp no-lock no-error.
       find cif where cif.cif = aaa.cif no-lock no-error.
       for each aaa where aaa.cif = cif.cif and substring(aaa.aaa,4,3) <> "140"
           and aaa.sta <> "C" and aaa.crc = remtrz.tcrc no-lock:
           if aaa.aaa <> vv-arp then
           do:
               icnt = icnt + 1.
               scnt = scnt + "|" + string (icnt, "z9") + ") " + aaa.aaa + " " + aaa.cif.
           end.
       end.
       run sel ("", scnt).
       vv-arp:screen-value = substr (entry (int(return-value), scnt, "|"), 5, 9).
    end.
    else do:
       find arp where arp.arp = vv-arp no-lock no-error.
       find cif where cif.cif = arp.cif no-lock no-error.
       for each arp where arp.cif = cif.cif and arp.crc = remtrz.tcrc no-lock:
           if arp.arp <> vv-arp then
           do:
               icnt = icnt + 1.
               scnt = scnt + "|" + string (icnt, "z9") + ") " + arp.arp + " " + arp.cif.
           end.
       end.
       run sel ("", scnt).
       vv-arp:screen-value = substr (entry (int(return-value), scnt, "|"), 5, 9).
    end.
end.


on help of v-arp in frame upa2
do:
    icnt = 0.
    scnt = "".

    v-arp = v-arp:screen-value.

    icnt = icnt + 1.
    scnt = " 1) " + v-arp.

    if l-cif then /* cif -> aaa */
    do:
       find aaa where aaa.aaa = v-arp no-lock no-error.
       find cif where cif.cif = aaa.cif no-lock no-error.
       for each aaa where aaa.cif = cif.cif and substring(aaa.aaa,4,3) <> "140"
           and aaa.sta <> "C" and aaa.crc = remtrz.tcrc no-lock:
           if aaa.aaa <> v-arp then
           do:
               icnt = icnt + 1.
               scnt = scnt + "|" + string (icnt, "z9") + ") " + aaa.aaa + " " + aaa.cif.
           end.
       end.
       run sel ("", scnt).
       v-arp:screen-value = substr (entry (int(return-value), scnt, "|"), 5, 9).
    end.
    else do:
       find arp where arp.arp = v-arp no-lock no-error.
       find cif where cif.cif = arp.cif no-lock no-error.
       for each arp where arp.cif = cif.cif and arp.crc = remtrz.tcrc no-lock:
           if arp.arp <> v-arp then
           do:
               icnt = icnt + 1.
               scnt = scnt + "|" + string (icnt, "z9") + ") " + arp.arp + " " + arp.cif.
           end.
       end.
       run sel ("", scnt).
       v-arp:screen-value = substr (entry (int(return-value), scnt, "|"), 5, 9).
    end.
end.

on help of v-arp in frame upa3
do:
    icnt = 0.
    scnt = "".

    v-arp = v-arp:screen-value.

    icnt = icnt + 1.
    scnt = " 1) " + v-arp.

    if lll-cif then
    do:
       find fun where fun.fun = v-arp no-lock no-error.
       run sel ("", scnt).
       v-arp:screen-value = substr (entry (int(return-value), scnt, "|"), 5, 9).
    end.
    else do:
       find arp where arp.arp = v-arp no-lock no-error.
       find cif where cif.cif = arp.cif no-lock no-error.
       for each arp where arp.cif = cif.cif and arp.crc = remtrz.tcrc no-lock:
           if arp.arp <> v-arp then
           do:
               icnt = icnt + 1.
               scnt = scnt + "|" + string (icnt, "z9") + ") " + arp.arp + " " + arp.cif.
           end.
       end.
       run sel ("", scnt).
       v-arp:screen-value = substr (entry (int(return-value), scnt, "|"), 5, 9).
    end.
end.

on help of v-arp in frame upa4
do:
    icnt = 0.
    scnt = "".

    v-arp = v-arp:screen-value.

    icnt = icnt + 1.
    scnt = " 1) " + v-arp.

    if llll-cif then
    do:
       find tsf where tsf.tsf = v-arp no-lock no-error.
       run sel ("", scnt).
       v-arp:screen-value = substr (entry (int(return-value), scnt, "|"), 5, 9).
    end.
    else do:
       find arp where arp.arp = v-arp no-lock no-error.
       find cif where cif.cif = arp.cif no-lock no-error.
       for each arp where arp.cif = cif.cif and arp.crc = remtrz.tcrc no-lock:
           if arp.arp <> v-arp then
           do:
               icnt = icnt + 1.
               scnt = scnt + "|" + string (icnt, "z9") + ") " + arp.arp + " " + arp.cif.
           end.
       end.
       run sel ("", scnt).
       v-arp:screen-value = substr (entry (int(return-value), scnt, "|"), 5, 9).
    end.
end.


/* - - - - - - - - - - - - - - - - - - - - - - - - - */

find first remtrz where remtrz.remtrz = s-remtrz no-lock .

if length(remtrz.racc) = 20 and substr(remtrz.racc,19,2) = "00" then
   find first swift where swift.swift_id = int(remtrz.ref) and swift.rmz = remtrz.remtrz no-lock no-error.

if not avail swift then do:
    if remtrz.jh1 eq ? then do:
     message " 1 проводка еще не сделана ! " . pause .
     return.
    end.

    if remtrz.info[10] eq "" then do:
     message " Поле info[10] (счет ГК по Дт) в таблице remtrz не заполнено ! " .   pause .
     return.
    end.
end.
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   display " Записи OURBNK нет в таблице sysc!".
   pause.
   undo,return.
end.
ourbank = sysc.chval.

if remtrz.rbank ne ourbank  then do:
 message "  Банк-получатель не " + ourbank + "! ".  pause.
 bell. bell.
 return.
end.

if not avail swift then do:
    if remtrz.info[10] ne "" then do:
       find first jl where jl.jh = remtrz.jh1
                       and jl.gl = integer(remtrz.info[10])
                       no-lock no-error.
       if not avail jl then do:
          message " Значение поля info[10] в таблице remtrz "
          "не совпадает со счетом ГК в 1 проводке (таблица jl поле gl)! ".
          pause .
          return.
       end.
    end.
end.

if remtrz.jh2 ne ? and remtrz.jh2 ne 0 then do:
   message " 2 проводка уже сделана !". pause.
   return.
end.

/*для валютных переводов ФЛ (substr(sub-cod.rcode,5,1) = '9') проверяем заполнение справочников*/
find sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz and sub-cod.d-cod = 'eknp' no-lock no-error.
if avail sub-cod and trim(substr(sub-cod.rcode,5,1)) = '9' then do:
 if remtrz.tcrc <> 1 or remtrz.fcrc <> 1 then do:
   find sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz and  d-cod = 'zdcavail' no-lock no-error.
    if not avail sub-cod or sub-cod.ccod = 'msc' then do:
      message 'Не заполнен справочник "Наличие документа обоснования!"'  view-as  alert-box.
      undo,retry.
    end.
    if avail sub-cod and sub-cod.ccod = '2' then do:
     find sub-cod2 where sub-cod2.sub = 'rmz' and sub-cod2.acc = s-remtrz and  sub-cod2.d-cod = 'zsgavail' no-lock no-error.
      if not avail sub-cod2 or  sub-cod2.ccod = 'msc' then do:
       message 'Не заполнен справочник zsgavail!'  view-as  alert-box.
       undo,retry.
      end.
    end.
 end.
end.

do on error undo, retry :
  if remtrz.rsub = "valcon" then do.
/*
     update ll-cif help "1 - Клиент  2 - До выяснения"
            with side-label row 5 centered overlay frame upa.
*/
     find first sysc where sysc.sysc = 'VCTRAN' no-lock no-error.
     if not avail sysc then do.
       message " В таблице sysc отсутствует запись VCTRAN!" .
       pause .
       return .
     end.
     v-vcarp = sysc.chval.

     update ll-cif with frame upa.

     v-cif  = "cif" .
     if ll-cif then vv-arp = trim(remtrz.ba).
     else do.
        find first aaa where aaa.aaa = remtrz.racc no-lock no-error.
        if avail aaa then do:
            find first cif where cif.cif = aaa.cif no-lock no-error.
            if avail cif then do:
                for each arp where arp.gl = 223730 and arp.crc = aaa.crc no-lock:
                    find sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.acc = arp.arp no-lock no-error.
                    if avail sub-cod and sub-cod.ccode <> "msc" and sub-cod.rdt <= g-today then next.
                    if arp.des matches "*ЮЛ*" and cif.type = "b" then do:
                        vv-arp = arp.arp.
                        if remtrz.fcrc <> 1 then v-vcarp = arp.arp.
                        v-arp = arp.arp.
                    end.
                    if arp.des matches  "*ФЛ*" and cif.type = "p" then do:
                        vv-arp = arp.arp.
                        if remtrz.fcrc <> 1 then v-vcarp = arp.arp.
                        v-arp = arp.arp.
                    end.
                end.
            end.
        end.
        if not avail aaa then do:
            find first arp where substr(string(arp.gl),1,4) = "2870" and arp.arp =  remtrz.racc no-lock no-error.
            if avail arp then do:
                for each arp where arp.gl = 223730 and arp.crc = remtrz.fcrc no-lock:
                    find sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.acc = arp.arp no-lock no-error.
                    if avail sub-cod and sub-cod.ccode <> "msc" and sub-cod.rdt <= g-today then next.
                    find sub-cod where sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" and sub-cod.acc = remtrz.remtrz no-lock no-error.
                    if avail sub-cod and substr(sub-cod.rcode,5,1) = "9" then v-type = "p".
                    if avail sub-cod and substr(sub-cod.rcode,5,1) <> "9" then v-type = "b".
                    if arp.des matches "*ЮЛ*" and v-type = "b" then do:
                        vv-arp = arp.arp.
                        if remtrz.fcrc <> 1 then v-vcarp = arp.arp.
                        v-arp = arp.arp.
                    end.
                    if arp.des matches  "*ФЛ*" and v-type = "p" then do:
                        vv-arp = arp.arp.
                        if remtrz.fcrc <> 1 then v-vcarp = arp.arp.
                        v-arp = arp.arp.
                    end.
                end.
            end.
        end.
     end.

     update vv-arp with frame upa.

     v-arp = vv-arp.
     if ll-cif then do.   /* просмотр клиента-получателя */
        find aaa where aaa.aaa = v-arp no-lock no-error.
        if available aaa then do :
          if aaa.crc <> remtrz.tcrc then do:
             message "Валюта счета и платежа не совпадают!" .
             pause .
             return .
           end.
           find cif of aaa no-lock.
           v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
           tt1 = substring(v-name,1,60).
           tt2 = substring(v-name,61,60).
           vpname = "".
           vpoint = integer(cif.jame) / 1000 - 0.5.
           vdep = integer(cif.jame) - vpoint * 1000.
           find ppoint where ppoint.point = vpoint and ppoint.dep = vdep
                             no-lock no-error.
           if available ppoint then vpname = ppoint.name + ", ".
           find point where point.point = vpoint no-lock no-error.
           if available point then vpname = vpname + point.addr[1].
           form
               vpname format "x(60)" label "Пункт      "
               tt1                   label "Полное     "
               tt2                   label "название   "
               cif.lname             label "Сокращенное" format "x(60)"
               cif.jss               label "РНН        "  format "x(13)"
               with overlay  centered  row 5 1 column frame upp.
           disp   vpname tt1 tt2  cif.lname  cif.jss with frame upp.
           pause .
        end.
     end.
  end.
  else do.

        if remtrz.rsub = "dil" and remtrz.tcrc <> 1 then do.

           v-arp = trim(remtrz.ba).

            update lll-cif v-arp
                   with frame upa3.

            if lll-cif then vc-fun = "yes".
               else vc-fun = "no".

            if vc-fun = "yes" then do:
               find fun where fun = v-arp no-lock no-error.
               if not avail fun then do :
                  Message "Счет Fun не найден ".
                  pause. undo, retry.
               end.
            end.
            else do.
              if vc-fun = "no" then do:
                 find arp where arp.arp  = v-arp no-lock no-error .
                 if not avail arp or arp.crc ne remtrz.tcrc then do :
                    Message "Счет не найден "
                    "или валюта счета и платежа не совпадают".
                    pause. undo, retry.
                 end.
              end.
            end.
       end.

        else do.

       if remtrz.rsub = "swift" then do.
          find first sysc  where sysc.sysc = "TRACCV" no-lock no-error.
          if not avail sysc then do.
             message " В таблице sysc отсутствует запись TRACCV!" .
             pause .
             return .
          end.
          else do.
             ii = 0.
             repeat on error undo, leave:
               ii = ii + 1.
               rr = "".
               rr = entry(ii,sysc.chval) no-error.
               if rr = "" or rr = ? then leave.
               if ii modulo 2 ne 0 then do.
                  create temp1.
                  temp1.crc = integer(rr).
                  rr1 =rr.
               end.
               else do.
                 find first temp1 where temp1.crc = integer(rr1)
                                  no-lock no-error.
                 if avail temp1 then temp1.acc = rr.
               end.
             end.
          end.
          find first temp1 where temp1.crc = remtrz.tcrc no-lock no-error.
          if avail temp1 then v-arp = temp1.acc.
          else do.
             message " В таблице sysc в записи TRACCV "
             "не описан счет для валюты!" .
             pause .
             return .
          end.
          find first aaa where aaa.aaa = v-arp no-lock no-error.
          if not avail aaa then do.
             find first arp where arp.arp = v-arp
                            no-lock no-error.
             if avail arp then do.
                vv-arp = arp.arp.
                v-cif = "arp".
             end.
             else do.
                message " Не найден счет из переменной TRACCV!" .
                pause .
                return .
             end.
          end.
          else do.
               vv-arp = aaa.aaa.
               v-cif  = "cif".
          end.
          ll-cif = false.
          update ll-cif vv-arp with frame upa1.
          v-arp = vv-arp.

       end. /*swift*/
        else if remtrz.rsub = "tsf" then do.

           v-cif = "tsf".
           v-arp = trim(remtrz.ba).

            update llll-cif v-arp
                   with frame upa4.

            if llll-cif then vc-tsf = "yes".
               else vc-tsf = "no".

            if vc-tsf = "yes" then do:
               find tsf where tsf.tsf = v-arp no-lock no-error.
               if not avail tsf then do :
                  Message "Счет Tsf не найден ".
                  pause. undo, retry.
               end.
            end.
            else do.
              if vc-fun = "no" then do:
                 find arp where arp.arp  = v-arp no-lock no-error .
                 if not avail arp or arp.crc ne remtrz.tcrc then do :
                    Message "Счет не найден "
                    "или валюта счета и платежа не совпадают".
                    pause. undo, retry.
           end.
          end.
         end.
        end.  /*tsf*/
       else do.
            update l-cif with frame upa2.
            if l-cif = no and (remtrz.rsub = "arp"  or remtrz.rsub = "valcon") then do:
                find first aaa where aaa.aaa = remtrz.racc no-lock no-error.
                if avail aaa then do:
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    if avail cif then do:
                        for each arp where arp.gl = 223730 and arp.crc = aaa.crc no-lock:
                            find sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.acc = arp.arp no-lock no-error.
                            if avail sub-cod and sub-cod.ccode <> "msc" and sub-cod.rdt <= g-today then next.
                            if arp.des matches "*ЮЛ*" and cif.type = "b" then do:
                                vv-arp = arp.arp.
                                v-arp = arp.arp.
                                if remtrz.fcrc <> 1 then v-vcarp = arp.arp.
                            end.
                            if arp.des matches  "*ФЛ*" and cif.type = "p" then do:
                                vv-arp = arp.arp.
                                v-arp = arp.arp.
                                if remtrz.fcrc <> 1 then v-vcarp = arp.arp.
                            end.
                        end.
                    end.
                end.
                if not avail aaa then do:
            find first arp where substr(string(arp.gl),1,4) = "2870" and arp.arp =  remtrz.racc no-lock no-error.
            if avail arp then do:
                for each arp where arp.gl = 223730 and arp.crc = remtrz.fcrc no-lock:
                    find sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.acc = arp.arp no-lock no-error.
                    if avail sub-cod and sub-cod.ccode <> "msc" and sub-cod.rdt <= g-today then next.
                    find sub-cod where sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" and sub-cod.acc = remtrz.remtrz no-lock no-error.
                    if avail sub-cod and substr(sub-cod.rcode,5,1) = "9" then v-type = "p".
                    if avail sub-cod and substr(sub-cod.rcode,5,1) <> "9" then v-type = "b".
                    if arp.des matches "*ЮЛ*" and v-type = "b" then do:
                        vv-arp = arp.arp.
                        if remtrz.fcrc <> 1 then v-vcarp = arp.arp.
                        v-arp = arp.arp.
                    end.
                    if arp.des matches  "*ФЛ*" and v-type = "p" then do:
                        vv-arp = arp.arp.
                        if remtrz.fcrc <> 1 then v-vcarp = arp.arp.
                        v-arp = arp.arp.
                    end.
                end.
            end.
        end.
            end.
            if l-cif = yes then v-arp = trim(remtrz.ba).
            update l-cif v-arp
                   with frame upa2.
/*
            update l-cif help "1 - Cчет   2 - Карточка "
                   v-arp validate (true, "Введите верно номер счета/карточки")
                   with side-label row 5 centered overlay frame upa2.
*/
            if l-cif then v-cif = "cif" .
               else v-cif = "arp" .
            if v-cif = "arp" then do:
               find arp where arp.arp = v-arp no-lock no-error .
               if not avail arp or arp.crc ne remtrz.tcrc then do :
                  Message "Карточка не найдена "
                  "или валюта карточки и платежа не совпадают".
                  pause. undo, retry.
               end.
            end.
            else
              if v-cif = "cif" then do:
                 find aaa where aaa.aaa  = v-arp no-lock no-error .
                 if not avail aaa or aaa.crc ne remtrz.tcrc then do :
                    Message "Счет не найден "
                    "или валюта счета и платежа не совпадают".
                    pause. undo, retry.
                 end.
              end.
            end.
        end.
        end.
end.

/*galina 18/11/2008*/

if remtrz.rsub <> "valcon" and remtrz.rsub <> "dil" and remtrz.rsub <> "vcon" and (ll-cif = true and l-cif = true) then do:
  find sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz and sub-cod.d-cod = 'eknp' no-lock no-error.
  if substr(sub-cod.rcode,1,1) = "2" or substr(sub-cod.rcode,4,1)= "2" then do transaction:
    find current remtrz exclusive-lock.
    remtrz.rsub = "valcon".
    find current remtrz no-lock.
    message "Платеж подлежит валюному контролю.~n Отправлен на полочку valcon." view-as alert-box title "Внимание".
    v-text = "Платеж подлежит валюному контролю." + trim(remtrz.remtrz) + " Отправлен на полочку valcon." + g-ofc.
    run lgps.
    return.
  end.
  if substr(sub-cod.rcode,1,1) = "1" and substr(sub-cod.rcode,4,1)= "1" then do:
    if remtrz.fcrc <> 1 then do transaction:
      if (substr(sub-cod.rcode,2,1) = "9" and substr(sub-cod.rcode,5,1) = "9" and substr(sub-cod.rcode,7,3) <> '423' and  substr(sub-cod.rcode,7,3) <> '421') or (substr(sub-cod.rcode,2,1) <> "9" or substr(sub-cod.rcode,5,1) <> "9")  then do:
        find current remtrz exclusive-lock.
        remtrz.rsub = "valcon".
        find current remtrz no-lock.
        message "Платеж подлежит валюному контролю.~n Отправлен на полочку valcon." view-as alert-box title "Внимание".
        v-text = "Платеж подлежит валюному контролю." + trim(remtrz.remtrz) + " Отправлен на полочку valcon." + g-ofc.
        run lgps.
        return.
      end.
    end.
  end.
end.

/*galina фин.мониторинг*/
def var v-monamt as deci no-undo.
def var v-monamt2 as deci no-undo.
def var v-str as char no-undo.
def var v-kfm as logi no-undo init no.
def var v-kfm1 as logi no-undo init no.
def var v-kfm2 as logi no-undo init no.
def var v-kfm3 as logi no-undo init no.
def var v-kfm4 as logi no-undo init no.
def var v-kfm5 as logi no-undo init no.
def var v-kfm6 as logi no-undo init no.
def var v-kfm7 as logi no-undo init no.
def var v-kfm8 as logi no-undo init no.
def var v-kfm9 as logi no-undo init no.
def var v-kfm10 as logi no-undo init no.
def var v-kfm11 as logi no-undo init no.
def var v-kfm12 as logi no-undo init no.
def var v-kfm13 as logi no-undo init no.
def var v-kfmrem as char no-undo.
def var v-oper as char no-undo.
def var v-cltype as char no-undo.
def var v-res as char no-undo.
def var v-res2 as char no-undo.
def var v-FIO1U as char no-undo.
def var v-publicf  as char no-undo.
def var v-OKED as char no-undo.
def var v-clnameF as char no-undo.
def var v-clnameU as char no-undo.
def var v-prtUD as char no-undo.
def var v-prtUdN as char no-undo.
def var v-prtUdIs as char no-undo.
def var v-prtUdDt as char no-undo.
def var v-opSumKZT as char no-undo.
def var v-num as inte no-undo.
def var k as inte no-undo.
def var v-operId as integer no-undo.
def var v-bdt as char no-undo.
def var v-bplace as char no-undo.
def var v-prtEmail as char no-undo.
def var v-prtFLNam as char no-undo.
def var v-prtFFNam as char no-undo.
def var v-prtFMNam as char no-undo.
def var v-prtOKPO  as char no-undo.
def var v-prtPhone as char no-undo.
def var v-mess as integer no-undo.
def var v-rnn as char no-undo.
def var v-addr as char no-undo.
def buffer b-remtrz for remtrz.
def var v-country2 as char.

/*запрос на терроризм*/
    /*проверка бенефициара на терроризм*/

def var v-senderNameList as char.
def var v-benNameList as char.
def var v-benCountry as char.
def var v-benName as char.
def var v-senderCountry as char.
def var v-senderName as char.
def var v-pttype as integer.
def var v-errorDes as char.
def var v-operIdOnline as char.
def var v-operStatus as char.
def var v-operComment as char.


/*****проверка на список террористов******/
    v-benCountry  = ''.
    v-benName = ''.
    v-senderCountry = ''.
    v-senderName = ''.
    v-benNameList = ''.
    v-senderNameList = ''.
    v-errorDes = ''.
    v-operIdOnline = ''.
    v-operStatus = ''.
    v-operComment = ''.
    v-prtFLNam = ''.
    v-prtFFNam = ''.
    v-prtFMNam = ''.

    find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "iso3166" use-index dcod no-lock no-error .
    if avail sub-cod and sub-cod.ccode <> 'msc' then v-senderCountry = sub-cod.ccode.


    v-senderName = entry(1,trim(remtrz.ord),'/').
    find first aaa where aaa.aaa = remtrz.racc no-lock no-error.
    /*тут добавим учредителей ЮЛ*/
    if avail aaa then do:
        find first cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then do:
            if cif.type = 'B' then do:
                v-benNameList = ''.

               if cif.cgr <> 403 then do:
                   for each founder where founder.cif = cif.cif no-lock:
                       if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
                       if founder.ftype = 'B' then v-benNameList = v-benNameList + founder.name.
                       if founder.ftype = 'P' then v-benNameList = v-benNameList + trim(founder.sname) + ' ' + trim(founder.fname) + ' ' + trim(founder.mname).
                   end.
               end.
               if cif.cgr = 403 then do:
                   find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error.
                   if avail sub-cod and sub-cod.ccode <> 'msc' then do:
                       if num-entries(sub-cod.rcode,' ') > 0 then v-prtFLNam = entry(1,trim(sub-cod.rcode),' ').
                       if num-entries(sub-cod.rcode,' ') >= 2 then v-prtFFNam = entry(2,trim(sub-cod.rcode),' ').
                       if num-entries(sub-cod.rcode,' ') >= 3 then v-prtFMNam = entry(3,trim(sub-cod.rcode),' ').
                   end.
                   if v-prtFLNam <> '' then do:
                       if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
                       v-benNameList = v-benNameList + v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
                   end.
               end.

               if v-benNameList <> '' then v-benNameList = v-benNameList + '|'.
            end.
            if cif.cgr <> 403 then v-benName = trim(cif.prefix) + ' ' + trim(cif.name).
            if cif.type = 'P' then v-benName = v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
            if cif.cgr <> 403 then v-benName = trim(cif.prefix) + ' ' + trim(cif.name).

        end.
    end.
    else v-benName = entry(1,trim(trim(remtrz.bn[1]) + ' ' + trim(remtrz.bn[2])),'/').
    if trim(v-benName + v-benCountry + v-senderCountry + v-senderName) <> '' then do:
        if trim(v-senderCountry) <> '' then do:
            find first code-st where code-st.code = v-senderCountry no-lock no-error.
            if avail code-st then v-senderCountry = code-st.cod-ch.
        end.
        find first pksysc where pksysc.sysc = 'kfmOn' no-lock no-error.
        if avail pksysc and pksysc.loval then do:
            display "" skip(2) "          ПОДОЖДИТЕ" skip "    ИДЕТ ПРОВЕРКА КЛИЕНТА     " skip(2) "" with frame f1 centered overlay row 10 title 'ВНИМАНИЕ'.
            run kfmAMLOnline(remtrz.remtrz,
                              v-benCountry,
                              v-benName,
                              v-benNameList,
                              '1',
                              '1',
                              v-senderCountry,
                              v-senderName,
                              v-senderNameList,
                              output v-errorDes,
                              output v-operIdOnline,
                              output v-operStatus,
                              output v-operComment).

            hide frame f1 no-pause.
            if trim(v-errorDes) <> '' then do:
                message "Ошибка!~n" + v-errorDes + "~nПри необходимости обратитесь в ДИТ" view-as alert-box title 'ВНИМАНИЕ'.
                return.
            end.
            if v-operStatus = '0' then do:
                run kfmOnlineMail(remtrz.remtrz).
                message "Операция приостановлена для анализа! Обратитесь в службу Комплаенс" view-as alert-box title 'ВНИМАНИЕ'.
                return.
            end.
            if v-operStatus = '2' then do:
                run kfmOnlineMail(remtrz.remtrz).
                message "Проведение операции запрещено! Обратитесь в службу Комплаенс" view-as alert-box title 'ВНИМАНИЕ'.
                return.
            end.
        end.
    end.


find first aaa where aaa.aaa = remtrz.racc no-lock no-error.
/*if avail aaa then do:
    k = 0.
    find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
    if avail sub-cod then do:

        if remtrz.fcrc = 1 then v-monamt = remtrz.amt.
        else do:
            find first crc where crc.crc = remtrz.fcrc no-lock no-error.
            v-monamt = remtrz.amt * crc.rate[1].
        end.

        v-str = remtrz.detpay[1] + ' ' + remtrz.detpay[2] + ' ' + remtrz.detpay[3] + ' ' + remtrz.detpay[4].

        if entry(3,sub-cod.rcode) = '119' then do:
            if v-monamt >= 6000000 then do:
                 if checkkey2(v-str,'kfmkey') = yes then do:
                     k = k + 1.
                     v-kfm3 = yes.
                     if not v-kfm1 and not v-kfm2 then message "Поступления от другого лица на безвозмездной основе ~nсуммой >= 6000000 тенге подлежат финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.
                 end.
            end.
        end.
    end.
end.


if v-kfm1 or v-kfm2 or v-kfm3 or v-kfm4 or v-kfm5 or v-kfm6 or v-kfm7 or v-kfm8 or v-kfm9 or v-kfm10 or v-kfm11 or v-kfm12 or v-kfm13 then do:
   if v-kfm1 then v-oper = '06'.
   if not v-kfm1 and v-kfm2 then v-oper = '11'.
   if not v-kfm1 and not v-kfm2 and v-kfm3 then  v-oper = '09'.
   if not v-kfm1 and not v-kfm2 and v-kfm4 then  v-oper = '16'.
   if not v-kfm1 and not v-kfm2 and v-kfm5 then  v-oper = '01'.
   if v-kfm6 then v-oper = '14'.
   if not v-kfm2 and v-kfm7 then  v-oper = '13'.
   if not v-kfm1 and not v-kfm2 and v-kfm8 then  v-oper = '17'.
   if not v-kfm1 and not v-kfm2 and v-kfm9 then  v-oper = '18'.
   if not v-kfm1 and not v-kfm2 and v-kfm10 then  v-oper = '19'.
   if not v-kfm1 and not v-kfm2 and v-kfm11 then  v-oper = '10'.
   if not v-kfm1 and not v-kfm2 and v-kfm12 then  v-oper = '05'.
   if not v-kfm1 and not v-kfm2 and not v-kfm3 and not v-kfm4 and not v-kfm12 and v-kfm13 then v-oper = '09'.
   v-kfmrem = ''.
   if k >= 2 then v-kfmrem = 'Имеется дополнительный признак для фин. мониторинга!'.

   run fm1.
   if not kfmres then return.
   if v-kfm then run kfmcopy(v-operId,remtrz.remtrz,'fm',0).
end.*/


if keyfunction(lastkey) ne "end-error"
then do trans :
   find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
   find first que of remtrz exclusive-lock no-error.

   if vc-fun = "yes" and remtrz.rsub = "dil" and remtrz.tcrc <> 1 then do:
     remtrz.rsub = "fun".
     v-cif = "fun".
   end.

   if vc-fun = "no" and remtrz.rsub = "dil" and remtrz.tcrc <> 1 then do:
     v-cif = "arp".
   end.

   if length(remtrz.racc) = 20 and substr(remtrz.racc,19,2) = "00" then
      find first swift where swift.swift_id = int(remtrz.ref) and swift.rmz = remtrz.remtrz  no-lock no-error.
   if not avail swift then do:
       def var my-name as char init "2ltrx.p".
       {2ltrx.i
                " if remtrz.rsub = 'valcon' or remtrz.rsub = 'swift' then remtrz.rsub = 'vcon'.
                  else if (remtrz.rsub <> 'x-name' and remtrz.rsub <> 'x-pref') then remtrz.rsub = v-cif. "

                " display remtrz.jh2 remtrz.valdt2 remtrz.rsub with frame remtrz. pause 0. "
        }                   /*02.05.2006 u00600 remtrz.valdt2*/
   end. else do transaction:
        run savelog('2ltrx', '964. ' + remtrz.remtrz   ).
        find first b-rmz where b-rmz.remtrz = remtrz.remtrz exclusive-lock no-error.
        if avail b-rmz then do :
            vparam = remtrz.remtrz      + vdel +
                      string(remtrz.amt) + vdel +
                      remtrz.sacc + vdel + remtrz.racc + vdel +
                      remtrz.remtrz + " " + replace(
                      trim(remtrz.detpay[1]) +
                      trim(remtrz.detpay[2]) +
                      trim(remtrz.detpay[3]) +
                      trim(remtrz.detpay[4]) +
                      substr(remtrz.ord,1,35) +
                      substr(remtrz.ord,36,70) +
                      substr(remtrz.ord,71),"^"," ") .
            shcode = "PSY0048".
            if remtrz.jh2 ne ? and remtrz.jh2 ne 0 then do:
               message " 2 проводка уже сделана !" . pause .
               return .
            end.


            run trxgen(shcode,vdel,vparam,"rmz",remtrz.remtrz,output rcode,output rdes,input-output s-jh).
            run savelog('2ltrx', '985. ' + remtrz.remtrz  + ' ' + string(s-jh) ).
            if rcode ne 0 then do :
               v-text = " Ошибка 2 проводки rcode = " + string(rcode) + ":" +
                        rdes + " " + remtrz.remtrz + " " + remtrz.dracc .
               message v-text . pause .
               return.
            end.
            b-rmz.jh1  = s-jh.
            b-rmz.jh2  = s-jh.
            v-dt = remtrz.valdt2.
            if remtrz.valdt2 <> g-today then b-rmz.valdt2 = g-today.
            if v-dt = remtrz.valdt2 then v-text = "2 TRX сделана вручную " + trim(remtrz.remtrz).
            else v-text = "2 TRX сделана вручную и 2-я дата валютирования изменена " + trim(remtrz.remtrz).

            run lgps.
            v-text = "1 TRX = 2 TRX ".
            run lgps.
             run savelog('2ltrx', '1002. ' + remtrz.remtrz  + ' ' + string(s-jh) ).
             que.pid = "F".
        end.
        find current b-rmz no-lock no-error.
   end.
end.


/*данные по клиенту*/
procedure defclparam.

  v-cltype = ''.
  v-res = ''.
  v-res2 = ''.
  v-publicf = ''.
  v-FIO1U = ''.
  v-OKED = ''.
  v-prtOKPO = ''.
  v-prtEmail = ''.
  v-prtPhone = ''.
  v-prtFLNam = ''.
  v-prtFFNam = ''.
  v-prtFMNam = ''.

  v-clnameU = ''.
  v-prtUD = ''.
  v-prtUdN = ''.
  v-prtUdIs = ''.
  v-prtUdDt = ''.
  v-bdt = ''.
  v-bplace = ''.

  if cif.type = 'B' then do:
     if cif.cgr <> 403 then v-cltype = '01'.
     if cif.cgr = 403 then v-cltype = '03'.
  end.
  else v-cltype = '02'.

  if cif.geo = '021' then do:
   v-res2 = '1'.
   v-res = 'KZ'.
  end.
  else do:
    v-res2 = '0'.
    if num-entries(cif.addr[1]) = 7 then do:
        v-country2 = entry(1,cif.addr[1]).
        if num-entries(v-country2,'(') = 2 then v-res = substr(entry(2,v-country2,'('),1,2).
    end.
  end.

  find first cif-mail where cif-mail.cif = cif.cif no-lock no-error.
  if avail cif-mail then v-prtEmail = cif-mail.mail.
  v-prtPhone = cif.tel.

  if v-cltype = '01' then v-clnameU = trim(cif.prefix) + ' ' + trim(cif.name).
  else v-clnameU = ''.

  if v-cltype = '02' or v-cltype = '03' then do:
      if v-cltype = '02' then do:
          if num-entries(trim(cif.name),' ') > 0 then v-prtFLNam = entry(1,trim(cif.name),' ').
          if num-entries(trim(cif.name),' ') >= 2 then v-prtFFNam = entry(2,trim(cif.name),' ').
          if num-entries(trim(cif.name),' ') >= 3 then v-prtFMNam = entry(3,trim(cif.name),' ').
      end.
      else do:
          find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error.
          if avail sub-cod and sub-cod.ccode <> 'msc' then do:
              if num-entries(trim(sub-cod.rcode),' ') > 0 then v-prtFLNam = entry(1,trim(sub-cod.rcode),' ').
              if num-entries(trim(sub-cod.rcode),' ') >= 2 then v-prtFFNam = entry(2,trim(sub-cod.rcode),' ').
              if num-entries(trim(sub-cod.rcode),' ') >= 3 then v-prtFMNam = entry(3,trim(sub-cod.rcode),' ').
          end.
      end.

      if cif.geo = '021' then v-prtUD = '01'.
      else v-prtUD = '11'.

      if num-entries(cif.pss,' ') > 1 then v-prtUdN = entry(1,cif.pss,' ').
      else v-prtUdN = cif.pss.

      if num-entries(cif.pss,' ') >= 2 then v-prtUdDt = entry(2,cif.pss,' ').
      if num-entries(cif.pss,' ') >= 3 then v-prtUdIs = entry(3,cif.pss,' ').
      if num-entries(cif.pss,' ') > 3 then v-prtUdIs = entry(3,cif.pss,' ') + ' ' + entry(4,cif.pss,' ').

      find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "publicf" use-index dcod no-lock no-error .
      if avail sub-cod and sub-cod.ccode <> 'msc' then v-publicf = sub-cod.ccode.

      v-bdt = string(cif.expdt,'99/99/9999').
      v-bplace = cif.bplace.
  end.
  find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error .
  if avail sub-cod and sub-cod.ccode <> 'msc' then v-FIO1U = sub-cod.rcode.


  find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "ecdivis" use-index dcod no-lock no-error .
  if avail sub-cod and sub-cod.ccode <> 'msc' then v-OKED = sub-cod.ccode.
end procedure.

procedure deffilial.
     v-cltype = '01'.
     v-res = 'KZ'.
     v-res2 = '1'.

     find first codfr where codfr.codfr = 'DKPODP' and codfr.code = '1' no-lock no-error.
     if avail codfr then v-FIO1U = codfr.name[1].

     v-OKED = '65'.
     /*пока пустое, т.к. у филиала 12-значный ОКПО cmp.addr[3]*/
     v-prtOKPO = cmp.addr[3].

     find first cmp no-lock no-error.
     v-prtPhone = cmp.tel.
     v-rnn = cmp.addr[2].
     v-addr = cmp.addr[1].

     find sysc where sysc.sysc = "bnkadr" no-lock no-error.
     if avail sysc then do:
        v-prtEmail = entry(5, sysc.chval, "|") no-error.
        v-addr = v-addr + ',' + entry(1, sysc.chval, "|") no-error.
     end.

     find first sysc where sysc.sysc = 'CLECOD' no-lock no-error.

end procedure.


/*заполняем форму для фин.мониторинга*/
procedure fm1.

  def var v-knp as char.
  def var v-resben as char.
  def var v-resbenC as char.
  def var v-resben2 as char.
  def var v-scbank as char.
  def var v-scbankbik as char.
  def var v-sendnameU  as char no-undo.
  def var v-sendnameF  as char no-undo.
  def var v-sendFAM as char no-undo.
  def var v-sendNAM as char no-undo.
  def var v-sendM as char no-undo.
  def var v-sendrnn as char no-undo.
  def var v-sendtype as char no-undo.
  def var v-sumkzt as char no-undo.
  def var v-sbankname as char no-undo.



  find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(remtrz.fcrc) no-lock no-error.
  v-sendFAM = ''.
  v-sendNAM = ''.
  v-sendM = ''.
  v-sendnameU = ''.
  v-sendnameF = ''.
  find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
  if avail sub-cod and substr(entry(1,sub-cod.rcode),2,1) <> '9' then do:
    if num-entries(remtrz.ord,'/') > 1 then v-sendnameU = trim(entry(1,remtrz.ord,'/')).
    v-sendtype = '01'.
  end.
  if avail sub-cod and substr(entry(1,sub-cod.rcode),2,1) = '9' then do:
    v-sendtype = '02'.
    if num-entries(remtrz.ord,'/') > 1 then v-sendnameF = trim(entry(1,remtrz.ord,'/')).
    if num-entries(v-sendnameF) > 0 then v-sendFAM = entry(1,v-sendnameF).
    if num-entries(v-sendnameF) >= 2 then v-sendNAM = entry(2,v-sendnameF).
    if num-entries(v-sendnameF) >= 3 then v-sendM = entry(3,v-sendnameF).
  end.
  if avail sub-cod then v-knp = entry(3,sub-cod.rcode).
  if avail sub-cod then do:
    if substr(entry(1,sub-cod.rcode),1,1) <> '1' then v-resben2 = '0'.
    if substr(entry(1,sub-cod.rcode),1,1) = '1' then v-resben2 = '1'.
  end.
  if v-resben2 = '1' then v-resbenC = 'KZ'.
  v-sumkzt = ''.
  if remtrz.fcrc <> 1 then do:
    find first crc where crc.crc = remtrz.fcr no-lock no-error.
    v-sumkzt = trim(string(remtrz.amt * crc.rate[1],'>>>>>>>>>>>>9.99')).
  end.

  run kfmoperh_cre('01','01',remtrz.remtrz,v-oper,v-knp,'2',codfr.code,trim(string(remtrz.amt,'>>>>>>>>>>>>9.99')),v-sumkzt,'','','','','','','','',v-kfmrem, output v-operId).

  v-num = 0.

  find first aaa where aaa.aaa = remtrz.racc no-lock no-error.
  if avail aaa then do:
     find first cif where cif.cif = aaa.cif no-lock no-error.
     run defclparam.

     find first cmp no-lock no-error.
     find first sysc where sysc.sysc = 'CLECOD' no-lock no-error.

     v-num = v-num + 1.

     run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',remtrz.racc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','02').
  end.
  else do:
     find first arp where arp.arp = remtrz.racc no-lock no-error.
     if avail arp then do:
         find first cmp no-lock no-error.
         find first sysc where sysc.sysc = 'CLECOD' no-lock no-error.

         run deffilial.
         v-num = v-num + 1.

         run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'01','','','',cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,'','','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','','02').
     end.
  end.


  v-num = v-num + 1.

  find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "iso3166" use-index dcod no-lock no-error .
  if avail sub-cod and sub-cod.ccode <> 'msc' then  v-resben = sub-cod.ccode.

  v-scbank = ''.
  find first bankl where bankl.bank = remtrz.scbank no-lock no-error.
  if avail bankl then v-scbank = trim(bankl.name).
  v-scbankbik = ''.
  if remtrz.scbank matches "TXB*" then do:
     find first txb where txb.consolid and txb.bank = remtrz.scbank no-lock no-error.
     if avail txb then v-scbankbik = txb.mfo.
  end.
  v-scbankbik = remtrz.scbank.
  find first bankl where bankl.bank = remtrz.scbank no-lock no-error.
  if avail bankl then v-sbankname = trim(bankl.name).
  if num-entries(remtrz.ord,'/') >= 3 then v-sendrnn = entry(3,remtrz.ord,'/').


  run kfmprt_cre(v-operId,v-num,'01','01','57',v-resben2,v-resbenC,v-sendtype,'','',remtrz.sacc,v-sbankname,remtrz.sbank,v-resben,remtrz.dracc,v-scbank,v-scbankbik,'',v-sendnameU,'',v-sendrnn,'','','',v-sendFAM,v-sendNAM,v-sendM,'','','','','','','','','','','','','01').

  run kfmoper_cre(v-operId).
  v-kfm = yes.

end procedure.
