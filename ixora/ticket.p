/* ticket.p
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
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       17.03.2004 nataly  - добавлена валюта + счет ARP в EUR (076643)
       13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

/* 20/02/03 nataly
   программа по автоматичесокму зачислению сумм, пришедших по TICKETу */

{global.i}
def var h as int .
h = 12 .

def var v-dat1 as date.
def var v-dat2 as date.
def var v-dat3 as date.
def var v-sum as decimal.
def var v-jh as integer.

def var vparam as char.
def var rcode as inte.
def var rdes as char.
def var vdel as char initial "^".

def var ja as log format "да/нет".
def var vou-count as int initial 1.
def var i as integer.
def var v-code as integer init 1.

def  new shared var s-jh like jh.jh.
def temp-table w-rmz like ticket
    index dt1 dt1    .


if not g-batch then do:
   update v-dat1 label 'Введите дату проводок: С ...'
    validate (v-dat1 le g-today,
             " Дата не может быть больше текущего закрытого ОД " + string(g-today) )
              v-dat2 label ' ПО ...'  skip
              v-dat3 label 'Задайте дату TICKETа'
              v-sum label 'Задайте сумму TICKETа'
   with row 8 centered  side-label frame opt.
end.
hide frame opt.

if v-dat1 = ? or v-dat2 = ? or v-dat3 = ? or v-sum = 0
  then do:
   message 'Заданы не все параметры!!!' view-as alert-box.
   undo,retry .
  end.

for each ticket where ticket.dt1 >= v-dat1 and ticket.dt1 <= v-dat2
   and dt2 = ?  break by ticket.dt1  .
     create w-rmz.
     w-rmz.dt1 = ticket.dt1 .
     w-rmz.arp = ticket.arp.
     w-rmz.gl = ticket.gl   .
     w-rmz.des = ticket.des.
     w-rmz.amt[1]  = ticket.amt[1]   .
     w-rmz.crc = ticket.crc.
end.

define query q1 for w-rmz.

define browse b1 query q1
              displ
                 w-rmz.arp label "ARP #."
                 w-rmz.dt1 label "Дата 1пров"
                 w-rmz.gl label "Счет ГК"
                 w-rmz.des label "ОПИСАНИЕ" format 'x(27)'
                 w-rmz.crc label "ВАЛ" format 'z9'
                 w-rmz.amt[1] label "СуммаД" format 'z,zzz,zz9.99'
     with centered no-label row 2 10 down no-box.

define frame f1 b1
help "F1 - Проводка и акцепт, F4 - выход"
with row 2.


{yes-no.i}
def var yn as log.

on GO of b1 do:
yn = yes-no ("", "Сформировать проводку и акцептовать ее ?").
if yn then do:
  run  arptrx(w-rmz.dt1, w-rmz.arp, w-rmz.amt[1], output v-code, output s-jh).
   if v-code   = 0  then do:
     w-rmz.dt2 = g-today.
  /*   w-rmz.jh2 =    .*/
     find ticket where ticket.arp = w-rmz.arp and ticket.amt[1] = w-rmz.amt[1]
      and ticket.dt1 = w-rmz.dt1 and ticket.dt2 = ? exclusive-lock no-error.
     if available ticket
      then do:
      ticket.dt2 = g-today. ticket.jh2 = s-jh.
      end.
     close query q1.
     open query q1 for each w-rmz where w-rmz.dt2 = ? no-lock.
     find first w-rmz where w-rmz.dt2 = ? no-lock no-error.
     if available w-rmz then  browse b1:refresh().
   end.
end.
end.

/* обработка нажатие клавиши F4 */
on END-ERROR of b1 do:
  hide all.
  return.
end.

hide all.
open query q1 for each w-rmz where w-rmz.dt2 = ? no-lock.
enable all with frame f1.

wait-for window-close of current-window.

Procedure arptrx.

DEFINE INPUT PARAMETER dt1 as date.
DEFINE INPUT PARAMETER arp as char.
DEFINE INPUT PARAMETER amt AS DECIMAL.
DEFINE OUTPUT PARAMETER code AS integer.
DEFINE OUTPUT PARAMETER v-jh AS integer.

def var nazn as char.
def var v-ccod106 as char.
def var v-ccod012 as char.
def var v-ccodarp as char.
def var v-geoi as integer.

def var v-r106 as char.
def var v-r012 as char.
def var v-rarp as char.

         if amt > 0 then do transaction:
           v-jh = 0.

           find arp where arp.arp = '000076012' no-lock.
           find cif where cif.cif eq arp.cif no-lock no-error.
           if available cif then v-geoi = integer(cif.geo).
           else v-geoi = integer(arp.geo).
           if substring(string(v-geoi,"999"),3,1) eq "1" then v-r012 = "1".
           else v-r012 = "2".
           find sub-cod where sub = 'arp' and acc = '000076012' and d-cod = 'secek' no-lock no-error.
           if available sub-cod  and sub-cod.ccod <> 'msc' then v-ccod012 = sub-cod.ccod.

           find arp where arp.arp = '000076106' no-lock.
           find cif where cif.cif eq arp.cif no-lock no-error.
           if available cif then v-geoi = integer(cif.geo).
           else v-geoi = integer(arp.geo).
           if substring(string(v-geoi,"999"),3,1) eq "1" then v-r106 = "1".
           else v-r106 = "2".
           find sub-cod where sub = 'arp' and acc = '000076106' and d-cod = 'secek' no-lock no-error.
           if available sub-cod and sub-cod.ccod <> 'msc'  then v-ccod106 = sub-cod.ccod.

           find arp where arp.arp = arp no-lock.
           find cif where cif.cif eq arp.cif no-lock no-error.
           if available cif then v-geoi = integer(cif.geo).
           else v-geoi = integer(arp.geo).
           if substring(string(v-geoi,"999"),3,1) eq "1" then v-rarp = "1".
           else v-rarp = "2".
           find sub-cod where sub = 'arp' and acc = arp and d-cod = 'secek' no-lock no-error.
           if available sub-cod and sub-cod.ccod <> 'msc' then v-ccodarp = sub-cod.ccod.
             else  do:
              message 'Не задан признак "Сектор Экономики" для счета ' arp
              view-as alert-box title 'Внимание!' . code = 1. return.
             end.

            if arp <> '000076106'  and arp <> '000076643' then do:

             nazn = 'DEPOSIT ticket ' + string(v-dat3) + ' сумма USD ' +  string(v-sum).
             vparam = string(amt) + vdel + "000076012" + vdel + arp + vdel + nazn +
             vdel + v-r012 + vdel + v-rarp +
             vdel + v-ccod012 + vdel + v-ccodarp .
             run trxgen("uni0154", vdel, vparam, "ARP", arp, output rcode, output rdes, input-output v-jh).
           end.
           else do:
             nazn = 'Зачислить для ' +  w-rmz.des  + ' сумму ' +  string(amt).
             if arp = '000076106' then  vparam = string(amt) + vdel + arp + vdel + nazn + vdel  + string(amt).
             if arp = '000076643' then  vparam = string(amt) + vdel + arp + vdel + nazn + vdel  + string(0).
             run trxgen("ock0018", vdel, vparam, "ARP", arp, output rcode, output rdes, input-output v-jh).
           end.

           if rcode ne 0 then do:
             code = 1.
             message
             "Не удалось сформировать проводку ARP - ARP "
                 arp ", " string(amt) " -> " rdes view-as alert-box .
           end.
           else do:
             release jl. release jh.
             run trxsts(v-jh, 6, output rcode, output rdes).
             if rcode ne 0 then do:
                message
                 "Не удалось отштамповать проводку ARP - ARP "
                 arp ", " string(amt) " -> " rdes view-as alert-box.
                    code = 1.
             end.
             else do:
               /*  message "Проводка # " string(v-jh) " удачно сформировна!!!"
                   view-as alert-box.  */
                   code = 0.
             end.
           end.
        /*voucher printing nataly--------------------*/
          if v-jh ne 0 then do :
            do on endkey undo:
                find first jl where jl.jh = v-jh no-error.
                  if available jl  then do:

                message "Печатать ваучер ?" update ja.
                if ja   then do:
                     message "Сколько ?" update vou-count.
                    if vou-count > 0 and vou-count < 10 then do:
                            s-jh =  v-jh.
                            {mesg.i 0933} s-jh.
                            do i = 1 to vou-count:
                                /*run x-jlvou.*/
                              run vou_bank(2).
                            end.
                    end.  /* if vou-count > 0 */
               end. /* if ja */

               if not ja then  do:
                {mesg.i 0933} v-jh.    pause 5.
                end. /*  if not ja*/
                pause 0.
               end.  /* if available jl */
               else do:
                message "Can't find transaction " v-jh view-as alert-box.
                 return.
               end.
            pause 0.
          end. /* do on endkey undo: */
        end.  /*  if v-jh ne 0 then do : */

/*voucher printing nataly--------------------*/

         end.
End procedure.
