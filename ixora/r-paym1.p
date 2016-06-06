/* r-paym1.p
 * MODULE
        Отчет по переводам без открытия счета
        Метроэкспресс SWIFT
 * DESCRIPTION
        Отчет
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        освное меню Список скриптов, вызывающих этот файл
 * INHERIT
        
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK COMM TXB
 * AUTHOR
        27.04.09 marinav
 * CHANGES
        12.04.2011 marinav  -  страну брать из bank.remtrz , в филиале почему то страна пустая.
*/

def shared temp-table paym no-undo 
    field dt as int
    field name as char
    field type as char
    field country as char
    field crc like bank.crchis.crc
    field cnt as int
    field sum like translat.summa
    index main dt name type country crc.



def shared var dt1     as date.
def shared var dt2     as date.
def shared var v-eknp as char.
def shared var v-iso as char.


for each txb.remtrz where txb.remtrz.fcrc ne 1 and txb.remtrz.cover = 4 and txb.remtrz.valdt1 >= dt1 and txb.remtrz.valdt1 <= dt2 no-lock.
 if txb.remtrz.drgl = 100100 then do:
    find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.rem and txb.sub-cod.ccode = 'eknp' no-lock no-error.
    if avail txb.sub-cod then v-eknp = txb.sub-cod.rcode. else v-eknp = "".
    if substr(v-eknp,2,1) = '9' then do:
       /*find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.rem and txb.sub-cod.d-cod = 'iso3166' no-lock no-error.
       if avail txb.sub-cod then v-iso = txb.sub-cod.ccode. else v-iso = "".*/
       find bank.remtrz where bank.remtrz.rdt = txb.remtrz.rdt and bank.remtrz.amt = txb.remtrz.amt and  substr(bank.remtrz.sqn,7,10) = txb.remtrz.rem no-lock no-error.
       if avail bank.remtrz then do:
            find first bank.sub-cod where bank.sub-cod.sub = 'rmz' and bank.sub-cod.acc = bank.remtrz.rem and bank.sub-cod.d-cod = 'iso3166' no-lock no-error.
            if avail bank.sub-cod then v-iso = bank.sub-cod.ccode. else v-iso = "".
       end.
  
       find last txb.crchis where txb.crchis.crc = txb.remtrz.fcrc and txb.crchis.rdt <= txb.remtrz.valdt1 no-lock no-error.
       find first paym where paym.dt = month(txb.remtrz.valdt1) and paym.name = 'SWIFT' and paym.type = 'отправленные' and paym.country = v-iso and paym.crc = txb.remtrz.fcrc no-lock no-error.
       if not avail paym then do:
          create paym.
          assign paym.dt = month(txb.remtrz.valdt1) paym.name = 'SWIFT' paym.type = 'отправленные' paym.country = v-iso paym.crc = txb.remtrz.fcrc.
       end.
       assign paym.cnt = paym.cnt + 1 paym.sum = paym.sum + txb.remtrz.amt * txb.crchis.rate[1].
    end.
 end.



 else do:
     find first txb.gl where txb.gl.gl = txb.remtrz.drgl and txb.gl.sub = 'arp' no-lock no-error.
     if avail txb.gl then do:
         find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.rem and txb.sub-cod.ccode = 'eknp' no-lock no-error.
         if avail txb.sub-cod then v-eknp = txb.sub-cod.rcode. else v-eknp = "".
         if substr(v-eknp,2,1) = '9' then do:
          /*   find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.rem and txb.sub-cod.d-cod = 'iso3166' no-lock no-error.
             if avail txb.sub-cod then v-iso = txb.sub-cod.ccode. else v-iso = "".*/
             find bank.remtrz where bank.remtrz.rdt = txb.remtrz.rdt and bank.remtrz.amt = txb.remtrz.amt and substr(bank.remtrz.sqn,7,10) = txb.remtrz.rem no-lock no-error.
             if avail bank.remtrz then do:
                  find first bank.sub-cod where bank.sub-cod.sub = 'rmz' and bank.sub-cod.acc = bank.remtrz.rem and bank.sub-cod.d-cod = 'iso3166' no-lock no-error.
                  if avail bank.sub-cod then v-iso = bank.sub-cod.ccode. else v-iso = "".
             end.

             find last txb.crchis where txb.crchis.crc = txb.remtrz.fcrc and txb.crchis.rdt <= txb.remtrz.valdt1 no-lock no-error.
             find first paym where paym.dt = month(txb.remtrz.valdt1) and paym.name = 'SWIFT' and paym.type = 'отправленные' and paym.country = v-iso and paym.crc = txb.remtrz.fcrc no-lock no-error.
             if not avail paym then do:
                create paym.
                assign paym.dt = month(txb.remtrz.valdt1) paym.name = 'SWIFT' paym.type = 'отправленные' paym.country = v-iso paym.crc = txb.remtrz.fcrc.
             end.
             assign paym.cnt = paym.cnt + 1 paym.sum = paym.sum + txb.remtrz.amt * txb.crchis.rate[1].
         end.
     end.
 end.
end.
                                                                                    3