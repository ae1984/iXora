/* tarif2fil.i
 * MODULE
        Системные параметры
 * DESCRIPTION
        Копирование тарифа на филиалы
 * RUN
        
 * CALLER
        tar2_br.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9-1-2-6
 * AUTHOR
        29.09.2003 nadejda
 * CHANGES
*/



def input parameter p-num like ast.tarif2.num.
def input parameter p-kod like ast.tarif2.kod.
def input parameter p-bank as char.

def shared var g-today as date.
def shared var g-ofc as char.
def shared var stnum like ast.tarif2.num.
def shared var rr4 as int.
def var v-answ as logical.
def var v-deflgot as logical init no.
def var v-pakalp as char.

find bank.tarif2 where bank.tarif2.num = p-num and bank.tarif2.kod = p-kod no-lock no-error.

find ast.tarif2 where ast.tarif2.num = p-num and ast.tarif2.kod = p-kod exclusive-lock no-error.


do transaction on error undo, retry:
  if not avail ast.tarif2 then do:
    v-answ = yes.
     
    message skip " НОВЫЙ тариф для филиала" p-bank "!~n~n Данный тариф будет использоваться в филиале" p-bank "?"
            skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-answ.
    

    find ast.tarif where ast.tarif.num  = stnum and ast.tarif.nr = rr4 no-lock no-error.
    if not avail ast.tarif then do:
      find bank.tarif where bank.tarif.num  = stnum and bank.tarif.nr = rr4 no-lock no-error.
      create ast.tarif.
      buffer-copy bank.tarif to ast.tarif.
      find current ast.tarif no-lock.
    end.

    create ast.tarif2.
    buffer-copy bank.tarif2 to ast.tarif2.

    v-pakalp = bank.tarif2.pakalp.
    if v-pakalp begins "N/A " then v-pakalp = substr(v-pakalp, 5).
    ast.tarif2.pakalp = if v-answ then v-pakalp else "N/A " + v-pakalp.

    v-deflgot = v-answ.
  end.
  else do:
    if ast.tarif2.kont <> bank.tarif2.kont then do:
      v-answ = yes.
      message skip " Счет ГК данного тарифа в тарификаторе филиала" p-bank "(" ast.tarif2.kont ")~n отличается от заданного в головном офисе (" bank.tarif2.kont ")!"
              skip " Изменить счет ГК в тарификаторе филиала?"
              skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-answ.
      if v-answ then do:
        ast.tarif2.kont = bank.tarif2.kont.
        v-deflgot = yes.
      end.
    end.

    if ast.tarif2.pakalp <> bank.tarif2.pakalp then do:
      v-answ = yes.
      message skip    " Наименование данного тарифа в тарификаторе филиала" p-bank 
              skip    " (" + trim(ast.tarif2.pakalp) + ")"
              skip(1) " отличается от заданного в головном офисе!"
              skip    " (" + trim(bank.tarif2.pakalp) + ")"
              skip(1) " Изменить наименование в тарификаторе филиала?"
              skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-answ.
      if v-answ then 
        ast.tarif2.pakalp = bank.tarif2.pakalp.
    end.
  end.
end.

find current ast.tarif2 no-lock.

if v-deflgot then do:
  def var p-ans as logical.
  /* поискать клиентов с льготным обслуживанием */
  find first ast.cif where ast.cif.pres <> "" no-lock no-error.
  if avail ast.cif then do:
    p-ans = yes.
    message skip " В филиале" p-bank "найдены клиенты по группам льготного обслуживания !"
            skip(1) " Пересчитать данный тариф для групп льготного обслуживания ?"
            skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update p-ans.

    if p-ans then do:
      /* по всем группам запустить пересчет льготы для данного тарифа */
      for each ast.codfr where ast.codfr.codfr = "clnlgot" and ast.codfr.code <> "msc" no-lock:
        run value("clnlgotf-" + ast.codfr.code) ("", ast.tarif2.str5, yes). 
      end.
    end.
  end.
end.

