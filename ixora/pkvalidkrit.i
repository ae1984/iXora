/* pkvalidkrit.i
 * MODULE
        ПотребКредит
 * DESCRIPTION
        Библиотека функций проверки вводимых данных при вводе анкеты
 * RUN

 * CALLER
        pknew0.p
 * SCRIPT

 * INHERIT

 * MENU
        4.x.1
 * AUTHOR
        27.01.2003 nadejda
 * CHANGES
        16.07.2003 nadejda - добавлена проверка формата целого и вещественного числа на отсутствие недопустимых символов
        14.11.2003 nadejda - добавлен пробел в список допустимых символов в ФИО
        26.04.2006 u00121  - добавил last для find pkkrit
        25/10/2006 madiyar - подправил проверку справочника
        20/10/2008 madiyar - добавил казахские символы в разрешенные
        30/12/2009 galina - перекодировка
                            добавила проверку ИИН
        31/12/2009 galina - перекомпиляция
        03/01/2010 madiyar - исходник криво добавился в библиотеку, добавляем заново
*/

{chk12_innbin.i}

function valid-krit returns logical
      (p-kritcod as char, p-value as char, p-credtype as char, output p-msg as char).

  def var v-res as char no-undo.
  def var l as logical no-undo.
  def var v-vspr as char no-undo.
  def var i-credtype as integer no-undo.
  i-credtype = integer(s-credtype).

  l = true.

  /* пока позволяем пустые значения */
  if p-value = "" then
    return l.

  find last pkkrit where pkkrit.kritcod = p-kritcod no-lock no-error.

  if num-entries(pkkrit.kritspr) = 1 then v-vspr = pkkrit.kritspr.
  else do:
    if num-entries(pkkrit.kritspr) >= i-credtype then v-vspr = entry(i-credtype,pkkrit.kritspr).
    else v-vspr = ''.
  end.

  if v-vspr = "" then do:
  /* если не подвешен справочник */
    if pkkrit.procval = "" then
      /* нет процедуры проверки */
      l = true.
    else do:
      /* если есть процедура проверки - ее и запустим */
      run value (pkkrit.procval) (p-kritcod, p-value, output p-msg).
      l = (return-value = "0").
    end.
  end.
  else do:
    /* если подвешен справочник - проверка на наличие в списке значений */
    run valid-book (v-vspr, p-value, output l).
    /* message "1...." l view-as alert-box info. */
    if not l then
      p-msg = " Значение " + p-value + " не найдено в справочнике " + p-kritcod + " !".
  end.

  return l.
end.


/* ============================================ */
/*                 ОБЩИЕ ПРОВЕРКИ               */

/* проверка справочника */
procedure valid-book.
  def input parameter p-book as char.
  def input parameter p-val as char.
  def output parameter p-logi as logical.

  p-logi = yes.

  if can-find (first bookcod where bookcod.bookcod = p-book no-lock) then
    p-logi = can-find (bookcod where bookcod.bookcod = p-book and bookcod.code = p-val no-lock).
  else do:
    if can-find (first codfr where codfr.codfr = p-book no-lock) then
      p-logi = can-find (codfr where codfr.codfr = p-book and codfr.code = p-val no-lock).
  end.

end procedure.

/* общая проверка на соответствие введенных данных типу критерия */
procedure val-krtype.
  def input parameter p-krcod as char.
  def input parameter p-val as char.
  def output parameter p-mess as char.

  def var v-dt as date.
  def var v-i as integer.
  def var v-r as decimal.
  def var v-l as logical.
  def var v-logs as char init "yes,y,no,n,true,t,false,f,да,д,нет,н,0,1".

  p-mess = "".

  find last pkkrit where pkkrit.kritcod = p-krcod no-lock no-error.

  case pkkrit.krittype:
    when "d" then do: /* дата */
      v-dt = date(p-val) no-error.
      if v-dt = ? then p-mess = " Введенное значение не является датой !".
      else do:
        v-i = integer(p-val) no-error.
        if error-status:error then do:
          v-i = r-index(p-val, ".").
          if v-i = 0 then do:
            v-i = r-index(p-val, "/").
            if v-i = 0 then v-i = r-index(p-val, "-").
          end.
          if v-i = 0 then p-mess = " Неверный формат даты!".
          else do:
            if length(substr(p-val, v-i + 1)) < 4 then p-mess = " Введите 4 цифры года!".
          end.
        end.
        else do:
          if length(p-val) < 8 then p-mess = " Введите 4 цифры года!".
        end.
      end.
    end.
    when "i" then do: /* целое */
      v-i = r-index(p-val, ",") + r-index(p-val, ".") + r-index(p-val, " ").
      if v-i > 0 then
        p-mess = " Введены недопустимые в целом числе символы !".
      else do:
        v-i = integer(p-val) no-error.
        if error-status:error then
          p-mess = " Введенное значение не является целым числом !".
      end.
    end.
    when "r" then do: /* вещественное */
      v-i = r-index(p-val, ",") + r-index(p-val, " ").
      if v-i > 0 then
        p-mess = " Введены недопустимые символы ! Дробная часть отделяется точкой.".
      else do:
        v-r = decimal(p-val) no-error.
        if error-status:error then
          p-mess = " Введенное значение не является вещественным числом !".
      end.
    end.
    when "l" then do: /* логическое */
      if lookup(p-val, v-logs) = 0 then
        p-mess = " Введенное значение не может быть распознано как логическое !".
    end.
  end case.

  if p-mess = "" then return "0".
                 else return "1".
end.

/* общая проверка на наличие ТОЛЬКО цифр (для телефонов) */
procedure val-digit.
  def input parameter p-krcod as char.
  def input parameter p-val as char.
  def output parameter p-mess as char.

  def var i as integer.
  def var l as logical.
  def var v-digit as char init "0123456789".

  l = false.
  do i = 1 to length(p-val):
    if index(v-digit, substr(p-val, i, 1)) = 0 then do:
      l = true.
      leave.
    end.
  end.

  if l then do:
    p-mess = " Введены нецифровые символы !".
    return "1".
  end.

  return "0".
end.

/* общая проверка на наличие ТОЛЬКО алфавитных символов (для фамилий и имен) */
procedure val-nodigt.
  def input parameter p-krcod as char.
  def input parameter p-val as char.
  def output parameter p-mess as char.

  def var i as integer.
  def var l as logical.
  def var v-liter as char init "ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕіЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ-Ј????????' ".

  p-val = caps(p-val).

  l = false.
  do i = 1 to length(p-val):
    if index(v-liter, substr(p-val, i, 1)) = 0 then do:
      message "NO" view-as alert-box error.
      l = true.
      leave.
    end.
  end.

  if l then do:
    p-mess = " Введены недопустимые символы !".
    return "1".
  end.

  return "0".
end.

/* ============================================ */




/* ============================================ */
/*       ПРОВЕРКИ ОТДЕЛЬНЫХ КРИТЕРИЕВ           */


/* проверка РНН по алгоритму */
procedure val-rnn.
  def input parameter p-krcod as char.
  def input parameter p-val as char.
  def output parameter p-mess as char.
  def var l as logical.
  def var v-len as integer init 12.

  p-mess = "".

  if p-val = "" then do:
    p-mess = " Введите РНН !".
    return "1".
  end.

  find sysc where sysc.sysc = "rnnlen" no-lock no-error.
  if avail sysc then v-len = sysc.inval.

  if length(p-val) <> v-len then do:
    p-mess = " РНН должен иметь длину " + string(v-len) + " символов !".
    return "1".
  end.

  run val-digit (p-krcod, p-val, output p-mess).
  if return-value <> "0" then
    return "1".

  run rnnchk( p-val, output l).
  if l then do:
    p-mess = " Неверный контрольный ключ РНН !".
    return "1".
  end.

  return "0".
end procedure.

/* проверка ИИН по алгоритму */
procedure val-iin.
  def input parameter p-krcod as char.
  def input parameter p-val as char.
  def output parameter p-mess as char.
  def var l as logical.
  def var v-len as integer init 12.

  p-mess = "".

  if p-val = "" then do:
    p-mess = " Введите ИИН !".
    return "1".
  end.


  if length(p-val) <> v-len then do:
    p-mess = " ИИН должен иметь длину " + string(v-len) + " символов !".
    return "1".
  end.

  run val-digit (p-krcod, p-val, output p-mess).
  if return-value <> "0" then
    return "1".

  if not chk12_innbin(p-val)then do:
    p-mess = " Неверный контрольный ключ ИИН !".
    return "1".
  end.

  return "0".
end procedure.

/* простейшие проверки е-mail */
procedure val-email.
  def input parameter p-krcod as char.
  def input parameter p-val as char.
  def output parameter p-mess as char.

  def var i as integer.
  def var l as logical.
  def var v-err as char init ",~!#$%^&*()=+\/?|<>:;`'""".

  p-mess = "".

  if p-val = "" then do:
    p-mess = " Введите e-mail !".
    return "1".
  end.


  /* проверки :
     - отсутствие запрещенных символов ,~!#$%^&*()=+\/?|<>:;`'"
     - наличие собачки
     - собачка не первый символ
     - после собачки есть точка, и точка идет по крайней мере через один символ после собачки
     - нет повторений собачки
     - нет двух точек подряд
     - после последней точки есть по крайней мере 2 символа
  */

  /* отсутствие запрещенных символов */
  l = false.
  do i = 1 to length(p-val):
    if index(v-err, substr(p-val, i, 1)) > 0 then do:
      l = true.
      leave.
    end.
  end.
  if l then do:
    p-mess = " Введены запрещенные символы !".
    return "1".
  end.


  i = index(p-val, "@").
  if (i < 2)                                                     /* наличие собачки и собачка не первый символ */
     or (index(substr(p-val, i + 1), "@") > 0)                   /* нет повторений собачки */
     or (index(substr(p-val, i + 1), ".") < 2)                   /* после собачки есть точка, и точка идет по крайней мере через один символ после собачки */
     or (length(entry(num-entries(p-val, "."), p-val, ".")) < 2) /* после последней точки есть по крайней мере 2 символа */
     or (index(p-val, "..") > 0)                                 /* нет двух точек подряд */
     then do:
    p-mess = " Введенное значение не соответствует формату e-mail адреса !".
    return "1".
  end.

  return "0".
end.

/* первичная проверка СИК */
procedure val-sik.
  def input parameter p-krcod as char.
  def input parameter p-val as char.
  def output parameter p-mess as char.

  def var v-len as integer init 16.
  def var v-symbol as char init "0123456789ABCDEFGHJKMNPRSTUVWXYZ".
  def var l as logical.
  def var i as integer.

  p-mess = "".

  if p-val = "" then do:
    p-mess = " Введите СИК !".
    return "1".
  end.

  /* проверки :
     - длина 16 символов
     - все буквы прописные
     - отсутствие запрещенных символов I, L, O, Q
  */

  find sysc where sysc.sysc = "siklen" no-lock no-error.
  if avail sysc then v-len = sysc.inval.

  if length(p-val) <> v-len then do:
    p-mess = " СИК должен иметь длину " + string(v-len) + " символов !".
    return "1".
  end.

  if caps(p-val) <> p-val then do:
    p-mess = " СИК может содержать только цифры и прописные буквы !".
    return "1".
  end.

  l = false.
  do i = 1 to length(p-val):
    if index(v-symbol, substr(p-val, i, 1)) = 0 then do:
      l = true.
      leave.
    end.
  end.
  if l then do:
    p-mess = " Введены недопустимые символы !".
    return "1".
  end.


  return "0".
end.

/* проверка кода валюты */
procedure val-crc.
  def input parameter p-krcod as char.
  def input parameter p-val as char.
  def output parameter p-mess as char.

  p-mess = "".

  if p-val = "" then do:
    p-mess = " Введите код валюты !".
    return "1".
  end.

  find crc where crc.code = p-val no-lock no-error.
  if not avail crc then do:
    p-mess = " Введен недопустимый код валюты !".
    return "1".
  end.


  return "0".
end.

/* проверка на наличие алфавитных символов для фамилий и имен, казахские буквы принимаются ЦИФРАМИ
   БУКВА          КОД АКИ      ЦИФРА
   А казахское    187            1
   I              211            2
   Н с хвостиком  209            3
   Г с чертой     184            4
   У мягкое       190            5
   У твердое      188            6
   К с хвостиком  214            7
   О с чертой     199            8
   Х казахское    182            9

*/

procedure val-fiokaz.
  def input parameter p-krcod as char.
  def input parameter p-val as char.
  def output parameter p-mess as char.

  def var i as integer.
  def var l as logical.
  def var v-liter as char init "ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯІЅЄЇЎЌҐЋ-'".

  p-val = caps(trim(p-val)).
  l = false.
  do i = 1 to length(p-val):
    if index(v-liter, substr(p-val, i, 1)) = 0 then do:
      l = true.
      leave.
    end.
  end.

  if l then do:
    p-mess = " Введены недопустимые символы !".
    return "1".
  end.

  return "0".
end.

