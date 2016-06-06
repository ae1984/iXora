/* mclnadd.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Добавление клиентов для мониторинга казначейства
 * RUN
        run mclnadd.p (s-cif, s-lon, s-acc, jl.crc, jl.cam, s-jh).
 * CALLER
        s-lonisl.p, ln_kont.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-1-1- Верхнее меню "Выдача", 4-1-11
 * AUTHOR
        08.05.2004 nadejda
 * CHANGES
        04.06.2004 nadejda - записывать дату обновления
*/

{global.i}

def input parameter p-type as char.
def input parameter p-cif as char.
def input parameter p-lon as char.
def input parameter p-acc as char.
def input parameter p-crc as integer.
def input parameter p-sum as decimal.
def input parameter p-jh as integer.

find coll where coll.type = p-type and coll.jh = p-jh no-lock no-error.
if avail coll then return.

/* если уже стоит мониторинг - снова ставить не надо, только записать дату обновления */
find coll where coll.cif = p-cif and coll.sts = "0" no-lock no-error.
if avail coll then do:
  do transaction:
    find current coll exclusive-lock.
    coll.whn = g-today.
    coll.who = g-ofc.
    release coll.
  end.
  return.
end.

def var i as integer.

i = 0.
find last coll where coll.cif = p-cif no-lock use-index cifcno no-error.
if avail coll then i = coll.cno.
i = i + 1.

do transaction on error undo, retry:
  create coll.
  assign coll.type  = p-type
         coll.cif   = p-cif
         coll.cno   = i
         coll.lon   = p-lon
         coll.crc   = p-crc
         coll.sum   = p-sum
         coll.acc   = p-acc
         coll.jh    = p-jh
         coll.sts   = "0"
         coll.stsdt = g-today
         coll.rdt   = g-today
         coll.rwho  = g-ofc
         coll.who   = g-ofc
         coll.whn   = g-today.

  i = time.
  assign coll.rtim = i
         coll.tim  = i.
end.
release coll.

