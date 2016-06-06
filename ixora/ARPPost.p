/* ARPPost.p
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
        23/02/2011 evseev - возмещение почтовых расходов
 * BASES
        BANK  COMM
 * CHANGES
       01/03/2011 evseev - перекомпиляция
*/

{global.i}
define var fname1 as char.
def var rcode as int.
def var rdes as char.
def var vparam as char.
define variable vdel as character initial "^".
def var v-jh like jh.jh.
def var v_arp like arp.arp.
def var v-amt like arp.dam[1].
def var isCreateLog as logical.

def var v_kol as int.
def var v_arp1 like arp.arp.
def var i as int.

fname1 = "ARPPost" + substring(string(g-today),1,2) + substring(string(g-today),4,2) + ".txt".

def stream m-out.
output stream m-out to ARPPost.txt.

isCreateLog = true.
find sysc where sysc.sysc = "ARPPost" no-lock no-error.
if available sysc then do:
    v_arp = sysc.chval.
    find first arp where arp.arp = v_arp no-lock no-error.
    if not avail arp then do:
       put stream m-out unformatted g-today ': Не найден ARP-счет' skip.
    end. /*not avail arp*/
    else do:
       if arp.crc = 1 then do:
           v-amt = arp.cam[1] - arp.dam[1].
           if v-amt > 0 then do:
              v-jh = 0.
              vparam = string (v-amt) + vdel + v_arp.

              run trxgen("vnb0084", vdel, vparam,
                      "arp", "", output rcode, output rdes, input-output v-jh).

              if rcode ne 0 then do:
                 message rcode ' ' rdes.
                 put stream m-out unformatted g-today ': ' rcode rdes skip.
              end.
              put stream m-out unformatted g-today ': arp:' v_arp ' сумма:' v-amt ' трн:' v-jh skip.
           end. /* v-amt > 0*/
           else isCreateLog = False.
       end. /*arp.crc = 1*/
       else put stream m-out unformatted g-today ': Валюта ARP-счета не KZT' skip.
    end. /*not avail arp*/
end. /*available sysc*/
else do:
    put stream m-out unformatted g-today ': В sysc не указан ARP-счет' skip.
end. /*available sysc*/

output stream m-out close.
if isCreateLog then unix silent mv ARPPost.txt value(fname1).