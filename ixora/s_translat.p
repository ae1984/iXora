/* s_translat.p
 * MODULE
        Переводы
 * DESCRIPTION
        Переводы
 * RUN
        translat.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        .
 * BASES
        BANK COMM
 * AUTHOR
        16.06.2005 Ilchuk
 * CHANGES
        19.07.05 nataly было добавлено release translat.
        20.07.05 nataly была добавлена проверка на ЕКНП
        21.07.05 nataly добавлен код валюты внесения наличности
        23/12/05 nataly убрала ограничение на 10 000 USD
        13.01.06 nataly добавила проверку справочника zdcavail, zsgavail.
        27/05/08 marinav - добавление поля РНН
        28/05/08 marinav
        14/07/08 marinav - ограничение на сумму ( не > 10000)
        16/11/2009 madiyar - подправил расчет суммы переводов по клиенту за сегодня
        02/07/2010 galina - добавила поле kfmcif для Фин.Мониторинга
        03/07/2010 galina - добавила exclusive-lock no-lock для таблицы translat
                            выводим запрос доп.информации только по переводом со статусом 1
        15/07/2010 galina - запрос дополнительной информации до проводки
*/


def input parameter podtv as logical.
def var vrate as decimal extent 3.
def var v-name as char.
def var v-crc as integer.
def var v-summa as deci.
def buffer b-translat for translat.
def var v-code as integer.
/**/
def var v-kfmcif as char no-undo.
def var v-fam as char no-undo.
def var v-name2 as char no-undo.
def var v-mname as char no-undo.
def var v-rnn as char no-undo.
def var v-numreg as char no-undo.
def var v-dtreg as date no-undo.
def var v-orgreg as char no-undo.
def var v-dtbth as date no-undo.
def var v-bplace as char no-undo.
def var v-res as char no-undo.
def var v-country as char no-undo.
def var v-clfam2 as char no-undo.
def var v-clname2 as char no-undo.
def var v-clmname2 as char no-undo.
def var v-addr as char no-undo.
def var v-tel as char no-undo.
def var v-public as char no-undo.
def var v-doctyp as char no-undo.

def new shared var v-dopres as logi init no.

{mainhead.i}
{opr-stat.i}

{sisn.i
    &head = "translat"
    &headkey = "nomer"
    &option = "TRANSL"
    &start = " "
    &end = " "
    &noedt = "false"
    &nodel = "false"
    &variable = " "
    &aftersub = " "

    &no-update = "
       /* if  translat.stat > 1 then do:
            message 'Перевод отправлен, редактирование невозможно.'.
            pause 3.
            next.
        end.*/ "


    &update = "
        if podtv = false then do:
          if translat.stat < 2 then do:
             run update. /* Редактирование возможно только до отправки */
           end.
         else message 'Редактирование невозможно, тк перевод имеет статус ""' opr-stat(translat.stat) '"" !'
                        view-as alert-box.
        end.
        if podtv = true then do:
          if translat.stat = 1 then do:
            v-ans = true.
            message ' Отправить перевод?' view-as alert-box buttons yes-no title 'Внимание!' update v-ans.
            if v-ans = true then do:
               run check-sprav(output v-code).
               /*if v-code = 0 then run create-file(translat.nomer).*/

           end.
          end.
             else message 'Перевод не может быть отправлен, тк имеет статус ""' opr-stat(translat.stat) '"" !'
                view-as alert-box.
        end.


    "
    &postupdate = " run kfmcif. if v-dopres and podtv = true and translat.stat = 1 and v-ans = true and v-code = 0 then run create-file(translat.nomer). "
    &no-delete = "

    "
    &delete = "
                if  translat.stat < 2 then   do transaction:
                    find current translat exclusive-lock.
                    delete translat.
                end.
                else  message 'Удаление невозможно, тк перевод имеет статус ""' opr-stat(translat.stat) '"" !'
                   view-as alert-box.


              "



    &predisplay = " find first crc where crc.crc = translat.crc no-lock no-error.
                    v-stat = opr-stat(translat.stat).
                    if translat.tim <> 0 then
                      v-tim  = STRING(translat.tim, 'hh:mm:ss').
                    if translat.send-tim <> 0 then
                      v-send-tim = STRING(translat.send-tim, 'hh:mm:ss').
                    if translat.tim-dostav <> 0 then
                      v-tim-dostav = STRING(translat.tim-dostav, 'hh:mm:ss').
                    if translat.tim-vidach <> 0 then
                      v-tim-vidach = STRING(translat.tim-vidach, 'hh:mm:ss').
                    find first codfr where codfr.codfr = 'iso3166' and codfr.code = translat.cod-country no-lock no-error.

    "

    &display = "
     displ translat.nomer translat.jh v-stat translat.fam translat.name translat.otch translat.resident translat.type-doc translat.cod-country translat.series translat.nom-doc
          translat.vid-doc translat.dt-doc translat.rnn translat.addres translat.tel translat.crc translat.summa translat.commis
          translat.rec-fam translat.rec-name translat.rec-otch translat.rec-code translat.rec-bank
          (if avail crc then crc.code else '') @ v-name-val
          (if avail codfr then codfr.name[2] else '') @ v-name-cou
          translat.date v-tim translat.send-date v-send-tim translat.who
          translat.dt-dostav v-tim-dostav translat.dt-vidach v-tim-vidach
          with frame translat.
    "
    &postdisplay = "  "
}
procedure check-sprav.
def output parameter v-code as integer .

            find sub-cod where sub ='trl' and acc = translat.nomer and d-cod = 'eknp'no-lock   no-error  .
            if (avail  sub-cod  and sub-cod.ccode = 'msc') or not  avail sub-cod  then
             do:
               message 'Не заполнен справочник ЕКНП!!! Отправка перевода невозможна!'.
               pause 3.  v-code = 1.
                return .
             end.

            find sub-cod where sub-cod.sub ='trl' and sub-cod.acc = translat.nomer and d-cod = 'zdcavail' no-lock   no-error  .
            if (avail  sub-cod  and sub-cod.ccode = 'msc') or not  avail sub-cod  then
             do:
               message 'Не заполнен справочник Наличия док-та основания!!! Отправка перевода невозможна!'.
               pause 3. v-code = 1.
                return .
             end.

            find sub-cod where sub ='trl' and sub-cod.acc = translat.nomer and d-cod =  'zsgavail' no-lock   no-error  .
            if (avail  sub-cod  and sub-cod.ccode = 'msc') or not  avail sub-cod  then
             do:
               message 'Не заполнен справочник zsgavail!!! Отправка перевода невозможна!'.
               pause 3. v-code = 1.
                return .
             end.
                v-code = 0.

end.

procedure crc.
def input parameter v-crc as integer.
def output parameter v-name as char.

  find first crc where crc.crc = v-crc no-lock no-error.
   if avail crc then
     v-name = crc.code.
   else
     v-name = "".

/*   displ v-name-val with frame translat.*/
end.

procedure update. /* Редактирование translat*/
    find current translat exclusive-lock.
    if s-newrec then do:
      translat.crc = 2.
      displ translat.crc with frame translat.
       run crc(translat.crc, output v-name).
      translat.date = g-today.
      translat.who = g-ofc.
      displ translat.date translat.who with frame translat.
    end.

    update translat.fam
           translat.name
           translat.otch  with frame translat.

    update translat.resident  with frame translat.

   update translat.type-doc with frame translat.
    update translat.cod-country with frame translat.
    find first codfr where codfr.codfr = 'iso3166' and codfr.code = translat.cod-country no-lock no-error.
     if avail codfr then do:
       v-name-cou = codfr.name[2].
       display v-name-cou with frame translat.
     end.
    update translat.series translat.nom-doc
           translat.vid-doc
           translat.dt-doc
           translat.rnn
           translat.addres
           translat.tel
           translat.crc with frame translat.
    run crc(translat.crc,output v-name).
      v-name-val = v-name.
       displ v-name-val with frame translat.

    do trans.
        update translat.summa  with frame translat.

        find crc where crc.crc = 2 no-lock no-error. vrate[1] = crc.rate[1]. /*USD*/
        find crc where crc.crc = 4 no-lock no-error. vrate[2] = crc.rate[1].  /*RUR*/
        find crc where crc.crc = 3 no-lock no-error. vrate[3] = crc.rate[1]. /*EUR*/

        /*проверка на отправку одним и тем же лицом двух переводов за день*/
          v-summa = 0.
          for each b-translat where trim(b-translat.fam) = trim(translat.fam) and trim(b-translat.name) = trim(translat.name)
            and trim(b-translat.otch) = trim(translat.otch) and b-translat.date = translat.date and b-translat.nom-doc = translat.nom-doc no-lock .
              if b-translat.crc = 1 then v-summa = v-summa + b-translat.summa / vrate[1].
              else
              if b-translat.crc = 2 then v-summa = v-summa + b-translat.summa.
              else
              if b-translat.crc = 3 then v-summa = v-summa + b-translat.summa * vrate[3] / vrate[1].
              else
              if b-translat.crc = 4 then v-summa = v-summa + b-translat.summa * vrate[2] / vrate[1].
          end.

        /*
        if (translat.crc = 2 and v-summa > 10000)  or (translat.crc = 4 and v-summa * vrate[2] / vrate[1] > 10000) or
            (translat.crc = 3 and v-summa * vrate[3] / vrate[1] > 10000)
           then do: message 'Сумма всех переводов этого отправителя не должна превышать 10 000 USD' skip
                           ' или эквивалента этой суммы в другой валюте !' view-as alert-box .
                 undo, retry.
           end.

        */
        if v-summa > 10000 then do:
            message 'Сумма всех переводов этого отправителя не должна превышать 10 000 USD' skip
                    ' или эквивалента этой суммы в другой валюте !' view-as alert-box .
            undo, retry.
        end.
    end. /*end transaction*/
    /* Поиск тарифа на перевод. Тарифы должны быть заполнены в под номером указанным в таблице ssedt под кодом sysc*/
    find first sysc where sysc.sysc = 'tariff' no-lock no-error.
    if not avail sysc then do:
        message  " Не найдена запись tariff в SYSC. Комиссия не будет рассчитана!".
        pause 3.
    end.

    find first tarif2 where tarif2.num = sysc.chval and tarif2.crc = translat.crc no-lock no-error.
      if avail tarif2 then do:
        translat.commis = translat.summa / 100 * tarif2.proc.
        if translat.commis < tarif2.min1 then
          translat.commis = tarif2.min1.
          displ translat.commis with frame translat.
      end.

    update translat.crc-cash  with frame translat.
    run crc(translat.crc-cash,output v-name).
      v-name-valcash = v-name.
       displ v-name-valcash with frame translat.
    update translat.rec-fam
           translat.rec-name
           translat.rec-otch
           translat.rec-code with frame translat.

    find first spr_bank where spr_bank.code = translat.rec-code no-lock no-error.
    if avail spr_bank then
        translat.rec-bank = spr_bank.name.
    else
        translat.rec-bank = ''.
    display translat.rec-bank with frame translat.
    if translat.stat = 0 then do:
       translat.stat = 1.
       translat.tim = time.
    end.
    find current translat no-lock no-error.

end.


procedure kfmcif:
    if podtv = true and translat.stat = 1 and v-ans = true and v-code = 0 then do:
         v-kfmcif = ''.

         run kfmdopinf(trim(trim(translat.fam) + ' ' + trim(translat.name) + ' ' + trim(translat.otch)), /*имя клиента*/
              translat.rnn,
              translat.nom-doc,
              translat.dt-doc,
              translat.vid-doc,
              trim(trim(translat.rec-fam) + ' ' + trim(translat.rec-name) + ' ' + trim(translat.rec-otch)),
              translat.addres,
              translat.tel,
              2,
              output v-fam,
              output v-name2,
              output v-mname,
              output v-rnn,
              output v-numreg,
              output v-dtreg,
              output v-orgreg,
              output v-dtbth,
              output v-bplace,
              output v-res,
              output v-country,
              output v-clfam2,
              output v-clname2,
              output v-clmname2,
              output v-addr,
              output v-tel,
              output v-public,
              output v-doctyp,
              output v-kfmcif).

              if not v-dopres then return.

              if v-kfmcif <> '' then do transaction:
                  find current translat exclusive-lock no-error.
                  translat.kfmcif = v-kfmcif.
                  find current translat no-lock no-error.
              end.
    end.
end procedure.