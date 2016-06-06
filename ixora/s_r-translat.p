/* s_r-translat.p
 * MODULE
        Переводы
 * DESCRIPTION
        Переводы
 * RUN
        r-translat.p
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
        20.07.05 nataly была добавлена проверка на ЕКНП
        21.07.05 nataly добавлен код валюты внесения наличности
        13.01.06 nataly добавила проверку справочника zdcavail, zsgavail.
        25.02.10 marinav - РНН получателя
        02/07/2010 galina - добавила поле kfmcif для Фин.Мониторинга
        03/07/2010 galina - добавила exclusive-lock no-lock для таблицы r-translat
                            выводим запрос доп.информации только по переводом со статусом 1
        15/07/2010 galina - запрос дополнительной информации до проводки
*/
{mainhead.i}
{rec-opr-stat.i}
def input parameter podtv as logical.
def buffer rec-crc for crc.
def var v-code as integer.

/*для выгрузки в AML*/
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

{sisn.i
    &head = "r-translat"
    &headkey = "nomer"
    &option = "TRANSL"
    &start = " "
    &end = " /*run kfmcif.*/ "
    &noedt = "false"
    &nodel = "false"
    &variable = " "
    &aftersub = " "

    &no-update = " "

    &preupdate = " ".
    &update = "
      case r-translat.stat:
       when 2 then do:
           message 'Перевод выплачен, редактирование невозможно!'.
           pause 3.
       end.
       when 3 then do:
           message 'Перевод отменен, редактирование невозможно!'.
           pause 3.
       end.
       when 4 then do:
           message 'Перевод возвращен, редактирование невозможно!'.
           pause 3.
       end.
       OTHERWISE run update.

      end.
    "
    &postupdate = " run kfmcif."
    &no-delete = " "
    &delete = " "



    &predisplay = " find first crc where crc.crc = r-translat.crc no-lock no-error.
                    find first rec-crc where rec-crc.crc = r-translat.rec-crc no-lock no-error.
                    v-stat = rec-opr-stat(r-translat.stat).
                    if r-translat.tim <> 0 then
                      v-tim  = STRING(r-translat.tim, 'hh:mm:ss').
                    if r-translat.send-tim <> 0 then
                      v-send-tim = STRING(r-translat.send-tim, 'hh:mm:ss').
                    if r-translat.tim-vidach <> 0 then
                      v-tim-vidach = STRING(r-translat.tim-vidach, 'hh:mm:ss').
                    if r-translat.tim-otm <> 0 then
                      v-tim-otm = STRING(r-translat.tim-otm, 'hh:mm:ss').
                    find first codfr where codfr.codfr = 'iso3166' and codfr.code = r-translat.rec-cod-country no-lock no-error.

    "

    &display = "
     displ r-translat.nomer r-translat.jh v-stat r-translat.fam r-translat.name r-translat.otch r-translat.type-doc r-translat.series r-translat.nom-doc
          r-translat.vid-doc r-translat.dt-doc r-translat.addres r-translat.tel r-translat.crc r-translat.summa
          r-translat.rec-fam r-translat.rec-name r-translat.rec-otch r-translat.code r-translat.bank
          (if avail crc then crc.code else '') @ v-name-val
          r-translat.date v-tim r-translat.send-date v-send-tim r-translat.who
          r-translat.rec-type-doc r-translat.rec-series r-translat.rec-nom-doc r-translat.rec-dt-doc
          r-translat.rec-vid-doc r-translat.rec-addres r-translat.rec-tel r-translat.rec-crc r-translat.rec-summa
          (if avail rec-crc then rec-crc.code else '') @ v-name-val2
          (if avail codfr then codfr.name[2] else '') @ v-name-cou
          r-translat.dt-vidach v-tim-vidach r-translat.dt-otm v-tim-otm
          r-translat.rec-resident  r-translat.acc r-translat.rec-cod-country
          with frame r-translat.
    "
    &postdisplay = "  "
}

procedure rec-crc. /* Определение кода валюты*/
def input parameter v-crc as integer.
def output parameter v-name as char.
  find first rec-crc where rec-crc.crc = v-crc no-lock no-error.
   if avail rec-crc then
     v-name = rec-crc.code.
   else
     v-name = "".

/*   displ v-name-val2 with frame r-translat.*/
end.

procedure update. /* Редактирование r-translat*/
  if podtv = false then do transaction:  /*В режиме редактирования*/
    find current r-translat exclusive-lock.
    update r-translat.rec-resident  with frame r-translat.
    update r-translat.acc with frame r-translat.
    update r-translat.rec-type-doc  with frame r-translat.
    update r-translat.rec-cod-country with frame r-translat.
    find first codfr where codfr.codfr = 'iso3166' and codfr.code = r-translat.rec-cod-country no-lock no-error.
     if avail codfr then do:
       v-name-cou = codfr.name[2].
       display v-name-cou with frame r-translat.
     end.
    update r-translat.rec-series
           r-translat.rec-nom-doc
           r-translat.rec-dt-doc
           r-translat.rec-vid-doc
           r-translat.rec-addres
           r-translat.rec-tel with frame r-translat.

    update r-translat.rec-crc with frame r-translat.

    run rec-crc(r-translat.rec-crc,output v-name).
      v-name-val2 = v-name.
       displ v-name-val2 with frame r-translat.

    update r-translat.rec-summa  with frame r-translat.

    update r-translat.crc-cash with frame r-translat.

    run rec-crc(r-translat.crc-cash,output v-name).
      v-name-valcash = v-name.
       displ v-name-valcash with frame r-translat.
    find current r-translat no-lock.
  end.


  if podtv = true then do:  /*В режиме подтверждения для отправки*/

    if r-translat.stat = 1 then do transaction:
      find current r-translat exclusive-lock.
       v-ans = true.
       message ' После выплаты перевода, его редактирование невозможно! Выплатить перевод?' view-as alert-box buttons yes-no title 'Внимание!' update v-ans.
       if v-ans = true then do:
           run check-sprav(output v-code).
           /*if v-code = 0 then run payment-file(r-translat.nomer,1).*/
             /*run kfmcif.*/
        end.
        find current r-translat no-lock.
    end.
    else do:
         message 'Перевод не может быть отправлен, тк имеет статус ""' rec-opr-stat(r-translat.stat) '"" !'.
         pause 3.
         next.
    end.
  end.

end.


procedure check-sprav.
def output parameter v-code as integer .

            find sub-cod where sub ='trl' and acc = r-translat.nomer and d-cod = 'eknp'no-lock   no-error  .
            if (avail  sub-cod  and sub-cod.ccode = 'msc') or not  avail sub-cod  then
             do:
               message 'Не заполнен справочник ЕКНП!!! Отправка перевода невозможна!'.
               pause 3.  v-code = 1.
                return .
             end.

            find sub-cod where sub-cod.sub ='trl' and sub-cod.acc = r-translat.nomer and d-cod = 'zdcavail' no-lock   no-error  .
            if (avail  sub-cod  and sub-cod.ccode = 'msc') or not  avail sub-cod  then
             do:
               message 'Не заполнен справочник Наличия док-та основания!!! Отправка перевода невозможна!'.
               pause 3. v-code = 1.
                return .
             end.

            find sub-cod where sub ='trl' and sub-cod.acc = r-translat.nomer and d-cod =  'zsgavail' no-lock   no-error  .
            if (avail  sub-cod  and sub-cod.ccode = 'msc') or not  avail sub-cod  then
             do:
               message 'Не заполнен справочник zsgavail!!! Отправка перевода невозможна!'.
               pause 3. v-code = 1.
                return .
             end.
                v-code = 0.

end.

procedure kfmcif:
   if podtv = true and r-translat.stat = 1 and v-ans = true and v-code = 0 then do:

     v-kfmcif = ''.
    run kfmdopinf(trim(trim(r-translat.rec-fam) + ' ' + trim(r-translat.rec-name) + ' ' + trim(r-translat.rec-otch)), /*имя клиента*/
      r-translat.acc,
      r-translat.rec-nom-doc,
      r-translat.rec-dt-doc,
      r-translat.rec-vid-doc,
      trim(trim(r-translat.fam) + ' ' + trim(r-translat.name) + ' ' + trim(r-translat.otch)),
      r-translat.rec-addres,
      r-translat.rec-tel,
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
          find current r-translat exclusive-lock no-error.
          r-translat.kfmcif = v-kfmcif.
          find current r-translat no-lock no-error.
      end.

       run payment-file(r-translat.nomer,1).
   end.
end procedure.