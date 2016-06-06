/* s_change.p
 * MODULE
        Переводы
 * DESCRIPTION
        Отмена переводов
 * RUN
        change-per.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        .
 * AUTHOR
        15.07.2005 nataly
 * CHANGES
        21.07.05 nataly добавлен код валюты внесения наличности
        20/07/2010 madiyar - поменял release на find current
*/

{mainhead.i}
{opr-stat.i}

def var v-name as char.

/*define new shared variable s-nomer like translat.nomer.
  */
{sisn.i
    &head = "translat"
    &headkey = "nomer"
    &post = "ch"
    &option = "TRANSL"
    &start = " "
    &end = " "
    &noedt = "false"
    &nodel = "false"
    &variable = " "
    &aftersub = " "

    &no-update = " "

    &update = "
/*      if podtv = false then do:
      if translat.stat < 2 then do:
             run update.
           end.
         else message 'Редактирование невозможно, тк перевод имеет статус ""' opr-stat(translat.stat) '"" !'
                        view-as alert-box.
        end.*/

        if translat.stat = 2 or translat.stat = 3 then do:
          v-ans = true.
          message ' Отменить данный перевод и создать новый с другими реквизитами ?'  view-as alert-box buttons yes-no title 'Внимание!' update v-ans.
          if v-ans = true then run payment-file(translat.nomer,6).
            find translat where translat.nomer = s-nomer exclusive-lock no-error.
            if not avail translat then do:
                message 'Не найден перевод с номером ' s-nomer '!!!' view-as alert-box.
                pause 3.
                return.
            end.
            displ translat.nomer with  frame translatch.
            run update.
/*            run platezh(s-nomer).*/
/*              run create-file(translat.nomer).*/
          find current translat no-lock.
        end.
        else if translat.stat = 9  then do:
            run update.
        end.
        else do:
                message 'Перевод не подлежит редактированию, тк имеет статус ' opr-stat(translat.stat) '!!!' view-as alert-box.
                pause 3.
                return.
        end.
    "

    &no-delete = "

    "
    &delete = " "

    &predisplay = "
                    find first crc where crc.crc = translat.crc no-lock no-error.
                    v-stat = opr-stat(translat.stat).
                    if translat.tim <> 0 then
                      v-tim  = STRING(translat.tim, 'hh:mm:ss').
                    if translat.send-tim <> 0 then
                      v-send-tim = STRING(translat.send-tim, 'hh:mm:ss').
                    if translat.tim-otm <> 0 then
                      v-tim-otm = STRING(translat.tim-otm, 'hh:mm:ss').
                    if translat.tim-vidach <> 0 then
                      v-tim-vidach = STRING(translat.tim-vidach, 'hh:mm:ss').
                    if translat.tim-pod-otm <> 0 then
                      v-tim-pod-otm = STRING(translat.tim-pod-otm, 'hh:mm:ss').

    "

    &display = "

/*     displ translat.nomer translat.jh v-stat translat.fam translat.name translat.otch translat.resident translat.type-doc translat.cod-country translat.series translat.nom-doc
          translat.vid-doc translat.dt-doc translat.addres translat.tel translat.crc translat.summa translat.commis
          translat.rec-fam translat.rec-name translat.rec-otch translat.rec-code translat.rec-bank
          (if avail crc then crc.code else '') @ v-name-val
          (if avail codfr then codfr.name[2] else '') @ v-name-cou
          translat.date v-tim translat.send-date v-send-tim translat.who
          translat.dt-dostav v-tim-dostav translat.dt-vidach v-tim-vidach
          with frame translat.*/

     displ translat.nomer translat.jh v-stat translat.fam translat.name translat.otch translat.type-doc translat.series translat.nom-doc
          translat.vid-doc translat.dt-doc translat.addres translat.tel translat.crc translat.summa translat.commis
          translat.rec-fam translat.rec-name translat.rec-otch translat.rec-code translat.rec-bank
          (if avail crc then crc.code else '') @ v-name-val
          translat.date v-tim translat.send-date v-send-tim translat.who
          translat.dt-otm v-tim-otm translat.dt-pod-otm v-tim-pod-otm
          with frame translatch.
    "
    &postdisplay = "  "
}

procedure crc. /* Определение кода валюты*/
def input parameter v-crc as integer.
def output parameter v-name as char.
  find first crc where crc.crc = v-crc no-lock no-error.
   if avail crc then
     v-name = crc.code.
   else
     v-name = "".

/*   displ v-name-val with frame translatch.*/
end.

procedure update. /* Редактирование translat*/
  /*  if s-newrec then do:
      translat.crc = 2.
      displ translat.crc with frame translatch.
      run crc.
      translat.date = g-today.
      translat.who = g-ofc.
      displ translat.date translat.who with frame translatch.
    end.
    */
    update translat.fam with frame translatch.
    update translat.name with frame translatch.
    update translat.otch  with frame translatch.
    update translat.resident  with frame translatch.
    update translat.type-doc with frame translatch.
    update translat.cod-country with frame translatch.
    find first codfr where codfr.codfr = 'iso3166' and codfr.code = translat.cod-country no-lock no-error.
     if avail codfr then do:
       /*v-name-cou = codfr.name[2].
       display v-name-cou with frame translatch. */
     end.
    update translat.series translat.nom-doc with frame translatch.
    update translat.vid-doc with frame translatch.
    update translat.dt-doc with frame translatch.
    update translat.addres with frame translatch.
    update translat.tel /*translat.crc*/ with frame translatch.
       run crc(translat.crc, output v-name).
       v-name-val = v-name.
     displ v-name-val with frame translatch.

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
          displ translat.commis with frame translatch.
      end.

   /* update translat.commis  with frame translatch.    */
    update translat.rec-fam  with frame translatch.
    update translat.rec-name with frame translatch.
    update translat.rec-otch translat.rec-code with frame translatch.

    find first spr_bank where spr_bank.code = translat.rec-code no-lock no-error.
    if avail spr_bank then
        translat.rec-bank = spr_bank.name.
    else
        translat.rec-bank = ''.
    display translat.rec-bank with frame translatch.
    if translat.stat = 0 then do:
       translat.stat = 1.
       translat.tim = time.
    end.
end.


