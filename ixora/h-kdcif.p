/* 
 * MODULE
        Кредитное досье
 * DESCRIPTION
      Список клиентов - F2 для переменной s-kdcif
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.11.2
 * AUTHOR
   21.07.2003 marinav
 * CHANGES
   21.07.2003 marinav
   30/04/2004 madiar - Просмотр клиентов филиалов в ГБ
*/

{global.i}
{kd.i}

def temp-table t-ln
  field sort as char
  field rdt like kdcif.regdt
  field cif like kdcif.kdcif
  field rnn as char
  field name as char
  field bank as char
  index main is primary sort ASC rnn ASC.

def var v-sel as char format "x".
def var v-nom as char format "x(30)".
def var v-dt as date format "99/99/9999".
def var v-int as integer format ">>>9".

hide message no-pause.                
message " R)РНН  N)ФИО  C)Код клиента  " update v-sel.

hide message no-pause.
case v-sel :
  when "r" or when "к" then do:
    v-nom = "". 
    message " Введите полный номер РНН " update v-nom.

    find first kdcif where (kdcif.bank = s-ourbank or s-ourbank = "TXB00") and kdcif.rnn = v-nom no-lock no-error.
    if avail kdcif then do:
      for each kdcif where (kdcif.bank = s-ourbank or s-ourbank = "TXB00") and kdcif.rnn = v-nom no-lock.
        create t-ln.
        assign t-ln.rdt = kdcif.regdt
               t-ln.rnn = kdcif.rnn
               t-ln.name = caps(kdcif.name)
               t-ln.cif = kdcif.kdcif.
        end.
    end.
    else do:
    find first cif where cif.jss = v-nom no-lock no-error.
    if avail cif then do:
      for each cif where cif.jss = v-nom no-lock.
        create t-ln.
        assign t-ln.rdt = cif.regdt
               t-ln.rnn = cif.jss
               t-ln.name = caps(cif.name)
               t-ln.cif = cif.cif.
        end.
    end.
    end.
  end.

  when "n" or when "т" then do: 
    v-nom = "". 
    message " Введите любую часть наименования " update v-nom.
    v-nom = caps(v-nom).

    find first kdcif where (kdcif.bank = s-ourbank or s-ourbank = "TXB00") and caps(kdcif.name) matches "*" + v-nom + "*" no-lock no-error.
    if avail kdcif then do:
      for each kdcif where (kdcif.bank = s-ourbank or s-ourbank = "TXB00") and caps(kdcif.name) matches "*" + v-nom + "*" no-lock.
        create t-ln.
        assign t-ln.rdt = kdcif.regdt
               t-ln.rnn = kdcif.rnn
               t-ln.name = caps(kdcif.name)
               t-ln.cif = kdcif.kdcif.
      end.
    end.
/*    else do:*/
    find first cif where caps(cif.name) matches "*" + v-nom + "*" no-lock no-error.
    if avail cif  then do:
      for each cif where caps(cif.name) matches "*" + v-nom + "*" 
               and not can-find(t-ln where t-ln.cif = cif.cif) no-lock.
        create t-ln.
        assign t-ln.rdt = cif.regdt
               t-ln.rnn = cif.jss
               t-ln.name = caps(cif.name)
               t-ln.cif = cif.cif.
      end.
  /*  end.*/
    end.
  end.

  when "c" or when "с" then do:
    v-nom = "". 
    message " Введите код клиента " update v-nom.

    find first kdcif where (kdcif.bank = s-ourbank or s-ourbank = "TXB00") and kdcif.kdcif = v-nom no-lock no-error.
    if avail kdcif then do:
      for each kdcif where (kdcif.bank = s-ourbank or s-ourbank = "TXB00") and kdcif.kdcif = v-nom no-lock.
        create t-ln.
        assign t-ln.rdt = kdcif.regdt
               t-ln.rnn = kdcif.rnn
               t-ln.name = caps(kdcif.name)
               t-ln.cif = kdcif.kdcif.
      end.
    end.
    else do:
    find first cif where cif.cif = v-nom  no-lock no-error.
    if avail cif then do:
      for each cif where cif.cif = v-nom  no-lock.
        create t-ln.
        assign t-ln.rdt = cif.regdt
               t-ln.rnn = cif.jss
               t-ln.name = caps(cif.name)
               t-ln.cif = cif.cif.
      end.
    end.
    end.
  end.
end case.


find first t-ln no-error.
if not avail t-ln then do:
  message skip " Совпадение не найдено !" skip(1) view-as alert-box button ok title "".
  return.
end.


{itemlist.i 
       &file = "t-ln"
       &frame = "row 6 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " t-ln.cif label 'КОД КЛ' format 'x(6)'
                    t-ln.rnn label 'РНН' format 'x(12)'
                    t-ln.name label 'ЗАЕМЩИК' format 'x(35)'
                   " 
       &chkey = "cif"
       &chtype = "string"
       &index  = "main" 
}



