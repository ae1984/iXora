/* create-file.p
 * MODULE
        Переводы
 * DESCRIPTION
        Переводы (выгрузка в файл)
 * RUN
        s_translat.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        .
 * AUTHOR
        18/06/05 Ilchuk
 * BASES
        BANK COMM
 * CHANGES
        15.07.05 nataly  - добавлен статус 9 - изменен перевод
        21.07.05 nataly  - добавлен вариант проводки когда валюты перевода и наличности отличаются
        22.07.05 nataly  - добавлено проставление символа кас плана
        27.07.05 nataly добавлена обработка банка по коду nmbr
        12.09.05 nataly  - для рублей задан курс покупки безнала
        27/05/08 marinav - добавление поля РНН
        28/05/08 marinav
        15/07/08 marinav - добавила условие arp.des matches "*МЕТРОЭКСПРЕСС*"
        13.01.2012 damir - добавил keyord.i
        01.02.2012 lyubov - изменила символ кассплана (200 на 100)
        07.03.2012 damir - перекомпиляция.

*/

{keyord.i} /*Переход на новые и старые форматы ордеров*/

def input parameter v-nomer as char. /* Номер перевода который необходимо отправить*/
def var v-crc as char.
def buffer b-crc for crc.

def var sum as decimal.
def var sumcom as decimal.
def var sumraz as decimal.

def var vh as char.
define var v-chk as char.
define buffer b-acheck FOR acheck.
{global.i}

def new shared var s-jh like jh.jh.
def var vdel as char initial "^".
def var vparam as char.
def var rcode as inte.
def var rdes as char.
def var outper as char.
def var outcom as char.
def var arpper as char.
def var arpcom as char.

def buffer outsysc for sysc.
find first sysc where sysc.sysc = 'sendtr' no-lock no-error.   /* Пути откуда отправляем*/
if not avail sysc then do:
    message " Не найдена запись sendtr Б SYSC ".
    pause 3.
    return.
end.

find nmbr where nmbr.code = 'translat' no-lock no-error.
find first spr_bank where spr_bank.code = nmbr.prefix no-lock no-error.
  if not avail spr_bank then do:
    message " Не найден банк отправитель перевода в таблице spr_bank!".
    pause 3.
    return.
  end.

find first translat where translat.nomer = v-nomer exclusive-lock no-error.
  if not avail translat then do:
    message " Не найден перевод: " v-nomer ", для отправки! ".
    pause 3.
    return.
  end.

find first crc where crc.crc = translat.crc no-lock no-error.
  if not avail crc then do:
    message " Не найдена валюта перевода в таблице crc!".
    pause 3.
    return.
  end.
  if crc.code = 'RUR' then  /* У нас рубли обозначаются RUR, конверчу в общепринятый стандарт*/
    v-crc = 'RUB'.
  else
    v-crc = crc.code.

  translat.send-date = today.
  translat.send-tim = time.

output to rpt.img.
put unformatted translat.nomer     "|"  /* Номер перевода */
                spr_bank.code      "|"  /* Код пункта отправки перевода */
                spr_bank.name      "|"  /* Банк/филиал из которого отправлен перевод */
                translat.fam       "|"  /* Фамилия отправителя */
                translat.name      "|"  /* Имя отправителя */
                translat.otch      "|"  /* Отчество отправителя */
                translat.type-doc  "|"  /* Документ отправителя */
                translat.series    "|"  /* Серия документа */
                translat.nom-doc   "|"  /* Номер документа */
                translat.vid-doc   "|"  /* Кем выдан документ */
                translat.dt-doc    "|"  /* Когда выдан документ */
                translat.addres    "|"  /* Адрес отправителя */
                translat.tel       "|"  /* Телефон отправителя */
                translat.rec-fam   "|"  /* Фамилия получателя */
                translat.rec-name  "|"  /* Имя получателя */
                translat.rec-otch  "|"  /* Отчество получателя */
                translat.rec-code  "|"  /* Код банка получателя */
                translat.rec-bank  "|"  /* Банк получателя */
                v-crc              "|"  /* Балюта перевода */
                translat.summa     "|"  /* Сумма перевода */
                translat.send-date "|"  /* Дата отправки перевода */
                translat.send-tim  "|"  /* Время отправки перевода */
                                  skip.
output close. pause 0.

unix value ("cat rpt.img | win2koi > " + sysc.chval + substring(translat.nomer,5,6) + "." + spr_bank.eng-code).

if translat.stat <> 9 then do:
/*транзакционная часть*/
s-jh = 0.

find outsysc where outsysc.sysc = 'outpr' no-lock no-error.
if avail outsysc then outper = outsysc.chval.


find arp where arp.gl  = integer(outper)  and arp.crc = translat.crc and arp.des matches "*МЕТРО*" and length(arp.arp) = 20 no-lock no-error.
if avail arp then arpper = arp.arp.
else do:
     message 'Не найден счет ARP по ГК ' outper  ' в валюте ' v-crc skip 'Перевод не может быть отправлен!'.
     return.
    end.
   /*валюта перевода = вал наличности*/
if translat.crc = translat.crc-cash
 then  do:
    vparam = string(translat.summa + translat.commis / 2)+ vdel + arpper  + vdel + translat.fam + " " + translat.name + " " +  translat.otch + vdel +
               translat.type-doc + " "  + translat.series +  " "  + translat.nom-doc + " от " + string(translat.dt-doc) + " выдан " + translat.vid-doc
              + vdel +  string(translat.commis / 2)  + vdel +  string(translat.crc) .

         run trxgen("uni0177", vdel, vparam, "", arpper, output rcode,output rdes, input-output s-jh).
         if rcode ne 0 then do:
           message rdes view-as alert-box title "".
           return.
         end.
      run setcsymb (s-jh, 100).
      find first jh where jh.jh = s-jh. jh.party = "MXP".
   end.
   else do:
     find b-crc where b-crc.crc = translat.crc-cash no-lock no-error.
   if translat.crc <> 4 then do:
     sum = translat.summa * crc.rate[3].
     sumcom = translat.commis * crc.rate[3] .
     sumraz = (translat.summa + translat.commis / 2) * (crc.rate[3] - crc.rate[1]).
     if sumraz < 0  then sumraz = 0.
     if crc.rate[3]  = 0
         then do:
             message 'Не задан курс продажи для ' v-crc ' !!! Отмена проводки.'. pause 3.
             return.
         end.
  end.
   else do:   /*для рублей берем курс безналичности*/
     sum = translat.summa * crc.rate[5].
     sumcom = translat.commis * crc.rate[5] .
     sumraz = (translat.summa + translat.commis / 2) * (crc.rate[5] - crc.rate[1]).
     if sumraz < 0  then sumraz = 0.
     if crc.rate[5]  = 0
         then do:
             message 'Не задан курс продажи для ' v-crc ' !!! Отмена проводки.'. pause 3.
             return.
         end.
   end.

     vparam = string(sum + sumcom / 2)+ vdel + translat.fam + " " + translat.name + " " +  translat.otch + vdel +
               translat.type-doc + " "  + translat.series +  " "  + translat.nom-doc + " от " + string(translat.dt-doc) + " выдан " + translat.vid-doc + vdel +
               string(translat.summa + translat.commis / 2) + vdel + arpper  + vdel +
               string(sumcom / 2) + vdel + string(sumraz) .
         run trxgen("uni0180", vdel, vparam, "", arpper, output rcode,output rdes, input-output s-jh).
         if rcode ne 0 then do:
           message rdes view-as alert-box title "".
           return.
         end.
      run setcsymb (s-jh, 100).
      find first jh where jh.jh = s-jh. jh.party = "MXP".
   end.
      translat.jh = s-jh.
/*run vou_bank(2).*/
{nomer.i}
translat.stat = 11. /*подтвержден менеджером*/
run platezh(translat.nomer).
end.
else do: /*translat.stat = 9*/
run mail  ("metroexport@ml01.metrobank.kz",
            "METROKOMBANK <mkb@metrokombank.kz>",
           "Kildd638Hsy728" ,
            "Перевод  См. вложение." ,
            "1", "",
           sysc.chval + substring(translat.nomer,5,6) + "." + spr_bank.eng-code  ).
translat.stat = 2. /*ОТПРАВЛЕН*/
  end.

