/* dsrlistrdat.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Хранилище карточек подписей
        Список файлов в хранилище - подбор данных с филиальных баз
 * RUN
        
 * CALLER
        dsrlistr.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-6
 * BASES
        COMM TXB
 * AUTHOR
        07.02.2005 marinav
 * CHANGES
        16/08/2006 marinav - оптимизация 
*/

{dsr0.i}

def input parameter p-bank as char.


def shared temp-table t-cif
  field cif as char
  field name as char
  index cif is primary unique cif.

for each dsr where dsr.bank = p-bank no-lock use-index cif:
  find first t-cif where t-cif.cif = dsr.cif no-lock no-error.
  if not avail t-cif then do:
    find first txb.cif where txb.cif.cif = dsr.cif no-lock no-error.
    if avail txb.cif then do:
       create t-cif.
       assign t-cif.cif = dsr.cif
              t-cif.name = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
    end.
  end.
end.

