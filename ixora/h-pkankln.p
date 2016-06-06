/* h-pkankln.p
 * MODULE
        ПотребКредит
 * DESCRIPTION
        Список анкет по параметру 
 * RUN
        F2 на номере анкеты
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-х-2, 4-x-3
 * AUTHOR
        31.01.2003 nadejda
 * CHANGES
        12.12.2003 nadejda - поставила ограничение по банку
*/


{global.i}
{pk.i}

def temp-table t-ln
  field ln like pkanketa.ln
  field rdt as date
  field rnn as char
  field name as char
  field bank as char
  field cif like cif.cif
  field lon like lon.lon
  field rating like pkanketa.rating
  index main is primary rdt DESC name ASC rnn ASC.

def var v-sel as char format "x".
def var v-nom as char format "x(30)".
def var v-dt as date format "99/99/9999".
def var v-int as integer format ">>>9".

hide message no-pause.
message " R)РНН  N)ФИО  C)Код клиента  D)Дата  T)Рейтинг  L)Ссуд.счет " update v-sel.

hide message no-pause.
case v-sel :
  when "r" or when "к" then do:
    v-nom = "". 
    message " Введите полный номер РНН " update v-nom.

    for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.rnn = v-nom no-lock.
      create t-ln.
      assign t-ln.ln = pkanketa.ln
             t-ln.rdt = pkanketa.rdt
             t-ln.rating = pkanketa.rating
             t-ln.rnn = pkanketa.rnn
             t-ln.bank = pkanketa.bank
             t-ln.name = caps(pkanketa.name)
             t-ln.cif = pkanketa.cif
             t-ln.lon = pkanketa.lon.
    end.
  end.

  when "n" or when "т" then do: 
    v-nom = "". 
    message " Введите любую часть ФИО " update v-nom.
    v-nom = caps(v-nom).

    for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and caps(pkanketa.name) matches "*" + v-nom + "*" no-lock.
      create t-ln.
      assign t-ln.ln = pkanketa.ln
             t-ln.rdt = pkanketa.rdt
             t-ln.rating = pkanketa.rating
             t-ln.rnn = pkanketa.rnn
             t-ln.bank = pkanketa.bank
             t-ln.name = caps(pkanketa.name)
             t-ln.cif = pkanketa.cif
             t-ln.lon = pkanketa.lon.
    end.
  end.

  when "c" or when "с" then do:
    v-nom = "". 
    message " Введите код клиента " update v-nom.

    for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.cif = v-nom no-lock.
      create t-ln.
      assign t-ln.ln = pkanketa.ln
             t-ln.rdt = pkanketa.rdt
             t-ln.rating = pkanketa.rating
             t-ln.rnn = pkanketa.rnn
             t-ln.bank = pkanketa.bank
             t-ln.name = caps(pkanketa.name)
             t-ln.cif = pkanketa.cif
             t-ln.lon = pkanketa.lon.
    end.
  end.

  when "d" or when "в" then do:
    v-dt = g-today. 
    message " Введите дату регистрации анкеты " update v-dt.

    for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.rdt = v-dt no-lock.
      create t-ln.
      assign t-ln.ln = pkanketa.ln
             t-ln.rdt = pkanketa.rdt
             t-ln.rating = pkanketa.rating
             t-ln.rnn = pkanketa.rnn
             t-ln.bank = pkanketa.bank
             t-ln.name = caps(pkanketa.name)
             t-ln.cif = pkanketa.cif
             t-ln.lon = pkanketa.lon.
    end.
  end.

  when "T" or when "т" then do:
    v-int = 0. 
    message " Введите рейтинг анкеты " update v-int.

    for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.rating = v-int no-lock.
      create t-ln.
      assign t-ln.ln = pkanketa.ln
             t-ln.rdt = pkanketa.rdt
             t-ln.rating = pkanketa.rating
             t-ln.rnn = pkanketa.rnn
             t-ln.bank = pkanketa.bank
             t-ln.name = caps(pkanketa.name)
             t-ln.cif = pkanketa.cif
             t-ln.lon = pkanketa.lon.
    end.
  end.

  when "l" or when "д" then do:
    v-nom = "". 
    message " Введите номер ссуд.счета " update v-nom.

    for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.lon = v-nom no-lock.
      create t-ln.
      assign t-ln.ln = pkanketa.ln
             t-ln.rdt = pkanketa.rdt
             t-ln.rating = pkanketa.rating
             t-ln.rnn = pkanketa.rnn
             t-ln.bank = pkanketa.bank
             t-ln.name = caps(pkanketa.name)
             t-ln.cif = pkanketa.cif
             t-ln.lon = pkanketa.lon.
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
       &flddisp = " t-ln.ln label 'N' format '>>>>>9'
                    t-ln.rdt label 'РЕГ.ДАТА'
                    t-ln.rnn label 'РНН' format 'x(12)'
                    t-ln.name label 'ФИО' format 'x(25)'
                    t-ln.cif label 'КОД КЛ' format 'x(6)'
                    t-ln.lon label 'ССУД.СЧЕТ' format 'x(9)'
                    t-ln.rating label 'РЕЙТ'
                   " 
       &chkey = "ln"
       &chtype = "integer"
       &index  = "main" 
}



