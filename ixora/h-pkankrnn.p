/* h-pkankrnn.p
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
 * CHANGES
*/

/* h-pkankrnn.p Потребкредит
   Список РНН по анкетам - F2 для выборки РНН

   31.01.2003 nadejda
*/

{global.i}

{pk.i}

{name2sort.i}

def temp-table t-rnn 
  field sort as char
  field rnn as char
  field name as char
  field bank as char
  field cif as char
  field lon as char
  index main is primary sort rnn.

def var v-sel as char format "x".
def var v-nom as char format "x(30)".

hide message no-pause.
message " R)Начало РНН  N)ФИО  L)Ссуд.счет  A)Тек.счет  C)Код клиента " update v-sel.

hide message no-pause.
case v-sel :
  when "r" or when "к" then do:
    v-nom = "". 
    message " Введите любую часть номера РНН " update v-nom.

    for each pkanketa where pkanketa.credtype = s-credtype and pkanketa.rnn matches "*" + v-nom + "*" no-lock break by pkanketa.rnn.
      if first-of(pkanketa.rnn) then do:
        create t-rnn.
        t-rnn.rnn = pkanketa.rnn.
        t-rnn.bank = pkanketa.bank.
      end.

      if length(pkanketa.name) > length(t-rnn.name) then t-rnn.name = caps(pkanketa.name).
      if length(pkanketa.cif) > length(t-rnn.cif) then t-rnn.cif = pkanketa.cif.
      if length(pkanketa.lon) > length(t-rnn.lon) then t-rnn.lon = pkanketa.lon.

      if last-of(pkanketa.rnn) then do:
        t-rnn.sort = name2sort(t-rnn.name).
      end.
    end.
  end.

  when "n" or when "т" then do: 
    v-nom = "". 
    message " Введите любую часть ФИО " update v-nom.
    v-nom = caps(v-nom).

    for each pkanketa where pkanketa.credtype = s-credtype and caps(pkanketa.name) matches "*" + v-nom + "*" no-lock break by pkanketa.rnn.
      if first-of(pkanketa.rnn) then do:
        create t-rnn.
        t-rnn.rnn = pkanketa.rnn.
        t-rnn.bank = pkanketa.bank.
      end.

      if length(pkanketa.name) > length(t-rnn.name) then t-rnn.name = caps(pkanketa.name).
      if length(pkanketa.cif) > length(t-rnn.cif) then t-rnn.cif = pkanketa.cif.
      if length(pkanketa.lon) > length(t-rnn.lon) then t-rnn.lon = pkanketa.lon.

      if last-of(pkanketa.rnn) then do:
        t-rnn.sort = name2sort(t-rnn.name).
      end.
    end.
  end.

  when "l" or when "д" then do:
    v-nom = "". 
    message " Введите ссудный счет " update v-nom.

    find last pkanketa where pkanketa.credtype = s-credtype and pkanketa.lon = v-nom no-lock no-error.
    if avail pkanketa then do:
      create t-rnn.
      assign t-rnn.rnn = pkanketa.rnn
             t-rnn.bank = pkanketa.bank
             t-rnn.name = caps(pkanketa.name)
             t-rnn.cif = pkanketa.cif
             t-rnn.lon = pkanketa.lon.
      t-rnn.sort = name2sort(t-rnn.name).
    end.
  end.

  when "a" or when "ф" then do:
    v-nom = "". 
    message " Введите текущий счет " update v-nom.

    find last pkanketa where pkanketa.credtype = s-credtype and pkanketa.aaa = v-nom
         no-lock no-error.
    if avail pkanketa then do:
      create t-rnn.
      assign t-rnn.rnn = pkanketa.rnn
             t-rnn.bank = pkanketa.bank
             t-rnn.name = caps(pkanketa.name)
             t-rnn.cif = pkanketa.cif
             t-rnn.lon = pkanketa.lon.
      t-rnn.sort = name2sort(t-rnn.name).
    end.
  end.

  when "c" or when "с" then do:
    v-nom = "". 
    message " Введите код клиента " update v-nom.

    find last pkanketa where pkanketa.credtype = s-credtype and pkanketa.cif = v-nom
           no-lock no-error.
    if avail pkanketa then do:
      create t-rnn.
      assign t-rnn.rnn = pkanketa.rnn
             t-rnn.bank = pkanketa.bank
             t-rnn.name = caps(pkanketa.name)
             t-rnn.cif = pkanketa.cif
             t-rnn.lon = pkanketa.lon.
      t-rnn.sort = name2sort(t-rnn.name).
    end.
  end.
end case.


find first t-rnn no-error.
if not avail t-rnn then do:
  message skip " Совпадение не найдено !" skip(1) view-as alert-box button ok title "".
  return.
end.

{itemlist.i 
       &file = "t-rnn"
       &frame = "row 6 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " t-rnn.rnn format 'x(12)' label 'РНН'
                    t-rnn.name format 'x(40)' label 'ФИО'
                    t-rnn.bank format 'x(5)' label 'БАНК'
                    t-rnn.cif format 'x(6)' label 'КОД КЛ'
                    t-rnn.lon format 'x(9)' label 'ССУДСЧЕТ'
                   " 
       &chkey = "rnn"
       &chtype = "string"
       &index  = "main" 
}


